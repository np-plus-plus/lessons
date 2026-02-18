//
//  ContentView.swift
//  TimerAssync
//
//  Created by Денис Кушнаренко on 16.02.2026.
//

import SwiftUI
import Combine

class TimerStore: ObservableObject {
    @Published var second: Int = 0
    @Published var isRunning: Bool = false
    @Published var errorMessage: String = ""
    
    func Reset() {
        second = 0
        isRunning = false
    }
    
    func Stop() {
        isRunning = false
    }
    
    func Start() {
        isRunning = true
        Task {
            await timer()
        }
    }
    
 
    func timer() async {
            while isRunning && !Task.isCancelled {
                do {
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                   
                        await MainActor.run {
                            self.second += 1

             
                        
                    }
                } catch {
                    await MainActor.run {
                        errorMessage = "Ошибка: \(error.localizedDescription)"
                    }
                    break
                }
            }
        }

    }
    

struct ContentView: View {
    @ObservedObject var timerStore = TimerStore()
    
    var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter
    }
    
    
    var body: some View {
        TextField("Введите число", value: $timerStore.second, formatter: formatter)
            .textFieldStyle(RoundedBorderTextFieldStyle())
        Text("\(timerStore.second)")
        Text(timerStore.errorMessage)
        HStack{
            Button("Старт"){
                timerStore.Start()
            }
            Button("Стоп"){
                timerStore.Stop()
            }
            Button("Сброс"){
                timerStore.Reset()
            }
        }
    }
}

#Preview {
    ContentView()
}
