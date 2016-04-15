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


func color(r: Ray, world: Traceable) -> double3 {
	if let rec = world.trace(r, minimumT: 0.0, maximumT: 500.0) {
		return 0.5 * double3(rec.normal.x + 1, rec.normal.y + 1, rec.normal.z + 1)
	} else {
		let unitDirection = normalize(r.direction)
		let t = 0.5 * (unitDirection.y + 1.0)
		let white = double3(1.0, 1.0, 1.0)
		let blue = double3(0.5, 0.7, 1.0)
		return mix(white, blue, t: t)
	}
}
let t0 = CFAbsoluteTimeGetCurrent()
let width = 512
let height = 384
let samples = 64
let coverage = 0.5
let viewportWidth = 4.0
let viewportHeight = viewportWidth * (Double(height) / Double(width))

let image = RGBA8Image(width: width, height: height)
let lowerLeftCorner = double3(-(viewportWidth / 2.0), -(viewportHeight / 2.0), -1.0)
let horizontal = double3(viewportWidth, 0.0, 0.0)
let vertical = double3(0.0, viewportHeight, 0.0)
let origin = double3(0.0, 0.0, 0.0)

let sphere1 = Sphere(center: double3(0.0, 0.0, -1.0), radius: 0.5)
let sphere2 = Sphere(center: double3(0.0, -100.5, -1.0), radius: 100.0)
let world = TraceableCollection(list: [sphere1, sphere2])
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
			let u = (Double(x) + ((randomDouble() - 0.5) * coverage)) / Double(width)
			let v = (Double(y) + ((randomDouble() - 0.5) * coverage)) / Double(height)
			let r = cam.getRay(u, v)
			
			let p = r.pointAtDistance(2.0)
			col += color(r, world: world)
		}
		col.x = col.x / Double(samples)
		col.y = col.y / Double(samples)
		col.z = col.z / Double(samples)
		
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