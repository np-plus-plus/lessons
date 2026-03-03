import SwiftUI
import Combine

struct SwiftUIView: View {
    @ObservedObject private var settings = SettingsHouse.shared
    @ObservedObject private var storeHouse = HouseStore.shared
    
    var body: some View {
        VStack(spacing: 16) {
            Text("\(settings.selectedCalculatonMethod)")
            Button("переключить1"){
                settings.selectedCalculatonMethod = .МинимальныйПроцент
            }
            Button("переключить2"){
                settings.selectedCalculatonMethod = .СреднийПроцент
            }
            
            Button("Добавить"){
                storeHouse.addHouse(name: "Новая квартира")
            }
            List(storeHouse.houses, id: \.id) { house in
                VStack {
                    Text("\(house.name)")
                    Text("\(house.heals)")
                }
                    .onTapGesture {pGesture in
                        storeHouse.selectedHouse = house
                    }
                    .background(storeHouse.selectedHouse?.id == house.id ? Color.blue : Color.clear)
            }
            
            Button("Добавить"){
                guard storeHouse.selectedHouse != nil else {return}
                let startdate = Date()
                let enddate = Calendar.current.date(byAdding: .day, value: 10, to: startdate)!
                storeHouse.addObjectHouse(name: "Новый объект", startDate: startdate, endDate: enddate)
            }
            Button("Изменить") {
                storeHouse.editHouse(id: storeHouse.selectedHouse!.id, name: "Измененная квартира")
            }
            
            List(storeHouse.objectsHouse, id: \.id) { objectHouse in
                Text("\(objectHouse.heals)")
                Text("\(objectHouse.startDate)")
                Text("\(objectHouse.endDate)")
            }
            
            Text("\(storeHouse.selectedHouse?.name)")
        }
        .padding()
        
        
        
    }
}

#Preview {
    SwiftUIView()
}
