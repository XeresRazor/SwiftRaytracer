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

let width = 640
let height = 360
let samples = 64

let maxDepth = 50
let coverage = 1.0
let viewportWidth = 4.0
let viewportHeight = viewportWidth * (Double(height) / Double(width))
srand48(0)

func colorForSkyDirection(direction: double3) -> double3 {
	let unitDirection = normalize(direction)
	let t = 0.5 * (unitDirection.y + 1.0)
	let white = double3(1.0, 1.0, 1.0)
	let blue = double3(0.5, 0.7, 1.0)
	return mix(white, blue, t: t)
}

func color(r: Ray, world: Traceable, depth: Int) -> double3 {
	if let rec = world.trace(r, minimumT: 0.001, maximumT: 50000.0) {
		let scatter = rec.material?.scatter(r, rec: rec)
		if depth < maxDepth && scatter != nil  {
			return scatter!.attenuation * color(scatter!.scattered, world: world, depth: depth + 1)
		} else {
			return double3(0.0, 0.0, 0.0)
		}
	} else {
		return colorForSkyDirection(r.direction)
	}
}

let t0 = CFAbsoluteTimeGetCurrent()


let image = RGBA8Image(width: width, height: height)
let lowerLeftCorner = double3(-(viewportWidth / 2.0), -(viewportHeight / 2.0), -1.0)
let horizontal = double3(viewportWidth, 0.0, 0.0)
let vertical = double3(0.0, viewportHeight, 0.0)
let origin = double3(0.0, 0.0, 0.0)

let sphere1 = Sphere(center: double3(0.0, 0.0, -1.0), radius: 0.5, material: LambertianMaterial(albedo: double3(0.8, 0.3, 0.3)))
let sphere2 = Sphere(center: double3(0.0, -100.5, -1.0), radius: 100.0, material: LambertianMaterial(albedo: double3(0.8, 0.8, 0.0)))
let sphere3 = Sphere(center: double3(1.0, 0.0, -1.0), radius: 0.5, material: MetalMaterial(albedo: double3(0.8, 0.6, 0.2)))
let sphere4 = Sphere(center: double3(-1.0, 0.0, -1.0), radius: 0.5, material: MetalMaterial(albedo: double3(0.8, 0.8, 0.8)))
let world = TraceableCollection(list: [sphere1, sphere2, sphere3, sphere4])
var cam = Camera(width: viewportWidth, height: viewportHeight)
cam.aperture = 0.0

let t1 = CFAbsoluteTimeGetCurrent()

print("Beginning render")
var pixels = 0
var pixelCount = width * height
var lastTime = t1
for y in 0 ..< height {
	for x in 0 ..< width {
		var col = double3(0.0, 0.0, 0.0)
		for s in 0 ..< samples {
			let u = (Double(x) + ((drand48() - 0.5) * coverage)) / Double(width)
			let v = (Double(y) + ((drand48() - 0.5) * coverage)) / Double(height)
			let r = cam.getRay(u, v)
			
			let p = r.pointAtDistance(2.0)
			col += color(r, world: world, depth: 0)
		}
		col.x = sqrt(col.x / Double(samples))
		col.y = sqrt(col.y / Double(samples))
		col.z = sqrt(col.z / Double(samples))
		
		let pixel = RGBA8Pixel(UInt8(255.0 * col.x), UInt8(255.0 * col.y), UInt8(255.0 * col.z))
		image[x,height - y - 1] = pixel // Our image is rendered bottom to top, but image files expect top to bottom
		
		pixels += 1
	}
	
	let time = CFAbsoluteTimeGetCurrent()
	if time - lastTime > 1.0 {
		lastTime = time
		print("Rendering \((Float(pixels)/Float(pixelCount)) * 100.0)% complete")
	}
}
let t2 = CFAbsoluteTimeGetCurrent()

image.writeTo("image.png", format: .png)

let t3 = CFAbsoluteTimeGetCurrent()

print("Time to initialize: \(t1 - t0).\nTime to render: \(t2 - t1).\nTime to save: \(t3 - t2).\nTotal time: \(t3 - t0)")