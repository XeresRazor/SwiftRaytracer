//
//  Image.swift
//  Raytracer
//
//  Created by David Green on 4/6/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation
import Libimage

public struct RGBA8Pixel {
	public var r: UInt8
	public var g: UInt8
	public var b: UInt8
	public var a: UInt8
	
	public init(_ red: UInt8, _ green: UInt8, _ blue: UInt8, _ alpha: UInt8) {
		r = red
		g = green
		b = blue
		a = alpha
	}

	public init(_ red: UInt8, _ green: UInt8, _ blue: UInt8) {
		r = red
		g = green
		b = blue
		a = 255
	}
}

public class RGBA8Image {
	public let width: Int
	public let height: Int
	public var pixels: [RGBA8Pixel]
	
	public init(width w: Int, height h: Int) {
		width = w
		height = h
		let pixel = RGBA8Pixel(0, 0, 0, 255)
		pixels = [RGBA8Pixel](count: width * height, repeatedValue: pixel)
	}
	
	public init?(filename:String) {
		var w = Int32(0)
		var h = Int32(0)
		var c = Int32(0)
		let imagePixels = stbi_load(filename, &w, &h, &c, 4)

		
		width = Int(w)
		height = Int(h)

		let pixel = RGBA8Pixel(0,0,0,0)
		pixels = [RGBA8Pixel](count: width * height, repeatedValue: pixel)

		if imagePixels == nil {
			return nil
		}
		
		for i in 0 ..< width * height {
			let pixOffset = i * 4
			let pixel = RGBA8Pixel(imagePixels[pixOffset + 0], imagePixels[pixOffset + 1], imagePixels[pixOffset + 2], imagePixels[pixOffset + 3])
			pixels[i] = pixel
		}
		
		stbi_image_free(imagePixels)
	}
	
	public subscript(index: Int) -> RGBA8Pixel {
		get {
			assert(index < (width * height))
			return pixels[index]
		}
		set(newValue) {
			assert(index < (width * height))
			pixels[index] = newValue
		}
	}
	
	public subscript(x: Int, y: Int) -> RGBA8Pixel {
		get {
			let index = (x + y * width)
			return self[index]
		}
		set(newValue) {
			let index = (x + y * width)
			self[index] = newValue
		}
	}
	
	// MARK: Image file writing
	
	public enum ImageFormat {
		case png
		case bmp
		case tga
	}
	
	public func writeTo(file: String, format: ImageFormat) -> Bool {
		var result: Bool
		
		switch format {
		case .png:
			result = stbi_write_png(file, Int32(width), Int32(height), 4, pixels, Int32(width * 4)) != 0
		case .bmp:
			result = stbi_write_bmp(file, Int32(width), Int32(height), 4, pixels) != 0
		case .tga:
			result = stbi_write_tga(file, Int32(width), Int32(height), 4, pixels) != 0
		}
		
		return result
	}
}