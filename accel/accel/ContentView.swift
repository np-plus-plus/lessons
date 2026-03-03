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

struct ContentView: View {
    @State private var acceleration: (x: Double, y: Double, z: Double) = (0, 0, 0)

    var body: some View {
        VStack {
            Text("Acceleration:")
            Text("x: \(acceleration.x, specifier: "%.2f")")
            Text("y: \(acceleration.y, specifier: "%.2f")")
            Text("z: \(acceleration.z, specifier: "%.2f")")
        }
        .padding()
        .task {
            for await data in startAccelerometerStream() {
                acceleration = (data.acceleration.x, data.acceleration.y, data.acceleration.z)
                handleAccelerometerData(data)
            }
        }
    }
}

#Preview {
    ContentView()
}
