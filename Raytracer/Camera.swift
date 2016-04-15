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
		
	public init(lookFrom: double3, lookAt: double3, up: double3, verticalFOV: Double, aspect: Double) {
		let theta = verticalFOV * M_PI/180
		let halfHeight = tan(theta / 2)
		let halfWidth = aspect * halfHeight
		
		origin = lookFrom
		let w = normalize(lookFrom - lookAt)
		let u = normalize(cross(up, w))
		let v = cross(w, u)
		
		lowerLeftCorner = origin - halfWidth * u - halfHeight * v - w
		horizontal = 2 * halfWidth * u
		vertical = 2 * halfHeight * v
	}
	
	public func getRay(u: Double, _ v: Double) -> Ray {
		let jitterX = (drand48() - 0.5) * aperture
		let jitterY = (drand48() - 0.5) * aperture
		return Ray(origin: double3(origin.x + jitterX, origin.y + jitterY, origin.z), direction: lowerLeftCorner + u * horizontal + v * vertical - origin)
	}
	
}
