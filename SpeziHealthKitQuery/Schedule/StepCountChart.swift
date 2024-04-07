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
    let stepCount: Double
}

enum DateRanges: String, Identifiable {
    case oneWeek = "7 Days"
    case oneMonth = "1 Month"
    case threeMonths = "3 Months"
    case oneYear = "1 Year"
    
    var id: String { self.rawValue }
}

let allDateRanges: [DateRanges] = [.oneWeek, .oneMonth, .threeMonths]

//class ViewModel: ObservableObject {
//    @Published var selectedDateRange: DateRanges = .oneMonth
//    
//    func fetchData(for dateRange: DateRanges) {
//        // Perform your API call here
//        print("Fetching data for \(dateRange.rawValue)")
//        // Simulating API call completion
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            // Update UI or data state here after API call
//            
//        }
//    }
//}

struct StepCountChart: View {
    
    @EnvironmentObject var healthManager: HealthKitManager
    @State private var selectedDateRange : DateRanges = .oneMonth // Default: This week (since Monday)
    @State private var stepData : [StepView]?
    
    // things to try: onChange, DispatchQueue.global
    
    // TODO: implement a date picker to select the range of dates manually
    
    
    var body: some View {
        VStack {
            
            Picker(selection: $selectedDateRange, label: Text("Date Range")) {
                ForEach(allDateRanges) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(SegmentedPickerStyle()).padding()
            
            
            .onChange(of: $selectedDateRange.wrappedValue) { oldValue, newValue in
                
                healthManager.fetchStepCount(startDate: healthManager.getStartDate(for: newValue)) { currStepData in
                    DispatchQueue.main.async {
                        self.stepData = currStepData
                    }
                }
            }
            
            Chart {
                ForEach(self.stepData ?? [StepView(date: Date(), stepCount: 0.0)]) { daily in
                    BarMark(x: .value(daily.date.formatted(), daily.date, unit: .day), y: .value("Step Count", daily.stepCount))
                }
            }.padding(.horizontal)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel()
                    }
                }
                
        }
        .onAppear {
            healthManager.fetchStepCount(startDate: healthManager.getStartDate(for: $selectedDateRange.wrappedValue)) { currStepData in
                DispatchQueue.main.async {
                    self.stepData = currStepData
                }
            }
        }
        
    }
}

#Preview {
    StepCountChart().environmentObject(HealthKitManager())
}
