//
//  Ray.swift
//  Raytracer
//
//  Created by David Green on 4/6/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import simd

public struct Ray {
	private(set) public var origin: float3
	private(set) public var direction: float3
	private(set) public var time: Float
	
	public init(origin o: float3, direction d: float3, time t: Float = 0.0) {
		origin = o
		direction = d
		time = t
	}
	
	public func pointAtDistance(t: Float) -> float3 {
		return origin + t * direction
	}
}
