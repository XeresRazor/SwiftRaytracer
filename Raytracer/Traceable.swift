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
	var point: double4
	var normal: double4
	var material: Material?
	init() {
		time = 0
		point = double4()
		normal = double4()
	}
	
	init(_ t: Double, _ p: double4, _ n: double4) {
		time = t
		point = p
		normal = n
	}
}

public class Traceable {
	public func trace(r: Ray, minimumT tMin: Double, maximumT tMax: Double) -> HitRecord? {
		fatalError("trace() must be overridden")
	}
	
	public func boundingBox(t0: Double, t1: Double) -> AABB? {
		fatalError("boundingBox() must be overridden")
	}
}
