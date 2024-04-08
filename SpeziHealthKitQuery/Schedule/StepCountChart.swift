//
//  StepCountChart.swift
//  SpeziHealthKitQuery
//
//  Created by Mihir Joshi on 4/4/24.
//

import SwiftUI
import Charts
import Combine


struct StepView: Identifiable {
    let id = UUID()
    let date: Date
    let stepCount: Double
}

enum DateRanges: String, Identifiable {
    case oneWeek = "7D"
    case oneMonth = "1M"
    case threeMonths = "3M"
    case oneYear = "1Y"
    
    var id: String { self.rawValue }
}

let allDateRanges: [DateRanges] = [.oneWeek, .oneMonth, .threeMonths]

struct StepCountChart: View {
    
    @EnvironmentObject var healthManager: HealthKitManager
    @State private var selectedDateRange : DateRanges = .oneWeek // Default: This week (7 days to present)
    @State private var stepData : [StepView]?
    @State private var isLoading = true
    
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
                isLoading = true
                healthManager.fetchStepCount(startDate: healthManager.getStartDate(for: newValue)) { currStepData in
                    DispatchQueue.main.async {
                        self.stepData = currStepData
                        
                    }
                    isLoading = false
                }
            }
            
            if isLoading {
                LoadingView()
            } else {
                if let myStepData = stepData {
                    
                    Chart {
                        ForEach(myStepData) { daily in
                            BarMark(x: .value(daily.date.formatted(), daily.date, unit: .day), y: .value("Step Count", daily.stepCount))
                        }
                    }.padding(.horizontal)
                        .chartXAxis {
                            AxisMarks(values: .automatic) { _ in
                                AxisValueLabel()
                            }
                        }
                    
                }
            }
            
        }
        .onAppear {
            isLoading = true
            healthManager.fetchStepCount(startDate: healthManager.getStartDate(for: $selectedDateRange.wrappedValue)) { currStepData in
                DispatchQueue.main.async {
                    self.stepData = currStepData
                    
                }
                isLoading = false
            }
        }
        
    }
}

// Loading View from: https://github.com/SwiftfulThinking/SwiftfulLoadingIndicators/blob/main/Sources/SwiftfulLoadingIndicators/Animations/LoadingThreeBalls.swift

struct LoadingView: View {
    
    let timer: Publishers.Autoconnect<Timer.TimerPublisher>
    let timing: Double
    
    let maxCounter = 3
    @State var counter = 0
    
    let frame: CGSize
    let primaryColor: Color
    
    init(color: Color = .primary, size: CGFloat = 50, speed: Double = 0.35) {
        timing = speed
        timer = Timer.publish(every: timing, on: .main, in: .common).autoconnect()
        frame = CGSize(width: size, height: size)
        primaryColor = color
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<maxCounter) { index in
                Circle()
                    .scale(counter == index ? 1.0 : 0.5)
                    .fill(primaryColor)
            }
        }
        .frame(width: frame.width, height: frame.height, alignment: .center)
        .onReceive(timer, perform: { _ in
            withAnimation(.linear(duration: timing)) {
                counter = counter == (maxCounter - 1) ? 0 : counter + 1
            }
        })
    }
}


#Preview {
    StepCountChart().environmentObject(HealthKitManager())
}
