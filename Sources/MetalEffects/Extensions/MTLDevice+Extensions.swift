//
//  MTLDevice+Extensions.swift
//  
//
//  Created by Tibor Felföldy on 2023-05-29.
//

import Metal
import simd

extension MTLDevice {
    func quadVertexBuffer() throws -> MTLBuffer {
        let vertices: [vector_float2] = [
            // Top left triangle.
            [-1, -1],
            [1, 1],
            [-1, 1],
            // Bottom right triangle.
            [-1, -1],
            [1, -1],
            [1, 1]
        ]
        
        let length = vertices.count * MemoryLayout<vector_float2>.stride
        let buffer = makeBuffer(bytes: vertices, length: length)
        
        guard let buffer else {
            throw MetalEffectsErrorType.createVertexBufferFailed
        }
        return buffer
    }
}
