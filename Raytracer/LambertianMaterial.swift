//
//  LambertianMaterial.swift
//  Raytracer
//
//  Created by David Green on 4/15/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation
import simd

public struct LambertianMaterial: Material {
	public var albedo: double3
	public init(albedo a: double3) {
		albedo = a
	}
	
	public func scatter(rayIn: Ray, rec: HitRecord) -> (attenuation: double3, scattered: Ray)? {
		let target = rec.point + rec.normal + randomInUnitSphere()
		let scattered = Ray(origin: rec.point, direction: target - rec.point)
		let attenuation = albedo
		return (attenuation, scattered)
	}
}