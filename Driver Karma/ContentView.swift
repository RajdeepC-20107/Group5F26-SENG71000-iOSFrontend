//
//  ContentView.swift
//  Driver Karma
//
//  Created by Antony Rudkovsky on 2026-10-03.
//

import SwiftUI

struct ContentView: View {
  @State private var progress: CGFloat = 0.2

  var body: some View {
      NavigationView {
          VStack {
              CircularProgressView(progress: progress)
                  .frame(width: 200, height: 200)
              
              Slider(value: $progress, in: 0...1)
                  .padding()
          }.navigationTitle("Driver Karma 😇")
      }
  }
}

struct CircularProgressView: View {
  let progress: CGFloat

  var body: some View {
    ZStack {
      Circle()
        .stroke(lineWidth: 20)
        .opacity(0.1)
        .foregroundColor(.gray)
        
        Text(String(format: "%u", Int(progress*100.0)))
            .font(.title)
            .bold()

      Circle()
        .trim(from: 0.0, to: min(progress, 1.0))
        .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
        .foregroundColor(Int(progress*100.0) > 70 ? .green : Int(progress*100.0) > 50 ? .yellow : .red)
        .rotationEffect(Angle(degrees: 270.0))
        .animation(.linear, value: progress)
    }
  }
}

#Preview {
    ContentView()
}
