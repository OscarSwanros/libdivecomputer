import Foundation
import CLibDiveComputer

/// Swift wrapper for libdivecomputer
public class LibDiveComputer {
    
    /// Shared instance
    public static let shared = LibDiveComputer()
    
    private init() {}
    
    /// Get the libdivecomputer version
    public var version: String {
        let cString = dc_version(nil)
        return String(cString: cString!)
    }
    
    /// Context for libdivecomputer operations
    public class Context {
        private var context: OpaquePointer?
        
        public init() throws {
            var ctx: OpaquePointer?
            let status = dc_context_new(&ctx)
            guard status == DC_STATUS_SUCCESS, let context = ctx else {
                throw DCError.contextCreationFailed
            }
            self.context = context
        }
        
        deinit {
            if let context = context {
                dc_context_free(context)
            }
        }
        
        /// Set the log level
        public func setLogLevel(_ level: LogLevel) {
            dc_context_set_loglevel(context, level.rawValue)
        }
        
        /// Get the raw context pointer for C API usage
        public var rawContext: OpaquePointer? {
            return context
        }
    }
    
    /// Log levels
    public enum LogLevel: dc_loglevel_t.RawValue {
        case none = 0
        case error = 1
        case warning = 2
        case info = 3
        case debug = 4
        case all = 5
    }
    
    /// Error types
    public enum DCError: Error {
        case contextCreationFailed
        case deviceOpenFailed
        case deviceNotFound
        case unsupported
        case invalidArgument
        case memoryError
        case protocolError
        case timeoutError
        case dataError
        case unknownError(dc_status_t)
        
        init(status: dc_status_t) {
            switch status {
            case DC_STATUS_SUCCESS:
                self = .unknownError(status)
            case DC_STATUS_UNSUPPORTED:
                self = .unsupported
            case DC_STATUS_INVALIDARGS:
                self = .invalidArgument
            case DC_STATUS_NOMEMORY:
                self = .memoryError
            case DC_STATUS_NODEVICE:
                self = .deviceNotFound
            case DC_STATUS_NOACCESS:
                self = .deviceOpenFailed
            case DC_STATUS_IO:
                self = .protocolError
            case DC_STATUS_TIMEOUT:
                self = .timeoutError
            case DC_STATUS_PROTOCOL:
                self = .protocolError
            case DC_STATUS_DATAFORMAT:
                self = .dataError
            case DC_STATUS_CANCELLED:
                self = .unknownError(status)
            default:
                self = .unknownError(status)
            }
        }
    }
    
    /// Device descriptor iterator
    public class DescriptorIterator: Sequence {
        private var iterator: OpaquePointer?
        
        public init() throws {
            var iter: OpaquePointer?
            let status = dc_descriptor_iterator_new(&iter)
            guard status == DC_STATUS_SUCCESS, let iterator = iter else {
                throw DCError(status: status)
            }
            self.iterator = iterator
        }
        
        deinit {
            if let iterator = iterator {
                dc_iterator_free(iterator)
            }
        }
        
        public func makeIterator() -> AnyIterator<Descriptor> {
            return AnyIterator {
                var descriptor: OpaquePointer?
                let status = dc_iterator_next(self.iterator, &descriptor)
                
                if status == DC_STATUS_SUCCESS, let desc = descriptor {
                    return Descriptor(descriptor: desc)
                }
                return nil
            }
        }
    }
    
    /// Device descriptor
    public class Descriptor {
        private var descriptor: OpaquePointer
        private var shouldFree: Bool
        
        init(descriptor: OpaquePointer) {
            self.descriptor = descriptor
            self.shouldFree = false
        }
        
        deinit {
            if shouldFree {
                dc_descriptor_free(descriptor)
            }
        }
        
        public var vendor: String {
            let cString = dc_descriptor_get_vendor(descriptor)
            return String(cString: cString!)
        }
        
        public var product: String {
            let cString = dc_descriptor_get_product(descriptor)
            return String(cString: cString!)
        }
        
        public var model: UInt32 {
            return dc_descriptor_get_model(descriptor)
        }
        
        public var transports: UInt32 {
            return dc_descriptor_get_transports(descriptor)
        }
        
        /// Get the raw descriptor pointer for C API usage
        public var rawDescriptor: OpaquePointer {
            return descriptor
        }
    }
    
    /// Device wrapper
    public class Device {
        private var device: OpaquePointer?
        
        public init(context: Context, descriptor: Descriptor) throws {
            var dev: OpaquePointer?
            let status = dc_device_open(&dev, context.rawContext, descriptor.rawDescriptor, nil)
            guard status == DC_STATUS_SUCCESS, let device = dev else {
                throw DCError(status: status)
            }
            self.device = device
        }
        
        deinit {
            if let device = device {
                dc_device_close(device)
            }
        }
        
        /// Get the raw device pointer for C API usage
        public var rawDevice: OpaquePointer? {
            return device
        }
    }
}