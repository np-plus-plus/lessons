//
//  ContentView.swift
//  Food
//
//  Created by Денис Кушнаренко on 10.02.2026.
//

import SwiftUI
import Combine

struct Food: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var price: Double
}

class FoodStore: ObservableObject {
    @Published var foods: [Food:Int] = [:]
    
    var PriceFood : [Food] = []
    var totalPrice: Double {
        foods.reduce(0) { $0 + Double($1.value) * $1.key.price }
    }
    
    init() {
        loadFoods()
    }
    
    func loadFoods() {
        PriceFood.append(Food(name: "Котлета", price: 100))
        PriceFood.append(Food(name: "Запеченная курица", price: 150))
        PriceFood.append(Food(name: "Чизкейк", price: 120))
        PriceFood.append(Food(name: "Пицца", price: 180))
    }
    
}


struct ContentView: View {
    @ObservedObject var store = FoodStore()
    
    var body: some View {
        VStack {
            List(store.PriceFood, id: \.id) { food in
                HStack {
                    Text(food.name)
                    Spacer()
                    Text("\(food.price) ₽")
                    Button(action: {
                        self.store.foods[food, default: 0] += 1
                    }) {
                        Text("+")
                    }
                }
            }
            Text("Итого \(store.totalPrice, specifier: "%.2f") ₽")
            List(Array(store.foods), id: \.key.id) { pair in
                Text("\(pair.0.name): \(pair.1)")
            }
            
        }
    }
}

#Preview {
    ContentView()
}

