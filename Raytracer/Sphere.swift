//
//  Sphere.swift
//  Raytracer
//
//  Created by David Green on 4/6/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import simd

public struct Sphere: Traceable {
	public var center: double3
	public var radius: Double
	private var material: Material
	
	public init() {
		center = double3()
		radius = 0
		material = LambertianMaterial(albedo: double3(0.5, 0.5, 0.5))
	}
	
	public init(center c: double3, radius r: Double, material m: Material) {
		center = c
		radius = r
		material = m
	}
	
	public func trace(r: Ray, minimumT tMin: Double, maximumT tMax: Double) -> HitRecord? {
		var rec = HitRecord()
		rec.material = material
		let oc = r.origin - center
		let a = dot(r.direction, r.direction)
		let b = dot(oc, r.direction)
		let c = dot(oc, oc) - radius * radius
		let discriminant = b * b - a * c
		if discriminant > 0 {
			var temp = (-b - sqrt(b * b - a * c)) / a
			if temp < tMax && temp > tMin {
				rec.time = temp
				rec.point = r.pointAtDistance(rec.time)
				rec.normal = normalize(rec.point - center)
				return rec
			}
			temp = (-b + sqrt(b * b - a * c)) / a
			if temp < tMax && temp > tMin {
				rec.time = temp
				rec.point = r.pointAtDistance(rec.time)
				rec.normal = normalize(rec.point - center)
				return rec
			}
		}
		return nil
	}
}
