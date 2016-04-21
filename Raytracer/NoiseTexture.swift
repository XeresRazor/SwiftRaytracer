//
//  NoiseTexture.swift
//  Raytracer
//
//  Created by David Green on 4/20/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation
import simd

public class NoiseTexture: Texture {
	private var noise = Perlin()
	private(set) public var scale: Double
	
	public init(scale sc: Double) {
		scale = sc
	}
	
	public override func value(u: Double, v: Double, point: double4) -> double4 {
		return double4(1,1,1,0) * noise.noise(scale * point)
	}
}
