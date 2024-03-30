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
    let image: String
    let amount: String // TODO: change to value
    
    // TODO: add weekly, monthly, yearly
}

struct StepCount: View {
    @EnvironmentObject var healthManager : HealthKitManager // TODO: convert to SpeziHealthKit
    @State var activity: Activity
    var body: some View {
        HStack {
            Text(activity.title).padding()
            Text(activity.amount).padding()
        }
        .onAppear {
            // Fetch the daily step count
            healthManager.fetchDailySteps()
        }
        
    }
        
    
    // TODO: Add Swift Chart integration
}

#Preview {
    StepCount(activity: Activity(id: 0, title: "Step Count", subtitle: "Daily", image: "figure.walk", amount: "1,234"))
}
