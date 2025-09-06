//
//  RootTabView.swift
//  canva
//
//  Created by Jerry Jin on 7/9/2025.
//

import Foundation
import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            NavigationView { ContentView() }
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            NavigationView { AddMedicineView() }
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Add")
                }
        }
        // Optional: iOS 15 compact tab style
        .accentColor(.ochre)
    }
}
