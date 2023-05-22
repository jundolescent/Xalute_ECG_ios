
/*
 * Copyright 2022 Korea University(os.korea.ac.kr). All rights reserved.
 *
 * HeartBeat - Digital Health Platform Project
 */


import Foundation
import HealthKit

// MARK: - Data Type Strings

/// Return a readable name for a HealthKit data type identifier.
func getDataTypeName(for identifier: String) -> String? {
    
    var description: String?
    let sampleType = getSampleType(for: identifier)
    
    if sampleType is HKQuantityType {
        let quantityTypeIdentifier = HKQuantityTypeIdentifier(rawValue: identifier)
        
        switch quantityTypeIdentifier {
        case .heartRate:
            description = "Heart Rate"
        case .heartRateVariabilitySDNN:
            description = "Heart Rate Variability"
        case .restingHeartRate:
            description = "Resting Heart Rate"
        //case .walkingHeartRateAverage:
        //    description = "Walking Heart Rate Average"
       
        default:
            break
        }
    } else if sampleType is HKElectrocardiogramType {
        description = "ECG"
    }
    
    return description
}

// MARK: - Formatted Value Strings

/// Return a formatted readable value suitable for display for a health data value based on its type. Example: "10,000 steps"
func formattedValue(_ value: Double, typeIdentifier: String) -> String? {
    guard
        let unit = preferredUnit(for: typeIdentifier),
        let roundedValue = getRoundedValue(for: value, with: unit),
        let unitSuffix = getUnitSuffix(for: unit)
    else {
        return nil
    }
    
    let formattedString = String.localizedStringWithFormat("%@ %@", roundedValue, unitSuffix)
    
    return formattedString
}

private func getRoundedValue(for value: Double, with unit: HKUnit) -> String? {
    let numberFormatter = NumberFormatter()
    
    numberFormatter.numberStyle = .decimal
    
    switch unit {
    case .count(), .meter():
        let numberValue = NSNumber(value: round(value))
        
        return numberFormatter.string(from: numberValue)
    default:
        return nil
    }
}


// Unit Strings
func getUnitDescription(for unit: String) -> String? {
    switch unit {
    case "Heart Rate", "Resting Heart Rate":
        return " BPM"
    case "Heart Rate Variability":
        return " ms"
    default:
        return " BPM"
    }
}

// Unit Suffix Strings

private func getUnitSuffix(for unit: HKUnit) -> String? {
    switch unit {
    case .count():
        return "steps"
    case .meter():
        return "m"
    default:
        return nil
    }
}

// ECG Classification Strings

func getECGClassification( classification : HKElectrocardiogram.Classification ) -> String?
{
    switch classification {
    case .atrialFibrillation:
        return "Atrial Fibrillation"
    case .sinusRhythm:
        return "Sinus Rhythm"
    case .notSet:
        return "Not Set"
    case .inconclusiveLowHeartRate:
        return "Inconclusive Low Heart Rate"
    case .inconclusiveHighHeartRate:
        return "Inconclusive High Heart Rate"
    case .inconclusivePoorReading:
        return "Inconclusive Poor Reading"
    case .inconclusiveOther:
        return "Inconclusive Other"
    case .unrecognized:
        return "Unrecognized"
        
    @unknown default:
        return nil
    }
}


func getECGSymptomsStatus( symptomsStatus : HKElectrocardiogram.SymptomsStatus ) -> String?
{
    switch symptomsStatus {
    case .notSet:
        return "기록없음"
    case .present:
        return "증상있음"
    case .none:
        return "Not Set"
        
    @unknown default:
        return nil
    }
}
