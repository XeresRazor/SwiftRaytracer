//
//  MetalMaterial.swift
//  Raytracer
//
//  Created by David Green on 4/15/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation
import simd

public class MetalMaterial: Material {
	public var albedo: double4
	public var fuzziness: Double
	
	public init(albedo a: double4, fuzziness f: Double) {
		albedo = a
		fuzziness = f
	}
	
	public override func scatter(rayIn: Ray, rec: HitRecord) -> (attenuation: double4, scattered: Ray)? {
		let reflected = reflect(normalize(rayIn.direction), n: rec.normal)
		let scattered = Ray(origin: rec.point, direction: reflected + fuzziness * randomInUnitSphere(), time: rayIn.time)
		let attenuation = albedo
		if (dot(scattered.direction, rec.normal) > 0) {
			return (attenuation, scattered)
		} else {
			return nil
		}
	}
}
