/*
 * Copyright 2022 Korea University(os.korea.ac.kr). All rights reserved.
 *
 * HeartBeat - Digital Health Platform Project
 *
 *
 */


import UIKit
import Photos

private let reuseIdentifier = "AlbumsCell"

class AlbumsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        return cell
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
  
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   
    }

    @IBAction func cancelPressed(_ sender: Any) {
        // assetPickerDelegate?.assetPickerDidCancel()
    }
  
    @IBAction func donePressed(_ sender: Any) {
        
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
}

// MARK: - Private Methods

extension AlbumsTableViewController {
    func fetchCollections() {
   
    }
  
    func showNoAccessAlertAndCancel() {
   
    }
  
    private func updateDoneButton() {

    }
}
