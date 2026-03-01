////
////  del.swift
////  isMyHouse
////
////  Created by Денис Кушнаренко on 01.03.2026.
////
//
//func healsСategory(category: Category) -> Int {
//    let filtered = self.objects.filter { $0.category == category}
//    guard !filtered.isEmpty else {
//        return 100
//    }
//    switch self.selectedCalculatonMethod {
//    case .СреднийПроцент:
//        let sum = filtered.reduce(0) { $0 + $1.heals }
//        return sum / filtered.count
//    case .МинимальныйПроцент:
//        return filtered.map { $0.heals }.min() ?? 100
//    }
//}
//
//func healsRoom(room: Room) -> Int {
//    let filtered = self.objects.filter { $0.room == room}
//    guard !filtered.isEmpty else {
//        return 100
//    }
//    switch self.selectedCalculatonMethod {
//    case .СреднийПроцент:
//        let sum = filtered.reduce(0) { $0 + $1.heals }
//        return sum / filtered.count
//    case .МинимальныйПроцент:
//        return filtered.map { $0.heals }.min() ?? 100
//    }
//}
//
//func healsHouse(house: House) -> Int {
//    let filtered = self.objects.filter { $0.house == house}
//    guard !filtered.isEmpty else {
//        return 100
//    }
//    switch self.selectedCalculatonMethod {
//    case .СреднийПроцент:
//        let sum = filtered.reduce(0) { $0 + $1.heals }
//        return sum / filtered.count
//    case .МинимальныйПроцент:
//        return filtered.map { $0.heals }.min() ?? 100
//    }
//}

//        let request = NSFetchRequest<House>(entityName: "House")
//        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
//
//
//        if let results = try? viewContext.fetch(request), let entity = results.first {
//
//            let objectHouseRequest = NSFetchRequest<ObjectHouse>(entityName: "ObjectHouse")
//            objectHouseRequest.predicate = NSPredicate(format: "house == %@", entity as CVarArg)
//
//            if let objectHouseResults = try? viewContext.fetch(objectHouseRequest) {
//                objectHouseResults.forEach { viewContext.delete($0) }
//            }
//
//            let roomRequest = NSFetchRequest<Room>(entityName: "Room")
//            roomRequest.predicate = NSPredicate(format: "room == %@", entity as CVarArg)
//
//            if let roomResults = try? viewContext.fetch(roomRequest) {
//                roomResults.forEach { viewContext.delete($0) }
//            }
//
//            viewContext.delete(entity)
//            saveContext()
