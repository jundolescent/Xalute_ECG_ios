
/*
 * Copyright 2022 Korea University(os.korea.ac.kr). All rights reserved.
 *
 * HeartBeat - Digital Health Platform Project
 *
 */


import UIKit
import HealthKit


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let data = ["Heart", "Sleep", "Nutrition"]
    private let imageName = ["suit.heart.fill", "moon.zzz", "homepodmini.2"]
    
    let healthKitManager = HealthKitManager()
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HKAuthorizer.authorizeHealthKit(completion: { (success, error) in
            if success { print("HealthKit Authorized") }
            else {
                print("Error requesting access to HealthKit")
              
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "HealthKit 접근 권한", message:"HealthKit 접근 권한이 승인되지 않았습니다!", preferredStyle: UIAlertController.Style.alert)
                    let okAction = UIAlertAction(title:"OK", style: .default) { (action) in }
                    alert.addAction(okAction)
                    self.present(alert, animated:false, completion: nil)
                    self.view.isUserInteractionEnabled = false
                }
            }
        })
        
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
          
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.sharedData = "Hello"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL1", for: indexPath)
        
        cell.imageView?.image = UIImage(systemName: imageName[indexPath.row])
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.font = UIFont(name:"SeoulHanagang", size:30)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("ViewController Selected Index \(indexPath)")
        print("ViewController Selected Data : \(data[indexPath.row])")
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
            case 0:
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "HeartViewController") as! UITableViewController
                self.navigationController!.pushViewController(vc, animated: true)            
            case 1: //self.performSegue(withIdentifier: "SleepViewSegue", sender: nil)
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "SleepViewController")
                self.navigationController!.pushViewController(vc, animated: true)
            case 2: //self.performSegue(withIdentifier: "NutritionViewSegue", sender: nil)
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "PhotoViewController")
                self.navigationController!.pushViewController(vc, animated: true)
            default:
                return
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if (segue.identifier == "HeartView") {
               print("************** SEGUE : HeartViewController")
           }
        
           if (segue.identifier == "NutritionView") {
               print("************** SEGUE : NutritionView")
           }
    }
}

