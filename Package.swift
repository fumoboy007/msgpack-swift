// swift-tools-version: 5.9

import PackageDescription

// The reference implementation requires the `msgpack-c` library to be provided by the system.
// Therefore, the reference implementation can only support the platform that the build system
// is running on.
let referenceImplementationSupportedPlatforms: [Platform] = {
#if os(macOS)
   return [.macOS]
#elseif os(Linux)
   return [.linux]
#elseif os(Windows)
   return [.windows]
#elseif os(OpenBSD)
   return [.openbsd]
#else
   return []
#endif
}()

var package = Package(
   name: "msgpack-swift",
   platforms: [
      .visionOS(.v1),
      .macOS(.v13),
      .macCatalyst(.v16),
      .iOS(.v16),
      .tvOS(.v16),
      .watchOS(.v9),
   ],
   products: [
      .library(
         // TODO: Remove `DM` prefix after FB13180164 is resolved. The Xcode build system fails to build
         // a package graph that has duplicate product names. In this case, the `Flight-School/MessagePack`
         // package also has a product named `MessagePack`.
         name: "DMMessagePack",
         targets: [
            "MessagePack",
         ]
      ),
   ],
   dependencies: [
      .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0"),
      .package(url: "https://github.com/apple/swift-log.git", from: "1.5.3"),
      .package(url: "https://github.com/fumoboy007/MessagePackReferenceImplementation.git", from: "1.0.1"),
      .package(url: "https://github.com/hirotakan/MessagePacker.git", from: "0.4.7"),
      .package(url: "https://github.com/nnabeyang/swift-msgpack.git", from: "0.2.7"),
   ],
   targets: [
      .target(
         name: "MessagePack"
      ),

      .testTarget(
         name: "MessagePackTests",
         dependencies: [
            "MessagePack",
            .product(
               name: "MessagePackReferenceImplementation",
               package: "MessagePackReferenceImplementation",
               condition: .when(platforms: referenceImplementationSupportedPlatforms)
            ),
         ],
         swiftSettings: [
            .define("HAS_REFERENCE_IMPLEMENTATION", .when(platforms: referenceImplementationSupportedPlatforms))
         ]
      ),
      .testTarget(
         name: "Benchmarks",
         dependencies: [
            .product(name: "Logging", package: "swift-log"),
            "MessagePack",
            "MessagePacker",
            .product(name: "SwiftMsgpack", package: "swift-msgpack"),
         ]
      )
   ]
)

let commonSwiftSettings: [SwiftSetting] = [
   .enableUpcomingFeature("StrictConcurrency"),
]
for index in (package.targets.startIndex)..<package.targets.endIndex {
   let targetSpecificSwiftSettings = package.targets[index].swiftSettings ?? []
   package.targets[index].swiftSettings = targetSpecificSwiftSettings + commonSwiftSettings
}
