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
	public var albedo: float3
	public var fuzziness: Float
	
	public init(albedo a: float3, fuzziness f: Float) {
		albedo = a
		fuzziness = f
	}
	
	public func scatter(rayIn: Ray, rec: HitRecord) -> (attenuation: float3, scattered: Ray)? {
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
