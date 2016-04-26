//
//  AABB.swift
//  Raytracer
//
//  Created by David Green on 4/16/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import simd


public class AABB {
	private(set) public var minimum: double4
	private(set) public var maximum: double4
	
	public init(min n: double4, max x: double4) {
		minimum = n
		maximum = x
	}
	
	public func hit(ray r: Ray, tMin min: Double, tMax max: Double) -> Bool {
		var tMin = min
		var tMax = max
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
