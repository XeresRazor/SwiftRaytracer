//
//  Material.swift
//  Raytracer
//
//  Created by David Green on 4/15/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import simd

public class Material {
	public func scatter(rayIn: Ray, rec: HitRecord) -> (attenuation: double4, scattered: Ray)? {
		fatalError("scatter() must be overridden.")
	}
	public func emitted(u: Double, v: Double, point p: double4) -> double4 {
		return double4(0,0,0,0)
	}
}