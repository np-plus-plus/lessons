//import Foundation
//import SwiftUI
//
//// MARK: - Модели данных
//
//// Структура для хранения данных с акселерометра
//struct AccelerometerData {
//    let timestamp: Date      // Время измерения
//    let x: Double            // Ускорение по оси X
//    let y: Double            // Ускорение по оси Y
//    let z: Double            // Ускорение по оси Z
//    
//    // Вычисляем общую активность ( magnitude )
//    var activityLevel: Double {
//        return sqrt(x*x + y*y + z*z)
//    }
//}
//
//// Типы фаз сна
//enum SleepPhase: String {
//    case deep = "Глубокий сон"      // Глубокий сон
//    case light = "Легкий сон"       // Легкий сон
//    case rem = "Быстрый сон (REM)"  // Фаза быстрого сна
//    case awake = "Пробуждение"      // Проснулись
//    
//    // Эмодзи для наглядности
//    var emoji: String {
//        switch self {
//        case .deep: return "😴"
//        case .light: return "🛌"
//        case .rem: return "👀"
//        case .awake: return "🙂"
//        }
//    }
//}
//
//// Причина пробуждения
//enum WakeReason: String {
//    case movement = "Движение во сне"
//    case noise = "Внешний шум"
//    case natural = "Естественное пробуждение"
//    case unknown = "Неизвестно"
//}
//
//// MARK: - Основной класс для анализа сна
//
//class SleepAnalyzer {
//    // Параметры для определения фаз сна
//    private let movementThreshold = 1.2      // Порог движения
//    private let remThreshold = 0.8           // Порог для REM фазы
//    private let windowSize = 60               // Размер окна для анализа (в секундах)
//    
//    // Буфер для хранения последних данных
//    private var dataBuffer: [AccelerometerData] = []
//    private var currentPhase: SleepPhase = .light
//    private var lastWakeTime: Date?
//    
//    // MARK: - AsyncStream для получения данных с акселерометра
//    
//    /// Создает поток данных с акселерометра
//    func startAccelerometerStream() -> AsyncStream<AccelerometerData> {
//        return AsyncStream { continuation in
//            // Симуляция акселерометра - генерируем данные каждую секунду
//            let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
//                // Генерируем случайные данные, имитирующие разные фазы сна
//                let data = self.generateSimulatedData()
//                
//                // Отправляем данные в поток
//                continuation.yield(data)
//                
//                print("📊 Данные акселерометра: x=\(String(format: "%.2f", data.x)), y=\(String(format: "%.2f", data.y)), z=\(String(format: "%.2f", data.z))")
//            }
//            
//            // Когда поток закрывается - останавливаем таймер
//            continuation.onTermination = { _ in
//                timer.invalidate()
//                print("⏹ Поток данных остановлен")
//            }
//        }
//    }
//    
//    // MARK: - Генерация тестовых данных
//    
//    /// Генерирует данные, имитирующие разные фазы сна
//    private func generateSimulatedData() -> AccelerometerData {
//        // Разные паттерны для разных фаз
//        let hour = Calendar.current.component(.hour, from: Date())
//        let minute = Calendar.current.component(.minute, from: Date())
//        
//        // Создаем циклический паттерн для имитации фаз сна
//        let totalMinutes = hour * 60 + minute
//        let cyclePhase = (totalMinutes % 90) / 15 // 90-минутный цикл сна
//        
//        var x: Double = 0
//        var y: Double = 0
//        var z: Double = 0
//        
//        switch cyclePhase {
//        case 0...2: // Глубокий сон - минимальные движения
//            x = Double.random(in: 0.0...0.3)
//            y = Double.random(in: 0.0...0.3)
//            z = Double.random(in: 0.0...0.3)
//            currentPhase = .deep
//            
//        case 3: // REM фаза - небольшие движения
//            x = Double.random(in: 0.3...0.8)
//            y = Double.random(in: 0.3...0.8)
//            z = Double.random(in: 0.3...0.8)
//            currentPhase = .rem
//            
//        default: // Легкий сон - умеренные движения
//            x = Double.random(in: 0.5...1.2)
//            y = Double.random(in: 0.5...1.2)
//            z = Double.random(in: 0.5...1.2)
//            currentPhase = .light
//        }
//        
//        // Иногда добавляем пробуждение
//        if Int.random(in: 0...100) < 5 { // 5% шанс
//            x = Double.random(in: 1.5...3.0)
//            y = Double.random(in: 1.5...3.0)
//            z = Double.random(in: 1.5...3.0)
//            currentPhase = .awake
//        }
//        
//        return AccelerometerData(
//            timestamp: Date(),
//            x: x,
//            y: y,
//            z: z
//        )
//    }
//    
//    // MARK: - Анализ фаз сна
//    
//    /// Анализирует текущую фазу сна на основе буфера данных
//    private func analyzeSleepPhase() -> SleepPhase {
//        guard !dataBuffer.isEmpty else { return .light }
//        
//        // Вычисляем среднюю активность за последние измерения
//        let recentData = dataBuffer.suffix(10) // Последние 10 измерений
//        let avgActivity = recentData.map { $0.activityLevel }.reduce(0, +) / Double(recentData.count)
//        
//        // Определяем фазу сна по уровню активности
//        if avgActivity > movementThreshold {
//            return .awake
//        } else if avgActivity > remThreshold {
//            return .light
//        } else {
//            return .deep
//        }
//    }
//    
//    /// Обнаруживает пробуждение и определяет его причину
//    private func detectWakeReason() -> WakeReason {
//        guard let lastData = dataBuffer.last,
//              let previousData = dataBuffer.dropLast().last else {
//            return .unknown
//        }
//        
//        // Резкое изменение активности может указывать на пробуждение
//        let activityChange = abs(lastData.activityLevel - previousData.activityLevel)
//        
//        if activityChange > 2.0 {
//            // Если резкое движение - возможно, от внешнего шума
//            if lastData.activityLevel > 3.0 {
//                return .noise
//            } else {
//                return .movement
//            }
//        } else if activityChange < 0.5 && currentPhase == .rem {
//            // Плавный переход из REM фазы - естественное пробуждение
//            return .natural
//        }
//        
//        return .unknown
//    }
//    
//    // MARK: - Основная функция обработки потока
//    
//    /// Запускает обработку потока данных с акселерометра
//    func processSleepData() async {
//        print("💤 Начинаем анализ сна...")
//        print("═══════════════════════════════════════")
//        
//        let stream = startAccelerometerStream()
//        
//        var lastPhase: SleepPhase?
//        var phaseStartTime = Date()
//        
//        for await data in stream {
//            // Добавляем данные в буфер
//            dataBuffer.append(data)
//            
//            // Ограничиваем размер буфера последними 5 минутами
//            if dataBuffer.count > 300 { // 300 секунд = 5 минут
//                dataBuffer.removeFirst()
//            }
//            
//            // Анализируем текущую фазу
//            let currentPhase = analyzeSleepPhase()
//            
//            // Если фаза изменилась
//            if currentPhase != lastPhase {
//                let duration = Date().timeIntervalSince(phaseStartTime)
//                
//                if let lastPhase = lastPhase {
//                    print("⏱ Фаза '\(lastPhase.rawValue)' длилась \(Int(duration)) секунд")
//                }
//                
//                print("\(currentPhase.emoji) Новая фаза: \(currentPhase.rawValue)")
//                
//                // Если это пробуждение - определяем причину
//                if currentPhase == .awake {
//                    let reason = detectWakeReason()
//                    print("⚠️ Пробуждение! Причина: \(reason.rawValue)")
//                    
//                    // Проверяем, оптимальное ли время для пробуждения
//                    checkWakeOptimality(reason: reason)
//                }
//                
//                lastPhase = currentPhase
//                phaseStartTime = Date()
//            }
//            
//            // Небольшая задержка для читаемости вывода
//            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 секунды
//        }
//    }
//    
//    // MARK: - Проверка оптимальности пробуждения
//    
//    /// Проверяет, оптимальная ли сейчас фаза для пробуждения
//    private func checkWakeOptimality(reason: WakeReason) {
//        let currentPhase = analyzeSleepPhase()
//        
//        switch currentPhase {
//        case .light, .rem:
//            print("✅ ОПТИМАЛЬНОЕ ВРЕМЯ! Пробуждение в фазе \(currentPhase.rawValue) - вы проснетесь бодрым!")
//            sendNotification(phase: currentPhase, isOptimal: true)
//            
//        case .deep:
//            print("❌ НЕОПТИМАЛЬНОЕ ВРЕМЯ! Пробуждение в фазе глубокого сна - вы будете чувствовать усталость.")
//            sendNotification(phase: currentPhase, isOptimal: false)
//            
//        case .awake:
//            print("👋 Вы уже проснулись. Доброе утро!")
//        }
//    }
//    
//    // MARK: - Отправка уведомлений
//    
//    /// Отправляет уведомление о фазе сна
//    private func sendNotification(phase: SleepPhase, isOptimal: Bool) {
//        let title = isOptimal ? "🌅 Оптимальное время для пробуждения" : "⏰ Пробуждение"
//        let body = isOptimal ?
//            "Сейчас фаза \(phase.rawValue). Самое время просыпаться!" :
//            "Вы проснулись в фазе глубокого сна. Рекомендуем поспать еще немного."
//        
//        // В реальном приложении здесь был бы UNUserNotificationCenter
//        print("🔔 УВЕДОМЛЕНИЕ: \(title)")
//        print("   \(body)")
//    }
//}
//
//
//// MARK: - Альтернативный вариант с SwiftUI интерфейсом
//
//struct SleepTrackingView: View {
//    @State private var currentPhase: SleepPhase = .light
//    @State private var lastNotification: String = ""
//    @State private var isTracking = false
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("😴 Монитор сна")
//                .font(.largeTitle)
//                .padding()
//            
//            // Отображение текущей фазы
//            VStack {
//                Text("Текущая фаза:")
//                    .font(.headline)
//                Text("\(currentPhase.emoji) \(currentPhase.rawValue)")
//                    .font(.title)
//                    .padding()
//                    .background(
//                        RoundedRectangle(cornerRadius: 10)
//                            .fill(currentPhase == .deep ? Color.blue.opacity(0.3) :
//                                  currentPhase == .rem ? Color.purple.opacity(0.3) :
//                                  currentPhase == .light ? Color.green.opacity(0.3) :
//                                  Color.orange.opacity(0.3))
//                    )
//            }
//            
//            // Последнее уведомление
//            if !lastNotification.isEmpty {
//                Text(lastNotification)
//                    .padding()
//                    .background(Color.yellow.opacity(0.2))
//                    .cornerRadius(8)
//            }
//            
//            // Кнопка управления
//            Button(isTracking ? "Остановить отслеживание" : "Начать отслеживание") {
//                isTracking.toggle()
//                if isTracking {
//                    startTracking()
//                }
//            }
//            .padding()
//            .background(isTracking ? Color.red : Color.green)
//            .foregroundColor(.white)
//            .cornerRadius(8)
//        }
//        .padding()
//    }
//    
//    private func startTracking() {
//        // Здесь бы запускался анализ в фоновом режиме
//        print("Отслеживание сна начато")
//    }
//}
//
//

import SwiftUI
import Combine
import CoreMotion



class CombineMotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    private let subject = PassthroughSubject<CMAccelerometerData, Never>()
    
    var publisher: AnyPublisher<CMAccelerometerData, Never> {
        subject.eraseToAnyPublisher()
    }
    
    func startUpdates(interval: TimeInterval = 0.1) {
        guard motionManager.isAccelerometerAvailable else { return }
        
        motionManager.accelerometerUpdateInterval = interval
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let data = data else { return }
            self?.subject.send(data)
        }
    }
    
    func stopUpdates() {
        motionManager.stopAccelerometerUpdates()
    }
}


struct SleepTrackingView: View {
    
    
    var body: some View {

    }
}

#Preview {
    SleepTrackingView()
}


