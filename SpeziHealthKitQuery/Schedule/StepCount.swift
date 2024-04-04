//
//  StepCount.swift
//  SpeziHealthKitQuery
//
//  Created by Mihir Joshi on 3/29/24.
//

import SwiftUI

struct Activity {
    let id: Int
    let title: String
    let subtitle: String
    let amount: String // TODO: change to value
    
    // TODO: add weekly, monthly, yearly
}

struct StepCount: View {
    @EnvironmentObject var healthManager : HealthKitManager // TODO: convert to SpeziHealthKit
//    @State var myHealthData: Activity
    @State private var myStepCount: Double?
    var body: some View {
        HStack {
            
            if let stepCount = myStepCount {
                HStack {
                    Text("Step Count").padding()
                    Text(stepCount.formattedString()).padding(.leading)
                }
            } else {
                Text("Fetching step count...")
            }
        }
        
        .onAppear {
            // Fetch the step count data on the main thread (this also avoids lag in the SwiftUI View)
            healthManager.fetchDailySteps { stepCount in
                DispatchQueue.main.async {
                    self.myStepCount = stepCount
                }
            }
            // TODO: add pull to refresh
        }
    }
        
    
    // TODO: Add Swift Chart integration
}

#Preview {
//    StepCount(myHealthData: Activity(id: 0, title: "Step Count", subtitle: "Daily", amount: "1,234"))
    StepCount()
}
