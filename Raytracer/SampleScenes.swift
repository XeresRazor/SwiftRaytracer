//
//  SampleScenes.swift
//  Raytracer
//
//  Created by David Green on 4/19/16.
//  Copyright © 2016 David Green. All rights reserved.
//

import Foundation
import simd

func generateFractalSpheresAroundSphere(parentSphere: Sphere, level: Int, maxLevel: Int, material0: Material, material1: Material, inout intoList: [Traceable]) {
	if level < maxLevel {
		let material = level % 2 == 0 ? material0 : material1
		for _ in 0 ..< level + 5 {
			let direction = normalize(randomInUnitSphere())
			let radius = parentSphere.radius * (drand48() / 5.0) + 0.4
			let sphere = Sphere(center: parentSphere.center + (direction * (parentSphere.radius + radius)), radius: radius, material: material)
			intoList.append(sphere)
			generateFractalSpheresAroundSphere(sphere, level: level + 1, maxLevel: maxLevel, material0: material0, material1: material1, intoList: &intoList)
		}
	}
}

func fractalScene() -> Scene {
	var list: [Traceable] = []
	let mirror = MetalMaterial(albedo: double3(1.0, 1.0, 1.0), fuzziness: 0.05)
	let diffuse = LambertianMaterial(albedo: ConstantTexture(color: double3(0.5, 0.5, 0.8)))
	//list.append(Sphere(center: double3(0,-1016,0), radius: 1000, material: LambertianMaterial(albedo: double3(0.8, 0.8, 0.8))))
	let sphere = Sphere(center: double3(0,0,0), radius: 16.0, material: DielectricMaterial(refractionIndex: 1.5))
	list.append(sphere)
	list.append(Sphere(center: double3(0,0,0), radius: -15.0, material: DielectricMaterial(refractionIndex: 1.5, color: double3(1,1,1), fuzziness: 0.5)))
	generateFractalSpheresAroundSphere(sphere, level: 0, maxLevel: 5, material0: diffuse, material1: mirror, intoList: &list)
	print("Generated \(list.count) objects to render.")
	
	let world = BVHNode(list: list, time0: 0.0, time1: 1.0)
	
	let up = double3(0,1,0)
	let lookfrom = double3(40,5,40)
	let lookAt = double3(0,0,0)
	let fov = 60.0
	let aperture = 0.1
	let focusDistance = 10.0
	
	// Render configuration
	let width = 640
	let height = 360
	let samples = 128

	let aspect = Double(width) / Double(height)
	
	let cam = Camera(lookFrom: lookfrom, lookAt: lookAt, up: up, verticalFOV: fov, aspect: aspect, aperture: aperture, focusDistance: focusDistance, time0: 0.0, time1: 1.0)
	
	let renderConfig = RenderConfig(width: width, height: height, samples: samples)
	
	return Scene(world: world, camera: cam, config: renderConfig)
}

func randomScene() -> Scene {
	var list: [Traceable] = []
	let baseTexture = CheckerTexture(texture0: ConstantTexture(color: double3(0.1, 0.2, 0.3)), texture1: ConstantTexture(color: double3(0.9, 0.95, 1.0)))
	list.append(Sphere(center: double3(0, -1000, 0), radius: 1000, material: LambertianMaterial(albedo: baseTexture)))
	
	for a in -11 ..< 11 {
		for b in -11 ..< 11 {
			let chooseMat = drand48()
			let center = double3(Double(a) + 0.9 * drand48(), 0.2, Double(b) + 0.9 * drand48())
			
			if length(center - double3(4, 0.2, 0)) > 0.9 {
				if chooseMat < 0.8 { // diffuse
					let rand2 = drand48() > 0.75
					if rand2 {
						list.append(
							Sphere(
								center: center,
								radius: 0.2,
								material: LambertianMaterial(
									albedo: ConstantTexture(
										color: double3(drand48() * drand48(), drand48() * drand48(), drand48() * drand48())
									)
								)
							)
						)
					} else {
						list.append(
							MovingSphere(
								center0: center,
								center1: center/* + double3(0, drand48(), 0.0)*/,
								time0: 0.0,
								time1: 1.0,
								radius: 0.2,
								material: LambertianMaterial(
									albedo: ConstantTexture(color: double3(
										drand48() * drand48(),
										drand48() * drand48(),
										drand48() * drand48())
									)
								)
							)
						)
					}
				} else if chooseMat < 0.95 { // metal
					list.append(Sphere(center: center, radius: 0.2, material: MetalMaterial(albedo: double3(0.5 * (1 + drand48()), 0.5 * (1 + drand48()), 0.5 * (1 + drand48())), fuzziness: 0.5 *  drand48())))
				} else { // glass
					list.append(
						Sphere(
							center: center,
							radius: 0.2,
							material: DielectricMaterial(
								refractionIndex: 1.5,
								color: double3(
									drand48() * drand48(),
									drand48() * drand48(),
									drand48() * drand48()
								),
								fuzziness:0.5 *  drand48()
							)
						)
					)
				}
			}
		}
	}
	
	list.append(Sphere(center: double3(0, 1, 0), radius: 1.0, material: DielectricMaterial(refractionIndex: 1.5, color: double3(1,1,1), fuzziness: 0.0)))
	list.append(Sphere(center: double3(-4, 1, 0), radius: 1.0, material: LambertianMaterial(albedo: ConstantTexture(color: double3(0.4, 0.2, 0.1)))))
	list.append(Sphere(center: double3(4, 1, 0), radius: 1.0, material: MetalMaterial(albedo: double3(1.0, 1.0, 1.0), fuzziness: 0.0)))
	
	let world = BVHNode(list: list, time0: 0.0, time1: 1.0)
	
	let up = double3(0,1,0)
	let lookfrom = double3(13,2,3)
	let lookAt = double3(0,0,0)
	let fov = 20.0
	let aperture = 0.0
	let focusDistance = 10.0
	
	// Render configuration
	let width = 1280
	let height = 720
	let samples = 1024

	let aspect = Double(width) / Double(height)
	
	let cam = Camera(lookFrom: lookfrom, lookAt: lookAt, up: up, verticalFOV: fov, aspect: aspect, aperture: aperture, focusDistance: focusDistance, time0: 0.0, time1: 1.0)
	
	let renderConfig = RenderConfig(width: width, height: height, samples: samples)
	
	let scene = Scene(world: world, camera: cam, config: renderConfig)
	return scene

}
