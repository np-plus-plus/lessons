//
//  ContentView.swift
//  TimerCombine
//
//  Created by Денис Кушнаренко on 13.02.2026.
//

import SwiftUI
import Combine
import AVFoundation

class TimerStore: ObservableObject {
    @Published var time: Int = 0
    private var timer: Timer?
    var isPaused: Bool = false
    private var audioPlayer: AVAudioPlayer?
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            if self.time > 0 {
                self.time -= 1
            } else {
                self.timer?.invalidate()
                startMusic()
                sendTestNotification()
            }
        })
    }
    
    func pauseTimer() {
        timer?.invalidate()
    }
    
    func stopTimer() {
        timer?.invalidate()
        time = 0
    }
    
    private func startMusic() {
        stopMusic()
        
        
        do {
            guard let url = Bundle.main.url(forResource: "фа", withExtension: "mp3") else {
                print("Файл фа.mp3 не найден")
                return
            }
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = 0
            
            audioPlayer?.play()
            
        } catch {
            print("Ошибка при воспроизведении музыки: \(error.localizedDescription)")
        }
    }
    
    private func stopMusic() {
        audioPlayer?.stop()
        audioPlayer = nil
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Ошибка при деактивации аудиосессии: \(error)")
        }
    }
    
    private func sendTestNotification() {
            let content = UNMutableNotificationContent()
            content.title = "Таймер"
            content.body = "Отсчет закончен"
    
           
            content.sound = .default
           
    
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "testNotification", content: content, trigger: trigger)
    
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error sending test notification: \(error)")
                }
            }
        }

        
}

struct ContentView: View {
    @ObservedObject var timerStore = TimerStore()
    @State private var input: String = ""
    
    
    var body: some View {
     
        HStack{
            TextField("Enter time", text: $input)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Старт") {
                timerStore.time = Int(input) ?? 0
                timerStore.startTimer()
            }
        }
        Text("\(timerStore.time)")
        HStack{
            Button("Пауза") {
                if !timerStore.isPaused {
                    timerStore.pauseTimer()
                    timerStore.isPaused = true
                }else {
                    timerStore.startTimer()
                    timerStore.isPaused = false
                }
                
            }
            Button("Стоп") {
                timerStore.stopTimer()
            }
        }
    }
    
   
    
    
    
}

#Preview {
    ContentView()
}
