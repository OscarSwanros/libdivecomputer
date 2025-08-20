// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LibDiveComputer",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "LibDiveComputer",
            targets: ["LibDiveComputer"]),
        .executable(
            name: "TestApp",
            targets: ["TestApp"]),
    ],
    targets: [
        .target(
            name: "LibDiveComputer",
            dependencies: ["CLibDiveComputer"]),
        .executableTarget(
            name: "TestApp",
            dependencies: ["LibDiveComputer"],
            path: "Sources/TestApp"),
        .target(
            name: "CLibDiveComputer",
            path: ".",
            exclude: [
                "examples",
                "doc",
                "contrib",
                "m4",
                "NEWS",
                "README",
                "COPYING",
                "configure.ac",
                "Makefile.am",
                "libdivecomputer.pc.in",
                "src/Makefile.am",
                "src/libdivecomputer.rc",
                "src/libdivecomputer.symbols",
                "include/Makefile.am",
                "include/libdivecomputer/Makefile.am",
                "include/libdivecomputer/version.h.in",
                "src/serial_win32.c"
            ],
            sources: [
                "src"
            ],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("include"),
                .headerSearchPath("src"),
                .headerSearchPath("."),
                .define("HAVE_CONFIG_H", to: "1"),
                .define("ENABLE_LOGGING", to: "1"),
                .define("VERSION", to: "\"0.10.0\""),
                .define("DC_VERSION_MAJOR", to: "0"),
                .define("DC_VERSION_MINOR", to: "10"),
                .define("DC_VERSION_MICRO", to: "0"),
                .define("DC_VERSION", to: "\"0.10.0\""),
                .define("DC_VERSION_LIBTOOL", to: "\"0:0:0\""),
                .define("HAVE_PTHREAD_H", to: "1"),
                .define("HAVE_UNISTD_H", to: "1"),
                .define("HAVE_GETUID", to: "1"),
                .define("HAVE_GETEUID", to: "1"),
                .define("HAVE_STRINGS_H", to: "1"),
                .define("_POSIX_C_SOURCE", to: "200809L"),
                .unsafeFlags(["-Wno-error", "-Wno-macro-redefined", "-Wno-implicit-function-declaration"])
            ],
            linkerSettings: [
                .linkedLibrary("iconv"),
                .linkedFramework("CoreBluetooth", .when(platforms: [.iOS, .macOS])),
                .linkedFramework("IOKit", .when(platforms: [.macOS]))
            ]
        )
    ]
)