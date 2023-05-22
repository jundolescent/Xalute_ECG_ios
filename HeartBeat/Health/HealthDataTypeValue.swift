/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A data model used to describe a health data value.
*/

import Foundation

/// A representation of health data to use for `HealthDataTypeTableViewController`.
struct HealthDataTypeValue {
    var startDate: Date
    var endDate: Date
    var value: Double
}
