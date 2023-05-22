
/*
 * Copyright 2022 Korea University(os.korea.ac.kr). All rights reserved.
 *
 * HeartBeat - Digital Health Platform Project
 *
 *
 */

import UIKit
import HealthKit
import Charts

class ECGViewController: UIViewController {
    
    var ecgSamples = [[(Double,Double)]] ()
    var ecgDates = [Date] ()
    var indices = [(Int,Int)]()
    
    var totalEcgCounts = 0
    var classification = [String] ()
    var systomsStatus = [String] ()
    var averageHeartRate = [Double] ()
    
    let healthStore = HKHealthStore()
    lazy var mainTitleLabel = UILabel()
    lazy var currentECGLineChart = LineChartView()
    lazy var contentView = UIView()
    var pickerView = UIPickerView()
    
 
    @IBOutlet weak var textTotalEcgCounts: UITextField!
    @IBOutlet weak var textClassification: UITextField!
    @IBOutlet weak var textSysmtomsStatus: UITextField!
    @IBOutlet weak var textAverageHeartRate: UITextField!
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // add title ECG
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        mainTitleLabel.text = "ECG"
        mainTitleLabel.textAlignment = .center
        mainTitleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        mainTitleLabel.sizeToFit()
        mainTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainTitleLabel)
        mainTitleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        mainTitleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        mainTitleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        mainTitleLabel.heightAnchor.constraint(equalTo: mainTitleLabel.heightAnchor, constant: 0).isActive = true
        
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.sizeToFit()
        contentView.addSubview(pickerView)
        pickerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        pickerView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -100).isActive = true
        pickerView.topAnchor.constraint(equalTo: mainTitleLabel.bottomAnchor, constant: 0).isActive = true
        
        pickerView.heightAnchor.constraint(equalTo: pickerView.heightAnchor).isActive = true
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.dataSource = self
        pickerView.delegate = self
        
        var counter = 0
        
        let healthKitTypes: Set = [HKObjectType.electrocardiogramType()]
        
        healthStore.requestAuthorization(toShare: nil, read: healthKitTypes) { (bool, error) in            
            if (bool) {
                //authorization succesful
                
                self.getECGsCount { (ecgsCount) in
                    print("Result is \(ecgsCount)")
                    if ecgsCount < 1 {
                        //print("You have no ecgs available")
                        return
                    } else {
                        self.totalEcgCounts = ecgsCount
                        
                        for i in 0...ecgsCount - 1 {
                            self.getECGs(counter: i) { (sample, ecgResults, ecgDate)  in
                                
                                DispatchQueue.main.async {
                                    self.ecgSamples.append(ecgResults)
                                    self.ecgDates.append(ecgDate)
                                    
                                    let classificationA : HKElectrocardiogram.Classification = sample.classification
                                    let classificationType : String? = getECGClassification(classification: classificationA)
                                    self.classification.append(classificationType!)
                                    self.averageHeartRate.append(sample.averageHeartRate?.doubleValue(for: HKUnit(from: "count/min")) ?? 0)
                                    self.systomsStatus.append(getECGSymptomsStatus(symptomsStatus: sample.symptomsStatus)!)
                                    
                                    counter += 1
                                    
                                    // the last thread will enter here, meaning all of them are finished
                                    if counter == ecgsCount {
                                        
                                        // sort ecgs by newest to oldest
                                        
                                        var newDates = self.ecgDates
                                        newDates.sort { $0 > $1 }
                                        for element in newDates {
                                            self.indices.append((self.ecgDates.firstIndex(of: element)!,newDates.firstIndex(of: element)!))
                                        }

                                        self.pickerView.reloadAllComponents()
                                        self.updateCharts(ecgSamples: self.ecgSamples[self.indices[0].0], animated: true)
                                    }
                                }
                                
                            }
                        }
                    }
                }
                
            } else {
                print("We had an error here: \n\(String(describing: error))")
            }
        }
    }
    
    
    func getECGs(counter: Int, completion: @escaping (HKElectrocardiogram, [(Double,Double)], Date) -> Void) {
        var ecgSamples = [(Double,Double)] ()
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast,end: Date.distantFuture,options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        var sample: HKElectrocardiogram?
        
        let ecgQuery = HKSampleQuery(sampleType: HKObjectType.electrocardiogramType(), predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            
            guard let samples = samples,
                  let mostRecentSample = samples.first as? HKElectrocardiogram else {
                return
            }
            //print(mostRecentSample)
            sample = (samples[counter] as! HKElectrocardiogram)
            
            let query = HKElectrocardiogramQuery(samples[counter] as! HKElectrocardiogram) { (query, result) in
                switch result {
                case .error(let error):
                    print("error: ", error)
                    
                case .measurement(let value):
                    let sample = (value.quantity(for: .appleWatchSimilarToLeadI)!.doubleValue(for: HKUnit.volt()) , value.timeSinceSampleStart)
                    ecgSamples.append(sample)
                    
                case .done:
                    //print("done")
                    DispatchQueue.main.async {
                        completion(sample!, ecgSamples,samples[counter].startDate)
                    }
                @unknown default:
                    print("default error")
                }
            }
            self.healthStore.execute(query)
        }
        
        self.healthStore.execute(ecgQuery)
    }
    
    func getECGsCount(completion: @escaping (Int) -> Void) {
        var result : Int = 0
        let max_ecg_count = 20
        
        let ecgQuery = HKSampleQuery(sampleType: HKObjectType.electrocardiogramType(), predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil){ (query, samples, error) in
            guard let samples = samples
            else {
                return
            }
            
            if result >= max_ecg_count {
                result = max_ecg_count
            }
            else {
                result = samples.count
            }
            
            completion(result)
        }
        self.healthStore.execute(ecgQuery)
    }
    
    
    func updateCharts(ecgSamples : [(Double,Double)], animated : Bool) {
        if !ecgSamples.isEmpty {
            
            // add line chart with constraints
            
            currentECGLineChart.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(currentECGLineChart)
            currentECGLineChart.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20).isActive = true
            currentECGLineChart.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20).isActive = true
            currentECGLineChart.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 10).isActive = true
            currentECGLineChart.heightAnchor.constraint(equalToConstant: view.frame.size.width + -115).isActive = true
            
            // customize line chart and add data
            
            var entries = [ChartDataEntry] ()
            for i in 0...ecgSamples.count-1 {
                entries.append(ChartDataEntry(x: ecgSamples[i].1, y: ecgSamples[i].0))
            }
            let set1 = LineChartDataSet(entries: entries, label: "ECG data")
            set1.colors = [UIColor.systemRed]
            set1.drawCirclesEnabled = false
            let data = LineChartData(dataSet: set1)
            self.currentECGLineChart.data = data
            currentECGLineChart.setVisibleXRangeMaximum(10)
            
            currentECGLineChart.rightAxis.enabled = false
            //let yAxis = currentECGLineChart.leftAxis
            if animated {
                currentECGLineChart.animate(xAxisDuration: 1.0)
            }
            
            currentECGLineChart.xAxis.labelPosition = .bottom
        }
    }
}


//MARK: - UIPickerViewDataSource

extension ECGViewController : UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if ecgDates.count < 1 {
            return 1
        } else {
            textTotalEcgCounts.text = String(ecgDates.count)
            return ecgDates.count
        }
    }
}


extension ECGViewController : UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.updateCharts(ecgSamples: self.ecgSamples[self.indices[row].0], animated: false)
        textTotalEcgCounts.text = String(totalEcgCounts)
        textClassification.text = classification[row]
        textSysmtomsStatus.text = systomsStatus[row]
        textAverageHeartRate.text = averageHeartRate[row].string
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy HH:mm"
        if ecgDates.count < 1 {
            return "Loading"
        } else {
            textTotalEcgCounts.text = String(totalEcgCounts)
            textClassification.text = classification[row]
            textSysmtomsStatus.text = systomsStatus[row]
            textAverageHeartRate.text = averageHeartRate[row].string
            return dateFormatter.string(from: ecgDates[indices[row].0])
        }
    }
}
