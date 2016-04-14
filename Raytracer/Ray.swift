//
//  Ray.swift
//  Raytracer
//
//  Created by David Green on 4/6/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import simd

public struct Ray {
	public var origin: double3
	public var direction: double3
	
	public init(origin o: double3, direction d: double3) {
		origin = o
		direction = d
	}
	
	public func pointAtDistance(t: Double) -> double3 {
		return origin + t * direction
	}
}
