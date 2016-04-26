//
//  Perlin.swift
//  Raytracer
//
//  Created by David Green on 4/20/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation
import simd

private func perlinGenerate() -> [double4] {
	var p = [double4](repeating: double4(0,0,0,1), count: 256)
	for i in 0 ..< 256 {
		p[i] = normalize(double4(-1 + 2 * drand48(), -1 + 2 * drand48(), -1 + 2 * drand48(), 1))
	}
	return p
}

private func permute(p: inout [Int]) {
	var i = p.count - 1
	while i > 0 {
		let target = Int(drand48() * Double(i + 1))
		let tmp = p[i]
		p[i] = p[target]
		p[target] = tmp
		i -= 1
	}
}

private func perlinGeneratePermutation() -> [Int] {
	var p = [Int](repeating: 0, count: 256)
	for i in 0 ..< 256 {
		p[i] = i
	}
	permute(p: &p)
	return p
}

private func perlinInterpolation(c: [[[double4]]], u: Double, v: Double, w: Double) -> Double {
	let uu = u * u * (3 - 2 * u)
	let vv = v * v * (3 - 2 * v)
	let ww = w * w * (3 - 2 * w)
	
	var accum: Double = 0
	
	for i in 0 ..< 2 {
		for j in 0 ..< 2 {
			for k in 0 ..< 2 {
				let weightV = double4(u - Double(i), v - Double(j), w - Double(k), 1)
				let accum1 = ((Double(i) * uu) + (Double(1 - i) * Double(1 - uu)))
				let accum2 = ((Double(j) * vv) + (Double(1 - j) * Double(1 - vv)))
				let accum3 = ((Double(k) * ww) + (Double(1 - k) * Double(1 - ww)))
				
				accum += accum1 * accum2 * accum3 * dot(c[i][j][k], weightV)
			}
		}
	}
	
	return accum
}

public struct Perlin {
	private var ranVec = perlinGenerate()
	private var permX = perlinGeneratePermutation()
	private var permY = perlinGeneratePermutation()
	private var permZ = perlinGeneratePermutation()
	
	public func noise(point: double4) -> Double {
		let u = point.x - floor(point.x)
		let v = point.y - floor(point.y)
		let w = point.z - floor(point.z)
		
		let i = Int(floor(point.x))
		let j = Int(floor(point.y))
		let k = Int(floor(point.z))
		
		var c = [[[double4]]](repeating: [[double4]](repeating: [double4](repeating: double4(0,0,0,0), count: 2), count: 2), count: 2)
		
		for di in 0 ..< 2 {
			for dj in 0 ..< 2 {
				for dk in 0 ..< 2 {
					c[di][dj][dk] = ranVec[permX[(i + di) & 255] ^ permY[(j + dj) & 255] ^ permZ[(k + dk) & 255]]
				}
			}
		}

		return perlinInterpolation(c: c, u: u, v: v, w: w)
	}
}


