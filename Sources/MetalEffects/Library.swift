//
//  Library.swift
//  
//
//  Created by Tibor Felföldy on 2023-06-18.
//

import Foundation
import Metal

enum FunctionName: String {
    case noise_dissolve
    case linear_dissolve
}

final class Library {
    static let standard = Library()
    
    private let library: MTLLibrary?
    private var cache: [FunctionName: MTLFunction] = [:]
    
    init() {
        do {
            try RenderHelper.setupDevice()
            library = RenderHelper.library
        } catch {
            print(error.localizedDescription)
            library = nil
        }
    }
    
    static func load(function name: FunctionName) -> MTLFunction? {
        if let function = standard.cache[name] {
            return function
        }
        do {
            guard let function = standard.library?.makeFunction(name: name.rawValue) else {
                throw MetalEffectsErrorType.makeFunctionFailed(name.rawValue)
            }
            standard.cache[name] = function
            return function
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
