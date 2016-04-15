//
//  TraceableCollection.swift
//  Raytracer
//
//  Created by David Green on 4/6/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import simd

public struct TraceableCollection: Traceable {
	public var list: [Traceable]
	
	public init() {
		list = [Traceable]()
	}
	
	public init(list l: [Traceable]) {
		list = l
	}
	
	public func trace(r: Ray, minimumT tMin: Double, maximumT tMax: Double) -> HitRecord? {
		var rec = HitRecord()
		var hitAnything = false
		var closest = tMax
		
		for item in list {
			if let tempRec = item.trace(r, minimumT: tMin, maximumT: closest) {
				hitAnything = true
				closest = tempRec.time
				rec = tempRec
			}
		}
		
		if hitAnything {
			return rec
		}
		
		return nil
	}
}
