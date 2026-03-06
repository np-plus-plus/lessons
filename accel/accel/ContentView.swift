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

struct ContentView: View {
    @State private var acceleration: (x: Double, y: Double, z: Double) = (0, 0, 0)
    @State private var m: Double = 0
    @State private var activity: Activity = .sitting
    @State private var isRunning: Bool = false
    @State private var storedActivities: [ActivityStore] = []
    @State private var task: Task<Void, Never>? = nil
    @State private var lastTick: Date? = nil

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
            
            List {
                ForEach(storedActivities) { item in
                    HStack {
                        Text(activityDisplayName(item.name))
                        Spacer()
                        let minutes = item.timelocal / 60
                        let seconds = item.timelocal % 60
                        Text(String(format: "%02dm %02ds", minutes, seconds))
                    }
                }
            }
            
            Spacer()

            Text("Acceleration: x: \(acceleration.x, specifier: "%.2f"), y: \(acceleration.y, specifier: "%.2f"), z: \(acceleration.z, specifier: "%.2f")")
            Text("\(m, specifier: "%.2f")")


        }
        .padding()
    }

    func StartActivity() {
        if isRunning {
            lastTick = Date()
            task = Task { @MainActor in
                var lastUpdate = Date()
                for await data in startAccelerometerStream() {
                    let acc = (data.acceleration.x, data.acceleration.y, data.acceleration.z)
                    acceleration = acc

                    let now = Date()
                    if inferredActivity(from: acceleration) {
                        let delta = Int(now.timeIntervalSince(lastUpdate))
                        if delta > 0 {
                            incrementTime(for: activity, by: delta)
                            lastUpdate = now
                        }
                    }else {
                        lastUpdate = now
                    }
                }
            }
        } else {
            task?.cancel()
            task = nil
        }
    }
    
    private func inferredActivity(from acc: (x: Double, y: Double, z: Double)) -> Bool {
     
        m = sqrt(acc.x * acc.x + acc.y * acc.y + acc.z * acc.z)
        switch m {
        case 0.0...1.0:
            return  activity == .sitting
        case 1.0..<2.0:
            return activity == .walking
        case 2.0..<5.0:
            return activity == .running
        default:
            return false
        }
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
