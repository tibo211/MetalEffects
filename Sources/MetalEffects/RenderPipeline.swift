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
}

struct FragmentParams {
    let time: Float32
}

class RenderPipeline {
    private let pipelineState: MTLRenderPipelineState
    private let vertexBuffer: MTLBuffer
    private let initialTime = CFAbsoluteTimeGetCurrent()
    private let name: String

    init(device: MTLDevice, fragmentFunction: MTLFunction) throws {
        name = fragmentFunction.name
        
        // Create pipeline state.
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.vertexFunction = RenderHelper.vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        
        pipelineState = try device
            .makeRenderPipelineState(descriptor: pipelineDescriptor)

        vertexBuffer = try device.quadVertexBuffer()
    }
    
    static func create(device: MTLDevice, library: MTLLibrary! = RenderHelper.library, function: FragmentFunction) throws -> RenderPipeline {
        
        guard let fragmentFunction = library.makeFunction(name: function.rawValue) else {
            throw MetalEffectsErrorType.makeFunctionFailed(function.rawValue)
        }
        
        return try RenderPipeline(device: device, fragmentFunction: fragmentFunction)
    }
    
    func encode(with encoder: MTLRenderCommandEncoder, texture: MTLTexture) {
        encoder.pushDebugGroup(name)
        encoder.setRenderPipelineState(pipelineState)
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.setFragmentTexture(texture, index: 0)
        
        var params = FragmentParams(time: Float(CFAbsoluteTimeGetCurrent() - initialTime))
        
        encoder.setFragmentBytes(&params, length: MemoryLayout<FragmentParams>.stride, index: 0)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        encoder.popDebugGroup()
    }
}
