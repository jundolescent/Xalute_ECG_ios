
/*
 * Copyright 2022 Korea University(os.korea.ac.kr). All rights reserved.
 *
 * HeartBeat - Digital Health Platform Project
 *
 *
 */

import Foundation
import SMART
import FHIR

//0829
import WebKit


class FhirClient {
    var client: Client
    
    init(client: Client) {
        self.client = client
    }
    
    //jsl
    var WKwebView: WKWebView!
    
    
    func getUserAgent() {

              let webConfiguration = WKWebViewConfiguration()
       WKwebView = WKWebView(frame: .zero, configuration: webConfiguration)
             WKwebView.evaluateJavaScript("navigator.userAgent", completionHandler: { (result, error) in
                  debugPrint(result as Any)
                  debugPrint(error as Any)

                  if let unwrappedUserAgent = result as? String {
                      print("userAgent: \(unwrappedUserAgent)")
                  } else {
                      print("failed to get the user agent")
                  }
              })
    }

    
    func send(resource: Resource, closure: @escaping (Bool) -> Void) {
        
        //jsl
        
        print("Store ECG data to SQL storage")
        print("Add ECG data to Blockchain on GCP")
        let result = try? resource.asJSON()
        request("http://34.121.35.61:8080/data/add", "POST", result) { (success, data) in
            print(success)
            print(data)
            if success{
                closure(true)
            }
            else{
                closure(false)
            }

        }
        
        
        
        
        
        //original code
        /*
         print("Store ECG data to SQL storage")
         resource.create(client.server) { error in
             if nil != error {
                 // Transmission of the observation failed
                 print("sending error")
                 print(error!)
                 closure(false)
             } else {
                 //Observation was transmitted successfully
                 print("FhirClient - Successful transmission of resource")
                 closure(true)
             }
         }
         */

        
    }
    
    func requestPost(url: String, method: String, param: [String: Any], completionHandler: @escaping (Bool, Any) -> Void) {

        let sendData = try! JSONSerialization.data(withJSONObject: param, options: [])
        print(sendData)
        
        guard let url = URL(string: url) else {
            print("Error: cannot create URL")
            return
        }
        
        struct Response: Codable {
            let dataId: Double

        }
         
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = sendData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Mozilla/5.0 Apple", forHTTPHeaderField: "User-Agent")
        
        //getUserAgent()
        print ("hello: ", request.allHTTPHeaderFields )
        print ("SendData : ", sendData)
        print ("SendData count : ", sendData.count )
        
        //print(String(sendData, encoding: .utf8)!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard error == nil else {
                print("Error: error calling POST")
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
            
            // 일단 datID만 반환하므로 없앰
            guard let output = try? JSONDecoder().decode(Response.self, from: data) else {
                //print("Request_sendData: ", sendData)
                //print("Request_data: ", data)
                //print("Request_output: ", output)
                print("Error: JSON Data Parsing failed")
                return
            }
             
            if(output.dataId == "null"){
                print("Error: 중복 dataID")
                return
            }
            
            
            completionHandler(true, output.dataId)
        }.resume()
            
    }
    
    
    func requestGet(url: String, completionHandler: @escaping (Bool, Any) -> Void) {
        guard let url = URL(string: url) else {
            print("Error: cannot create URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        struct Response: Codable {
            let Birthday: String
            let CreatedAt: String
            let Data: String
            let DataCreatedAt: String
            let DataType: String
            let ID: String
            let Name: String

        }
        
        struct ECGDATA: Codable{
            let Response: String
        }
         URLSession.shared.dataTask(with: request) { data, response, error in

             guard error == nil else {
                 print("Error: error calling GET")
                 print(error!)
                 return
             }
             guard let data = data else {
                 print("Error: Did not receive data")
                 return
             }
             guard let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode else {
                 print("Error: HTTP request failed")
                 return
             }

             do {
                 let decodedResponse = try JSONDecoder().decode([Response].self, from: data)
                 print(decodedResponse)
             } catch let DecodingError.dataCorrupted(context) {
                 print(context)
             } catch let DecodingError.keyNotFound(key, context) {
                 print("Key '\(key)' not found:", context.debugDescription)
                 print("codingPath:", context.codingPath)
             } catch let DecodingError.valueNotFound(value, context) {
                 print("Value '\(value)' not found:", context.debugDescription)
                 print("codingPath:", context.codingPath)
             } catch let DecodingError.typeMismatch(type, context)  {
                 print("Type '\(type)' mismatch:", context.debugDescription)
                 print("codingPath:", context.codingPath)
             } catch {
                 print("error: ", error)
                 return
             }
             
             /*
              guard let output = try? JSONDecoder().decode(Response.self, from: data) else {
                  print("Error: JSON Data Parsing failed")
                  return
              }
              */

             
             //completionHandler(true, output)
              

         }.resume()
         

    }
    func request(_ url: String, _ method: String, _ param: [String: Any]? = nil, completionHandler: @escaping (Bool, Any) -> Void) {
        if (method == "GET") {
            requestGet(url: url) { (success, data) in
                completionHandler(success, data)
            }
        }
        else if (method == "POST") {
            requestPost(url: url, method: method, param: param!) { (success, data) in
                completionHandler(success, data)
            }
        }
    }
           
    
    //jsl, 테스트용 코드
    func query(resource: Resource, closure: @escaping (Bool) -> Void){
            //jsl
        //requestGet

        /*
        let parameters: [String: Any] = [
            "type":"batch",
            "resourceType":"Bundle",
            "entry":
                [
                    [
                    "request":
                        [
                            "url":"Observation",
                            "method":"POST"
                        ],
                    "resource":
                        [
                            "resourceType":"Observation",
                            "id":"mjkim515",
                            "component":
                                [
                                    [
                                        "code":
                                            [
                                                "coding":
                                                    [
                                                        [
                                                            "display":"MDC_ECG_ELEC_POTL_I"
                                                        ],
                                                        [
                                                            "code":"mV",
                                                            "display":"microvolt",
                                                            "system":"http:"
                                                        ]
                                                    ]
                                            ],
                                        "valueSampledData":
                                            [
                                                "origin":
                                                    [
                                                        "value":55
                                                    ],
                                                "period":29.998046875,
                                                "data":"(0.0006958216552734375, 0.0) (0.0009062403564453125, 0.001953125) (0.0010620897216796874, 0.00390625) (0.0011458143310546873, 0.005859375) (0.001167954833984375, 0.0078125) (0.001161498779296875, 0.009765625) (0.0011577355952031249, 0.01171875) ",
                                                "dimensions":2
                                            ]
                                    ]
                                ],
                            "subject":
                                [
                                    "reference":"Patient/jslee: 19960415 2023-11-23 19:59"
                                ],
                            "status":"final",
                            "code":[]
                        ]
                ]
            ]
        ]
         
         request("http://34.121.35.61:8080/data/add", "POST", parameters) { (success, data) in

             print(data)
         }
         */
         request("http://34.121.35.61:8080/data/get", "GET") { (success, data) in
           print(data)
         }
        //Birthday, CreatedAt, Data,DataCreatedAt, DataType, ID, Name
        /*
         request("http://34.121.35.61:8080/data/add", "POST", {"type":"batch","resourceType":"Bundle","entry":[{"request":{"url":"Observation","method":"POST"},"resource":{"resourceType":"Observation","id":"mjkim515","component":[{"code":{"coding":[{"display":"MDC_ECG_ELEC_POTL_I"},{"code":"mV","display":"microvolt","system":"http:"}]},"valueSampledData":{"origin":{"value":55},"period":29.998046875,"data":"(0.0006958216552734375, 0.0) (0.0009062403564453125, 0.001953125) (0.0010620897216796874, 0.00390625) (0.0011458143310546873, 0.005859375) (0.001167954833984375, 0.0078125) (0.001161498779296875, 0.009765625) (0.0011577355957031249, 0.01171875) ","dimensions":2}}],"subject":{"reference":"Patient/테스트134: 20221114 2022-11-23 19:59"},"status":"final","code":{}}}]}) { (success, data) in

             print(data)
         }
         */
            
    }
        

    
        

}

