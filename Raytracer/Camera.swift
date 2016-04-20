//
//  Camera.swift
//  Raytracer
//
//  Created by David Green on 4/14/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import simd

func randomInUnitDisc() -> double4 {
	var p = double4()
	repeat {
		p = 2.0 * double4(drand48(), drand48(), 0, 0) - double4(1,1,0, 0)
	} while dot(p, p) >= 1.0
	return p
}

public struct Camera {
	private var origin: double4
	private var lowerLeftCorner: double4
	private var horizontal: double4
	private var vertical: double4
	private var u: double4
	private var v: double4
	private var w: double4
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
		
		let originTemp = lookFrom
		let wTemp = normalize(lookFrom - lookAt)
		let uTemp = normalize(cross(up, wTemp))
		let vTemp = cross(wTemp, uTemp)
		
		origin = double4(originTemp.x, originTemp.y, originTemp.z, 0.0)
		w = double4(wTemp.x, wTemp.y, wTemp.z, 0.0)
		u = double4(uTemp.x, uTemp.y, uTemp.z, 0.0)
		v = double4(vTemp.x, vTemp.y, vTemp.z, 0.0)
		
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
