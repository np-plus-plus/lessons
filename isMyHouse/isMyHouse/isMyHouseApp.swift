//
//  isMyHouseApp.swift
//  isMyHouse
//
//  Created by Денис Кушнаренко on 01.03.2026.
//

import SwiftUI
import CoreData

@main
struct isMyHouseApp: App {
    var body: some Scene {
        let persistenceController = PersistenceController.shared
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
