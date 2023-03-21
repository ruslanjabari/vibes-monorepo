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
        let url = URL(string: "http://0291-68-65-175-24.ngrok.io/htp")!
        
        var request = URLRequest(
                    url: url,
                    cachePolicy: .reloadIgnoringLocalCacheData
                )
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        print("\(sample.quantity)")
        var quantityDict : [String: Any];
        if (sample.quantityType == HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!) {
            quantityDict = [
                "sample_type": sample.quantityType.description,
//                "value": sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())),
                "value": "\(sample.quantity)",
                "unit": sample.quantity.description
               ]
        } else if (sample.quantityType == HKQuantityType.quantityType(forIdentifier: .appleSleepingWristTemperature)!) {
            quantityDict = [
                "sample_type": sample.quantityType.description,
//                "value": sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute())),
                "unit": sample.quantity.description
               ]
        } else {
            quantityDict = [
                "sample_type": sample.quantityType.description,
                "value": "\(sample.quantity)",
                "unit": sample.quantity.description
               ]
        }
        
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
        let oType = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!
        let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!

        
        if HKHealthStore.isHealthDataAvailable() {
            // Add code to use HealthKit here.
            healthStore = HKHealthStore()
            let tempType: Set = [hType, hrvType] // add others if needed
            do {
                try await healthStore?.requestAuthorization(toShare: Set(), read: tempType)
//                try await healthStore?.requestAuthorization(toShare: [HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!], read: [HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!])
            } catch {
                print("It threw")
            }
            
            
            let tempQunatity = HKQuantity(unit: HKUnit(from: "degF"), doubleValue: Double(arc4random_uniform(80) + 100))
            
            let tempSample = HKQuantitySample(type: tType, quantity: tempQunatity, start: NSDate() as Date, end: NSDate() as Date)
            
//            print("tempSample data is \(tempSample.quantity) as of \(tempSample.endDate) which started @ \(tempSample.startDate)")
            
            let heartRateQuantity = HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: Double(arc4random_uniform(80) + 100))
            
            let heartSample = HKQuantitySample(type: hType, quantity: heartRateQuantity, start: NSDate() as Date, end: Date(timeIntervalSinceNow: 5))
            
//            print("heartSample data is \(heartSample.quantity) as of \(tempSample.endDate) which started @ \(tempSample.startDate)")
            
            let breatheQunat = HKQuantity(unit: HKUnit(from: "count/min"), doubleValue: Double(arc4random_uniform(80) + 100))
            
            let breatheSample = HKQuantitySample(type: bType, quantity: breatheQunat, start: NSDate() as Date, end: NSDate() as Date)
            
//            print("breatheSample data is \(breatheSample.quantity) as of \(breatheSample.endDate) which started @ \(breatheSample.startDate)")
            let hrvQuant = HKQuantity(unit: HKUnit(from: "ms"), doubleValue: Double(arc4random_uniform(80) + 100))
            let hrvSample = HKQuantitySample(type: hrvType, quantity: hrvQuant, start: NSDate() as Date, end: NSDate() as Date);
//                        print("hrvSample data is \(hrvSample.quantity) as of \(hrvSample.endDate) which started @ \(hrvSample.startDate)")

            let oQuant = HKQuantity(unit: HKUnit(from: "%"), doubleValue: Double(arc4random_uniform(80) + 100))
            let oSample = HKQuantitySample(type: oType, quantity: oQuant, start: NSDate() as Date, end: NSDate() as Date);

//            print("oSample data is \(oSample.quantity) as of \(oSample.endDate) which started @ \(oSample.startDate)")

            
            
            
            
            await send(sample: heartSample)
            await send(sample: hrvSample)
//            await send(sample: breatheSample)
//            await send(sample: tempSample)
//            await send(sample: hrvSample)
//            await send(sample: oSample)

            
            
        } else {
            print("nO HealTh StoRE")
        }
    }
    
    let heartRateUnit:HKUnit = HKUnit(from: "count/min")
    let heartRateType:HKQuantityType   = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
    var heartRateQuery:HKQuery?
    private func createStreamingQuery() -> HKQuery {
        let queryPredicate  = HKQuery.predicateForSamples(withStart: NSDate() as Date, end: nil, options: [])
            
        let query:HKAnchoredObjectQuery = HKAnchoredObjectQuery(type: self.heartRateType, predicate: queryPredicate, anchor: nil, limit: Int(HKObjectQueryNoLimit))
        {
            (query:HKAnchoredObjectQuery, samples:[HKSample]?, deletedObjects:[HKDeletedObject]?, anchor:HKQueryAnchor?, error:Error?) -> Void in
        
            if let errorFound:NSError = error as NSError?
            {
                print("query error: \(errorFound.localizedDescription)")
            }
            else
            {
                //printing heart rate
                 if let samples = samples as? [HKQuantitySample]
                  {
                     if let quantity = samples.last?.quantity
                     {
                         print("\(quantity.doubleValue(for: heartRateUnit))")
                     }
                   }
            }
        }//eo-query
        
        query.updateHandler = { (query:HKAnchoredObjectQuery, samples:[HKSample]?, deletedObjects:[HKDeletedObject]?, anchor:HKQueryAnchor?, error:Error?) -> Void in
                
            if let errorFound:NSError = error as NSError?
                {
                    print("query-handler error : \(errorFound.localizedDescription)")
                }
                else
                {
                    print("\(String(describing: samples))")
                      //printing heart rate
                      if let samples = samples as? [HKQuantitySample]
                      {
                           if let quantity = samples.last?.quantity
                           {
                               print("\(quantity.doubleValue(for: heartRateUnit))")
                           }
                      }
                }//eo-non_error
        }//eo-query-handler
        
        return query
    }//eom
    
    func run() async {
        let myTimer = MyTimer()
        myTimer.startTimer()
        
//        streaming query seems to be a better way to do this but I could not get it working in time
//        var healthStore: HKHealthStore?
//        let q = self.createStreamingQuery()
//        if HKHealthStore.isHealthDataAvailable() {
//            // Add code to use HealthKit here.
//            healthStore = HKHealthStore()
//            print("\(q.debugDescription)")
//            healthStore?.execute(q)
//        }
        
        
    
        while true {
            await self.start()
            if myTimer.timer != nil || myTimer.timer?.isValid != nil || myTimer.timer?.isValid == true {
                await self.start() // gets data and uploads it
                
            } else {
                continue;
            }
            do {
                sleep(10)
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
