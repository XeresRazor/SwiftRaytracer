//
//  MovingSphere.swift
//  Raytracer
//
//  Created by David Green on 4/16/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import simd

public class MovingSphere: Traceable {
	private var center0: double4
	private var center1: double4
	private var time0: Double
	private var time1: Double
	private var radius: Double
	private var material: Material
	
	public init(center0 cen0: double4, center1 cen1: double4, time0 t0: Double, time1 t1: Double, radius r: Double, material m: Material) {
		center0 = cen0
		center1 = cen1
		time0 = t0
		time1 = t1
		radius = r
		material = m
	}
	
	public func center(time: Double) -> double4 {
		return mix(center0, center1, t: time)
	}
	
	public override func trace(r: Ray, minimumT tMin: Double, maximumT tMax: Double) -> HitRecord? {
		let cen = center(time: r.time)
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
				rec.point = r.pointAtDistance(t: rec.time)
				rec.normal = normalize(rec.point - cen)
				return rec
			}
			temp = (-b + sqrt(b * b - a * c)) / a
			if temp < tMax && temp > tMin {
				rec.time = temp
				rec.point = r.pointAtDistance(t: rec.time)
				rec.normal = normalize(rec.point - cen)
				return rec
			}
		}
		return nil

	}
	
	public override func boundingBox(t0: Double, t1: Double) -> AABB? {
		let box0 = AABB(min: center0 - double4(radius, radius, radius, 0), max: center0 + double4(radius, radius, radius, 0))
		let box1 = AABB(min: center1 - double4(radius, radius, radius, 0), max: center1 + double4(radius, radius, radius, 0))
		return surroundingBox(box0: box0, box1: box1)
	}
}
