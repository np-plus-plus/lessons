//
//  models2.swift
//  isMyHouse
//
//  Created by Денис Кушнаренко on 02.03.2026.
//

import SwiftUI
import Combine

enum CalculatonMethod: String {
    case СреднийПроцент
    case МинимальныйПроцент
}

enum DMode: String {
    case Проценты
    case Даты
}

private func aggregateHeals(from values: [Int], method: CalculatonMethod) -> Int {
    guard !values.isEmpty else { return 0 }
    switch method {
    case .СреднийПроцент:
        let total = values.reduce(0, +)
        return max(0, min(100, total / values.count))
    case .МинимальныйПроцент:
        return max(0, min(100, values.min() ?? 0))
    }
}

class SettingsHouse: ObservableObject {
    static let shared = SettingsHouse()
    
    @Published var selectedCalculatonMethod: CalculatonMethod = .СреднийПроцент {
        didSet {
            UserDefaults.standard.set(selectedCalculatonMethod.rawValue, forKey: "selectedCalculatonMethod")
        }
    }
    @Published var dMode: DMode = .Проценты {
        didSet {
            UserDefaults.standard.set(dMode.rawValue, forKey: "dMode")
        }
    }
    init() {
        if let methodRaw = UserDefaults.standard.string(forKey: "selectedCalculatonMethod"),
           let method = CalculatonMethod(rawValue: methodRaw) {
            self.selectedCalculatonMethod = method
        } else {
            self.selectedCalculatonMethod = .СреднийПроцент
        }
        
        if let modeRaw = UserDefaults.standard.string(forKey: "dMode"),
           let mode = DMode(rawValue: modeRaw) {
            self.dMode = mode
        } else {
            self.dMode = .Проценты
        }
    }
}

struct House: Codable, Identifiable {
    internal var id: UUID = UUID()
    var name: String
    var heals: Int {
        let values = HouseStore.shared.objectsHouse
            .filter { $0.houseId == self.id }
            .map { $0.heals }
        return aggregateHeals(from: values, method: SettingsHouse.shared.selectedCalculatonMethod)
    }
}

struct Room: Codable, Identifiable {
    internal var id: UUID = UUID()
    var name: String
    var houseId: UUID
    var heals: Int {
        let values = HouseStore.shared.objectsHouse
            .filter { $0.roomId == self.id }
            .map { $0.heals }
        return aggregateHeals(from: values, method: SettingsHouse.shared.selectedCalculatonMethod)
    }
}

struct Category: Codable, Identifiable {
    internal var id: UUID = UUID()
    var name: String
    var heals: Int {
        let values = HouseStore.shared.objectsHouse
            .filter { $0.categoryId == self.id }
            .map { $0.heals }
        return aggregateHeals(from: values, method: SettingsHouse.shared.selectedCalculatonMethod)
    }
}

struct ObjectHouse: Codable, Identifiable {
    internal var id: UUID = UUID()
    var name: String
    var houseId: UUID
    var roomId: UUID?
    var categoryId: UUID?
    var startDate: Date
    var endDate: Date
    var heals: Int {
        
        let calendar = Calendar.current
        let start = Calendar.current.startOfDay(for: self.startDate)
        let finish = Calendar.current.startOfDay(for: self.endDate)
        let now = Calendar.current.startOfDay(for: Date())
        
        guard start < finish else { return 0 }
        
        
        let allDay = calendar.dateComponents([.day], from: start, to: finish).day ?? 0
        let passedDay = calendar.dateComponents([.day], from: now, to: finish).day ?? 0
        guard allDay > 0 else { return 0 }
        let value = Int((Float(passedDay) / Float(allDay)) * 100)
        return max(0, min(100, value))
        
    }
}

class HouseStore: ObservableObject {
    static let shared = HouseStore()
    
    private func save<T: Encodable>(_ value: T, forKey key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(value) {
            UserDefaults.standard.set(encoded, forKey: key)
        } else {
            print("Failed to encode \(key)")
        }
    }
    
    private func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(type, from: data)
    }
    
    @Published var houses = [House]() {
        didSet {
            save(houses, forKey: "houses")
        }
    }
    @Published var rooms = [Room]() {
        didSet {
            save(rooms, forKey: "rooms")
        }
    }
    @Published var categories = [Category]() {
        didSet {
            save(categories, forKey: "categories")
        }
    }
    @Published var objectsHouse = [ObjectHouse]() {
        didSet {
            save(objectsHouse, forKey: "objectsHouse")
        }
    }
    
    @Published var selectedHouse: House? = nil {
        didSet {
            save(selectedHouse, forKey: "selectedHouse")
        }
    }
    @Published var selectedRoom: Room?
    @Published var selectedCategory: Category?
    @Published var selectedObject: ObjectHouse?
    
    func addHouse(name: String) {
        if !name.isEmpty {
            let newHouse = House(name: name)
            houses.append(newHouse)
        }
    }
    
    func addRoom(name: String) {
        if !name.isEmpty && selectedHouse != nil {
            let newRoom = Room(name: name, houseId: selectedHouse!.id)
            rooms.append(newRoom)
        }
    }
    
    func addCategory(name: String) {
        if !name.isEmpty {
            let newCategory = Category(name: name)
            categories.append(newCategory)
        }
    }
    
    func addObjectHouse(name: String, startDate: Date, endDate: Date) {
        if !name.isEmpty && startDate < endDate {
            let newObjectHouse = ObjectHouse(name: name, houseId: selectedHouse!.id, roomId: selectedRoom != nil ? selectedRoom!.id : nil, categoryId: selectedCategory != nil ? selectedCategory!.id : nil, startDate: startDate, endDate: endDate)
            objectsHouse.append(newObjectHouse)
            
        }
    }
    
    func editHouse(id: UUID, name: String) {
        if !name.isEmpty {
            let IndexPath = houses.firstIndex(where: { $0.id == id })!
            houses[IndexPath].name = name
        }
    }
    
    func editRoom(id: UUID, name: String) {
        if !name.isEmpty {
            let IndexPath = rooms.firstIndex(where: { $0.id == id })!
            rooms[IndexPath].name = name
        }
    }
    
    func editCategory(id: UUID, name: String) {
        if !name.isEmpty {
            let IndexPath = categories.firstIndex(where: { $0.id == id })!
            categories[IndexPath].name = name
        }
    }
    
    func editObjectHouse(id: UUID, name: String, startDate: Date, endDate: Date) {
        if !name.isEmpty && startDate < endDate {
            let IndexPath = objectsHouse.firstIndex(where: { $0.id == id })!
            objectsHouse[IndexPath].name = name
            objectsHouse[IndexPath].startDate = startDate
            objectsHouse[IndexPath].endDate = endDate
        }
    }
    
    func deleteHouse(id: UUID) {
        rooms.removeAll(where: { $0.houseId == id})
        objectsHouse.removeAll(where: { $0.houseId == id})
        houses.removeAll(where: { $0.id == id})
    }
    
    func deleteRoom(id: UUID) {
        objectsHouse.removeAll(where: { $0.roomId == id})
        rooms.removeAll(where: { $0.id == id})
    }
    
    func deleteCategory(id: UUID) {
        objectsHouse.removeAll(where: { $0.categoryId == id})
        categories.removeAll(where: { $0.id == id})
    }
    
    func deleteObjectHouse(id: UUID) {
        objectsHouse.removeAll(where: { $0.id == id})
    }
    
    
    
    init() {
        if let loaded: [House] = load([House].self, forKey: "houses") { self.houses = loaded }
        if let loaded: [Room] = load([Room].self, forKey: "rooms") { self.rooms = loaded }
        if let loaded: [Category] = load([Category].self, forKey: "categories") { self.categories = loaded }
        if let loaded: [ObjectHouse] = load([ObjectHouse].self, forKey: "objectsHouse") { self.objectsHouse = loaded }
        if let loaded: House? = load(House?.self, forKey: "selectedHouse") { self.selectedHouse = loaded }
    }
}

