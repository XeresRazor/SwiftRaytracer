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

// Render configuration
let width = 640
let height = 360
let samples = 128

let renderConfig = RenderConfig(width: width, height: height, samples: samples)

// CAmera configuration
let up = float3(0,1,0)

let lookfrom = float3(13,2,3)
let lookAt = float3(0,0,0)
let fov: Float = 20.0

//let lookfrom = float3(40,5,40)
//let lookAt = float3(0,0,0)
//let fov: Float = 60.0

let aperture: Float = 0.1
let focusDistance = Float(10.0) //length(lookfrom - lookAt)
let aspect = Float(width) / Float(height)

var cam = Camera(lookFrom: lookfrom, lookAt: lookAt, up: up, verticalFOV: fov, aspect: aspect, aperture: aperture, focusDistance: focusDistance, time0: 0.0, time1: 1.0)

// Scene creation
//let world = fractalScene()
let world = randomScene()


let t1 = CFAbsoluteTimeGetCurrent()

print("Beginning render")


let image = Raytrace(world, camera: cam, config: renderConfig) { image in
	image.writeTo("previewImage.png", format: .png)
}

image.writeTo("image.png", format: .png)

let t2 = CFAbsoluteTimeGetCurrent()

print("Time to initialize: \(t1 - t0).\nTime to render: \(t2 - t1).\nTotal time: \(t2 - t0)")

