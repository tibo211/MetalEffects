//
//  DissolveModifier.swift
//  
//
//  Created by Tibor Felföldy on 2023-05-29.
//

import SwiftUI

extension View {
    func dissolve() -> some View {
        MetalEffectView(.linear_dissolve) {
            self
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        Text("text\nto\ndissolve")
            .multilineTextAlignment(.center)
            .font(.largeTitle.bold())
            .foregroundColor(.white)
            .padding()
            .dissolve()
            .background(.black)
    }
}
