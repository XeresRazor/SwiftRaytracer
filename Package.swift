import PackageDescription

let package = Package(
	name: "PathTracer",
	targets: [
		Target(
			name: "stbi"
		),
		Target(
			name: "pathtracer",
			dependencies: [.Target(name: "stbi")]
		),
		Target(
			name: "renderer",
			dependencies: [.Target(name: "pathtracer")]
		)
	]
)
