//
//  SkyShader.swift
//  Raytracer
//
//  Created by David Green on 4/22/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation
import simd

public class SkyShader {
	public func colorForSkyDirection(direction: double4) -> double4 {
		let unitDirection = normalize(direction)
		let t = 0.5 * (unitDirection.y + 1.0)
		let white = double4(1.0, 1.0, 1.0, 1.0)
		let blue = double4(0.25, 0.35, 0.5, 1.0)
		return mix(white, blue, t: t)
	}
}
