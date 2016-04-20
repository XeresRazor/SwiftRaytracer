//
//  CheckerTexture.swift
//  Raytracer
//
//  Created by David Green on 4/19/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation
import simd

public class CheckerTexture: Texture {
	private(set) public var even: Texture
	private(set) public var odd: Texture
	
	public init(texture0 t0: Texture, texture1 t1: Texture) {
		even = t0
		odd = t1
	}
	
	public override func value(u: Double, v: Double, point: double4) -> double4 {
		let sines = sin(10 * point.x) * sin(10 * point.y) * sin(10 * point.z)
		if sines < 0 {
			return odd.value(u, v: v, point: point)
		} else {
			return even.value(u, v: v, point: point)
		}
	}
}
