//
//  Camera.swift
//  Raytracer
//
//  Created by David Green on 4/14/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import simd

func randomInUnitDisc() -> double3 {
	var p = double3()
	repeat {
		p = 2.0 * double3(drand48(), drand48(), 0) - double3(1,1,0)
	} while dot(p, p) >= 1.0
	return p
}

public struct Camera {
	private var origin: double3
	private var lowerLeftCorner: double3
	private var horizontal: double3
	private var vertical: double3
	private var u: double3
	private var v: double3
	private var w: double3
	private var time0: Double
	private var time1: Double
	private var lensRadius: Double
		
	public init(lookFrom: double3, lookAt: double3, up: double3, verticalFOV: Double, aspect: Double, aperture: Double, focusDistance: Double, time0 t0: Double, time1 t1: Double) {
		time0 = t0
		time1 = t1
		lensRadius = aperture / 2
		let theta = verticalFOV * M_PI / 180.0
		let halfHeight = tan(theta / 2)
		let halfWidth = aspect * halfHeight
		
		origin = lookFrom
		w = normalize(lookFrom - lookAt)
		u = normalize(cross(up, w))
		v = cross(w, u)
		
		lowerLeftCorner = origin - halfWidth * focusDistance * u - halfHeight * focusDistance * v - focusDistance * w
		horizontal = 2 * halfWidth * focusDistance * u
		vertical = 2 * halfHeight * focusDistance * v
	}
	
	public func getRay(s: Double, _ t: Double) -> Ray {
		let rd = lensRadius * randomInUnitDisc()
		let offset = u * rd.x + v * rd.y
		let time = time0 + drand48() * (time1 - time0)
		return Ray(origin: origin + offset, direction: lowerLeftCorner + s * horizontal + t * vertical - origin - offset, time: time)
	}
	
}
