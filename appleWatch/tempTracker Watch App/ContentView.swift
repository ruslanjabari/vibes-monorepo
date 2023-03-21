//
//  ContentView.swift
//  tempTracker Watch App
//
//  Created by Ruslan AlJabari on 2/10/23.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Recording your vitals ... ⏺")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
