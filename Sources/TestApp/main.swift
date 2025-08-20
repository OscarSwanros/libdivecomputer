import Foundation
import LibDiveComputer

do {
    // Test the basic functionality
    let context = try LibDiveComputer.Context()
    print("✓ Context created successfully")
    
    context.setLogLevel(.info)
    print("✓ Log level set to info")
    
    // Get version
    let version = LibDiveComputer.shared.version
    print("✓ LibDiveComputer version: \(version)")
    
    // Test descriptor iterator
    let descriptors = try LibDiveComputer.DescriptorIterator()
    print("✓ Descriptor iterator created successfully")
    
    var count = 0
    for descriptor in descriptors {
        print("✓ Found device: \(descriptor.vendor) - \(descriptor.product)")
        count += 1
        if count >= 5 { break } // Just show first 5
    }
    
    print("✓ All tests passed!")
    
} catch {
    print("✗ Error: \(error)")
}