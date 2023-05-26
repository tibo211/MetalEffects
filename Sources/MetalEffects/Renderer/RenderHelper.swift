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
    case renderingImageFailed
    case makeTextureFailed
    case makeCommandQueueFailed
}

extension MetalEffectsErrorType: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .createDeviceFailed:
            return "Unable to get system default gpu."
        case .renderingImageFailed:
            return "Rendering image failed."
        case .makeTextureFailed:
            return "Creating texture failed."
        case .makeCommandQueueFailed:
            return "Make command queue failed."
        }
    }
}

final class RenderHelper {
    private static var device: MTLDevice!
    private static var library: MTLLibrary!
    private static var vertexFunction: MTLFunction!
    
    let commandQueue: MTLCommandQueue
    
    let texture: MTLTexture
    let size: CGSize
    
    var device: MTLDevice { RenderHelper.device }

    @MainActor
    init<Content: View>(content: Content) throws {
        if RenderHelper.device == nil {
            guard let device = MTLCreateSystemDefaultDevice() else {
                throw MetalEffectsErrorType.createDeviceFailed
            }
            RenderHelper.device = device
            RenderHelper.library = try device.makeDefaultLibrary(bundle: .module)
            RenderHelper.vertexFunction = RenderHelper.library.makeFunction(name: "vertex_main")
        }
        
        guard let commandQueue = RenderHelper.device.makeCommandQueue() else {
            throw MetalEffectsErrorType.makeCommandQueueFailed
        }
        
        self.commandQueue = commandQueue

        let renderer = ImageRenderer(content: content)
        renderer.scale = 3
        guard let image = renderer.cgImage else {
            throw MetalEffectsErrorType.renderingImageFailed
        }
        
        size = CGSize(width: image.width / 3, height: image.height / 3)
        
        let texDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .rgba8Unorm,
            width: image.width,
            height: image.height,
            mipmapped: false
        )
        
        guard let texture = RenderHelper.device.makeTexture(descriptor: texDescriptor),
              let cfData: CFData = image.dataProvider?.data else {
            throw MetalEffectsErrorType.makeTextureFailed
        }
        
        let pixelData = CFDataGetBytePtr(cfData)
        
        let region = MTLRegionMake2D(0, 0, image.width, image.height)
        texture.replace(region: region,
                        mipmapLevel: 0,
                        withBytes: pixelData!,
                        bytesPerRow: image.bytesPerRow)
        
        self.texture = texture
    }
}
