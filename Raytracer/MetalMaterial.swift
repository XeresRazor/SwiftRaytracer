//
//  MetalMaterial.swift
//  Raytracer
//
//  Created by David Green on 4/15/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation
import simd

public struct MetalMaterial: Material {
	public var albedo: double3
	
	public init(albedo a: double3) {
		albedo = a
	}
	
	public func scatter(rayIn: Ray, rec: HitRecord) -> (attenuation: double3, scattered: Ray)? {
		let reflected = reflect(normalize(rayIn.direction), n: rec.normal)
		let scattered = Ray(origin: rec.point, direction: reflected)
		let attenuation = albedo
		if (dot(scattered.direction, rec.normal) > 0) {
			return (attenuation, scattered)
		} else {
			return nil
		}
	}
}
