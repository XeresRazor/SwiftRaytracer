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
	public var indexOfRefraction: Double
    public var attenuation: double4
    public var fuzziness: Double
    
	public init(refractionIndex: Double) {
		indexOfRefraction = refractionIndex
        attenuation = double4(1.0, 1.0, 1.0, 1.0)
        fuzziness = 0
	}
    
    public init(refractionIndex: Double, color: double4, fuzziness f: Double) {
        indexOfRefraction = refractionIndex
        attenuation = color
        fuzziness = f
    }
	
	public override func scatter(rayIn: Ray, rec: HitRecord) -> (attenuation: double4, scattered: Ray)? {
		var outwardNormal: double4
		let reflected = reflect(rayIn.direction, n: rec.normal)
		var niOverNt: Double
		var refracted: double4
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
		let zero = double4()
		
		if refracted.x != zero.x && refracted.y != zero.y && refracted.z != zero.z {
//			scattered = Ray(origin: rec.point, direction: refracted)
			reflectionProbability = schlick(cosine: cosine, refractionIndex: indexOfRefraction)
		} else {
//			scattered = Ray(origin: rec.point, direction: reflected)
			reflectionProbability = 1.0
		}
		
		if drand48() < reflectionProbability {
			scattered = Ray(origin: rec.point, direction: reflected + fuzziness * randomInUnitSphere(), time: rayIn.time)
		} else {
			scattered = Ray(origin: rec.point, direction: refracted + fuzziness * randomInUnitSphere(), time: rayIn.time)
		}
		
		return(attenuation, scattered)
	}
}
