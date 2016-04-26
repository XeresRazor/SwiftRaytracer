//
//  BVHNode.swift
//  Raytracer
//
//  Created by David Green on 4/16/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation
import simd

public class BVHNode: Traceable {
	public var left: Traceable
	public var right: Traceable
	public var box: AABB
	
	public init(list l: [Traceable], time0: Double, time1: Double) {
        var list = l
		let axis = Int(3 * drand48())
		
		if axis == 0 {
			list.sort(isOrderedBefore: { (ah, bh) -> Bool in
				let leftBox = ah.boundingBox(t0: 0, t1: 0)
				let rightBox = bh.boundingBox(t0: 0, t1: 0)
				if leftBox == nil || rightBox == nil {
					print("No bounding box in BVHNode init()")
				}
				if leftBox!.minimum.x - rightBox!.minimum.x < 0.0 {
					return false
				} else {
					return true
				}
			})
		} else if axis == 1 {
			list.sort(isOrderedBefore: { (ah, bh) -> Bool in
				let leftBox = ah.boundingBox(t0: 0, t1: 0)
				let rightBox = bh.boundingBox(t0: 0, t1: 0)
				if leftBox == nil || rightBox == nil {
					print("No bounding box in BVHNode init()")
				}
				if leftBox!.minimum.y - rightBox!.minimum.y < 0.0 {
					return false
				} else {
					return true
				}
			})
		} else {
			list.sort(isOrderedBefore: { (ah, bh) -> Bool in
				let leftBox = ah.boundingBox(t0: 0, t1: 0)
				let rightBox = bh.boundingBox(t0: 0, t1: 0)
				if leftBox == nil || rightBox == nil {
					fatalError("No bounding box in BVHNode init()")
				}
				if leftBox!.minimum.z - rightBox!.minimum.z < 0.0 {
					return false
				} else {
					return true
				}
			})
		}
		
		if list.count == 1 {
			left = list[0]
			right = list[0]
		} else if list.count == 2 {
			left = list[0]
			right = list[1]
		} else {
			let leftArray = Array(list[0 ..< list.count / 2])
			let rightArray = Array(list[(list.count / 2) ..< list.count])
			left = BVHNode(list: leftArray, time0: time0, time1: time1)
			right = BVHNode(list: rightArray, time0: time0, time1: time1)
		}
		let boxLeft = left.boundingBox(t0: time0, t1: time1)
		let boxRight = right.boundingBox(t0: time0, t1: time1)
		if boxLeft == nil || boxRight == nil {
			fatalError("No bounding box in BVHNode init()")
		}
		box = surroundingBox(box0: boxLeft!, box1: boxRight!)
	}
	
	public override func trace(r: Ray, minimumT tMin: Double, maximumT tMax: Double) -> HitRecord? {
		if box.hit(ray: r, tMin: tMin, tMax: tMax) {
			let leftRec = left.trace(r: r, minimumT: tMin, maximumT: tMax)
			let rightRec = right.trace(r: r, minimumT: tMin, maximumT: tMax)
			if leftRec != nil && rightRec != nil {
				if leftRec!.time < rightRec!.time {
					return leftRec!
				} else {
					return rightRec!
				}
			} else if leftRec != nil {
				return leftRec!
			} else if rightRec != nil {
				return rightRec!
			} else {
				return nil
			}
		} else {
			return nil
		}
	}
	
	public override func boundingBox(t0: Double, t1: Double) -> AABB? {
		return box
	}
}
