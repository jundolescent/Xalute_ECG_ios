
/*
 * Copyright 2022 Korea University(os.korea.ac.kr). All rights reserved.
 *
 * HeartBeat - Digital Health Platform Project
 *
 */

import Foundation
import HealthKit

typealias AccessRequestCallback = (_ success: Bool, _ error: NSError?) -> Void

/// Helper for reading and writing to HealthKit.
class HealthKitManager {
    
    private let healthStore = HKHealthStore()

    /// Requests access to all the data types the app wishes to read/write from HealthKit.
    /// On success, data is queried immediately and observer queries are set up for background
    /// delivery. This is safe to call repeatedly and should be called at least once per launch.
    func requestBackgroundDelivery(completion: AccessRequestCallback) {
        
        let readDataTypes = dataTypesToRead()

        self.setUpBackgroundDeliveryForDataTypes(types: readDataTypes)
        
        
    }
}

// MARK: - Private
private extension HealthKitManager {
    /// Initiates an `HKAnchoredObjectQuery` for each type of data that the app reads and stores
    /// the result as well as the new anchor.
    func readHealthKitData() { /* ... */ }

    // - parameter types: Set of `HKObjectType` to observe changes to.
    private func setUpBackgroundDeliveryForDataTypes(types: Set<HKObjectType>) {
        
        for type in types {
            
            guard let sampleType = type as? HKSampleType else { print("ERROR: \(type) is not an HKSampleType"); continue }
            
            let query = HKObserverQuery(sampleType: sampleType, predicate: nil) { [weak self] (query: HKObserverQuery, completionHandler: HKObserverQueryCompletionHandler, error: Error?) in
                //debugPrint("observer query update handler called for type \(type), error: \(String(describing: error) )")
                guard let strongSelf = self else { return }
                strongSelf.queryForUpdates(type: type) //TAG_REVIEW 0619 for added...
                //testBackGroundDelivery()
                completionHandler()
            }
            
            healthStore.execute(query)
            healthStore.enableBackgroundDelivery(for: type, frequency: .immediate) { (success: Bool, error: Error?) in
                //debugPrint("enableBackgroundDeliveryForType handler called for \(type) - success: \(success), error: \(String(describing: error) )")
            }
        }
    }

    /// Initiates HK queries for new data based on the given type
    ///
    /// - parameter type: `HKObjectType` which has new data avilable.
    private func queryForUpdates(type: HKObjectType) {
        switch type {
        case HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!:
            debugPrint("HKQuantityTypeIdentifierHeartRate")
        case HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.restingHeartRate)!:
            debugPrint("HKQuantityTypeIdentifierRestingHeartRate")
        case HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRateVariabilitySDNN)!:
            debugPrint("HKQuantityTypeIdentifierHeartRateVariabilitySDNN")
        case HKObjectType.electrocardiogramType():
            debugPrint("HKEletrocardiogrmaType")
        //case is HKWorkoutType:
        //    debugPrint("HKWorkoutType")
        default: debugPrint("Unhandled HKObjectType: \(type)")
        }
    }

    /// Types of data that this app wishes to read from HealthKit.
    ///
    /// - returns: A set of HKObjectType.
    private func dataTypesToRead() -> Set<HKObjectType> {
            return Set(arrayLiteral:
                       HKObjectType.electrocardiogramType(),
                       HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
                       HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.restingHeartRate)!,
                       HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRateVariabilitySDNN)!
                
        )
    }

    
    
    //======================================================================================================
    //======================================================================================================
    
    private func startObservingHeartRateChanges() {
        let sampleType =  HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
        let query: HKObserverQuery = HKObserverQuery(sampleType: sampleType!, predicate: nil, updateHandler: self.heartRateChangeHandler)
        healthStore.execute(query)
        healthStore.enableBackgroundDelivery(for: sampleType!, frequency: .hourly, withCompletion: {(succeeded: Bool, error: Error!) in
            if succeeded{
                print("Enabled background delivery of heartRate changes")
            } else {
                if let theError = error{
                    print("Failed to enable background delivery of heartRate changes. ")
                    print("Error = \(theError)")
                }
            }
        } as (Bool, Error?) -> Void)
    }
    
    
    private func heartRateChangeHandler(query: HKObserverQuery!, completionHandler: HKObserverQueryCompletionHandler!, error: Error!) {
    // Flag to check the background handler is working or not
        print("Backgound Mode activated")
        //fireTestPush() //FireBase Test
        testBackGroundDelivery()
        completionHandler()
     }
}
