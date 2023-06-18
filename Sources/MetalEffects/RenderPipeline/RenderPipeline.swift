//
//  RenderPipeline.swift
//  
//
//  Created by Tibor Felföldy on 2023-05-26.
//

import MetalKit

public enum FragmentFunction: String {
    case default_fragment
    case flame_fragment
    case water_fragment
    case distorted_fade
    case wave_fragment
    case linear_dissolve
    case noise_dissolve
}

struct FragmentParams {
    let time: Float32
}

class RenderPipeline {
    private let pipelineState: MTLRenderPipelineState
    private let vertexBuffer: MTLBuffer
    private let name: String
    private let textures: [MTLTexture]
    var animation: EffectAnimation

    init(device: MTLDevice, fragmentFunction: MTLFunction, textures: [MTLTexture]) throws {
        name = fragmentFunction.name
        
        // Create pipeline state.
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.vertexFunction = RenderHelper.vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineState = try device
            .makeRenderPipelineState(descriptor: pipelineDescriptor)

        vertexBuffer = try device.quadVertexBuffer()
        self.textures = textures
        animation = ContinuousEffectAnimation()
    }
    
    static func create(device: MTLDevice, parameters: EffectParameters) throws -> RenderPipeline {
        let library = parameters.library ?? RenderHelper.library
        guard let fragmentFunction = library!.makeFunction(name: parameters.function) else {
            throw MetalEffectsErrorType.makeFunctionFailed(parameters.function)
        }
        
        return try RenderPipeline(device: device, fragmentFunction: fragmentFunction, textures: parameters.textures)
    }
    
    func encode(with encoder: MTLRenderCommandEncoder, texture: MTLTexture?) {
        encoder.pushDebugGroup(name)
        encoder.setRenderPipelineState(pipelineState)
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        // Set textures for fragment shader.
        var textureIndex = 0
        if let texture {
            encoder.setFragmentTexture(texture, index: textureIndex)
            textureIndex += 1
        }
        for texture in textures {
            encoder.setFragmentTexture(texture, index: textureIndex)
            textureIndex += 1
        }
        
        // Set fragment shader parameters.
        var params = FragmentParams(time: animation.time)
        encoder.setFragmentBytes(&params, length: MemoryLayout<FragmentParams>.stride, index: 0)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        encoder.popDebugGroup()
    }
}
