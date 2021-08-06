//
//  ContentView.swift
//  CombineDemo
//
//  Created by Dhilip on 02/08/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .padding()
            .onAppear(){
              onAppear()
            }
    }
    
    func onAppear(){
        let publisherDemo = PublishersDemo()
        publisherDemo.subjectsDemo()
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
