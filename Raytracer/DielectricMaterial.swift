//
//  DielectricMaterial.swift
//  Raytracer
//
//  Created by David Green on 4/15/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation
import simd

public struct DielectricMaterial: Material {
	public var indexOfRefraction: Double
	
	init(refractionIndex: Double) {
		indexOfRefraction = refractionIndex
	}
	
	public func scatter(rayIn: Ray, rec: HitRecord) -> (attenuation: double3, scattered: Ray)? {
		var outwardNormal: double3
		let reflected = reflect(rayIn.direction, n: rec.normal)
		var niOverNt: Double
		let attenuation = double3(1.0, 1.0, 1.0)
		var refracted: double3
		var reflectionProbability: Double
		var cosine: Double
		
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
		let zero = double3()
		
		if refracted.x != zero.x && refracted.y != zero.y && refracted.z != zero.z {
//			scattered = Ray(origin: rec.point, direction: refracted)
			reflectionProbability = schlick(cosine, refractionIndex: indexOfRefraction)
		} else {
//			scattered = Ray(origin: rec.point, direction: reflected)
			reflectionProbability = 1.0
		}
		
		if drand48() < reflectionProbability {
			scattered = Ray(origin: rec.point, direction: reflected)
		} else {
			scattered = Ray(origin: rec.point, direction: refracted)
		}
		
		return(attenuation, scattered)
	}
}