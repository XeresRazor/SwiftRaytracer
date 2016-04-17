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

print("Initializing Renderer.")
let t0 = CFAbsoluteTimeGetCurrent()

// Constants
let width = 640
let height = 360
let samples = 128

let lookfrom = float3(13,2,3)
let lookAt = float3(0,0,0)
let up = float3(0,1,0)
let fov: Float = 20.0
let aperture: Float = 0.05
let focusDistance = Float(10.0) //length(lookfrom - lookAt)
let aspect = Float(width) / Float(height)


let maxDepth = 50
let coverage: Float = 0.5

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
	
	list.append(Sphere(center: float3(0, 1, 0), radius: 1.0, material: DielectricMaterial(refractionIndex: 1.5)))
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

srand48(0)



let image = RGBA8Image(width: width, height: height)
let world = randomScene()


var cam = Camera(lookFrom: lookfrom, lookAt: lookAt, up: up, verticalFOV: fov, aspect: aspect, aperture: aperture, focusDistance: focusDistance, time0: 0.0, time1: 1.0)

let t1 = CFAbsoluteTimeGetCurrent()

var rendered = 0
var pixelCount = width * height
var pixels = [float3](count: pixelCount, repeatedValue: float3(0.0, 0.0, 0.0))

var lastTime = t1
print("Beginning render")

for s in 0 ..< samples {
	let time = CFAbsoluteTimeGetCurrent()
	for y in 0 ..< height {
		for x in 0 ..< width {
			let u = (Float(x) + ((Float(drand48()) - 0.5) * coverage)) / Float(width)
			let v = (Float(y) + ((Float(drand48()) - 0.5) * coverage)) / Float(height)
			let r = cam.getRay(u, v)
			
			let p = r.pointAtDistance(2.0)
			let col = color(r, world: world, depth: 0)
			
			pixels[x + y * width] += col
			rendered += 1
		}
	}
	let endTime = CFAbsoluteTimeGetCurrent()
	
	print("Rendered sample \(s + 1) of \(samples) in \(endTime - time) seconds.")
	for y in 0 ..< height {
		for x in 0 ..< width {
			var col = pixels[x + y * width]
			col.x = sqrt(col.x / Float(s + 1))
			col.y = sqrt(col.y / Float(s + 1))
			col.z = sqrt(col.z / Float(s + 1))
			
			let pixel = RGBA8Pixel(UInt8(255.0 * col.x), UInt8(255.0 * col.y), UInt8(255.0 * col.z))
			image[x,height - y - 1] = pixel // Our image is rendered bottom to top, but image files expect top to bottom
			
		}
	}
	
	image.writeTo("image.png", format: .png)
}

let t2 = CFAbsoluteTimeGetCurrent()

print("Time to initialize: \(t1 - t0).\nTime to render: \(t2 - t1).\nTotal time: \(t2 - t0)")

