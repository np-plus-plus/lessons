//
//  ContentView.swift
//  TimerMVC
//
//  Created by Денис Кушнаренко on 10.03.2026.
//

//Задание: Приложение "Секундомер"
//Создайте приложение секундомера, которое позволяет пользователю запускать, останавливать и сбрасывать время.
//
//Требования
//Основные функции:
//
//Запуск: Начинает отсчет времени.
//Остановка: Приостанавливает отсчет времени.
//Сброс: Сбрасывает время обратно до нуля.
//Интерфейс:
//
//Отображайте elapsed time в формате MM:SS (минуты:секунды).
//Добавьте кнопку "Старт/Стоп", которая будет переключаться между запуском и остановкой.
//Добавьте кнопку "Сброс", которая сбрасывает время.
//Логика:
//
//Используйте Timer для обновления времени каждую секунду.
//Обработайте состояния запуска, остановки и сброса с помощью перечисления или переменной состояния.
//Дополнительные задания (по желанию):
//
//Позвольте пользователю установить время для обратного отсчета.
//Добавьте возможность сохранения лучших результатов в списке.


import SwiftUI
import Combine

enum TimerState {
    case stopped
    case running
    case paused
}

enum TypeTimer {
    case minus
    case plus
}



class TimerStore: ObservableObject {
    @Published var time: Int = 0
    private var timer: Timer?
    @Published var timerState: TimerState = .stopped
    @Published var typeTimer: TypeTimer = .plus
    
    func editTimer () {
        switch timerState {
        case .paused:
            timer?.invalidate()
            timer = nil
        case .running:
            guard timer == nil else { return }
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                guard let self else { return }
                if typeTimer == .minus {
                    if self.time == 0 {
                        timer?.invalidate()
                        timer = nil
                    }  else {
                        self.time -= 1
                    }
                    
                } else {
                    self.time += 1
                }
            }
        case .stopped:
            timer?.invalidate()
            timer = nil
            time = 0
        }
    }
}

struct TimeView: View {
    @Binding var time: Int
    var body: some View {
        HStack {
            let minuteString = String(format: "%02d", time / 60)
            let secondString = String(format: "%02d", time % 60)
            Text("\(minuteString)")
            Text(":")
            Text("\(secondString)")
        }
    }
}

struct ContentView: View {
    @StateObject private var store = TimerStore()
    
    var body: some View {
        TimeView(time: $store.time)
            .padding()
        HStack {
            Button(action: {
                store.timerState = .running
                store.editTimer()
            }){
                Text("Старт")
            }
            Button(action: {
                store.timerState = .stopped
                store.editTimer()
            }){
                Text("Стоп")
            }
            Button(action: {
                store.timerState = .paused
                store.editTimer()
            }){
                Text("Пауза")
            }
        }
    }


}

#Preview {
    ContentView()
}
