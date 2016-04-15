//
//  Material.swift
//  Raytracer
//
//  Created by David Green on 4/15/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation
import simd

public protocol Material {
	func scatter(rayIn: Ray, rec: HitRecord) -> (attenuation: double3, scattered: Ray)?
}