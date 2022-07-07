//
//  ContentView.swift
//  BetterRest
//
//  Created by Beto Toro on 6/07/22.
//

import CoreML
import SwiftUI

struct ContentView: View {
  
  
  @State private var wakeUp = defaultWakeTime
  @State private var sleepAmount = 8.0
  @State private var coffeeAmount = 0
  @State private var alertTitle = "Your ideal bedtime is…"
  @State private var alertMessage = "???"
  @State private var showingAlert = false
  static var defaultWakeTime: Date {
      var components = DateComponents()
      components.hour = 7
      components.minute = 0
      return Calendar.current.date(from: components) ?? Date.now
  }
  
  func calculateBedtime() {
    do {
      let config = MLModelConfiguration()
      let model = try SleepCalculator(configuration: config)
      
      let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
      let hour = (components.hour ?? 0) * 60 * 60
      let minute = (components.minute ?? 0) * 60
      
      let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
      
      let sleepTime = wakeUp - prediction.actualSleep
      
      alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
      
    } catch {
      alertTitle = "Error"
      alertMessage = "Sorry, there was a problem calculating your bedtime."
    }
    showingAlert = true
  }
  
  var body: some View {
    NavigationView {
      Form {
        
        Section {
          HStack {
            Spacer()
            DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
              .labelsHidden()
            Spacer()
          }
        } header: {
          Text("When do you want to wake up?")
            .font(.subheadline)
        }
        
        Section {
          Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
        } header: {
          Text("Desired amount of sleep")
            .font(.subheadline)
        }
        
        Section {
          Picker(coffeeAmount == 0 ? "1 cup" : "\(coffeeAmount + 1) cups", selection: $coffeeAmount) {
            ForEach(1..<21) { cup in
              Text("\(cup) \(cup > 1 ? "cups" : "cup")")
            }
          }
        } header: {
          Text("Daily coffee intake")
            .font(.subheadline)
        }
        
        Section {
          HStack() {
            Spacer()
            VStack(spacing: 20) {
              Text(alertTitle)
                .foregroundColor(.gray)
                .font(.subheadline)
              Text(alertMessage)
                .font(.largeTitle.bold())
            }
            Spacer()
          }
        }
        .padding()
      }
      .navigationTitle("BetterRest")
      .toolbar {
        Button("Calculate", action: calculateBedtime)
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
