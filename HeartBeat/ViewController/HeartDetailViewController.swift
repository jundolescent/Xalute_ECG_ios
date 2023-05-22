
/*
 * Copyright 2022 Korea University(os.korea.ac.kr). All rights reserved.
 *
 * HeartBeat - Digital Health Platform Project
 *
 *
 */


import UIKit
import Charts

class HeartDetailViewController : UITableViewController {
    
    //@IBOutlet var titleHeader : String?
    @IBOutlet weak var endDate : UILabel!

    @IBOutlet weak var ecgInfo: UILabel!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var startDate: UILabel!
    
    lazy var currentECGLineChart = LineChartView()

    
    var indexCell = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateCharts(ecgSamples: HealthData.ecgSamples, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
    
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        startDate.font = UIFont(name:"SeoulHanagang", size:10)
        endDate.font = UIFont(name:"SeoulHanagang", size:10)
        startDate.text = dateFormatter.string(from : HealthData.dataValues[self.indexCell].healthDataValue.startDate)
        
        
        // 데이터 측정 시간을 서버에 보내기 위해...
        UserDefaultsProvider.setValueInUserDefaults(key: "Datetest", value: dateFormatter.string(from : HealthData.dataValues[self.indexCell].healthDataValue.startDate))
        
        endDate.text = dateFormatter.string(from : HealthData.dataValues[self.indexCell].healthDataValue.endDate)
        
        ecgInfo.text = (HealthData.dataValues[self.indexCell].detail ?? "") + " 평균 " + String(HealthData.dataValues[self.indexCell].healthDataValue.value) + " BPM"
        //ecgDates.append(HealthData.dataValues[self.indexCell].healthDataValue.startDate)
    }
    
  
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return HealthData.dataValues[self.indexCell].title
    }

    
    
    func updateCharts(ecgSamples : [(Double,Double)], animated : Bool) {
        if !ecgSamples.isEmpty {
            // add line chart with constraints
            
            currentECGLineChart.translatesAutoresizingMaskIntoConstraints = false
            
            contentView.addSubview(currentECGLineChart)
            currentECGLineChart.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10).isActive = true
            currentECGLineChart.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -5).isActive = true
            currentECGLineChart.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 100).isActive = true
            currentECGLineChart.heightAnchor.constraint(equalTo: contentView.heightAnchor, constant: 0).isActive = true
    
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

            if animated {
                currentECGLineChart.animate(xAxisDuration: 1.0)
            }
            
            currentECGLineChart.xAxis.labelPosition = .bottom
        }
    }

}
