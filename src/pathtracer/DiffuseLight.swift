//
//  DiffuseLight.swift
//  Raytracer
//
//  Created by David Green on 4/21/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation
import simd

public class DiffuseLight: Material {
	private var emit: Texture
	
	public init(emissionTexture: Texture) {
		emit = emissionTexture
	}
	
	public override func scatter(rayIn: Ray, rec: HitRecord) -> (attenuation: double4, scattered: Ray)? {
		return nil
	}
	
	public override func emitted(u: Double, v: Double, point p: double4) -> double4 {
		return emit.value(u: u, v: v, point: p)
	}
}
