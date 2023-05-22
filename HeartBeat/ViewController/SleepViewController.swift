
/*
 * Copyright 2022 Korea University(os.korea.ac.kr). All rights reserved.
 *
 * HeartBeat - Digital Health Platform Project
 *
 *
 */

import Foundation


import Foundation
import UIKit


class SleepViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
  
    private let data = ["수면 데이터 설정", "수면 데이터 보기"]
    private let imageName = ["sleep.circle.fill", "moon.fill"]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL_SLEEP", for: indexPath)
        
        cell.imageView?.image = UIImage(systemName: imageName[indexPath.row])
        cell.textLabel?.text = data[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
