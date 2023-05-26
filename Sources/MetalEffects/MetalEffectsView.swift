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
    public init(@ViewBuilder content: () -> Content) {
        let view = content()
        self.content = view
        do {
            helper = try RenderHelper(content: view)
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
    static var previews: some View {
        MetalEffectView {
            ZStack {
                Rectangle().fill(.blue.gradient)
                
                Text("Rendered in metal")
                    .font(.title.bold())
                    .foregroundColor(.white)
                    .padding()
                    .cornerRadius(12)
            }
            .frame(width: 400, height: 300)
        }
    }
}
