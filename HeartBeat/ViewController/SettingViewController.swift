
/*
 * Copyright 2022 Korea University(os.korea.ac.kr). All rights reserved.
 *
 * HeartBeat - Digital Health Platform Project
 *
 */

/*
 * Key definition - Do not modify without notice.
 * 1. serverAddress : 서버 주소
 * 2. userName      : 사용자 이름
 * 3. birthDate     : 생년월일
 */

import Foundation
import UIKit

class SettingViewController: UIViewController {
    
    var activeTextField:UITextField?
    
    @IBOutlet weak var serverTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var birthDateTextField: UITextField!
    
    var serverAddress:String?
    var userName:String?
    var birthDate:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        serverAddress = UserDefaultsProvider.getValueFromUserDefaults(key: "serverAddress") ?? "http://34.64.114.227/data/json/Bundle"
        userName = UserDefaultsProvider.getValueFromUserDefaults(key: "userName") ?? ""
        birthDate = UserDefaultsProvider.getValueFromUserDefaults(key: "birthDate") ?? ""
        
        serverTextField.text = serverAddress
        userNameTextField.text = userName
        birthDateTextField.text = birthDate
    }
    
    @IBAction func handleServerAddress(_ serverTextField: UITextField) {
        print("SettingViewController - handleServerAddress : ", serverTextField.text as Any)
        
        if let str = serverTextField.text {
            UserDefaultsProvider.setValueInUserDefaults(key: "serverAddress", value: str)
        }
        else {
            UserDefaultsProvider.setValueInUserDefaults(key: "serverAddress", value: "http://34.64.114.227/data/json/Bundle")
        }
    }
    

    @IBAction func handelUserName(_ userNameTextField: UITextField) {
        print("SettingViewController - handelUserName : ", userNameTextField.text as Any)
        if let str = userNameTextField.text {
            UserDefaultsProvider.setValueInUserDefaults(key: "userName", value: str)
        }
        else {
            UserDefaultsProvider.setValueInUserDefaults(key: "userName", value: "")
        }
    }
    
    
    @IBAction func handleUserBirthday(_ birthDateTextField: UITextField) {
        print("SettingViewController - handleUserBirthday")
        if let str = birthDateTextField.text {
            UserDefaultsProvider.setValueInUserDefaults(key: "birthDate", value: str)
        }
        else {
            UserDefaultsProvider.setValueInUserDefaults(key: "birthDate", value: "")
        }
        
    }
    
    @IBAction func textFieldEditing(_ sender: UITextField) {
        activeTextField = sender
    }
}
