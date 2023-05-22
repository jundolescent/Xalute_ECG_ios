
/*
 * Copyright 2022 Korea University(os.korea.ac.kr). All rights reserved.
 *
 * HeartBeat - Digital Health Platform Project
 *
 *
 */


import Foundation
import FHIR

class TransactionBundle {
    
    let bundle: FHIR.Bundle
    
    init(resources: [Resource], cctype: Int) {
        bundle = FHIR.Bundle()
        bundle.entry = [BundleEntry]()
        bundle.type = BundleType.batch
        for resource in resources {
            let entry = FHIR.BundleEntry()
            
            let request = BundleEntryRequest()
            if(cctype == 1){
                request.method = HTTPVerb.POST
            }
            else if(cctype == 2){
                request.method = HTTPVerb.GET
            }
            //request.method = HTTPVerb.GET
            
            //request.url = FHIRURL(String(describing: type(of: resource)))
            request.url = FHIRURL("http://34.121.35.61:8080/data/add")
            entry.resource = resource
            entry.request = request
            bundle.entry?.append(entry)
        }
    }
}
