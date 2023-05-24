
/*
 * Copyright 2022 Korea University(os.korea.ac.kr). All rights reserved.
 *
 * HeartBeat - Digital Health Platform Project
 *
 *
 */

import UIKit
import Photos
import MobileCoreServices

class PhotoViewController : UIViewController,
                            UICollectionViewDataSource,
                            UICollectionViewDelegate {
    
    //jsl
    // MARK: - [전역 변수 선언 실시]
    @IBOutlet weak var imageView: UIImageView! // 이미지 뷰
    let photo = UIImagePickerController() // 앨범 이동을 위한 컨트롤러
    var imageData : NSData? = nil // 서버로 이미지 등록을 하기 위함
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return 2
    }

    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as?
                 UICollectionViewCell else {
                return UICollectionViewCell()
            }
         
            return cell
     }
     
    /*
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomCollectionCell.identifier, for: indexPath) as! CustomCollectionCell

        //cell.imageView.image = UIImage(named: imageData.self)
        return cell
    }
     */
     

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.photo.delegate = self
        
      
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
          
    }
    
    

    
    @IBAction func addPhotoAssets(_ sender: Any) {
        let alert = UIAlertController(title: "Get food pictures from:", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
           /*
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "SelectAnAlbum")
            self.present(vc, animated: true, completion: nil)
            */
            DispatchQueue.main.async {
                print("")
                print("===============================")
                print("[A_Image >> openPhoto() :: 앨범 열기 수행 실시]")
                print("===============================")
                print("")
                // -----------------------------------------
                //jsl

                self.photo.sourceType = .photoLibrary // 앨범 지정 실시
                self.photo.allowsEditing = false // 편집을 허용하면 .edited를 저장할 수 있음 -> imageview 저장위해서
                self.present(self.photo, animated: false, completion: nil)
                // -----------------------------------------
            }
            
            
        }
        
        alert.addAction(libraryAction)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
           /*
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "SelectAnAlbum")
            self.present(vc, animated: true, completion: nil)
            */
            DispatchQueue.main.async {
                print("")
                print("===============================")
                print("[A_Image >> takePhoto() :: 사진 촬영 실시]")
                print("===============================")
                print("")
                // -----------------------------------------
                // [사진 찍기 카메라 호출]
                //jsl

                self.photo.sourceType = .camera // 앨범 지정 실시
                self.photo.allowsEditing = false // 편집을 허용x
                self.present(self.photo, animated: false, completion: nil)
                // -----------------------------------------
            }
            
            
        }
        alert.addAction(cameraAction)
        
        let internetAction = UIAlertAction(title: "Internet", style: .default) { _ in
          //self.downloadImageAssets()
        }
        alert.addAction(internetAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func requestPOST2(){
        // MARK: [URL 지정 실시]
        let urlComponents = URLComponents(string: "http://34.121.35.61:8080/api/addNewImage")
        let imageBase64String = imageData?.base64EncodedString()
        
        
        struct Request: Codable {
            let userName: String
            let birthDate: String
            let dataCreatedAt: String
            let `extension`: String
            let image: String

        }
        
        struct Response: Codable {
            let dataID: Double
        }
        
        let userName = UserDefaultsProvider.getValueFromUserDefaults(key: "userName") ?? ""
        let birthDate = UserDefaultsProvider.getValueFromUserDefaults(key: "birthDate") ?? ""
        
        // To-Do List
        // let dataCreatedAt -> 사진이 언제 생성되었는지 확인해야함
        // let 'extension' -> 사진의 형식을 알아내야함
        
        let dicData = ["userName":userName, "birthDate":birthDate,"dataCreatedAt": "2022-01-01T00:00:00", "extension": "jpg", "image": imageBase64String] as Dictionary<String, Any>? // 딕셔너리 사용해 json 데이터 만든다
        
        print(userName)
        print(birthDate)
        
        
        /*
        let Data = [
            "userName": "test09",
            "birthDate": "1996-03-11",
            "dataCreatedAt": "2022-01-01T00:00:00",
            "extension": "jpg",
            "image": "/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAkGBwgHBgkIBwgKCgkLDRYPDQwMDRsUFRAWIB0iIiAdHx8kKDQsJCYxJx8fLT0tMTU3Ojo6Iys/RD84QzQ5OjcBCgoKDQwNGg8PGjclHyU3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3Nzc3N//AABEIAIIAggMBIgACEQEDEQH/xAAbAAEBAQEBAQEBAAAAAAAAAAAAAQYCBQMHBP/EAEEQAAIBAwICBAcOBAcAAAAAAAABAgMEEQUGITEHEkFREyJhcYGSoRQVFzI2UlZzkZPBwtHiM0JysSM0RHSCorL/xAAUAQEAAAAAAAAAAAAAAAAAAAAA/8QAFBEBAAAAAAAAAAAAAAAAAAAAAP/aAAwDAQACEQMRAD8A/YSN9wbCXawKAAABM4YFBMcSgACN4ANhcvKRceJ0AAAAE7SgUAAQAAAAAAPM1zXdP0KjTqahVlHwjahGEetKWOfoXAD0wZH4RdA+dc/dr9R8IugfOuful+oGuD4mRfSJoC/muful+o+EXQPnXP3S/UDXAzWnb50PULuna0q1WnUqSUYOpTwnJ8llZNKAAAAAAUAAQAjTWAKAABi95JS3dthSSadZ5T/rgbQxm8It7u2y0uCqtt93jwA1tSjRjTlKNtTk0m1FQWX5DPVdYvKeh0b+O2KkrmdXqStccYrj4z8XOOHcaZc8l/ADF2u49SrXNGlU2fVhGc1GUuPipvi+MFy85sHb0M/waXqI+mfKAMT0h06dOroTp04RzerPVil2xNs+bMf0hwbnocurlK9XbxXFGwfNgAAAAOeYHYAAjCyAAAAAxm7ptbt2yuyVbD9eBszF7x+V+1/rn/7gBrL+9ttOtKl3eVFTo01mUvwS7WY+nre59xOU9AtKVlZJtRuLnnLy9vsT85d2Rlrm7NM0BykrWnHw9dReOtz/AAWP+R9d+XV9YS0W20a4dpKpUlCEabUYtrqKKfZjjy5AcTob80/NeN1aX6jxdLCy/ZH2M9bbW5qOtudtWoytNQpZ8Jbzfd2xzj7Ow83T951LS4Vhuq0lY3S4KuovqT8uO7yrK8x8d+UYWvuDdGmSi69GpFTqU2mqsHy4rn83zSA+3SDVlSnonUeHK8UW+3GY5Ni+bMT0gVY147erU/i1LuM15n1WbZ82AAAEayygAUAAQAjAoAAGL3j8r9r/AF354G0MZvD5X7Y+tb/7wA51WotM6R9Pu6/i0Ly38Cpvkpcv79T7TjpLqytrnQa6g5ulcSmoL+ZpwaXsNFuXQqGv6c7aq+pVi+tRq4+JLy96fajNUNxaxt5Rtdy6bVuadJ/4d3Rw847cvg358PvALRNd3ZUhcbhquxsoy61O1pLE/secPyvL8iPpvyNtpu2bTRLGGJV6sYUaSeXhPPp8Zpek7q9INtWXg9K0y9urh8IxcEln0ZZ9dA0DULzVVr25WvdUf8vbLGKXc2lyxngvS+IH8u+aHua221b5z4G4hT+xRX4G5fNmN6RU3V0LC/1q/KbJ88gAAAAGQKAAOW8ESzxLgoAAADH7rlFbv2314ycXVaWPndeGDYGM3g2t37Yw+HhvzwA2aWGOzAPM3Baapd2kIaPfQs6ynmU5xypRw+HJ47APSjFR+LFLzIreEZG20fd8LmlOvuGhKlGac49TPWWeK+Ka5oDHdIFTqVNFwuMrxRz3cYmxfNmM6Rv4mhf71f3ibN82AAAE7SsACgACAAAAABn91beraxUsrqxu1bXtnJunOUcrjh+xpGgAGN95N4/SSl6n7QtE3j9I6XqftNkAMb7ybx7NyU8/0ftHvJvH6SUvU/abIAYuG1Navb60qa7rMLm3tqqqxhGHFtccclzwjaAAAAAAAFAAEJxKMgAAAAOeL8wFT4lAAAACce4qCAAAACc3lkw2zpAUAACFAAAACIoAAAAAAIUAAAAIUAAAAP/Z"
        ]
         */
        
        let sendData = try! JSONSerialization.data(withJSONObject: dicData, options: [])
        
        var requestURL = URLRequest(url: (urlComponents?.url)!) // url 주소 지정
        requestURL.httpMethod = "POST" // POST 방식 multipart/form-data
        requestURL.httpBody = sendData
        //requestURL.addValue("text/plain;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        requestURL.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
            
            guard error == nil else {
                print("Error: error calling POST")
                print(error!)
                return
            }
            guard let data = data else {
                print("Error: Did not receive data")
                return
            }

            // Failed to upload image일 경우 이미지가 업로드되지 않은 것임
            print(String(data: data, encoding: .utf8)!)
            
            guard let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode else {
                print("Error: HTTP request failed")
                return
            }
            
            /*
            guard let output = try? JSONDecoder().decode(Response.self, from: data) else {
                //print("Request_sendData: ", sendData)
                //print("Request_data: ", data)
                //print("Request_output: ", output)
                print("Error: JSON Data Parsing failed")
                return
            }
            */
             
             

        }.resume()
        
    }
    
    // MARK: - [URL Session Post 멀티 파트 사진 데이터 업로드]
    func requestPOST() {
        
        // jsl URL 수정해야함!
        // MARK: [URL 지정 실시]
        let urlComponents = URLComponents(string: "http://34.121.35.61:8080/api/addNewImage")
        
        
        
        // MARK: [사진 파일 파라미터 이름 정의 실시]
        let file = "file"
        
        
        // MARK: [전송할 데이터 파라미터 정의 실시]
        var reqestParam : Dictionary<String, Any> = [String : Any]()
        //reqestParam["idx"] = 201 // 일반 파라미터
        //jsl for test
        reqestParam["userName"] = "junseok"
        reqestParam["birthDate"] = "19960310"
        reqestParam["dataCreatedAt"] = "2023-05-10"
        reqestParam["extenstion"] = "jpg"
        
        let imageBase64String = imageData?.base64EncodedString()
        //reqestParam["\(file)"] = self.imageData! as NSData // 사진 파일
        //reqestParam["\(file)"] = imageBase64String
        
        //jsl -> 0523 수정
        reqestParam["image"] = imageBase64String
        
        
        // [boundary 설정 : 바운더리 라인 구분 필요 위함]
        let boundary = "Boundary-\(UUID().uuidString)" // 고유값 지정
        
        print("")
        print("====================================")
        print("[A_Image >> requestPOST() :: 바운더리 라인 구분 확인 실시]")
        print("boundary :: ", boundary)
        print("====================================")
        print("")
        
        
        
        // [http 통신 타입 및 헤더 지정 실시]
        var requestURL = URLRequest(url: (urlComponents?.url)!) // url 주소 지정
        requestURL.httpMethod = "POST" // POST 방식 multipart/form-data
        requestURL.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type") // 멀티 파트 타입
        
        
        
        // [서버로 전송할 uploadData 데이터 형식 설정]
        var uploadData = Data()
        let boundaryPrefix = "--\(boundary)\r\n"
        
        
        
        // [멀티 파트 전송 파라미터 삽입 : 딕셔너리 for 문 수행]
        for (key, value) in reqestParam {
            if "\(key)" == "\(file)" { // MARK: [사진 파일 인 경우]
                print("")
                print("====================================")
                print("[A_Image >> requestPOST() :: 멀티 파트 전송 파라미터 확인 실시]")
                print("타입 :: ", "사진 파일")
                print("key :: ", key)
                print("value :: ", value)
                print("====================================")
                print("")
                
                uploadData.append(boundaryPrefix.data(using: .utf8)!)
                // file -> image
                uploadData.append("Content-Disposition: form-data; name=\"\(file)\"; filename=\"\(file)\"\r\n".data(using: .utf8)!) // [파라미터 key 지정]
                uploadData.append("Content-Type: \("image/jpg")\r\n\r\n".data(using: .utf8)!) // [전체 이미지 타입 설정]
                //uploadData.append(value as! Data) // [사진 파일 삽입]
                uploadData.append("\(value)\r\n".data(using: .utf8)!) // [value 삽입]
                uploadData.append("\r\n".data(using: .utf8)!)
                uploadData.append("--\(boundary)--".data(using: .utf8)!)
            }
            else { // MARK: [일반 파라미터인 경우]
                print("")
                print("====================================")
                print("[A_Image >> requestPOST() :: 멀티 파트 전송 파라미터 확인 실시]")
                print("타입 :: ", "일반 파라미터")
                print("key :: ", key)
                print("value :: ", value)
                print("====================================")
                print("")
                
                uploadData.append(boundaryPrefix.data(using: .utf8)!)
                uploadData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!) // [파라미터 key 지정]
                if (key == "image"){
                    uploadData.append("Content-Type: \("image/jpg")\r\n\r\n".data(using: .utf8)!) // [전체 이미지 타입 설정]
                }
                uploadData.append("\(value)\r\n".data(using: .utf8)!) // [value 삽입]
                if (key == "image"){
                    uploadData.append("\r\n".data(using: .utf8)!)
                    uploadData.append("--\(boundary)--".data(using: .utf8)!)
                }
            }
        }

        
        
        // [http 요쳥을 위한 URLSessionDataTask 생성]
        print("")
        print("====================================")
        print("[A_Image >> requestPOST() :: 사진 업로드 요청 실시]")
        print("url :: ", requestURL)
        print("uploadData :: ", uploadData)
        print("====================================")
        print("")
        
        // MARK: [URLSession uploadTask 수행 실시]
        let dataTask = URLSession(configuration: .default)
        dataTask.configuration.timeoutIntervalForRequest = TimeInterval(20)
        dataTask.configuration.timeoutIntervalForResource = TimeInterval(20)
        dataTask.uploadTask(with: requestURL, from: uploadData) { (data: Data?, response: URLResponse?, error: Error?) in

            // [error가 존재하면 종료]
            guard error == nil else {
                print("")
                print("====================================")
                print("[A_Image >> requestPOST() :: 사진 업로드 요청 실패]")
                print("fail : ", error?.localizedDescription ?? "")
                print("====================================")
                print("")
                return
            }

            // [status 코드 체크 실시]
            let successsRange = 200..<300
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, successsRange.contains(statusCode)
            else {
                print("")
                print("====================================")
                print("[A_Image >> requestPOST() :: 사진 업로드 요청 에러]")
                print("error : ", (response as? HTTPURLResponse)?.statusCode ?? 0)
                print("allHeaderFields : ", (response as? HTTPURLResponse)?.allHeaderFields ?? "")
                print("msg : ", (response as? HTTPURLResponse)?.description ?? "")
                print("====================================")
                print("")
                return
            }

            // [response 데이터 획득, json 형태로 변환]
            let resultCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            let resultLen = data! // 데이터 길이
            do {
                guard let jsonConvert = try JSONSerialization.jsonObject(with: data!) as? [String: Any] else {
                    print("")
                    print("====================================")
                    print("[A_Image >> requestPOST() :: 사진 업로드 요청 에러]")
                    print("error : ", "json 형식 데이터 convert 에러")
                    print("====================================")
                    print("")
                    return
                }
                guard let JsonResponse = try? JSONSerialization.data(withJSONObject: jsonConvert, options: .prettyPrinted) else {
                    print("")
                    print("====================================")
                    print("[A_Image >> requestPOST() :: 사진 업로드 요청 에러]")
                    print("error : ", "json 형식 데이터 변환 에러")
                    print("====================================")
                    print("")
                    return
                }
                guard let resultString = String(data: JsonResponse, encoding: .utf8) else {
                    print("")
                    print("====================================")
                    print("[A_Image >> requestPOST() :: 사진 업로드 요청 에러]")
                    print("error : ", "json 형식 데이터 >> String 변환 에러")
                    print("====================================")
                    print("")
                    return
                }
                print("")
                print("====================================")
                print("[A_Image >> requestPOST() :: 사진 업로드 요청 성공]")
                print("allHeaderFields : ", (response as? HTTPURLResponse)?.allHeaderFields ?? "")
                print("resultCode : ", resultCode)
                print("resultLen : ", resultLen)
                print("resultString : ", resultString)
                print("====================================")
                print("")
            } catch {
                print("")
                print("====================================")
                print("[A_Image >> requestPOST() :: 사진 업로드 요청 에러]")
                print("error : ", "Trying to convert JSON data to string")
                print("====================================")
                print("")
                return
            }
        }.resume()
    }
    

    
}



// MARK: [앨범 선택한 이미지 정보를 확인 하기 위한 딜리게이트 선언]
extension PhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: [사진, 비디오 선택을 했을 때 호출되는 메소드]
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            
            // [앨범에서 선택한 사진 정보 확인]
            print("")
            print("====================================")
            print("[A_Image >> imagePickerController() :: 앨범에서 선택한 사진 정보 확인 및 사진 표시 실시]")
            //print("[사진 정보 :: ", info)
            print("====================================")
            print("")
            
            
            // [이미지 뷰에 앨범에서 선택한 사진 표시 실시]
            //self.imageView.image = img

            
            
            // [이미지 데이터에 선택한 이미지 지정 실시]
            //self.imageData = (img as? UIImage)!.jpegData(compressionQuality: 0.8) as NSData?
            self.imageData = img.jpegData(compressionQuality: 0.8) as NSData? // jpeg 압축 품질 설정

            /*
            print("")
            print("===============================")
            print("[A_Image >> imagePickerController() :: 앨범에서 선택한 사진 정보 확인 및 사진 표시 실시]")
            print("[imageData :: ", self.imageData)
            print("===============================")
            print("")
            // */
            
            
            // [멀티파트 서버에 사진 업로드 수행]
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // [1초 후에 동작 실시]
                self.requestPOST2()
            }
        }
        // [이미지 파커 닫기 수행]
        dismiss(animated: true, completion: nil)
    }
    
    
    
    // MARK: [사진, 비디오 선택을 취소했을 때 호출되는 메소드]
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("")
        print("===============================")
        print("[A_Image >> imagePickerControllerDidCancel() :: 사진, 비디오 선택 취소 수행 실시]")
        print("===============================")
        print("")
        
        // [이미지 파커 닫기 수행]
        self.dismiss(animated: true, completion: nil)
    }
}
