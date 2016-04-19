//
//  ConstantTexture.swift
//  Raytracer
//
//  Created by David Green on 4/19/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation
import simd

public class ConstantTexture: Texture {
	private(set) public var color: double3
	
	public init(color c: double3) {
		color = c
	}
	
	public override func value(u: Double, v: Double, point: double3) -> double3 {
		return color
	}
}
