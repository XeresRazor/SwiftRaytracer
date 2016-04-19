//
//  LambertianMaterial.swift
//  Raytracer
//
//  Created by David Green on 4/15/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation
import simd

public class LambertianMaterial: Material {
	public var albedo: Texture
	
	public init(albedo a: Texture) {
		albedo = a
	}
	
	public override func scatter(rayIn: Ray, rec: HitRecord) -> (attenuation: float3, scattered: Ray)? {
		let target = rec.point + rec.normal + randomInUnitSphere()
		let scattered = Ray(origin: rec.point, direction: target - rec.point, time: rayIn.time)
		let attenuation = albedo.value(0, v: 0, point: rec.point)
		return (attenuation, scattered)
	}
}