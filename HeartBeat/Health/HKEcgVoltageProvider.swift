
/*
 * Copyright 2022 Korea University(os.korea.ac.kr). All rights reserved.
 *
 * HeartBeat - Digital Health Platform Project
 *
 *
 */

import Foundation
import HealthKit

// String extension for double values
extension LosslessStringConvertible {
    var string: String { .init(self) }
}

class HKEcgVoltageProvider {
    
    func GetMeasurementsForHKElectrocardiogram(sample: HKElectrocardiogram, completionHandler: @escaping (String) -> Void) {
    //func GetMeasurementsForHKElectrocardiogram(sample: HKElectrocardiogram, completionHandler: @escaping ([(Double,Double)]) -> Void) {
        let healthStore = HKHealthStore()
        var measurements = ""
        var lastTimeStamp = 0.0
        
        let voltageQuery = HKElectrocardiogramQuery(sample) {(query, result) in
            switch(result) {
            
            case .measurement(let value):
                /// Option 1.  Get  just voltage values.
                /// Type (voltageData)
                /// if let voltageQuantity = measurement.quantity(for: .appleWatchSimilarToLeadI) {
                ///    measurements = measurements + voltageQuantity.doubleValue(for: HKUnit.volt()).string + " "
                /// }
                
                
                /// Option 2.  Get  voltageData & timeStamp values...
                /// Type (voltageData, timeStamp)
                let sample = (value.quantity(for: .appleWatchSimilarToLeadI)!.doubleValue(for: HKUnit.volt()), value.timeSinceSampleStart)
                
                HealthData.ecgSamples.append(sample)
                
                measurements = measurements + "\(sample) "
                lastTimeStamp = sample.1
                
            case .done:
                print("done")
                
                //print("measurements : ", measurements)
                
                DispatchQueue.main.async {
                    HealthData.ecgPeriod = lastTimeStamp
                    completionHandler(measurements)
                }

            case .error(let error):
                print(error)
                // Handle the error here.

            @unknown default:
                print("default error")
            }
        }

        healthStore.execute(voltageQuery)
    }
    
}
