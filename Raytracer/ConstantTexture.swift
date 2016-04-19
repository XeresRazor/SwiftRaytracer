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
	private(set) public var color: float3
	
	public init(color c: float3) {
		color = c
	}
	
	public override func value(u: Float, v: Float, point: float3) -> float3 {
		return color
	}
}
