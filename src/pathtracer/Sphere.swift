//
//  Sphere.swift
//  Raytracer
//
//  Created by David Green on 4/6/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import simd

func sphereUV(point: double4) -> (u: Double, v: Double) {
	let phi = atan2(point.z, point.x)
	let theta = asin(point.y)
	let u = 1.0 - (phi + M_PI) / (2 * M_PI)
	let v = (theta + M_PI / 2.0) / M_PI
	return (u, v)
}

public class Sphere: Traceable {
	public var center: double4
	public var radius: Double
	private var material: Material
	
	public override init() {
		center = double4()
		radius = 0
		material = LambertianMaterial(albedo: ConstantTexture(color: double4(0.5, 0.5, 0.5, 0)))
	}
	
	public init(center c: double4, radius r: Double, material m: Material) {
		center = c
		radius = r
		material = m
	}
	
	public override func trace(r: Ray, minimumT tMin: Double, maximumT tMax: Double) -> HitRecord? {
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
				rec.point = r.pointAtDistance(t: rec.time)
				rec.normal = normalize(rec.point - center)
				let uv = sphereUV(point: normalize(rec.point - center))
				rec.u = uv.u
				rec.v = uv.v
				return rec
			}
			temp = (-b + sqrt(b * b - a * c)) / a
			if temp < tMax && temp > tMin {
				rec.time = temp
				rec.point = r.pointAtDistance(t: rec.time)
				rec.normal = normalize(rec.point - center)
				let uv = sphereUV(point: normalize(rec.point - center))
				rec.u = uv.u
				rec.v = uv.v
				return rec
			}
		}
		return nil
	}
	
	public override func boundingBox(t0: Double, t1: Double) -> AABB? {
		return AABB(min: center - double4(radius, radius, radius, 0), max: center + double4(radius, radius, radius, 0))
	}
}
