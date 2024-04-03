//
//  HealthKitManager.swift
//  SpeziHealthKitQuery
//
//  Created by Mihir Joshi on 3/29/24.
//

import Foundation
import SpeziHealthKit
import HealthKit

class HealthKitManager: ObservableObject {
    
    // TODO: pass in HKHealthStore that was initialized when starting app
    let healthStore = HKHealthStore()
    
    @Published var healthKitData: [String : Activity] = [:] // makes it easy to store multiple HK values in one query
    
    // HealthKit authorization already handled during onboarding
    
    init() {
        let steps = HKQuantityType(.stepCount) // TODO: fetch this from info.plist? (i.e. don't hard code)
        let healthTypes:Set = [steps]
        
        Task {
            do {
                try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
            } catch {
                print("Unable to fetch health data.")
            }
        }
    }
   
    
    func fetchDailySteps() {
        // TODO: make this function reusable for common HKQuantityTypes
        let steps = HKQuantityType(.stepCount)
        var stepCount = 0.0
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { _, result, error in
            // Get the sum of queried data from start date to end date
            guard let quantity = result?.sumQuantity(), error == nil else {
                print("Unable to fetch today's HealthKit data.")
                return
            }
            
            // Print the queried step count data
            stepCount = quantity.doubleValue(for: .count())
            let activity = Activity(id: 0, title: "Step Count", subtitle: "Today's Steps", amount: stepCount.formattedString())
            DispatchQueue.main.async {
                self.healthKitData["todaysSteps"] = activity
            }
            
        }
        
        healthStore.execute(query)
    }
    
}

extension Date {
    static var startOfDay: Date {
        Calendar.current.startOfDay(for: Date())
    }
}

extension Double {
    func formattedString() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        
        return numberFormatter.string(from: NSNumber(value: self))!
    }
}
