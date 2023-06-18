//
//  RenderHelper.swift
//  
//
//  Created by Tibor Felföldy on 2023-05-26.
//

import MetalKit
import SwiftUI

public enum MetalEffectsErrorType: Error {
    case createDeviceFailed
    case createVertexBufferFailed
    case renderingImageFailed
    case makeTextureFailed
    case makeCommandQueueFailed
    case makeFunctionFailed(String)
}

extension MetalEffectsErrorType: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .createDeviceFailed:
            return "Unable to get system default gpu"
        case .renderingImageFailed:
            return "Rendering image failed"
        case .makeTextureFailed:
            return "Creating texture failed"
        case .makeCommandQueueFailed:
            return "Make command queue failed"
        case .createVertexBufferFailed:
            return "Create vertex buffer failed"
        case let .makeFunctionFailed(name):
            return "Failed to make function: \(name)"
        }
    }
}

final class RenderHelper {
    private static var device: MTLDevice!
    private(set) static var library: MTLLibrary!
    private(set) static var vertexFunction: MTLFunction!
    
    let commandQueue: MTLCommandQueue
    let renderPipeline: RenderPipeline
    
    private(set) var texture: MTLTexture?
    private(set) var size: CGSize?
    
    var device: MTLDevice { RenderHelper.device }
    
    init(parameters: MetalParameters) throws {
        try RenderHelper.setupDevice()
        
        guard let commandQueue = RenderHelper.device.makeCommandQueue() else {
            throw MetalEffectsErrorType.makeCommandQueueFailed
        }
        self.commandQueue = commandQueue
        
        renderPipeline = try .create(device: RenderHelper.device, parameters: parameters)
    }
    
    init(function: MTLFunction) throws {
        try RenderHelper.setupDevice()
        
        guard let commandQueue = RenderHelper.device.makeCommandQueue() else {
            throw MetalEffectsErrorType.makeCommandQueueFailed
        }
        self.commandQueue = commandQueue
        
        renderPipeline = try RenderPipeline(device: RenderHelper.device,
                                            fragmentFunction: function,
                                            textures: [])
    }
    
    static func setupDevice() throws {
        if RenderHelper.device == nil {
            guard let device = MTLCreateSystemDefaultDevice() else {
                throw MetalEffectsErrorType.createDeviceFailed
            }
            RenderHelper.device = device
            RenderHelper.library = try device.makeDefaultLibrary(bundle: .module)
            RenderHelper.vertexFunction = RenderHelper.library.makeFunction(name: "vertex_main")
        }
    }
    
    func updateTexture(from image: CGImage) throws {
        size = CGSize(width: image.width / 3, height: image.height / 3)
        
        // Create texture.
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .rgba8Unorm,
            width: image.width,
            height: image.height,
            mipmapped: false
        )
        
        guard let texture = RenderHelper.device.makeTexture(descriptor: textureDescriptor),
              let cfData: CFData = image.dataProvider?.data else {
            throw MetalEffectsErrorType.makeTextureFailed
        }
        
        // Copy pixel data to the texture.
        let pixelData = CFDataGetBytePtr(cfData)
        
        let region = MTLRegionMake2D(0, 0, image.width, image.height)
        texture.replace(region: region,
                        mipmapLevel: 0,
                        withBytes: pixelData!,
                        bytesPerRow: image.bytesPerRow)
        
        self.texture = texture
    }
}
