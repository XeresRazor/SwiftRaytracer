//
//  Scene.swift
//  Raytracer
//
//  Created by David Green on 4/19/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation

//	Scene contains everything needed to render a shot, camera, world to trace against, and render settings

public struct RenderConfig {
	public var width: Int
	public var height: Int
	public var samples: Int
	public var targetQuality: Double
	
	
	public init(width w: Int, height h: Int, samples s: Int, targetQuality q: Double = 0.01) {
		width = w
		height = h
		samples = s
		targetQuality = q
		
	}
}

public class Scene {
	public var world: Traceable
	public var camera: Camera
	public var config: RenderConfig
	public var skyShader: SkyShader
	
	public init(world w: Traceable, camera cam: Camera, config c: RenderConfig, skyshader sky: SkyShader = SkyShader()) {
		world = w
		camera = cam
		config = c
		skyShader = sky
	}
}