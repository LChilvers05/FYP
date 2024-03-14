//
//  ContentView.swift
//  FYPWatch Watch App
//
//  Created by Lee Chilvers on 07/01/2024.
//

import SwiftUI

struct WatchPracticeView: View {
    
    @StateObject var viewModel = WatchPracticeViewModel()
    
    var body: some View {
        VStack {
            if viewModel.isStreamingMovement {
                Text("Playing")
            } else {
                Text("Start on iPhone")
            }
        }
        .padding()
    }
}

#Preview {
    WatchPracticeView()
}
