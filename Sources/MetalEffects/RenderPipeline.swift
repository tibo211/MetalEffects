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
}

struct FragmentParams {
    let time: Float32
}

class RenderPipeline {
    let name: String
    let pipelineState: MTLRenderPipelineState
    let vertexBuffer: MTLBuffer
    
    let initialTime = CFAbsoluteTimeGetCurrent()
    
    init(device: MTLDevice, pipelineState: MTLRenderPipelineState, name: String) {
        self.name = name
        self.pipelineState = pipelineState

        let vertices: [vector_float2] = [
            [-1, -1],
            [1, -1],
            [1, 1],
            
            [-1, -1],
            [1, 1],
            [-1, 1]
        ]
        
        vertexBuffer = device
            .makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<vector_float2>.stride)!
    }
    
    static func create(device: MTLDevice, library: MTLLibrary! = RenderHelper.library, function: FragmentFunction) throws -> RenderPipeline {
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.vertexFunction = RenderHelper.vertexFunction
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: function.rawValue)
        
        let state = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        return RenderPipeline(device: device, pipelineState: state, name: function.rawValue)
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
