//
//  Traceable.swift
//  Raytracer
//
//  Created by David Green on 4/6/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import simd

public struct HitRecord {
	var time: Double
	var point: double3
	var normal: double3
	init() {
		time = 0
		point = double3()
		normal = double3()
	}
	
	init(_ t: Double, _ p: double3, _ n: double3) {
		time = t
		point = p
		normal = n
	}
}

public protocol Traceable {
	func trace(r: Ray, minimumT tMin: Double, maximumT tMax: Double) -> HitRecord?
}