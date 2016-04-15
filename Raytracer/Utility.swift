//
//  Utility.swift
//  Raytracer
//
//  Created by David Green on 4/14/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation
import simd

public func randomInUnitSphere() -> double3 {
	var p: double3
	repeat {
		p = 2.0 * double3(drand48(), drand48(), drand48()) - double3(1.0, 1.0, 1.0)
	} while length_squared(p) >= 1.0
	
	return p
}
