//
// This source file is part of the SpeziHealthKitQuery based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount
import SpeziQuestionnaire
import SpeziScheduler
import SwiftUI
import SpeziHealthKit


struct ScheduleView: View {
    @Environment(SpeziHealthKitQueryStandard.self) private var standard
    @Environment(SpeziHealthKitQueryScheduler.self) private var scheduler
    @State private var eventContextsByDate: [Date: [EventContext]] = [:]
    @State private var presentedContext: EventContext?


    @Binding private var presentingAccount: Bool
    
    @EnvironmentObject var healthManager : HealthKitManager
    
    private var startOfDays: [Date] {
        Array(eventContextsByDate.keys)
    }
    
    
    
    var body: some View {
        NavigationStack {
            List(startOfDays, id: \.timeIntervalSinceNow) { startOfDay in
                Section(format(startOfDay: startOfDay)) {
                    ForEach(eventContextsByDate[startOfDay] ?? [], id: \.event) { eventContext in
                        EventContextView(eventContext: eventContext)
                            .onTapGesture {
                                if !eventContext.event.complete {
                                    presentedContext = eventContext
                                }
                            }
                    }
                }
                Section {
                    //                    StepCount(myHealthData: Activity(id: 0, title: "Step Count", subtitle: "Daily", amount: "5,678"))
                    StepCount().environmentObject(healthManager)
                }
                
                Section {
                    StepCountChart().environmentObject(healthManager)
                }
                
            }
                .onChange(of: scheduler) {
                    calculateEventContextsByDate()
                }
                .task {
                    calculateEventContextsByDate()
                }
                .sheet(item: $presentedContext) { presentedContext in
                    destination(withContext: presentedContext)
                }
                .toolbar {
                    if AccountButton.shouldDisplay {
                        AccountButton(isPresented: $presentingAccount)
                    }
                }
                .navigationTitle("SCHEDULE_LIST_TITLE")
        }
    }
    
//    func readStepCount(from healthStore: HKHealthStore) async -> HKCategoryValue {
//        
////        let sampleType = HKQuantityType(.stepCount)
////        
////        try await healthStore.requestAuthorization(toShare: [], read: Set<HKObjectType>(HKElectrocardiogram.correlatedSymptomTypes))
////        
////        guard let sample = try await healthStore.sampleQuery(for: sampleType, withPredicate: predicate).first,
////              let categorySample = sample as? HKCategorySample else {
////            continue
////        }
////        symptoms[categorySample.categoryType] = HKCategoryValueSeverity(rawValue: categorySample.value)
//        
//        
//    }
    
    
    init(presentingAccount: Binding<Bool>) {
        self._presentingAccount = presentingAccount
    }
    
    
    private func destination(withContext eventContext: EventContext) -> some View {
        @ViewBuilder var destination: some View {
            switch eventContext.task.context {
            case let .questionnaire(questionnaire):
                QuestionnaireView(questionnaire: questionnaire) { result in
                    presentedContext = nil

                    guard case let .completed(response) = result else {
                        return // user cancelled the task
                    }

                    eventContext.event.complete(true)
                    await standard.add(response: response)
                }
            case let .test(string):
                ModalView(text: string, buttonText: String(localized: "CLOSE")) {
                    await eventContext.event.complete(true)
                }
            }
        }
        return destination
    }
    
    
    private func format(startOfDay: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: startOfDay)
    }
    
    private func calculateEventContextsByDate() {
        let eventContexts = scheduler.tasks.flatMap { task in
            task
                .events(
                    from: Calendar.current.startOfDay(for: .now),
                    to: .numberOfEventsOrEndDate(100, .now)
                )
                .map { event in
                    EventContext(event: event, task: task)
                }
        }
            .sorted()
        
        let newEventContextsByDate = Dictionary(grouping: eventContexts) { eventContext in
            Calendar.current.startOfDay(for: eventContext.event.scheduledAt)
        }
        
        eventContextsByDate = newEventContextsByDate
    }
}


#if DEBUG
#Preview("ScheduleView") {
    ScheduleView(presentingAccount: .constant(false))
        .previewWith(standard: SpeziHealthKitQueryStandard()) {
            SpeziHealthKitQueryScheduler()
            AccountConfiguration {
                MockUserIdPasswordAccountService()
            }
        }
}
#endif
