//
//  ContentView.swift
//  accel
//
//  Created by Денис Кушнаренко on 02.03.2026.
//

import SwiftUI
import CoreMotion


func handleAccelerometerData(_ data: CMAccelerometerData) {
    let x = data.acceleration.x
    let y = data.acceleration.y
    let z = data.acceleration.z
    print("Acceleration: x: \(x), y: \(y), z: \(z)")
}

func startAccelerometerStream() -> AsyncStream<CMAccelerometerData> {
    let motionManager = CMMotionManager()
    
    return AsyncStream<CMAccelerometerData> { continuation in
        guard motionManager.isAccelerometerAvailable else {
            continuation.finish()
            return
        }
        
        motionManager.accelerometerUpdateInterval = 0.1
        continuation.onTermination = { _ in
            motionManager.stopAccelerometerUpdates()
        }
        
        motionManager.startAccelerometerUpdates(to: .main) { data, error in
            if let error = error {
                print("Error receiving accelerometer data: \(error.localizedDescription)")
                motionManager.stopAccelerometerUpdates()
                continuation.finish()
                return
            }
            
            if let data = data {
                continuation.yield(data)
            }
        }
    }
}



//private func analyzeMotion(accelerometerData: CMAccelerometerData, gyroData: CMGyroData?) {
//    
//
//    
//    let acceleration = accelerometerData.acceleration
//    let rotationRate = gyroData?.rotationRate ?? CMRotationRate()
//
//    let walkingThreshold: Double = 0.5
//    let runningThreshold: Double = 1.0
//    let liftingThreshold: Double = 2.0
//    
//    if abs(acceleration.x) > liftingThreshold || abs(acceleration.y) > liftingThreshold {
//        currentExercise = "Подъем тяжестей"
//        repetitions += 1
//        duration += 1
//    } else if abs(acceleration.x) > runningThreshold {
//        currentExercise = "Бег"
//        duration += 1
//    } else if abs(acceleration.x) > walkingThreshold {
//        currentExercise = "Ходьба"
//        duration += 1
//    } else {
//        currentExercise = "Отсутствует"
//    }
//
//    print("Текущая активность: \(currentExercise)")
//    print("Повторы: \(repetitions)")
//    print("Время выполнения: \(duration) секунд")
//}

private func startGyroscopeUpdates() {
    
    let motionManager = CMMotionManager()
    
        if motionManager.isGyroAvailable {
            motionManager.gyroUpdateInterval = 0.1
            motionManager.startGyroUpdates(to: .main) { (data, error) in
                if let data = data {
                   // self.analyzeMotion(data: data)
                }
            }
        }
    }

enum Activity {
        case sitting
        case walking
        case running
    }

struct ActivityStore: Identifiable {
    var id: UUID = UUID()
    var name: Activity
    var timelocal: Int
}

struct Log: Identifiable {
    var id: UUID = UUID()
    var value: Double
}

struct ContentView: View {
    @State private var acceleration: (x: Double, y: Double, z: Double) = (0, 0, 0)
    @State private var m: Double = 0
    @State private var activity: Activity = .sitting
    @State private var isRunning: Bool = false
    @State private var storedActivities: [ActivityStore] = []
    @State private var task: Task<Void, Never>? = nil
    @State private var lastTick: Date? = nil
    @State private var log: [Log] = []
    @State private var LastY: Double = 0

    var body: some View {
        VStack() {
            Picker("Activity", selection: $activity) {
                Text("Sitting").tag(Activity.sitting)
                Text("Walking").tag(Activity.walking)
                Text("Running").tag(Activity.running)
            }
            
            Button(action: {
                isRunning.toggle()
                StartActivity()
            }) {
                Text(isRunning ? "Stop" : "Start")
            }
            
            Text("Количество повторений: \(sumLog(log: log))")
            
//            List {
//                ForEach(log) { item in
//                    HStack {
//                        Text("\(item.value)")
////                        Spacer()
////                        let minutes = item.timelocal / 60
////                        let seconds = item.timelocal % 60
////                        Text(String(format: "%02dm %02ds", minutes, seconds))
//                    }
//                }
//            }
            
            Spacer()

            Text("Acceleration: x: \(acceleration.x, specifier: "%.2f"), y: \(acceleration.y, specifier: "%.2f"), z: \(acceleration.z, specifier: "%.2f")")
            Text("\(m, specifier: "%.2f")")


        }
        .padding()
    }
    
    func sumLog(log: [Log]) -> Int {
        let total = log.reduce(0.0) { partial, item in
            partial + item.value
        }
        return Int(total)
    }

    func StartActivity() {
        if isRunning {
            log.removeAll()
            lastTick = Date()
            task = Task { @MainActor in
                var lastUpdate = Date()
                for await data in startAccelerometerStream() {
                    let acc = (data.acceleration.x, data.acceleration.y, data.acceleration.z)
                    acceleration = acc

                    let now = Date()
                    //if inferredActivity(from: acceleration) {
                    let delta = Int(now.timeIntervalSince(lastUpdate))
                     //   if delta > 0 {
                      //      incrementTime(for: activity, by: delta)
                     //       lastUpdate = now
                      //  }
                   // }else {
                       lastUpdate = now
                    inferredActivity(from: acceleration)
                    
                   }
                
            }
        } else {
            task?.cancel()
            task = nil
        }
    }
    
    private func inferredActivity(from acc: (x: Double, y: Double, z: Double)) {
        
   
        
        if abs(LastY) - abs(acc.y) > 0.3 {
            log.append(Log(value: 0.5))
            LastY = acc.y
        }
        
        
            
    
        
        
        
//        m = sqrt(acc.x * acc.x + acc.y * acc.y + acc.z * acc.z)
//        switch m {
//        case 0.0...1.0:
//            return  activity == .sitting
//        case 1.0..<2.0:
//            return activity == .walking
//        case 2.0..<5.0:
//            return activity == .running
//        default:
//            return false
//        }
    }

    private func incrementTime(for activity: Activity, by seconds: Int) {
       
        if let idx = storedActivities.firstIndex(where: { $0.name == activity }) {
            storedActivities[idx].timelocal += seconds
        } else {
            storedActivities.append(ActivityStore(name: activity, timelocal: seconds))
        }
    }
    
    private func activityDisplayName(_ activity: Activity) -> String {
        switch activity {
        case .sitting: return "Sitting"
        case .walking: return "Walking"
        case .running: return "Running"
        }
    }
}

#Preview {
    ContentView()
}

