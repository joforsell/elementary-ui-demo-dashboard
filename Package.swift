// swift-tools-version:6.2
import PackageDescription

let package = Package(
  name: "elementary-web-app",
  platforms: [.macOS(.v15)],
  dependencies: [
    .package(url: "https://github.com/elementary-swift/elementary-ui.git", from: "0.1.3"),
    .package(url: "https://github.com/swiftwasm/JavaScriptKit", .upToNextMinor(from: "0.37.0")),
  ],
  targets: [
    .executableTarget(
      name: "WebApp",
      dependencies: [
        .product(name: "ElementaryUI", package: "elementary-ui"),
        .product(name: "JavaScriptEventLoop", package: "JavaScriptKit"),
      ],
      swiftSettings: [
        .swiftLanguageMode(.v5)
      ],
    )
  ]
)
