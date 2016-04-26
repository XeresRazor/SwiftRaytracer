//
//  Ray.swift
//  Raytracer
//
//  Created by David Green on 4/6/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import simd

public struct Ray {
	private(set) public var origin: double4
	private(set) public var direction: double4
	private(set) public var time: Double
	
	public init(origin o: double4, direction d: double4, time t: Double = 0.0) {
		origin = o
		direction = d
		time = t
	}
	
	public func pointAtDistance(t: Double) -> double4 {
		return origin + t * direction
	}
}
