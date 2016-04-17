//
//  Utility.swift
//  Raytracer
//
//  Created by David Green on 4/14/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation
import simd

public func randomInUnitSphere() -> float3 {
	var p: float3
	repeat {
		p = 2.0 * float3(Float(drand48()), Float(drand48()), Float(drand48())) - float3(1.0, 1.0, 1.0)
	} while length_squared(p) >= 1.0
	
	return p
}

public func schlick(cosine: Float, refractionIndex: Float) -> Float {
	var r0 = (1 - refractionIndex) / (1 + refractionIndex)
	r0 = r0 * r0
	return r0 + (1 - r0) * pow((1 - cosine), 5)
}

public func surroundingBox(box0: AABB, box1: AABB) -> AABB {
	let small = min(box0.minimum, box1.minimum)
	let big = max(box0.maximum, box1.maximum)
	return AABB(min: small, max: big)
}
