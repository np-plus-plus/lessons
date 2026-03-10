//
//  SwiftUIView.swift
//  TimerMVC
//
//  Created by Денис Кушнаренко on 10.03.2026.
//

//Задание: Приложение "Список дел" (To-Do List)
//Создайте приложение для управления списком дел, которое позволяет добавлять, удалять и отмечать задачи как выполненные.
//
//Требования
//Модель:
//
//Реализуйте модель Task, которая содержит следующие поля:
//title (название задачи)
//isCompleted (статус выполнения задачи)
//Интерфейс:
//
//Создайте список для отображения задач.
//Добавьте текстовое поле для ввода новой задачи и кнопку "Добавить".
//Логика:
//
//Позвольте пользователю добавлять задачи в список.
//Реализуйте возможность удаления задач из списка при нажатии на кнопку "Удалить".
//Добавьте возможность отмечать задачи как выполненные (например, при нажатии на название задачи).
//Дополнительные функции (по желанию):
//
//Реализуйте возможность редактирования существующих задач.
//Сохраните задачи между сеансами с использованием UserDefaults.


import SwiftUI
import Combine

struct Task: Identifiable {
    var id: UUID = UUID()
    var title: String
    var isCompleted: Bool = false
}

class TaskController: ObservableObject {
    @Published var tasks: [Task] = []
    
    func addTask(_ title: String) {
        tasks.append(Task(title: title))
    }
    
    func toggleTaskStatus(id: UUID) {
        if let i = tasks.firstIndex(where: { $0.id == id }) {
            tasks[i].isCompleted.toggle()
        }
    }
    
    
    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
}

struct TaskView: View {
    var task: Task
    var body: some View {
        HStack{
            Image(systemName: task.isCompleted ? "checkmark.square.fill" : "square")
                .resizable()
                .frame(width: 20, height: 20)
            Text(task.title)
        }
    }
}


struct SwiftUIView: View {
    @StateObject private var controller = TaskController()
    @State var newTask: String = ""
    
    var body: some View {
        VStack{
            HStack{
                TextField("New Task", text: $newTask)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Add Task"){
                    controller.addTask(newTask)
                    newTask = ""
                }
            }
            .padding()
            List {
                ForEach(controller.tasks) { task in
                    TaskView(task: task)
                        .onTapGesture {
                            controller.toggleTaskStatus(id: task.id)
                        }
                }
                .onDelete { offsets in
                    controller.deleteTask(at: offsets)
                }
            }
        }
    }
}

#Preview {
    SwiftUIView()
}
