//
//  MetalHelper.swift
//  
//
//  Created by Tibor Felföldy on 2023-05-26.
//

import MetalKit

public enum MetalEffectsErrorType: Error {
    case createDeviceFailed
}

extension MetalEffectsErrorType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .createDeviceFailed:
            return "Unable to get system default gpu"
        }
    }
}

final class MetalHelper {
    let device: MTLDevice
    let library: MTLLibrary
    
    let vertexFunction: MTLFunction
    
    init() throws {
        guard let device = MTLCreateSystemDefaultDevice() else {
            throw MetalEffectsErrorType.createDeviceFailed
        }
        
        self.device = device
        library = try device.makeDefaultLibrary(bundle: .module)
        
        vertexFunction = library
            .makeFunction(name: "vertex_main")!
    }
}
