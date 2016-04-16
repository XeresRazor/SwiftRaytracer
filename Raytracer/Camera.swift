//
//  Camera.swift
//  Raytracer
//
//  Created by David Green on 4/14/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import simd

func randomInUnitDisc() -> float3 {
	var p = float3()
	repeat {
		p = 2.0 * float3(Float(drand48()), Float(drand48()), 0) - float3(1,1,0)
	} while dot(p, p) >= 1.0
	return p
}

public struct Camera {
	private var origin: float3
	private var lowerLeftCorner: float3
	private var horizontal: float3
	private var vertical: float3
	private var u: float3
	private var v: float3
	private var w: float3
	private var time0: Float
	private var time1: Float
	private var lensRadius: Float
		
	public init(lookFrom: float3, lookAt: float3, up: float3, verticalFOV: Float, aspect: Float, aperture: Float, focusDistance: Float, time0 t0: Float, time1 t1: Float) {
		time0 = t0
		time1 = t1
		lensRadius = aperture / 2
		let theta = verticalFOV * Float(M_PI)/180.0
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
	
	public func getRay(s: Float, _ t: Float) -> Ray {
		let rd = lensRadius * randomInUnitDisc()
		let offset = u * rd.x + v * rd.y
		let time = time0 + Float(drand48()) * (time1 - time0)
		return Ray(origin: origin + offset, direction: lowerLeftCorner + s * horizontal + t * vertical - origin - offset, time: time)
	}
	
}
