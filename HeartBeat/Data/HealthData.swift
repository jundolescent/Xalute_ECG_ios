
/*
 * Copyright 2022 Korea University(os.korea.ac.kr). All rights reserved.
 *
 * HeartBeat - Digital Health Platform Project
 *
 *
 */

import Foundation
import HealthKit


struct HeartRateSample
{
    var title : String?
    var detail : String?
    var healthDataValue = HealthDataTypeValue(startDate: Date(), endDate: Date(), value: 0)
}

enum DataIndex : Int {
    case heartRate = 0
    case restingHeartRate
    case heartRateVariabilitySDNN
    case ECG
}


struct HealthDataTypeValue {
    var startDate: Date
    var endDate: Date
    var value: Double
}


class HealthData {
    
    //static var onboardingComplete : Bool = false
    
    static var dataValues : [HeartRateSample] = [
        HeartRateSample(title : "Heart Rate"),
        HeartRateSample(title : "Resting Heart Rate"),
        HeartRateSample(title : "Heart Rate Variability"),
        HeartRateSample(title : "ECG") ]
    
    static var ecgSamples = [(Double, Double)]()
    static var ecgPeriod = 0.0
    static var isAvailableSendingEcgData = false
    static var sendingStatus = NetworkStatus.sendingInit

}

