//
//  AABB.swift
//  Raytracer
//
//  Created by David Green on 4/16/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import simd


public class AABB {
	private(set) public var minimum: float3
	private(set) public var maximum: float3
	
	public init(min n: float3, max x: float3) {
		minimum = n
		maximum = x
	}
	
	public func hit(ray r: Ray, var tMin: Float, var tMax: Float) -> Bool {
		for a in 0 ..< 3 {
			let invD = 1.0 / r.direction[a]
			var t0 = (minimum[a] - r.origin[a]) * invD
			var t1 = (maximum[a] - r.origin[a]) * invD
			
			if invD < 0.0 {
				swap(&t0, &t1)
			}
			tMin = t0 > tMin ? t0 : tMin
			tMax = t1 < tMax ? t1 : tMax
			
			if tMax <= tMin {
				return false
			}
		}
		
		return true
	}
}
