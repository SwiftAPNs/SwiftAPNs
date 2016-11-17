import PackageDescription

let package = Package(
    name: "swift-apn",
    targets: [],
    dependencies: [
    .Package(url: "https://github.com/Zewo/COpenSSL.git", versions: Version(0, 0, 0) ..< Version(1, 0, 0))
    ]
)
