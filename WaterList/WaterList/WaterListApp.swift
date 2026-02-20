//
//  WaterListApp.swift
//  WaterList
//
//  Created by Денис Кушнаренко on 20.02.2026.
//

import SwiftUI
import CoreData

@main
struct WaterListApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
