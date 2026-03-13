//
//  Quote.swift
//  TimerMVC
//
//  Created by Денис Кушнаренко on 13.03.2026.
//

//Задание: Приложение "Цитаты"
//Создайте приложение, которое отображает случайные цитаты и позволяет пользователю сохранять понравившиеся цитаты.
//
//Требования
//Модель:
//
//Реализуйте модель Quote, которая содержит:
//text (текст цитаты)
//author (автор цитаты)
//Интерфейс:
//
//Отображайте текст цитаты и ее автора на главном экране.
//Добавьте кнопку "Следующая", чтобы получать новую случайную цитату.
//Добавьте кнопку "Сохранить", чтобы добавлять цитату в список избранных.
//Логика:
//
//Создайте массив или список цитат для отображения на экране.
//Реализуйте функциональность для получения случайной цитаты из списка при нажатии на кнопку "Следующая".
//Сохранение избранных цитат:
//
//Реализуйте возможность сохранять понравившиеся цитаты в отдельный список.
//Отображайте список сохранённых цитат на отдельном экране нажав на соответствующую кнопку "Избранное".

import Combine
import SwiftUI

struct Quote: Identifiable {
    var id: UUID = UUID()
    var text: String
    var author: String
}

class QuoteStore: ObservableObject {
    @Published var quotes: [Quote]
    @Published var favoritQuotes: [Quote] = []
    @Published var currentQuote: Int?
    
    init() {
        self.quotes = Self.loadQuotes()
        self.currentQuote = 0
    }
    
    func saveQuote() {
        guard currentQuote != nil else {return}
        
        let quote = quotes[currentQuote!]
        
        if favoritQuotes.first(where: { $0.id == quote.id }) == nil {
            favoritQuotes.append(quote)
        }
    }
    
    func getIndex() {
        if currentQuote == nil || quotes.count == 1 {
            let i = Int.random(in: 0..<quotes.count)
            currentQuote = i
            //return i
        } else {
            var i: Int = currentQuote!
            while i == currentQuote! {
                i = Int.random(in: 0..<quotes.count)
            }
            currentQuote = i
           // return i
        }
    }
    
    func getQuote() -> Quote {
        guard currentQuote != nil && !quotes.isEmpty else {
            return Quote(text: "Цитат нет", author: "")
        }
        
        return quotes[currentQuote!]
    }
    
    static func loadQuotes() -> [Quote] {
        return [
            Quote(text: "Жизнь — это то, что с тобой происходит, пока ты строишь планы.", author: "Джон Леннон"),
            Quote(text: "Счастье — это когда то, что ты думаешь, что говоришь и что делаешь, находится в гармонии.", author: "Махатма Ганди"),
            Quote(text: "Единственный способ сделать что-то отлично — любить то, что ты делаешь.", author: "Стив Джобс"),
            Quote(text: "Мы становимся тем, о чём мы думаем весь день.", author: "Ральф Уолдо Эмерсон"),
            Quote(text: "Не важно, как медленно ты идёшь, пока ты не останавливаешься.", author: "Конфуций"),
            Quote(text: "Там, где закрывается одна дверь, открывается другая.", author: "Александр Грэм Белл"),
            Quote(text: "Будь изменением, которое хочешь видеть в мире.", author: "Махатма Ганди"),
            Quote(text: "Сомнения убивают больше мечт, чем неудачи.", author: "Сьюзи Кассем"),
            Quote(text: "Если хочешь изменить мир — начни с себя.", author: "Лев Толстой"),
            Quote(text: "Всё, что мы есть — это результат наших мыслей.", author: "Будда")
        ]
        
    }
    
}


struct QuoteListView: View {
    var quote: Quote
    
    var body: some View {
        
        VStack(spacing: 16) {
            Text(quote.text)
                .font(.title2)
                .multilineTextAlignment(.center)
            Text("— \(quote.author)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        
    }
}

struct QuoteView: View {
    @StateObject private var store = QuoteStore()

    var body: some View {
        NavigationView {
            VStack() {
                QuoteListView(quote: store.getQuote())
                HStack {
                    Button("Следующая") {
                        store.getIndex()
                    }
                    Button("Сохранить") {
                        store.saveQuote()
                    }
                    .padding()
                }
                Spacer()
            }
            .navigationTitle("Цитаты")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: QuotesView(quotes: store.quotes)) {
                        Image(systemName: "list.bullet.rectangle")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: QuotesView(quotes: store.favoritQuotes)) {
                        Image(systemName: "star.fill")
                    }
                }
            }
            .padding()
        }
    }
}

struct QuotesView: View {
    let quotes: [Quote]

    var body: some View {
        Group {
            if quotes.isEmpty {
                ContentUnavailableView("Пусто", systemImage: "quote.bubble", description: Text("Пока нет цитат"))
            } else {
                List(quotes) { quote in
                    QuoteListView(quote: quote)
                        .padding(.vertical, 8)
                }
            }
        }
    }
}

#Preview {
    QuoteView()
}
    
