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
let coverage: Float = 0.5


public struct RenderConfig {
	public var width: Int
	public var height: Int
	public var samples: Int
}

private func colorForSkyDirection(direction: float3) -> float3 {
	let unitDirection = normalize(direction)
	let t = 0.5 * (unitDirection.y + 1.0)
	let white = float3(1.0, 1.0, 1.0)
	let blue = float3(0.5, 0.7, 1.0)
	return mix(white, blue, t: t)
}

private func color(r: Ray, world: Traceable, depth: Int) -> float3 {
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

public typealias PreviewCallback = (RGBA8Image) -> Void

private func ImageFromPixels(pixels: [float3], samples: Int, width: Int, height: Int) -> RGBA8Image {
	let image = RGBA8Image(width: width, height: height)
	
	for y in 0 ..< height {
		for x in 0 ..< width {
			// Convert from accumulator to pixels
			var col = pixels[x + y * width]
			col.x = sqrt(col.x / Float(samples + 1))
			col.y = sqrt(col.y / Float(samples + 1))
			col.z = sqrt(col.z / Float(samples + 1))
			
			let pixel = RGBA8Pixel(UInt8(255.0 * col.x), UInt8(255.0 * col.y), UInt8(255.0 * col.z))
			image[x,height - y - 1] = pixel // Our image is rendered bottom to top, but image files expect top to bottom
		}
	}
	
	return image
}

public func Raytrace(scene: Traceable, camera: Camera, config: RenderConfig, previewCallback: PreviewCallback? = nil) -> RGBA8Image {
	let pixelCount = config.width * config.height
	var pixels = [float3](count: pixelCount, repeatedValue: float3(0.0, 0.0, 0.0))
	
	var lastCallbackTime = CFAbsoluteTimeGetCurrent()
	
	for s in 0 ..< config.samples {
		let time = CFAbsoluteTimeGetCurrent()
		let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
		dispatch_apply(config.height, queue) { y in
			for x in 0 ..< config.width {
				let u = (Float(x) + ((Float(drand48()) - 0.5) * coverage)) / Float(width)
				let v = (Float(y) + ((Float(drand48()) - 0.5) * coverage)) / Float(height)
				let r = camera.getRay(u, v)
				
				let col = color(r, world: scene, depth: 0)
				pixels[x + y * width] += col
			}
		}
		
		let endTime = CFAbsoluteTimeGetCurrent()
		
		if endTime - lastCallbackTime > 1.0 {
			lastCallbackTime = endTime
			if let callback = previewCallback  {
				callback(ImageFromPixels(pixels, samples: s, width: config.width, height: config.height))
			}
		}
		
		print("Rendered sample \(s + 1) of \(samples) in \(endTime - time) seconds.")
	}
	
	return ImageFromPixels(pixels, samples: config.samples, width: config.width, height: config.height)
}
