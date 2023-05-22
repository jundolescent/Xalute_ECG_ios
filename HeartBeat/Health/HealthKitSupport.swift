
import Foundation
import HealthKit

// MARK: Sample Type Identifier Support

/// Return an HKSampleType based on the input identifier that corresponds to an HKQuantityTypeIdentifier, HKCategoryTypeIdentifier
/// or other valid HealthKit identifier. Returns nil otherwise.
func getSampleType(for identifier: String) -> HKSampleType? {
    if let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: identifier)) {
        return quantityType
    }
    
    if let categoryType = HKCategoryType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: identifier)) {
        return categoryType
    }
    
    if HKElectrocardiogramType.electrocardiogramType() != nil {
        return HKElectrocardiogramType.electrocardiogramType()
    }
    
    return nil
}

// MARK: - Unit Support

/// Return the appropriate unit to use with an HKSample based on the identifier. Asserts for compatible units.
func preferredUnit(for sample: HKSample) -> HKUnit? {
    let unit = preferredUnit(for: sample.sampleType.identifier, sampleType: sample.sampleType)
    
    if let quantitySample = sample as? HKQuantitySample, let unit = unit {
        assert(quantitySample.quantity.is(compatibleWith: unit),
               "The preferred unit is not compatiable with this sample.")
    }
    
    return unit
}

/// Returns the appropriate unit to use with an identifier corresponding to a HealthKit data type.
func preferredUnit(for sampleIdentifier: String) -> HKUnit? {
    return preferredUnit(for: sampleIdentifier, sampleType: nil)
}


private func preferredUnit(for identifier: String, sampleType: HKSampleType? = nil) -> HKUnit? {
    var unit: HKUnit?
    let sampleType = sampleType ?? getSampleType(for: identifier)
    
    if sampleType is HKQuantityType {
        let quantityTypeIdentifier = HKQuantityTypeIdentifier(rawValue: identifier)
        
        switch quantityTypeIdentifier {
        case .heartRate, .restingHeartRate, .walkingHeartRateAverage:
            unit = HKUnit(from: "count/min")
        case .heartRateVariabilitySDNN:
            unit = HKUnit.secondUnit(with: .milli)
        default:
            break
        }
    } else if sampleType is HKElectrocardiogramType {
        //_ = HKObjectType.electrocardiogramType().identifier

        //let quantityTypeIdentifier = HKQuantityTypeIdentifier(rawValue: identifier)
        
            unit = HKUnit(from: "count/min")
        
    }
    
    return unit
}

func getUnit(type: HKQuantityTypeIdentifier) -> String//HKUnit?
{
    var unit: String// HKUnit?
    
    switch type {
    case .heartRate, .restingHeartRate, .walkingHeartRateAverage:
        unit = "BPM"//HKUnit(from: "count/min")
    case .heartRateVariabilitySDNN:
        unit = "ms" //HKUnit.secondUnit(with: .milli)
    default :
        unit = "BPM"
        break
    }
    
    return unit
}


func getDataIndex(for identifier: String) -> Int {
    
    var index = 0
    let sampleType = getSampleType(for: identifier)
    
    if sampleType is HKQuantityType {
        let quantityTypeIdentifier = HKQuantityTypeIdentifier(rawValue: identifier)
        
        switch quantityTypeIdentifier {
        case .heartRate:
            index = DataIndex.heartRate.rawValue
        case .restingHeartRate:
            index = DataIndex.restingHeartRate.rawValue
        case .heartRateVariabilitySDNN:
            index = DataIndex.heartRateVariabilitySDNN.rawValue
        //case .walkingHeartRateAverage:
        //    description = "Walking Heart Rate Average"
       
        default:
            break
        }
    } else if sampleType is HKElectrocardiogramType {
        index = DataIndex.ECG.rawValue
    }
    
    //print("DataIndex ", index)
    
    return index
}
// MARK: - Query Support
