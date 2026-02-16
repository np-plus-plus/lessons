//
//  ContentView.swift
//  ShoppingList
//
//  Created by Денис Кушнаренко on 16.02.2026.
//

import SwiftUI
import Combine

class Store: ObservableObject {
    @Published var items: [String:Bool] = [:]
    
    var total: Int {
        return items.count
    }
    
    var totalPurchased: Int {
        return items.values.filter(\.self).count
    }
    
    func changePurchase(forKey key: String) {
        if let current = items[key] {
            items[key] = !current
        }
    }
    
    func addItem(_ item: String) {
        items[item] = false
    }
    
    func removeItem(_ key: String) {
        items.removeValue(forKey: key)
    }
}

struct ContentView: View {
    @StateObject private var store = Store()
    @State private var showAddAlert = false
    @State private var newProductName = ""
    
    var body: some View {
        NavigationView {
            VStack{
                if store.total == 0 {
                    Text("Список пуст")
                        .font(.headline)
                }else{
                    List {
                        ForEach(store.items.keys.sorted(), id: \.self) { name in
                            HStack {
                                Image(systemName: store.items[name]! ? "checkmark.square" : "square")
                                Text(name)
                            }
                            .onTapGesture {
                                store.changePurchase(forKey: name)
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                    Spacer()
                    Text("Куплено продуктов: \(store.totalPurchased) из \(store.total)")
                    
                }
                
            }
            .navigationTitle("Список покупок")
            .toolbar {
                Button(action: {
                    showAddAlert = true
                }) {
                    Text("Добавить")
                }
            }
            .alert("Добавить продукт", isPresented: $showAddAlert, actions: {
                TextField("Название продукта", text: $newProductName)
                Button("Отмена", role: .cancel, action: {
                    newProductName = ""
                })
                Button("Добавить", action: {
                    if !newProductName.isEmpty {
                        store.addItem(newProductName)
                        newProductName = ""
                    }
                })
               
            })
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        let sortedKeys = store.items.keys.sorted()
        for index in offsets {
            let key = sortedKeys[index]
            store.removeItem(key)
        }
    }
}

#Preview {
    ContentView()
}
