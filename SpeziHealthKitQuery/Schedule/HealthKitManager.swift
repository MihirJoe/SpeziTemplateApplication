//
//  HealthKitManager.swift
//  SpeziHealthKitQuery
//
//  Created by Mihir Joshi on 3/29/24.
//

import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    
    // TODO: pass in HKHealthStore that was initialized when starting app
    let healthStore = HKHealthStore()
    
    @Published var healthKitData: [String : Activity] = [:] // makes it easy to store multiple HK values in one query
    
    @Published var oneMonthChartData = [StepView]()
    
    // HealthKit authorization already handled during onboarding
    
    init() {
        let steps = HKQuantityType(.stepCount) // TODO: fetch this from info.plist? (i.e. don't hard code)
        let healthTypes:Set = [steps]
        Task {
            do {
                try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
                fetchPastMonthStepData()
            } catch {
                print("Unable to fetch health data.")
            }
        }
    }
   
    // TODO: HKQuantityTypes
    func fetchDailySteps(completion: @escaping (Double?) -> Void) {
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
            
            // Save the queried step count data
            stepCount = quantity.doubleValue(for: .count())
            completion(stepCount)
            
        }
        
        healthStore.execute(query)
    }
    
    
    
    func fetchStepCount(startDate: Date, completion: @escaping ([StepView]) -> Void) {
        
        // Initialize HKQuantity type, interval, and query type
        let steps = HKQuantityType(.stepCount)
        let interval = DateComponents(day: 1)
        let query = HKStatisticsCollectionQuery(quantityType: steps, quantitySamplePredicate: nil, anchorDate: startDate, intervalComponents: interval)
        
        query.initialResultsHandler = { query, result, error in
            guard let result = result else {
                completion([])
                return
            }
            
            var dailySteps = [StepView]()
            
            result.enumerateStatistics(from: startDate, to: Date()) { statistics, stop in
                dailySteps.append(StepView(date: statistics.startDate, stepCount: statistics.sumQuantity()?.doubleValue(for: .count()) ?? 0.00))
            }
            
            completion(dailySteps)
        }
        
        healthStore.execute(query)
    }
    
    //TODO: StatisticsQueryCollection for graphs & plotting
    
    // TODO: HKCategoryTypes
    // TODO: HKCorrelationTypes
    // TODO: HKWorkoutTypes
    
    // other HealthKit data types: https://developer.apple.com/documentation/healthkit/hksampletype
    

    
}

extension Date {
    static var startOfDay: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    static var startOfWeek: Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        components.weekday = 2 // Monday
        
        return calendar.date(from: components)!
    }
    
    static var oneMonthAgo: Date {
        let calendar = Calendar.current
        let oneMonth = calendar.date(byAdding: .month, value: -1, to: Date())
        return calendar.startOfDay(for: oneMonth!)
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


// MARK: Chart Data

extension HealthKitManager {
    func fetchPastMonthStepData() {
        fetchStepCount(startDate: .oneMonthAgo) { dailySteps in
            DispatchQueue.main.async {
                self.oneMonthChartData = dailySteps
            }
        }
    }
}
