//
//  Raytracer.swift
//  Raytracer
//
//  Created by David Green on 4/19/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation
import simd

let maxDepth = 50

private func colorForSkyDirection(direction: double3) -> double3 {
	let unitDirection = normalize(direction)
	let t = 0.5 * (unitDirection.y + 1.0)
	let white = double3(1.0, 1.0, 1.0)
	let blue = double3(0.5, 0.7, 1.0)
	return mix(white, blue, t: t)
}

private func color(r: Ray, world: Traceable, depth: Int) -> double3 {
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

public typealias PreviewCallback = (RGBA8Image) -> Void

private func ImageFromPixels(pixels: [double3], samples: Int, width: Int, height: Int) -> RGBA8Image {
	let image = RGBA8Image(width: width, height: height)
	
	for y in 0 ..< height {
		for x in 0 ..< width {
			// Convert from accumulator to pixels
			var col = pixels[x + y * width]
			col.x = sqrt(col.x / Double(samples + 1))
			col.y = sqrt(col.y / Double(samples + 1))
			col.z = sqrt(col.z / Double(samples + 1))
			
			let pixel = RGBA8Pixel(UInt8(255.0 * col.x), UInt8(255.0 * col.y), UInt8(255.0 * col.z))
			image[x,height - y - 1] = pixel // Our image is rendered bottom to top, but image files expect top to bottom
		}
	}
	
	return image
}

public func Raytrace(scene: Scene, previewFrequency: Double = 1.0, previewCallback: PreviewCallback? = nil) -> RGBA8Image {
	let width = scene.config.width
	let height = scene.config.height
	
	let pixelCount = width * height
	var pixels = [double3](count: pixelCount, repeatedValue: double3(0.0, 0.0, 0.0))
	
	var lastCallbackTime = CFAbsoluteTimeGetCurrent()
	
	for s in 0 ..< scene.config.samples {
		let time = CFAbsoluteTimeGetCurrent()
		let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
		dispatch_apply(height, queue) { y in
			for x in 0 ..< width {
				let u = (Double(x) + (drand48() - 0.5)) / Double(width)
				let v = (Double(y) + (drand48() - 0.5)) / Double(height)
				let r = scene.camera.getRay(u, v)
				
				let col = color(r, world: scene.world, depth: 0)
				pixels[x + y * width] += col
			}
		}
		
		let endTime = CFAbsoluteTimeGetCurrent()
		
		if endTime - lastCallbackTime > previewFrequency {
			lastCallbackTime = endTime
			if let callback = previewCallback  {
				callback(ImageFromPixels(pixels, samples: s, width: width, height: height))
			}
		}
		
		print("Rendered sample \(s + 1) of \(scene.config.samples) in \(endTime - time) seconds.")
	}
	
	return ImageFromPixels(pixels, samples: scene.config.samples, width: width, height: height)
}
