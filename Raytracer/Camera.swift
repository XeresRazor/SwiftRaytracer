//
//  Camera.swift
//  Raytracer
//
//  Created by David Green on 4/14/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import simd

public struct Camera {
	private var origin: double3
	private var lowerLeftCorner: double3
	private var horizontal: double3
	private var vertical: double3
	public var aperture: Double = 0.0
	
	public init(width: Double, height: Double) {
		lowerLeftCorner = double3(-(width / 2.0), -(height / 2.0), -1.0)
		horizontal = double3(width, 0.0, 0.0)
		vertical = double3(0.0, height, 0.0)
		origin = double3(0.0, 0.0, 0.0)
	}
	
	public func getRay(u: Double, _ v: Double) -> Ray {
		let jitterX = (drand48() - 0.5) * aperture
		let jitterY = (drand48() - 0.5) * aperture
		return Ray(origin: double3(origin.x + jitterX, origin.y + jitterY, origin.z), direction: lowerLeftCorner + u * horizontal + v * vertical - origin)
	}
	
}
