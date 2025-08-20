# iOS Integration Guide for libdivecomputer

This guide explains how to integrate libdivecomputer into your Swift iOS application.

## Overview

libdivecomputer is a cross-platform library for communication with dive computers. This setup provides Swift Package Manager (SPM) support and iOS-specific build configurations.

## Integration Options

### Option 1: Swift Package Manager (Recommended)

1. **Add as Local Package Dependency**
   - In Xcode, go to File → Add Package Dependencies
   - Click "Add Local..." and select the libdivecomputer directory
   - The Package.swift file will be recognized automatically

2. **Add as Remote Package Dependency**
   - If you've pushed this to a Git repository:
   ```
   https://github.com/yourusername/libdivecomputer.git
   ```
   - Add this URL in Xcode's package dependencies

### Option 2: Build XCFramework

1. **Build the Framework**
   ```bash
   cd /path/to/libdivecomputer
   ./build_ios.sh
   ```

2. **Add to Xcode Project**
   - Drag `build-ios/LibDiveComputer.xcframework` into your Xcode project
   - Ensure "Copy items if needed" is checked
   - Add to your target's "Frameworks, Libraries, and Embedded Content"

### Option 3: Direct Source Integration

1. **Copy Required Files**
   - Copy the `src` and `include` directories to your project
   - Add all `.c` files from `src` to your target (excluding Windows-specific files)
   - Add `include` to your header search paths

## Usage in Swift

### Basic Setup

```swift
import LibDiveComputer

// Initialize the library
do {
    // Create a context
    let context = try LibDiveComputer.Context()
    context.setLogLevel(.info)
    
    // Get library version
    let version = LibDiveComputer.shared.version
    print("LibDiveComputer version: \(version)")
    
    // List available dive computers
    let descriptors = try LibDiveComputer.DescriptorIterator()
    for descriptor in descriptors {
        print("Found: \(descriptor.vendor) - \(descriptor.product)")
    }
} catch {
    print("Error: \(error)")
}
```

### Connecting to a Device

```swift
// Connect to a specific dive computer
do {
    let context = try LibDiveComputer.Context()
    let descriptors = try LibDiveComputer.DescriptorIterator()
    
    // Find your device
    if let descriptor = descriptors.first(where: { $0.vendor == "Suunto" }) {
        let device = try LibDiveComputer.Device(context: context, descriptor: descriptor)
        // Use the device...
    }
} catch {
    print("Connection error: \(error)")
}
```

### Using C API Directly

For advanced usage, you can access the raw C API:

```swift
import CLibDiveComputer

// Direct C API usage
var context: OpaquePointer?
let status = dc_context_new(&context)
if status == DC_STATUS_SUCCESS {
    // Use context...
    dc_context_free(context)
}
```

## iOS-Specific Considerations

### Bluetooth Permissions

Add to your `Info.plist`:
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app needs Bluetooth to communicate with dive computers</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app needs Bluetooth to communicate with dive computers</string>
```

### USB Support

iOS doesn't support direct USB access. You'll need:
- MFi certification for USB accessories
- Or use Bluetooth/BLE enabled dive computers

### Background Processing

For long-running downloads:
```swift
// Request background time
var backgroundTask: UIBackgroundTaskIdentifier = .invalid

backgroundTask = UIApplication.shared.beginBackgroundTask {
    // Clean up
    UIApplication.shared.endBackgroundTask(backgroundTask)
    backgroundTask = .invalid
}

// Perform dive computer operations...

// End background task when done
UIApplication.shared.endBackgroundTask(backgroundTask)
```

## Transport Support on iOS

| Transport | iOS Support | Notes |
|-----------|------------|-------|
| Serial (USB) | ❌ | Requires MFi certification |
| Bluetooth Classic | ✅ | Requires MFi for some devices |
| Bluetooth LE | ✅ | Fully supported |
| IrDA | ❌ | Not available on iOS |
| USB HID | ❌ | Not available on iOS |

## Example iOS App Structure

```
YourDiveApp/
├── Models/
│   ├── DiveComputer.swift
│   └── DiveData.swift
├── Services/
│   ├── DiveComputerService.swift
│   └── BluetoothManager.swift
├── Views/
│   ├── DeviceListView.swift
│   └── DiveDetailView.swift
└── YourDiveApp.swift
```

### Sample Service Implementation

```swift
import LibDiveComputer
import CoreBluetooth

class DiveComputerService: ObservableObject {
    @Published var devices: [DiveComputerDevice] = []
    @Published var isScanning = false
    
    private var context: LibDiveComputer.Context?
    
    init() {
        setupContext()
    }
    
    private func setupContext() {
        do {
            context = try LibDiveComputer.Context()
            context?.setLogLevel(.debug)
        } catch {
            print("Failed to create context: \(error)")
        }
    }
    
    func scanForDevices() {
        isScanning = true
        devices.removeAll()
        
        Task {
            do {
                let descriptors = try LibDiveComputer.DescriptorIterator()
                for descriptor in descriptors {
                    let device = DiveComputerDevice(
                        vendor: descriptor.vendor,
                        product: descriptor.product,
                        descriptor: descriptor
                    )
                    await MainActor.run {
                        devices.append(device)
                    }
                }
            } catch {
                print("Scan error: \(error)")
            }
            
            await MainActor.run {
                isScanning = false
            }
        }
    }
}
```

## Troubleshooting

### Common Issues

1. **Build Errors**
   - Ensure Xcode Command Line Tools are installed
   - Check minimum iOS deployment target (iOS 13.0+)

2. **Bluetooth Connection Issues**
   - Verify permissions in Info.plist
   - Check device pairing in iOS Settings

3. **Missing Symbols**
   - Ensure all required source files are included
   - Check preprocessor definitions in Package.swift

### Debug Tips

Enable verbose logging:
```swift
context.setLogLevel(.debug)
```

Check device capabilities:
```swift
let transports = descriptor.transports
if transports & DC_TRANSPORT_BLUETOOTH != 0 {
    print("Device supports Bluetooth")
}
```

## Additional Resources

- [libdivecomputer Documentation](https://www.libdivecomputer.org/)
- [Swift Package Manager Documentation](https://swift.org/package-manager/)
- [Core Bluetooth Framework](https://developer.apple.com/documentation/corebluetooth)