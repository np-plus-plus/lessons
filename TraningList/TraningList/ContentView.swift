//
//  ContentView.swift
//  TraningList
//
//  Created by Денис Кушнаренко on 20.02.2026.
//

import SwiftUI
import Combine



struct DownloadTask: Sendable {
    let id: UUID = UUID()
    let Data: Date
    let Name: String
}

@MainActor
class DownloadsViewModel: ObservableObject {
    @Published var downloads: [DownloadTask] = []
    @Published var errorMessage: String = ""
    
    func loadingData() async {
        do{
        try await
            downloads.append(DownloadTask(Data: Date(), Name: "Тест"))
            downloads.append(DownloadTask(Data: Date(), Name: "Тест1"))
            downloads.append(DownloadTask(Data: Date(), Name: "Тест2"))
        }catch{
            errorMessage = "Ошибка: \(error.localizedDescription)"
        }
    }
}


struct ContentView: View {
    @ObservedObject var downloadsViewModel = DownloadsViewModel()
    
    
    var body: some View {
        VStack {
            List(downloadsViewModel.downloads , id: \.id){ item in
                Text("\(item.Name)")
                Text("\(item.Data)")
                
            }
        }
        .onAppear {
            Task{
                await downloadsViewModel.loadingData()
            }
        }
    }
}

#Preview {
    ContentView()
}
