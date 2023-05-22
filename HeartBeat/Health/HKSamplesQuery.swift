
/*
 * Copyright 2022 Korea University(os.korea.ac.kr). All rights reserved.
 *
 * HeartBeat - Digital Health Platform Project
 *
 */


import Foundation
import HealthKit

class HKSamplesQuery {
    var resultProcessor: HKSampleProcessor
    var sampleType: HKSampleType
    var predicate: NSPredicate?
    var anchor: HKQueryAnchor
    var limit: Int
    
    init(resultProcessor: HKSampleProcessor, sampleType: HKSampleType, predicate: NSPredicate?, anchor: HKQueryAnchor, limit: Int) {
        self.resultProcessor = resultProcessor
        self.sampleType = sampleType
        self.predicate = predicate
        self.anchor = anchor
        self.limit = limit
    }
    
    func QueryAndProcess(closure: @escaping (_ synched: Bool) -> Void) {
        let healthStore = HKHealthStore()
        
        // Create the query.
        let query = HKAnchoredObjectQuery( type: sampleType,
                                           predicate: predicate,
                                           anchor: anchor,
                                           limit: HKObjectQueryNoLimit) { (query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil) in
            
                                            guard let samples = samplesOrNil, let deletedObjects = deletedObjectsOrNil else {
                                                fatalError("*** An error occurred during the initial query: \(errorOrNil!.localizedDescription) ***")
                                            }
                                            
                                            // Save new anchor
                                            HKAnchorProvider.SaveAnchor(forType: self.sampleType, anchor: newAnchor!)
            
                                            for deletedObject in deletedObjects {
                                                print("deleted: \(deletedObject)")
                                            }
                                            
                                            // Process results
                                            if (samples.count > 0) {
                                                //print("Found " + String(samples.count) + " matching samples.")
                                               
                                                self.resultProcessor.ProcessResults(sampleType: self.sampleType as HKObjectType, samples: samples) {( success: Bool) in
                                                    //print("HKSampleQuery - All results have been successfully processed")
                                                    closure(true);
                                                }
                                            } else {
                                                print("No new matching samples \(self.sampleType.identifier) found")
                                                closure(false);
                                            }
        }
        
        healthStore.execute(query)
    }
}

