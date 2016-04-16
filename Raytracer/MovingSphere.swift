//
//  MovingSphere.swift
//  Raytracer
//
//  Created by David Green on 4/16/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import simd

public class MovingSphere: Traceable {
	private var center0: float3
	private var center1: float3
	private var time0: Float
	private var time1: Float
	private var radius: Float
	private var material: Material
	
	public init(center0 cen0: float3, center1 cen1: float3, time0 t0: Float, time1 t1: Float, radius r: Float, material m: Material) {
		center0 = cen0
		center1 = cen1
		time0 = t0
		time1 = t1
		radius = r
		material = m
	}
	
	public func center(time: Float) -> float3 {
		return mix(center0, center1, t: time)
	}
	
	public func trace(r: Ray, minimumT tMin: Float, maximumT tMax: Float) -> HitRecord? {
		let cen = center(r.time)
		var rec = HitRecord()
		rec.material = material
		let oc = r.origin - cen
		let a = dot(r.direction, r.direction)
		let b = dot(oc, r.direction)
		let c = dot(oc, oc) - radius * radius
		let discriminant = b * b - a * c
		if discriminant > 0 {
			var temp = (-b - sqrt(b * b - a * c)) / a
			if temp < tMax && temp > tMin {
				rec.time = temp
				rec.point = r.pointAtDistance(rec.time)
				rec.normal = normalize(rec.point - cen)
				return rec
			}
			temp = (-b + sqrt(b * b - a * c)) / a
			if temp < tMax && temp > tMin {
				rec.time = temp
				rec.point = r.pointAtDistance(rec.time)
				rec.normal = normalize(rec.point - cen)
				return rec
			}
		}
		return nil

	}
	
}
