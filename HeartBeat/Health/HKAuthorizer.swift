
/*
 * Copyright 2022 Korea University(os.korea.ac.kr). All rights reserved.
 *
 * HeartBeat - Digital Health Platform Project
 *
 *
 */

import Foundation


import Foundation
import HealthKit

class HKAuthorizer {
    
    static func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
        
        let healthStore: HKHealthStore
        
        guard HKHealthStore.isHealthDataAvailable() else { fatalError("This app requires a device that supports HealthKit") }
        
        healthStore = HKHealthStore()
        
        let sampleTypes = Set([HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth)!,
                               HKObjectType.quantityType(forIdentifier: .heartRate)!,
                               HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!,
                               HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
                               HKSeriesType.heartbeat(),
                               HKObjectType.electrocardiogramType()])

        healthStore.requestAuthorization(toShare: nil/*sampleTypes*/, read: sampleTypes) { (success, error) in
            print("Request Authorization -- Success: ", success, " Error: ", error ?? "nil")
            completion(success, error)
        }
    }
}
