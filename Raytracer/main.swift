//
//  main.swift
//  Raytracer
//
//  Created by David Green on 4/6/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation
import simd
import Darwin

srand48(Int(arc4random()))
print("Initializing Renderer.")
let t0 = CFAbsoluteTimeGetCurrent()

// Constants
let width = 3840
let height = 2160
let samples = 2048

let lookfrom = float3(13,2,3)
let lookAt = float3(0,0,0)
let fov: Float = 20.0

//let lookfrom = float3(40,5,40)
//let lookAt = float3(0,0,0)
let up = float3(0,1,0)
//let fov: Float = 60.0
let aperture: Float = 0.1
let focusDistance = Float(10.0) //length(lookfrom - lookAt)
let aspect = Float(width) / Float(height)


let maxDepth = 50
let coverage: Float = 0.5

func generateFractalSpheresAroundSphere(parentSphere: Sphere, level: Int, maxLevel: Int, material0: Material, material1: Material, inout intoList: [Traceable]) {
	if level < maxLevel {
		let material = level % 2 == 0 ? material0 : material1
		for _ in 0 ..< level + 5 {
			let direction = normalize(randomInUnitSphere())
			let radius = parentSphere.radius * Float((drand48() / 5.0) + 0.4)
			let sphere = Sphere(center: parentSphere.center + (direction * (parentSphere.radius + radius)), radius: radius, material: material)
			intoList.append(sphere)
			generateFractalSpheresAroundSphere(sphere, level: level + 1, maxLevel: maxLevel, material0: material0, material1: material1, intoList: &intoList)
		}
	}
}

func fractalScene() -> Traceable {
	var list: [Traceable] = []
	let mirror = MetalMaterial(albedo: float3(1.0, 1.0, 1.0), fuzziness: 0.05)
	let diffuse = LambertianMaterial(albedo: float3(0.5, 0.5, 0.8))
	//list.append(Sphere(center: float3(0,-1016,0), radius: 1000, material: LambertianMaterial(albedo: float3(0.8, 0.8, 0.8))))
	let sphere = Sphere(center: float3(0,0,0), radius: 16.0, material: DielectricMaterial(refractionIndex: 1.5))
	list.append(sphere)
	list.append(Sphere(center: float3(0,0,0), radius: -15.0, material: DielectricMaterial(refractionIndex: 1.5, color: float3(1,1,1), fuzziness: 0.5)))
	generateFractalSpheresAroundSphere(sphere, level: 0, maxLevel: 5, material0: diffuse, material1: mirror, intoList: &list)
	print("Generated \(list.count) objects to render.")
	return BVHNode(list: list, time0: 0.0, time1: 1.0)
}

func randomScene() -> Traceable {
	var list: [Traceable] = []
	list.append(Sphere(center: float3(0, -1000, 0), radius: 1000, material: LambertianMaterial(albedo: float3(0.5, 0.5, 0.5))))
	
	for a in -11 ..< 11 {
		for b in -11 ..< 11 {
			let chooseMat = Float(drand48())
			let center = float3(Float(a) + 0.9 * Float(drand48()), 0.2, Float(b) + 0.9 * Float(drand48()))
			
			if length(center - float3(4, 0.2, 0)) > 0.9 {
				if chooseMat < 0.8 { // diffuse
					let rand2 = drand48() > 0.75
					if rand2 {
						list.append(Sphere(center: center, radius: 0.2, material: LambertianMaterial(albedo: float3(Float(drand48()) * Float(drand48()), Float(drand48()) * Float(drand48()), Float(drand48()) * Float(drand48())))))
					} else {
						list.append(
							MovingSphere(
								center0: center,
								center1: center + float3(0, Float(drand48()), 0.0),
								time0: 0.0,
								time1: 1.0,
								radius: 0.2,
								material: LambertianMaterial(
									albedo: float3(
										Float(drand48()) * Float(drand48()),
										Float(drand48()) * Float(drand48()),
										Float(drand48()) * Float(drand48())
									)
								)
							)
						)
					}
				} else if chooseMat < 0.95 { // metal
					list.append(Sphere(center: center, radius: 0.2, material: MetalMaterial(albedo: float3(0.5 * (1 + Float(drand48())), 0.5 * (1 + Float(drand48())), 0.5 * (1 + Float(drand48()))), fuzziness: 0.5 *  Float(drand48()))))
				} else { // glass
					list.append(Sphere(center: center, radius: 0.2, material: DielectricMaterial(refractionIndex: 1.5)))
				}
			}
		}
	}
	
	list.append(Sphere(center: float3(0, 1, 0), radius: 1.0, material: DielectricMaterial(refractionIndex: 1.5, color: float3(1,1,1), fuzziness: 1.0)))
	list.append(Sphere(center: float3(-4, 1, 0), radius: 1.0, material: LambertianMaterial(albedo: float3(0.4, 0.2, 0.1))))
	list.append(Sphere(center: float3(4, 1, 0), radius: 1.0, material: MetalMaterial(albedo: float3(0.7, 0.6, 0.5), fuzziness: 0.0)))
	let bvh = BVHNode(list: list, time0: 0.0, time1: 1.0)
	return bvh
	//    return TraceableCollection(list: list)
}

func colorForSkyDirection(direction: float3) -> float3 {
	let unitDirection = normalize(direction)
	let t = 0.5 * (unitDirection.y + 1.0)
	let white = float3(1.0, 1.0, 1.0)
	let blue = float3(0.5, 0.7, 1.0)
	return mix(white, blue, t: t)
}

func color(r: Ray, world: Traceable, depth: Int) -> float3 {
	if let rec = world.trace(r, minimumT: 0.001, maximumT: 50000.0) {
		let scatter = rec.material?.scatter(r, rec: rec)
		if depth < maxDepth && scatter != nil  {
			return scatter!.attenuation * color(scatter!.scattered, world: world, depth: depth + 1)
		} else {
			return float3(0.0, 0.0, 0.0)
		}
	} else {
		return colorForSkyDirection(r.direction)
	}
}


let image = RGBA8Image(width: width, height: height)
//let world = fractalScene()
let world = randomScene()


var cam = Camera(lookFrom: lookfrom, lookAt: lookAt, up: up, verticalFOV: fov, aspect: aspect, aperture: aperture, focusDistance: focusDistance, time0: 0.0, time1: 1.0)

let t1 = CFAbsoluteTimeGetCurrent()

var pixelCount = width * height
var pixels = [float3](count: pixelCount, repeatedValue: float3(0.0, 0.0, 0.0))

var lastTime = t1
print("Beginning render")

for s in 0 ..< samples {
	let time = CFAbsoluteTimeGetCurrent()
	let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
	dispatch_apply(height, queue) { y in
		//	for y in 0 ..< height {
		for x in 0 ..< width {
			let u = (Float(x) + ((Float(drand48()) - 0.5) * coverage)) / Float(width)
			let v = (Float(y) + ((Float(drand48()) - 0.5) * coverage)) / Float(height)
			let r = cam.getRay(u, v)
			
			let p = r.pointAtDistance(2.0)
			var col = color(r, world: world, depth: 0)
			
			pixels[x + y * width] += col
			
			// Convert from accumulator to pixels
			col = pixels[x + y * width]
			col.x = sqrt(col.x / Float(s + 1))
			col.y = sqrt(col.y / Float(s + 1))
			col.z = sqrt(col.z / Float(s + 1))
			
			let pixel = RGBA8Pixel(UInt8(255.0 * col.x), UInt8(255.0 * col.y), UInt8(255.0 * col.z))
			image[x,height - y - 1] = pixel // Our image is rendered bottom to top, but image files expect top to bottom
			
		}
	}
	let endTime = CFAbsoluteTimeGetCurrent()
	
	print("Rendered sample \(s + 1) of \(samples) in \(endTime - time) seconds.")
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
		image.writeTo("image.png", format: .png)
	}
}

let t2 = CFAbsoluteTimeGetCurrent()

print("Time to initialize: \(t1 - t0).\nTime to render: \(t2 - t1).\nTotal time: \(t2 - t0)")

