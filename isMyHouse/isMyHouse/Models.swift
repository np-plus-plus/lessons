////
////  Models.swift
////  isMyHouse
////
////  Created by Денис Кушнаренко on 01.03.2026.
////
//import CoreData
//import Combine
//import SwiftUI
//
//
//extension ObjectHouse {
//    
//    var heals: Int {
//        guard let start = self.startDate, let finish = self.finishedDate, start < finish else {
//            return 100
//        }
//        let calendar = Calendar.current
//        let allDay = calendar.dateComponents([.day], from: start, to: finish).day ?? 0
//        let passedDay = calendar.dateComponents([.day], from: start, to: Date()).day ?? 0
//        guard allDay > 0 else { return 100 }
//        let value = Int((Float(passedDay) / Float(allDay)) * 100)
//        return max(0, min(100, value))
//    }
//}
//
//extension Category {
//    func heals(in context: NSManagedObjectContext) -> Int {
//        var selectedCalculatonMethod = "СреднийПроцент"
//        
//        let settingsRequest: NSFetchRequest<Settings> = Settings.fetchRequest()
//        if let settings = try? context.fetch(settingsRequest).first {
//            if settings.selectedCalculatonMethod == "МинимальныйПроцент" {
//                selectedCalculatonMethod = "МинимальныйПроцент"
//            }
//        }
//        
//        let objectHouseRequest = NSFetchRequest<ObjectHouse>(entityName: "ObjectHouse")
//        objectHouseRequest.predicate = NSPredicate(format: "category == %@", self)
//        if let objectHouseResults = try? context.fetch(objectHouseRequest), !objectHouseResults.isEmpty {
//            if selectedCalculatonMethod == "МинимальныйПроцент" {
//                return objectHouseResults.map { $0.heals }.min() ?? 100
//            }else{
//                let sum = objectHouseResults.reduce(0) { $0 + $1.heals }
//                return sum / objectHouseResults.count
//            }
//        } else {
//            return 100
//        }
//    }
//}
//
//extension Room {
//    func heals(in context: NSManagedObjectContext) -> Int {
//        
//        var selectedCalculatonMethod = "СреднийПроцент"
//        
//        let settingsRequest: NSFetchRequest<Settings> = Settings.fetchRequest()
//        if let settings = try? context.fetch(settingsRequest).first {
//            if settings.selectedCalculatonMethod == "МинимальныйПроцент" {
//                selectedCalculatonMethod = "МинимальныйПроцент"
//            }
//        }
//        
//        
//        
//        let objectHouseRequest = NSFetchRequest<ObjectHouse>(entityName: "ObjectHouse")
//        objectHouseRequest.predicate = NSPredicate(format: "room == %@", self)
//        if let objectHouseResults = try? context.fetch(objectHouseRequest), !objectHouseResults.isEmpty {
//            if selectedCalculatonMethod == "МинимальныйПроцент" {
//                return objectHouseResults.map { $0.heals }.min() ?? 100
//            }else{
//                let sum = objectHouseResults.reduce(0) { $0 + $1.heals }
//                return sum / objectHouseResults.count
//            }
//        } else {
//            return 100
//        }
//    }
//}
//
//extension House {
//    func heals(in context: NSManagedObjectContext) -> Int {
//        var selectedCalculatonMethod = "СреднийПроцент"
//        
//        let settingsRequest: NSFetchRequest<Settings> = Settings.fetchRequest()
//        if let settings = try? context.fetch(settingsRequest).first {
//            if settings.selectedCalculatonMethod == "МинимальныйПроцент" {
//                selectedCalculatonMethod = "МинимальныйПроцент"
//            }
//        }
//        
//        let objectHouseRequest = NSFetchRequest<ObjectHouse>(entityName: "ObjectHouse")
//        objectHouseRequest.predicate = NSPredicate(format: "house == %@", self)
//        if let objectHouseResults = try? context.fetch(objectHouseRequest), !objectHouseResults.isEmpty {
//            if selectedCalculatonMethod == "МинимальныйПроцент" {
//                return objectHouseResults.map { $0.heals }.min() ?? 100
//            }else{
//                let sum = objectHouseResults.reduce(0) { $0 + $1.heals }
//                return sum / objectHouseResults.count
//            }
//        } else {
//            return 100
//        }
//    }
//}
//
//enum CalculatonMethod: String, Codable {
//    case СреднийПроцент
//    case МинимальныйПроцент
//}
//
//enum DMode: String, Codable {
//    case Проценты
//    case Даты
//}
//
//class Store: ObservableObject {
//    private(set) var viewContext: NSManagedObjectContext
//    
//    @Published var selectedHouse: House?
//    @Published var selectedRoom: Room?
//    @Published var selectedObject: ObjectHouse?
//    @Published var selectedCategory: Category?
//    
////    @Published var selectedCalculatonMethod: CalculatonMethod = .СреднийПроцент
////    @Published var dMode: DMode = .Проценты
//    
//    @Published private(set) var houses: [House] = []
//    @Published private(set) var rooms: [Room] = []
//    @Published private(set) var objects: [ObjectHouse] = []
//    @Published private(set) var categories: [Category] = []
//    @Published private(set) var settings: [Settings] = []
//    
//    init(viewContext: NSManagedObjectContext) {
//        self.viewContext = viewContext
//    }
//    
//    func updateContext(_ context: NSManagedObjectContext) {
//        self.viewContext = context
//    }
//    
//    func reloadAll() {
//        let houseRequest: NSFetchRequest<House> = House.fetchRequest()
//        houses = (try? viewContext.fetch(houseRequest)) ?? []
//        
//        let roomRequest: NSFetchRequest<Room> = Room.fetchRequest()
//        rooms = (try? viewContext.fetch(roomRequest)) ?? []
//        
//        let objectRequest: NSFetchRequest<ObjectHouse> = ObjectHouse.fetchRequest()
//        objects = (try? viewContext.fetch(objectRequest)) ?? []
//        
//        let categoryRequest: NSFetchRequest<Category> = Category.fetchRequest()
//        categories = (try? viewContext.fetch(categoryRequest)) ?? []
//        
//        let settingsRequest: NSFetchRequest<Settings> = Settings.fetchRequest()
//        settings = (try? viewContext.fetch(settingsRequest)) ?? []
//    }
//    
//    func addHouse(name: String, desc: String) {
//        let entity = House(context: viewContext)
//        entity.id = UUID()
//        entity.name = name
//        entity.desc = desc
//        saveContext()
//    }
//    
//    func deleteHouse(id: UUID) {
//        if let entity = houses.filter({ $0.id == id}).first {
//            
//            let objectsfilter = objects.filter { $0.house == entity }
//            objectsfilter.forEach { viewContext.delete($0) }
//            
//            let roomsfilter = rooms.filter { $0.house == entity }
//            roomsfilter.forEach { viewContext.delete($0) }
//            
//            viewContext.delete(entity)
//            saveContext()
//            
//        }
//    }
//    
//    func addRoom(name: String, desc: String) {
//        let entity = Room(context: viewContext)
//        entity.id = UUID()
//        entity.name = name
//        entity.desc = desc
//        entity.house = selectedHouse
//        
//        saveContext()
//    }
//    
//    func deleteRoom(id: UUID) {
//        if let entity = rooms.filter({ $0.id == id}).first {
//            
//            let objectsfilter = objects.filter { $0.room == entity }
//            objectsfilter.forEach { viewContext.delete($0) }
//            
//            viewContext.delete(entity)
//            saveContext()
//        }
//    }
//    
//    func addCategory(name: String) {
//        let entity = Category(context: viewContext)
//        entity.id = UUID()
//        entity.name = name
//        saveContext()
//    }
//    
//    
//    func deleteCategory(id: UUID) {
//        if let entity = categories.filter({ $0.id == id}).first {
//            
//            let objectsfilter = objects.filter { $0.category == entity }
//            objectsfilter.forEach { viewContext.delete($0) }
//            
//            viewContext.delete(entity)
//            saveContext()
//        }
//        
//    }
//    
//    func addObject(name: String, desc: String, startDate: Date, finishedDate: Date) {
//        guard let selectedHouse = selectedHouse
//              //let selectedRoom = selectedRoom,
//              //let selectedCategory = selectedCategory
//        else { return }
//        
//        let entity = ObjectHouse(context: viewContext)
//        entity.id = UUID()
//        entity.name = name
//        entity.desc = desc
//        entity.startDate = startDate
//        entity.finishedDate = finishedDate
//        entity.house = selectedHouse
//        entity.room = selectedRoom
//        entity.category = selectedCategory
//        
//        saveContext()
//    }
//    
//    func deleteObject(id: UUID) {
//        if let entity = objects.filter({ $0.id == id}).first {
//            
//            viewContext.delete(entity)
//            saveContext()
//        }
//        
//    }
//    
//    
//    private func saveContext() {
//        if viewContext.hasChanges {
//            try? viewContext.save()
//            reloadAll()
//        }
//    }
//    
//}
//
