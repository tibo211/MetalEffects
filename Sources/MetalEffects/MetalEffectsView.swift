//
//  MetalEffectView.swift
//  
//
//  Created by Tibor Felföldy on 2023-05-26.
//

import SwiftUI

public struct MetalEffectView<Content: View>: View {
    let content: Content

    let helper: RenderHelper?
    
    @MainActor
    public init(_ function: FragmentFunction, @ViewBuilder content: () -> Content) {
        let view = content()
        self.content = view
        do {
            helper = try RenderHelper(content: view, function: function)
        } catch {
            print(error.localizedDescription)
            helper = nil
        }
    }
    
    public var body: some View {
        if let helper {
            MetalView(renderHelper: helper)
                .frame(width: helper.size.width,
                       height: helper.size.height)
        } else {
            content
        }
    }
}

struct MetalEffectsView_Previews: PreviewProvider {
    struct ExampleView: View {
        var body: some View {
            ZStack {
                Rectangle().fill(.blue.gradient)
                
                Text("Rendered in metal")
                    .font(.title.bold())
                    .foregroundColor(.white)
            }
            .frame(width: 200, height: 200)
        }
    }
    
    
    static var previews: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            GridRow {
                MetalEffectView(.water_fragment) {
                    ExampleView()
                }
                
                MetalEffectView(.flame_fragment) {
                    ExampleView()
                }
            }
            GridRow {
                MetalEffectView(.linear_dissolve) {
                    ExampleView()
                }
                
                MetalEffectView(.wave_fragment) {
                    ExampleView()
                }
            }
        }
        
    }
}
