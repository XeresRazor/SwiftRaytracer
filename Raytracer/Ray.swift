//
//  Ray.swift
//  Raytracer
//
//  Created by David Green on 4/6/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import simd

public struct Ray {
	private(set) public var origin: double3
	private(set) public var direction: double3
	private(set) public var time: Double
	
	public init(origin o: double3, direction d: double3, time t: Double = 0.0) {
		origin = o
		direction = d
		time = t
	}
	
	public func pointAtDistance(t: Double) -> double3 {
		return origin + t * direction
	}
}
