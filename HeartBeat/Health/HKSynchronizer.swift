
/*
 * Copyright 2022 Korea University(os.korea.ac.kr). All rights reserved.
 *
 * HeartBeat - Digital Health Platform Project
 *
 *
 */

import Foundation
import HealthKit
import SMART

class HKSynchronizer {
    
    var client : FhirClient? = nil
    var processor : HKSampleProcessor? = nil
    
    func Synchronize(type: HKSampleType,
                     predicate: NSPredicate?,
                     anchor: HKQueryAnchor,
                     limit: Int,
                     completionHandler: @escaping (Bool) -> Void) {
        
        guard let client = client else { print("FhirClient nill"); return }
        
        //let processor = HKSampleProcessor(client: client)
        processor = HKSampleProcessor(client: client)
        let query = HKSamplesQuery(resultProcessor: processor!,
                                  sampleType: type,
                                  predicate: predicate,
                                  anchor: anchor,
                                  limit: limit)
        query.QueryAndProcess{ (synchronized) -> Void in
            //print("Synchronization for type \(type.identifier) has finished")
            completionHandler(synchronized)
        }
    }
    
    // TODO refactor
    func GetFhirClient() -> FhirClient {
        let serverAddress = UserDefaultsProvider.getValueFromUserDefaults(key: "serverAddress") ?? "http://34.121.35.61:8080/data/add"
        let smartConnection = Client(
            baseURL: URL(string: serverAddress)!,
                settings: [
                    //"client_id": "ECG Workflow app BIH",       // if you have one
                    "redirect": "smartapp://callback",    // must be registered
                ]
            )
        let client = FhirClient(client: smartConnection)
        return client
    }
    
    func SetFhirClient() {
        var serverAddress = UserDefaultsProvider.getValueFromUserDefaults(key: "serverAddress") ?? "http://34.121.35.61:8080/data/add"
        
        print ("serverAddress :", serverAddress)
        if serverAddress == "" { serverAddress = "http://34.121.35.61:8080/data/add" }
        let smartConnection = Client(
            baseURL: URL(string: serverAddress)!,
                settings: [
                    //"client_id": "ECG Workflow app BIH",   // if you have one
                    "redirect": "smartapp://callback",       // must be registered
                ]
            )
        client = FhirClient(client: smartConnection)
    }
    
    
    func SendFhirECG(completion: @escaping(Bool) -> Void) {
        self.processor?.RequestEcgFhir() { (success: Bool) in
            completion(true)
        }
    }
    /*
     func GetFhirECG(completion: @escaping(Bool) -> Void) {
         print("GetFhirECG")
         self.processor?.QueryEcgFhir() { (success: Bool) in
             completion(true)
         }
     }
     */

}
