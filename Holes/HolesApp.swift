//
//  HolesApp.swift
//  Holes
//
//  Created by Dylan Elliott on 19/2/2022.
//

import SwiftUI

@main
struct HolesApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationView {
                    InboxView()
                }
                .tabItem { Label("Inbox", systemImage: "envelope") }
                
                NavigationView {
                    HolesView()
                }
                .tabItem { Label("Holes", systemImage: "moon") }
                
                NavigationView {
                    NonHolesView()
                }
                .tabItem { Label("Nons", systemImage: "sun.min.fill") }
                
                NavigationView {
                    NotesView()
                }
                .tabItem { Label("Notes", systemImage: "square.and.pencil") }
            }
        }
    }
}
