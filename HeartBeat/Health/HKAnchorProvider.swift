
/*
 * Copyright 2022 Korea University(os.korea.ac.kr). All rights reserved.
 *
 * HeartBeat - Digital Health Platform Project
 *
 */

import Foundation
import HealthKit

class HKAnchorProvider {

    private let userDefaults = UserDefaults.standard
    
    private let anchorKeyPrefix = "Anchor_"
    
    private func anchorKey(for type: HKSampleType) -> String {
        return anchorKeyPrefix + type.identifier
    }
    
    /// Returns the saved anchor used in a long-running anchored object query for a particular sample type.
    /// Returns nil if a query has never been run.
    func getAnchor(for type: HKSampleType) -> HKQueryAnchor? {
        if let anchorData = userDefaults.object(forKey: anchorKey(for: type)) as? Data {
            return try? NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: anchorData)
        }
        return nil
    }
    
    static func GetAnchor(forType: HKSampleType) -> HKQueryAnchor {
        var anchor = HKQueryAnchor.init(fromValue: 0)
        let anchorKey = getNSUserDefaultsAnchorKey(forType: forType)

        if UserDefaults.standard.object(forKey: anchorKey ) != nil {
            let data = UserDefaults.standard.object(forKey: anchorKey) as! Data
            anchor = try! NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: data)!
            //NSKeyedUnarchiver.unarchiveObject(with: data) as! HKQueryAnchor
            print("Found existing anchor")
        } else {
            print("No existing anchor found, returning new anchor with value 0")
        }
        return anchor;
    }
    
    
    static func SaveAnchor(forType: HKSampleType, anchor: HKQueryAnchor) {
        let anchorKey = getNSUserDefaultsAnchorKey(forType: forType)

        let data : Data = try! NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: true)
        UserDefaults.standard.set(data, forKey: anchorKey)
        //print("Saved new anchor")
    }
    
    
    static func getNSUserDefaultsAnchorKey(forType: HKSampleType) -> String {
        let anchorKey = forType.identifier + "Anchor"
        return anchorKey
    }
    
    /// Return an anchor date for a statistics collection query.
    func createAnchorDate() -> Date {
        // Set the arbitrary anchor date to Monday at 3:00 a.m.
        let calendar: Calendar = .current
        var anchorComponents = calendar.dateComponents([.day, .month, .year, .weekday], from: Date())
        let offset = (7 + (anchorComponents.weekday ?? 0) - 2) % 7
        
        anchorComponents.day! -= offset
        anchorComponents.hour = 3
        
        let anchorDate = calendar.date(from: anchorComponents)!
        
        return anchorDate
    }

    /// This is commonly used for date intervals so that we get the last seven days worth of data,
    /// because we assume today (`Date()`) is providing data as well.
    func getLastWeekStartDate(from date: Date = Date()) -> Date {
        return Calendar.current.date(byAdding: .day, value: -6, to: date)!
    }

    func createLastWeekPredicate(from endDate: Date = Date()) -> NSPredicate {
        let startDate = getLastWeekStartDate(from: endDate)
        return HKQuery.predicateForSamples(withStart: startDate, end: endDate)
    }
}


