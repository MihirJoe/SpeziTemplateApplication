//
//  StepCountChart.swift
//  SpeziHealthKitQuery
//
//  Created by Mihir Joshi on 4/4/24.
//

import SwiftUI
import Charts


struct StepView: Identifiable {
    let id = UUID()
    let date: Date
    let stepCount: Double // might have to be an array
}

struct StepCountChart: View {
    
    @EnvironmentObject var healthManager: HealthKitManager
    
    var body: some View {
        VStack {
            Chart {
                ForEach(healthManager.oneMonthChartData) { daily in
                    BarMark(x: .value(daily.date.formatted(), daily.date, unit: .day), y: .value("Step Count", daily.stepCount))
                }
            }.foregroundStyle(.red).padding(.horizontal)
            
            HStack {
                
            }
        }
    }
}

#Preview {
    StepCountChart().environmentObject(HealthKitManager())
}
