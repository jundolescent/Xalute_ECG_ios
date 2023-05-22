//
//  HealthKitManager.swift
//  HeartBeat
//
//  Created by mjkim on 2022/04/28.
//

import Foundation
import HealthKit

struct HeartRateValues
{
    var heartRate : Double = 0.0
    var heartRateVariability : Double = 0.0
}

class HealthKitManager {

    //private var healthStore = HKHealthStore()
    static let healthStore: HKHealthStore = HKHealthStore()
    //static let healthStore: HKHealthStore = HKHealthStore()
    private var heartRateQuantity = HKUnit(from: "count/min")
    private var heartRateVariability = HKUnit.secondUnit(with: .milli)
    private var activeQueries = [HKQuery]()

    @Published var heartRateValues = HeartRateValues()

    func autorizeHealthKit() {

        let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let heartRateVariability = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!

        let HKreadTypes: Set = [heartRate, heartRateVariability]

        HealthKitManager.healthStore.requestAuthorization(toShare: nil, read: HKreadTypes) { (success, error) in
            if let error = error {
                print("Error requesting health kit authorization: \(error)")
            }
        }
    }

    func fetchHeartRateData(quantityTypeIdentifier: HKQuantityTypeIdentifier ) {

        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = {
        query, samples, deletedObjects, queryAnchor, error in
            guard let samples = samples as? [HKQuantitySample] else {
                return
            }
            self.process(samples, type: quantityTypeIdentifier)
        }
        let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
        query.updateHandler = updateHandler
        HealthKitManager.healthStore.execute(query)
        activeQueries.append(query)
    }

    
    private func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
        for sample in samples {
            if type == .heartRate {
                DispatchQueue.main.async {
                    self.heartRateValues.heartRate = sample.quantity.doubleValue(for: self.heartRateQuantity)
                }
            } else if type == .heartRateVariabilitySDNN {
                DispatchQueue.main.async {
                    self.heartRateValues.heartRateVariability = sample.quantity.doubleValue(for: self.heartRateVariability)//HKUnit.secondUnit(with: .milli))
                }
            }
        }
    }
    
    func stopFetchingHeartRateData() {
        activeQueries.forEach { HealthKitManager.healthStore.stop($0) }
        activeQueries.removeAll()
        DispatchQueue.main.async {
            self.heartRateValues.heartRate = 0.0
            self.heartRateValues.heartRateVariability = 0.0
        }

    }

}
