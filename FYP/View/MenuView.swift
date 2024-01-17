//
//  ContentView.swift
//  FYP
//
//  Created by Lee Chilvers on 06/01/2024.
//

import SwiftUI

struct MenuView: View {
    let rudiments = Repository().getRudiments()
    
    var body: some View {
        NavigationStack {
            List(rudiments) { rudiment in
                NavigationLink(value: rudiment) {
                    //list item
                    Text(rudiment.name)
                        .foregroundStyle(.primary)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Rudiments")
            .navigationBarTitleDisplayMode(.automatic)
            .navigationDestination(for: Rudiment.self) { rudiment in
                PracticeView(rudiment: rudiment)
            }
        }
    }
}

#Preview {
    MenuView()
}
