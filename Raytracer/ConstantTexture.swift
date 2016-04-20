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
	private(set) public var color: double4
	
	public init(color c: double4) {
		color = c
	}
	
	public override func value(u: Double, v: Double, point: double4) -> double4 {
		return color
	}
}
