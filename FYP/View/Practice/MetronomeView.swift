//
//  MetronomeView.swift
//  FYP
//
//  Created by Lee Chilvers on 27/02/2024.
//

import SwiftUI

struct MetronomeView: View {
    
    @ObservedObject var metronome: Metronome
    
    var body: some View {
        Text("\(metronome.beat)")
            .font(.system(size: 30.0))
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 2)
            )
    }
}
