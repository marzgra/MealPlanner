//
//  MealPlannerApp.swift
//  MealPlanner
//
//  Created by Grażyna Marzec on 13/06/2025.
//

import SwiftUI

@main
struct MealPlannerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
