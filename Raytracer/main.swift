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

// Scene creation
//let world = fractalScene()
let scene = randomScene()

let t1 = CFAbsoluteTimeGetCurrent()

print("Beginning render")

let image = Raytrace(scene) { image in
	image.writeTo("previewImage.png", format: .png)
}

image.writeTo("image.png", format: .png)

let t2 = CFAbsoluteTimeGetCurrent()

print("Time to initialize: \(t1 - t0).\nTime to render: \(t2 - t1).\nTotal time: \(t2 - t0)")

