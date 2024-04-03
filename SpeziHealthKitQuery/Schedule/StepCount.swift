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
    @State var myHealthData: Activity
    var body: some View {
        HStack {
            ForEach(healthManager.healthKitData.sorted(by: {$0.value.id < $1.value.id}), id: \.key) { item in
                HStack {
                    Text(item.value.title).padding(.horizontal)
                    Text(item.value.amount)
                }
                
            }
        }
        
        .onAppear {
            healthManager.fetchDailySteps()
        }
    }
        
    
    // TODO: Add Swift Chart integration
}

#Preview {
    StepCount(myHealthData: Activity(id: 0, title: "Step Count", subtitle: "Daily", amount: "1,234"))
}
