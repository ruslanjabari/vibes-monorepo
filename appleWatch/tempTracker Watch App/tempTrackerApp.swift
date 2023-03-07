//
//  tempTrackerApp.swift
//  tempTracker Watch App
//
//  Created by Ruslan AlJabari on 2/10/23.
//

import SwiftUI
import HealthKit

class MyTimer {
    var timer: Timer?

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in // 1200 = 20 minutes
            // Timer has fired
            print("Timer has fired")
            self.stopTimer()
            print("timer should have stopped")
            self.timer?.invalidate()
            print("timer is stopped ? \(self.timer?.isValid)")
        }
        timer?.fire()
    }

    func stopTimer() {
            timer?.invalidate()
    }
}


@main
struct tempTracker_Watch_AppApp: App {
    
    func send(sample: HKQuantitySample) async {
        let config = URLSessionConfiguration.ephemeral
        config.waitsForConnectivity = true
        let sesh = URLSession(configuration: config)
        let url = URL(string: "https://f089-68-65-175-6.ngrok.io")!
        
        var request = URLRequest(
                    url: url,
                    cachePolicy: .reloadIgnoringLocalCacheData
                )
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        
        let quantityDict: [String: Any] = [
            "sample_type": sample.quantityType.description,
            "value": sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())),
            "unit": sample.quantity.description
           ]
        let jsonData = try? JSONSerialization.data(withJSONObject: quantityDict)
        
        // add headers for the request
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // change as per server requirements
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
        request.httpBody = jsonData
        } catch let error {
          print(error.localizedDescription)
          return
        }
    
        let task = sesh.dataTask(with: request) { (data, res, error) in
                print("network response: \(String(describing: res))")
        }.resume()
    }

    func start() async {
        var healthStore: HKHealthStore?
        
        let tType = HKQuantityType.quantityType(forIdentifier: .appleSleepingWristTemperature)!
        let hType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let bType = HKQuantityType.quantityType(forIdentifier: .respiratoryRate)!
        

        
        if HKHealthStore.isHealthDataAvailable() {
            // Add code to use HealthKit here.
            healthStore = HKHealthStore()
            let tempType: Set = [HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.appleSleepingWristTemperature)!]
            do {
                try await healthStore?.requestAuthorization(toShare: Set(), read: tempType)
                try await healthStore?.requestAuthorization(toShare: Set(), read: [HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!])
            } catch {
                print("It threw")
            }
            
            let tempQunatity = HKQuantity(unit: HKUnit(from: "degF"), doubleValue: Double(arc4random_uniform(80) + 100))
            
            let tempSample = HKQuantitySample(type: tType, quantity: tempQunatity, start: NSDate() as Date, end: NSDate() as Date)
            
            print("tempSample data is \(tempSample.quantity) as of \(tempSample.endDate) which started @ \(tempSample.startDate)")
            
            let heartRateQuantity = HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: Double(arc4random_uniform(80) + 100))
            
            let heartSample = HKQuantitySample(type: hType, quantity: heartRateQuantity, start: NSDate() as Date, end: NSDate() as Date)
            
            print("heartSample data is \(heartSample.quantity) as of \(tempSample.endDate) which started @ \(tempSample.startDate)")
            
            
            let breatheQunat = HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: Double(arc4random_uniform(80) + 100))
            
            let breatheSample = HKQuantitySample(type: bType, quantity: breatheQunat, start: NSDate() as Date, end: NSDate() as Date)
            
            print("breatheSample data is \(breatheSample.quantity) as of \(breatheSample.endDate) which started @ \(breatheSample.startDate)")
            
            await send(sample: heartSample)
            await send(sample: breatheSample)
//            await send(sample: tempSample)
            
            
        } else {
            print("nO HealTh StoRE")
        }
    }
    
    func run() async {
        let myTimer = MyTimer()
        myTimer.startTimer()
        while true {
            if myTimer.timer != nil || myTimer.timer?.isValid != nil || myTimer.timer?.isValid == true {
                await self.start() // gets data and uploads it
                
            } else {
                continue;
            }
            do {
                sleep(5)
            }
//            if myTimer.timer?.isValid == false:
        }
    }

    
    var body: some Scene {
        Task {
               await self.run()
       }
        return WindowGroup {
            ContentView()
        }
    }
}
