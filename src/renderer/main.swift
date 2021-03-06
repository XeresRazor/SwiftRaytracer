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
import pathtracer

srand48(Int(arc4random()))
print("Initializing Renderer.")
let t0 = CFAbsoluteTimeGetCurrent()

// Scene creation
//let scene = fractalScene()
let scene = randomScene()
//let scene = twoPerlinSpheres()
//let scene = randomEmissiveScene()


let t1 = CFAbsoluteTimeGetCurrent()

print("Beginning render")



let image = Raytrace(scene: scene, previewFrequency: 5.0) { (image) in
	image.writeTo(file: "previewImage.png", format: .png)
}

image.writeTo(file: "image.png", format: .png)

let t2 = CFAbsoluteTimeGetCurrent()

print("Time to initialize: \(t1 - t0).\nTime to render: \(t2 - t1).\nTotal time: \(t2 - t0)")

