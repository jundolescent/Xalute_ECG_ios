

/*
 * Copyright 2022 Korea University(os.korea.ac.kr). All rights reserved.
 *
 * HeartBeat - Digital Health Platform Project
 *
 *
 */

import Foundation
import UIKit


struct Response: Codable {
    let success : Bool
    let result : String
    let message : String
}

//jsl 
func requestGet(url: String, completionHandler:@escaping(Bool, Any) -> Void) {
    
    //let sendData = try! JSONSerialization.data(withJSONObject: param, options: [])
    
    guard let url = URL(string: url) else {
        print("Error: cannot create URL")
        return
    }
        
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    //request.httpBody = sendData
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    //print ("SendData : ", sendData)
    //print ("SendData count : ", sendData.count )
    
    //print(String(sendData, encoding: .utf8)!)
    
    URLSession.shared.dataTask(with: request) { (data, response, error) in
        
        guard error == nil else {
            print("Error: error calling GET")
            print(error!)
            return
        }
        guard let data = data else {
            print("Error: Did not receive data")
            return
        }
        
        print(String(data: data, encoding: .utf8)!)
        
        guard let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode else {
            print("Error: HTTP request failed")
            return
        }
        
        guard let output = try? JSONDecoder().decode(Response.self, from: data) else {
            //print("Request_sendData: ", sendData)
            //print("Request_data: ", data)
            //print("Request_output: ", output)
            print("Error: JSON Data Parsing failed")
            return
        }
        
        completionHandler(true, output.result)
    }.resume()
    
}

func requestPost(url: String, method: String, param: [String: Any], completionHandler: @escaping (Bool, Any) -> Void) {

    let sendData = try! JSONSerialization.data(withJSONObject: param, options: [])
    
    guard let url = URL(string: url) else {
        print("Error: cannot create URL")
        return
    }
        
    var request = URLRequest(url: url)
    request.httpMethod = method
    request.httpBody = sendData
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    print ("SendData : ", sendData)
    print ("SendData count : ", sendData.count )
    
    //print(String(sendData, encoding: .utf8)!)
    
    URLSession.shared.dataTask(with: request) { (data, response, error) in
        
        guard error == nil else {
            print("Error: error calling GET")
            print(error!)
            return
        }
        guard let data = data else {
            print("Error: Did not receive data")
            return
        }
        
        print(String(data: data, encoding: .utf8)!)
        
        guard let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode else {
            print("Error: HTTP request failed")
            return
        }
        
        guard let output = try? JSONDecoder().decode(Response.self, from: data) else {
            //print("Request_sendData: ", sendData)
            //print("Request_data: ", data)
            //print("Request_output: ", output)
            print("Error: JSON Data Parsing failed")
            return
        }
        
        completionHandler(true, output.result)
    }.resume()
        
}

/* 메소드별 동작 분리 */
func request(url: String, method: String, param: [String: Any]? = nil, completionHandler: @escaping (Bool, Any) -> Void) {
    if method == "GET" {
        requestGet(url: url) { (success, data) in
            completionHandler(success, data)
        }
    }
    else {
        requestPost(url: url, method: method, param: param!) { (success, data) in
            completionHandler(success, data)
        }
    }
}


// makeJson... and Sending... 더 좋은 방법은 없을까?? -> 어짜피 FHIR resouce로 바뀔 것임 !!! 단지 테스트용...
func testSendHeartRateData()
{

    request(url: "http://localhost:8080"/*"http://34.64.120.5:80"*/, method: "POST", param: ["UUID":NSUUID().uuidString, HealthData.dataValues[0].title! : HealthData.dataValues[0].healthDataValue.value, HealthData.dataValues[1].title! : HealthData.dataValues[1].healthDataValue.value, HealthData.dataValues[2].title! : HealthData.dataValues[2].healthDataValue.value, HealthData.dataValues[3].title! : HealthData.dataValues[3].detail!]) { (success, data) in print(data) }
}


/* ECG 데이터만 전송하는 테스트 코드 */
func testSendECGData(ecgData:String) {
    request(url: "http://localhost:8080"/*"http://34.64.120.5:80"*/, method: "POST", param: ["ECGData" : ecgData]) { (success, data) in
        print("testSendECGData", data)
    }
}

func testBackGroundDelivery()
{
    request(url: "http://localhost:8080"/*"http://34.64.120.5:80"*/, method: "POST", param: ["BackGroundDelivery" : "ON"]) { (success, data) in print(data) }
}
