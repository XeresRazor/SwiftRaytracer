//
//  Utility.swift
//  Raytracer
//
//  Created by David Green on 4/14/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation

public func randomDouble() -> Double {
	return Double(arc4random()) / Double(UINT32_MAX)
}
