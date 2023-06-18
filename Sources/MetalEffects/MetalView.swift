//
//  MetalView.swift
//  
//
//  Created by Tibor Felföldy on 2023-06-18.
//

import SwiftUI

public struct MetalView: View {
    let renderHelper: RenderHelper?
    
    public init(function: MTLFunction) {
        do {
            renderHelper = try RenderHelper(function: function)
        } catch {
            print(error.localizedDescription)
            renderHelper = nil
        }
    }
    
    public var body: some View {
        if let renderHelper {
            MetalViewRepresentable(renderHelper: renderHelper)
        }
    }
}


struct MetalView_Previews: PreviewProvider {
    struct PreviewView: View {
        var function: MTLFunction! {
            try! RenderHelper.setupDevice()
            return RenderHelper.library.makeFunction(name: "water_fragment")
        }
        
        var body: some View {
            if let function {
                MetalView(function: function)
                    .background(.blue)
                    .frame(width: 200, height: 200)
            }
        }
    }
    
    static var previews: some View {
        PreviewView()
    }
}
