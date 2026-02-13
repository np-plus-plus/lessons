//
//  ContentView.swift
//  ConverterCurrency
//
//  Created by Денис Кушнаренко on 13.02.2026.
//

import SwiftUI
import Combine

class Currency: ObservableObject {
    @Published var rub: String = ""
    private var courseUsd: Double = 80.00
    private var courseEur: Double = 100.00
    
   var usd:  Double   {
        let rubDouble = Double(rub) ?? 0.00
        if rubDouble > 0 {
            return rubDouble / courseUsd
        }else {
            return 0.00
        }
    }
    var eur : Double {
        let rubDouble = Double(rub) ?? 0.00
        if rubDouble > 0 {
            return rubDouble / courseEur
        }else {
            return 0.00
        }
    }
    
}


struct ContentView: View {
    @ObservedObject var currency = Currency()

    
    var body: some View {
        VStack {
            TextField("Введите сумму в рублях", text: $currency.rub)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Text("\(currency.usd) $")
            Text("\(currency.eur) €")

        }
    }
}

#Preview {
    ContentView()
}
