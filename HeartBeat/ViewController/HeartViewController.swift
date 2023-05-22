
/*
 * Copyright 2022 Korea University(os.korea.ac.kr). All rights reserved.
 *
 * HeartBeat - Digital Health Platform Project
 *
 *
 */


import UIKit
import HealthKit
import Foundation

class HeartViewController : UITableViewController {
    
    var healthStore: HKHealthStore = HKHealthStore()
    let healthKitManager = HealthKitManager()
    
    let hkSynchronizer = HKSynchronizer()
    
    //private var activeQueries = [HKQuery]()
    var dataIndex : Int = 0
    var selectedCell : Int = 0
    
    let UUID = NSUUID()
    
    
    @objc func SendEcgData(_ sender: Any ) {
        if ( HealthData.isAvailableSendingEcgData == true ) {
           
            hkSynchronizer.SendFhirECG() { (success: Bool) in
                self.alertSendingStatus()
            }
        }
        
        else {
            
        }
    }
    
    @objc func SendPhoto(_ sender: Any ) {
        //let photo = PhotoViewController()
        //photo.buttonAction()
        //return null

    }
    //jsl
    /*
     @objc func GetEcgData(_ sender: Any ) {
         print("여기까지는 온다")
         if ( HealthData.isAvailableSendingEcgData == true ) {
            
             hkSynchronizer.GetFhirECG() { (success: Bool) in
                 self.alertSendingStatus()
             }
         }
         else{
             hkSynchronizer.GetFhirECG() { (success: Bool) in
                 self.alertSendingStatus()
             }
         }
     }
     */

    
    override func viewDidLoad() {
        
        self.dataIndex = 0
        super.viewDidLoad()
        
        let testButton = UIButton(type: .custom)
        testButton.setTitle("ECG 데이터 보내기", for: .normal)
        testButton.setTitleColor(UIColor.white, for: .normal)
        testButton.backgroundColor = UIColor.systemPink
        testButton.layer.cornerRadius = 15
        testButton.layer.shadowColor = UIColor.gray.cgColor
        testButton.layer.shadowOpacity = 1.0
        testButton.layer.shadowOffset = CGSize.zero
        testButton.layer.shadowRadius = 6
        self.view.addSubview(testButton)
        testButton.frame = CGRect(x: 100, y: 250, width: 180, height: 40)
        testButton.addTarget(self, action: #selector(SendEcgData(_:)), for: .touchUpInside)
        
        //For GetEcgData jsl
        
         let testButton2 = UIButton(type: .custom)
         testButton2.setTitle("사진 전송하기", for: .normal)
         testButton2.setTitleColor(UIColor.white, for: .normal)
         testButton2.backgroundColor = UIColor.systemPink
         testButton2.layer.cornerRadius = 15
         testButton2.layer.shadowColor = UIColor.gray.cgColor
         testButton2.layer.shadowOpacity = 1.0
         testButton2.layer.shadowOffset = CGSize.zero
         testButton2.layer.shadowRadius = 6
         self.view.addSubview(testButton2)
         testButton2.frame = CGRect(x: 100, y: 450, width: 180, height: 40)
         testButton2.addTarget(self, action: #selector(SendPhoto(_:)), for: .touchUpInside)
         

        //end of adding button.
         
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        GetHealthDataFromHealthStore()
    
    }
    
    override func viewDidAppear(_ animated: Bool) {

        UserDefaults.standard.setValue(true, forKey: "onboardingComplete")
        
        healthKitManager.requestBackgroundDelivery() { success, error in
              if success { print("HealthKit access granted") }
              else { print("Error requesting access to HealthKit")}
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HealthData.dataValues.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.font = UIFont(name:"SeoulHanagang", size:20)
        cell.detailTextLabel?.font = UIFont(name:"SeoulHanagang", size:20)
        cell.textLabel?.text = HealthData.dataValues[indexPath.row].title
        
        cell.detailTextLabel?.text = String(format: "%.2f", HealthData.dataValues[indexPath.row].healthDataValue.value) + getUnitDescription(for: HealthData.dataValues[indexPath.row].title!)!  //)" BPM"
        
        if HealthData.dataValues[indexPath.row].detail != nil {
            cell.detailTextLabel?.text = HealthData.dataValues[indexPath.row].detail!
        }
        
        if HealthData.dataValues[indexPath.row].healthDataValue.value != 0 {
            dataIndex += 1
        }
        
        
        print("indexPath   : \(indexPath.row), startDate : \(HealthData.dataValues[indexPath.row].healthDataValue.startDate)")
        print("heart title : \(HealthData.dataValues[indexPath.row].title!)")
        print("heart value : \(HealthData.dataValues[indexPath.row].healthDataValue.value)")
        
        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //DispatchQueue.main.async { [self] in
            self.selectedCell = indexPath.row
        //}
        
        print("HeartViewController Selected Index \(indexPath)")
        print("HeartViewController Selected Data : \(String(describing: HealthData.dataValues[indexPath.row].title))")
    }
    
  
    func reloadData()
    {
        self.tableView.reloadData()
    }
    
    func alertSendingStatus()
    {
        if ( HealthData.sendingStatus == NetworkStatus.sendingSuccess ) {
            self.showAlertMessage (title: "", message: "ECG 데이터 전송 완료!")
        }
        else if ( HealthData.sendingStatus == NetworkStatus.sendingFail ){
            self.showAlertMessage (title: "네트워크 오류", message: "ECG 데이터 전송 실패!!")
        }
        else {
            self.showAlertMessage(title: "안됨!", message: "그냥 안됨")
        }
    }
    
    func showAlertMessage(title: String, message:String) {
        DispatchQueue.main.async {
            let alertMessage = UIAlertController(title: "", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .cancel)
            
            alertMessage.addAction(okAction)
            self.present(alertMessage, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetailSegue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                guard let controller = segue.destination as? HeartDetailViewController else {
                    return
                }
                
                controller.indexCell = indexPath.row
                print ("prepare : indexPath,", indexPath.row)
            }
        }
    }

    func GetHealthDataFromHealthStore()
    {
        hkSynchronizer.SetFhirClient()
        FetchHeartRateSample(sampleType : HKObjectType.quantityType(forIdentifier: .heartRate)!)
        FetchHeartRateSample(sampleType : HKObjectType.quantityType(forIdentifier: .restingHeartRate)!)
        FetchHeartRateSample(sampleType : HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!)
        FetchHeartRateSample(sampleType : HKObjectType.electrocardiogramType())
    }
    
    
    func FetchHeartRateSample( sampleType : HKSampleType )
    {
        let anchor: HKQueryAnchor = HKQueryAnchor(fromValue: 0)
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast,
                                                                  end: Date(),
                                                                  options: .strictEndDate)
       
        hkSynchronizer.Synchronize(type: sampleType, predicate: mostRecentPredicate, anchor: anchor, limit: HKObjectQueryNoLimit) { [self] (success) in
            DispatchQueue.main.async {
                if (success) {
                    self.view.isUserInteractionEnabled = true
                } else {
                    self.showAlertMessage(title: "Health Data Query Fail!!", message: "건강 데이터를 측정해 주세요.")
                    self.view.isUserInteractionEnabled = false
                    
                }
            }
        }
    }
}
