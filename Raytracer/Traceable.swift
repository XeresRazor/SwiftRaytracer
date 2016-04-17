//
//  Traceable.swift
//  Raytracer
//
//  Created by David Green on 4/6/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import simd

public struct HitRecord {
	var time: Float
	var point: float3
	var normal: float3
	var material: Material?
	init() {
		time = 0
		point = float3()
		normal = float3()
	}
	
	init(_ t: Float, _ p: float3, _ n: float3) {
		time = t
		point = p
		normal = n
	}
}

public class Traceable {
	public func trace(r: Ray, minimumT tMin: Float, maximumT tMax: Float) -> HitRecord? {
		fatalError("trace() must be overridden")
	}
	
	public func boundingBox(t0: Float, t1: Float) -> AABB? {
		fatalError("boundingBox() must be overridden")
	}
}
