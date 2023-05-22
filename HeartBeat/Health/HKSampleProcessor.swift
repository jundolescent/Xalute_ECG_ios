
/*
 * Copyright 2022 Korea University(os.korea.ac.kr). All rights reserved.
 *
 * HeartBeat - Digital Health Platform Project
 *
 *
 */

import Foundation
import HealthKit
import FHIR
import UIKit

class HKSampleProcessor : HeartViewController {
    var client: FhirClient
    var dispatchGroup: DispatchGroup
    var processingDispatchGroup: DispatchGroup
    var resources: [Resource]
    private let accessQueue = DispatchQueue(label: "SynchronizedArrayAccess", attributes: .concurrent)
    
    //private var networkState : NetworkStatus
    
    init(client: FhirClient) {
        self.client = client
        self.dispatchGroup = DispatchGroup()
        self.processingDispatchGroup = DispatchGroup()
        self.resources = [Resource]()
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func ProcessResults(sampleType: HKObjectType, samples: [HKSample], closure: @escaping (_ result: Bool) -> Void ) {
        
        var dataValue = HeartRateSample()
        //for sample in samples {
            //print("sampleType :", sampleType)

            switch sampleType.identifier
            {
            case HKQuantityTypeIdentifier.heartRate.rawValue,
                 HKQuantityTypeIdentifier.heartRateVariabilitySDNN.rawValue,
                 HKQuantityTypeIdentifier.restingHeartRate.rawValue:
                
                //print("===========  HeartRate Data  ===========")
                guard let sample:HKQuantitySample = samples.last as? HKQuantitySample else { return }
            
                dataIndex = getDataIndex(for: sampleType.identifier)
                dataValue.title = getDataTypeName(for: sampleType.identifier)
                dataValue.healthDataValue = HealthDataTypeValue(startDate: sample.startDate,
                                                               endDate: sample.endDate,
                                                               value: .zero)
                
                if let unit = preferredUnit(for: sampleType.identifier) {
                    print("sampleType : ", sampleType.identifier, ", Unit.... :", unit)
                    dataValue.healthDataValue.value = sample.quantity.doubleValue(for: unit)
                }

                HealthData.dataValues[dataIndex] = dataValue
                
            
            case HKObjectType.electrocardiogramType().identifier:
                
                self.processingDispatchGroup.enter()
                
                //print ("======= HKElectrocardiogramType =======")
                guard let sample:HKElectrocardiogram = samples.last as? HKElectrocardiogram else { return }
                
                dataIndex = getDataIndex(for: sampleType.identifier)
                dataValue.title = getDataTypeName(for: sampleType.identifier)
                dataValue.healthDataValue = HealthDataTypeValue(startDate: sample.startDate,
                                                               endDate: sample.endDate,
                                                               value: .zero)
                
                if let unit = preferredUnit(for: sampleType.identifier) {
                    dataValue.healthDataValue.value = sample.averageHeartRate?.doubleValue(for: unit) ?? 0
                }
                
                let classification : HKElectrocardiogram.Classification = sample.classification
                let classificationType : String? = getECGClassification(classification: classification)
                dataValue.detail = classificationType
                
                HealthData.dataValues[dataIndex] = dataValue
                
                HKEcgVoltageProvider().GetMeasurementsForHKElectrocardiogram(sample: sample) { (measurements) in
                    let observation = self.CreateObservation(measurements: measurements,  averageHeartRate: dataValue.healthDataValue.value)
                    
                    self.accessQueue.async(flags:.barrier) {
                        self.resources.append(observation)
                        self.processingDispatchGroup.leave()
                    }
                }
            default:
                print ("======= default")
                break 
            }
        //}
        
        self.processingDispatchGroup.notify(queue: .main) {
            if (self.resources.count > 0) {
                HealthData.isAvailableSendingEcgData = true
            }
            
            self.dispatchGroup.notify(queue: .main) {
                super.reloadData()
                closure(true)
            }
            
        }
    }
   

    private func CreateObservation(measurements: String, averageHeartRate : Double) -> Observation {
       
        let dateOfBirth : Date?
        let vendorUUID = UIDevice.current.identifierForVendor?.uuidString ?? "false"
        print(vendorUUID)
        
        // Date of Birth
        if #available(iOS 10.0, *) {
            try? print(healthStore.dateOfBirthComponents())
        } else {
                // Fallback on earlier versions
            do {
                dateOfBirth = try healthStore.dateOfBirth()
                print(dateOfBirth!)
            } catch let error {
                print("There was a problem fetching your data: \(error)")
            }
        }
        
        let observation = EcgObservationTemplateProvider.GetObservationTemplate()
        observation.component?.first?.valueSampledData?.data = FHIRString(measurements)
        observation.component?.first?.valueSampledData?.origin?.value = FHIRDecimal(String(averageHeartRate))
        observation.component?.first?.valueSampledData?.period = FHIRDecimal(String(HealthData.ecgPeriod))
      
        var reference = "Patient/"
        
        // SettingViewController 파일내에서 birthDate, userName value 정의
        let Birthday = UserDefaultsProvider.getValueFromUserDefaults(key: "birthDate")
        let Name = UserDefaultsProvider.getValueFromUserDefaults(key: "userName")
    
        let referenceValue = UserDefaultsProvider.getValueFromUserDefaults(key: "patientReference")
        
        // 데이터 수집 시간을 보내기 위해
        let date:String?
        date=UserDefaultsProvider.getValueFromUserDefaults(key: "Datetest")
        
        if (referenceValue != nil) {
            reference += referenceValue!
        }
        
        // Name
        if (Name != nil) {
            reference += Name! + ": "
        }
        
        // Birthday
        if (Birthday != nil){
            reference += Birthday! + " "
        }
        // date
        if (date != nil){
            reference += date!
        }
        
        print(reference)
        
        observation.subject?.reference = FHIRString(reference)
        return observation
    }
    
    
    private func SendResources(resources: [Resource], cctype: Int) {
        print("SendResoucres함수")
        print("HKSampleProcessor - Attempting to transmit bundle with \(resources.count) entries")

        let bundle = TransactionBundle(resources: resources, cctype: cctype).bundle
        dispatchGroup.enter()
        if (cctype == 1){
            print("cctype == 1")
            client.send(resource: bundle) {( success: Bool) in
                //print ("Resource :", resources)
                print("SendResource Status :", success)
                
                if success { HealthData.sendingStatus = NetworkStatus.sendingSuccess }
                else { HealthData.sendingStatus = NetworkStatus.sendingFail }
                
                self.dispatchGroup.leave()
            }
        }
/*
 else if (cctype == 2){
     print("cctype == 2")
     client.query(resource: bundle) {( success: Bool) in
         //print ("Resource :", resources)
         print("SendResource Status :", success)
         
         if success { HealthData.sendingStatus = NetworkStatus.sendingSuccess }
         else { HealthData.sendingStatus = NetworkStatus.sendingFail }
         
         self.dispatchGroup.leave()
     }
 }
 */


    }
    
    func RequestEcgFhir(completion: @escaping(Bool) -> Void)  {
        let cctype = 1
        if (self.resources.count > 0) {
            self.SendResources(resources: self.resources, cctype: cctype)
            
            self.dispatchGroup.notify(queue: .main) {
                completion(true)
            }
        }
    }
    /*
     func QueryEcgFhir(completion: @escaping(Bool) -> Void)  {
         print("QueryEcgFhir")
         let cctype = 2

         self.SendResources(resources: self.resources, cctype: cctype)
         
         self.dispatchGroup.notify(queue: .main) {
             completion(true)
         }

     }
     */

}
