
/*
 * Copyright 2022 Korea University(os.korea.ac.kr). All rights reserved.
 *
 * HeartBeat - Digital Health Platform Project
 *
 *
 */


import Foundation
import FHIR

class EcgObservationTemplateProvider {
    
    static private var observationTemplate = GetEcgObservationTemplate()!
    
    static private func GetEcgObservationTemplate() -> FHIRJSON? {
        if let path = Bundle.main.path(forResource: "FhirECG", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                
                if let jsonResult = jsonResult as? FHIRJSON, let observationTemplate = jsonResult["ObservationTemplate"] as? FHIRJSON {
                    return observationTemplate
                }
            } catch {
                print(error)
            }
        }
        return nil //TAG_REVIEW : nil일 경우 에러처리 해줘야 함...
    }
    
    static func GetObservationTemplate() -> Observation {
        do {
            let observation = try Observation(json: self.observationTemplate)
            return observation

        } catch {
            print(error)
            return Observation()
        }
    }
}
