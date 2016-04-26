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



private func color(r: Ray, world: Traceable, depth: Int, skyShader: SkyShader) -> double4 {
	if let rec = world.trace(r: r, minimumT: 0.001, maximumT: 50000.0) {
		let emitted = rec.material?.emitted(u: rec.u, v: rec.v, point: rec.point)
		let scatter = rec.material?.scatter(rayIn: r, rec: rec)
		if depth < maxDepth && scatter != nil && emitted != nil  {
			return emitted! + scatter!.attenuation * color(r: scatter!.scattered, world: world, depth: depth + 1, skyShader: skyShader)
		} else {
			return emitted!
		}
	} else {
		return skyShader.colorForSkyDirection(direction: r.direction)
	}
}


private func ImageFromPixels(pixels: [double4], samples: Int, width: Int, height: Int) -> RGBA8Image {
	let image = RGBA8Image(width: width, height: height)
	
	for y in 0 ..< height {
		for x in 0 ..< width {
			// Convert from accumulator to pixels
			var col = pixels[x + y * width]
			col.x = col.x / Double(samples + 1)
			col.y = col.y / Double(samples + 1)
			col.z = col.z / Double(samples + 1)
			
			let pixel = RGBA8Pixel(toUInt8(col.x), toUInt8(col.y), toUInt8(col.z))
			image[x,height - y - 1] = pixel // Our image is rendered bottom to top, but image files expect top to bottom
		}
	}
	
	return image
}

func pixelAccumulation(accumulator: Int64, current: RGBA8Pixel) -> Int64 {
	return accumulator + Int64(current.r) + Int64(current.g) + Int64(current.b)
}

public typealias PreviewCallback = (RGBA8Image) -> Void

public func Raytrace(scene: Scene, previewFrequency: Double = 1.0, previewCallback: PreviewCallback) -> RGBA8Image {
	let width = scene.config.width
	let height = scene.config.height
	
	let pixelCount = width * height
	var pixels = [double4](repeating: double4(0.0, 0.0, 0.0, 0.0), count: pixelCount)
	
	var lastCallbackTime = CFAbsoluteTimeGetCurrent()
	
	var lastLuminance: Double = 0.0
	var targetLuminanceCount = 0
	
	var processedSamples = 0
	for s in 0 ..< scene.config.samples {
		processedSamples += 1
		let time = CFAbsoluteTimeGetCurrent()
		let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
		dispatch_apply(height, queue) { y in
			for x in 0 ..< width {
				let u = (Double(x) + (drand48() - 0.5)) / Double(width)
				let v = (Double(y) + (drand48() - 0.5)) / Double(height)
				let r = scene.camera.getRay(u, v)
				
				let col = color(r: r, world: scene.world, depth: 0, skyShader: scene.skyShader)
				
				pixels[x + y * width] += col
			}
		}
		
		let endTime = CFAbsoluteTimeGetCurrent()
		
		if endTime - lastCallbackTime > previewFrequency {
			lastCallbackTime = endTime
			previewCallback(ImageFromPixels(pixels: pixels, samples: s, width: width, height: height))
			
		}
		
		let totalLuminance = Double(ImageFromPixels(pixels: pixels, samples: scene.config.samples, width: width, height: height).pixels.reduce(0, combine: pixelAccumulation)) / Double(width * height)
		print(String(format: "Rendered sample \(s + 1) of \(scene.config.samples) in %0.4f seconds.\tChange in luminance: %0.5f", endTime - time, totalLuminance - lastLuminance))

		if totalLuminance - lastLuminance <= scene.config.targetQuality {
			targetLuminanceCount += 1
			if targetLuminanceCount > 5 {
				print("Target quality reached.")
				break
			}
		} else {
			targetLuminanceCount = 0
		}
		
		lastLuminance = totalLuminance
		
		
	}
	
	
	
	return ImageFromPixels(pixels: pixels, samples: processedSamples, width: width, height: height)
}
