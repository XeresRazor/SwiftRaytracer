//
//  Texture.swift
//  Raytracer
//
//  Created by David Green on 4/19/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation
import simd

public class Texture {
	public func value(u: Double, v: Double, point: double4) -> double4 {
		fatalError("value() must be overridden")
	}
}
