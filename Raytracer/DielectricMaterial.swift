//
//  DielectricMaterial.swift
//  Raytracer
//
//  Created by David Green on 4/15/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation
import simd

public class DielectricMaterial: Material {
	public var indexOfRefraction: Float
	
	init(refractionIndex: Float) {
		indexOfRefraction = refractionIndex
	}
	
	public func scatter(rayIn: Ray, rec: HitRecord) -> (attenuation: float3, scattered: Ray)? {
		var outwardNormal: float3
		let reflected = reflect(rayIn.direction, n: rec.normal)
		var niOverNt: Float
		let attenuation = float3(1.0, 1.0, 1.0)
		var refracted: float3
		var reflectionProbability: Float
		var cosine: Float
		
		if dot(rayIn.direction, rec.normal) > 0 {
			outwardNormal = -rec.normal
			niOverNt = indexOfRefraction
			cosine = indexOfRefraction * dot(rayIn.direction, rec.normal) /  length(rayIn.direction)
		} else {
			outwardNormal = rec.normal
			niOverNt = 1.0 / indexOfRefraction
			cosine = -dot(rayIn.direction, rec.normal) / length(rayIn.direction)
		}
		
		refracted = refract(rayIn.direction, n: outwardNormal, eta: niOverNt)
		
		var scattered: Ray
		let zero = float3()
		
		if refracted.x != zero.x && refracted.y != zero.y && refracted.z != zero.z {
//			scattered = Ray(origin: rec.point, direction: refracted)
			reflectionProbability = schlick(cosine, refractionIndex: indexOfRefraction)
		} else {
//			scattered = Ray(origin: rec.point, direction: reflected)
			reflectionProbability = 1.0
		}
		
		if Float(drand48()) < reflectionProbability {
			scattered = Ray(origin: rec.point, direction: reflected, time: rayIn.time)
		} else {
			scattered = Ray(origin: rec.point, direction: refracted, time: rayIn.time)
		}
		
		return(attenuation, scattered)
	}
}
