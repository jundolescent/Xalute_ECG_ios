
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

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView! // 이미지 뷰
    let photo = UIImagePickerController() // 앨범 이동을 위한 컨트롤러
    var imageData : NSData? = nil // 서버로 이미지 등록을 하기 위함
    
    let columns: CGFloat = 3
    let space: CGFloat = 1

    var images = [String]()
    var images2 = [UIImage]()
    
    //refresh 기능만 만들면

    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images2.count
        //return 12
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photocell", for: indexPath)  as! photocell

 
        //print(self.images2.count)
        DispatchQueue.main.async() {

            
        }
        cell.Image.image = self.images2[indexPath.item]

        let itemSize = CGSize(width:42.0, height:42.0)
        UIGraphicsBeginImageContextWithOptions(itemSize, false, 0.0)
        let imageRect = CGRect(x:0.0, y:0.0, width:itemSize.width, height:itemSize.height)
        cell.Image.image!.draw(in:imageRect)
        cell.Image.image! = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        
        return cell
     }
    
    //셀 크기
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width / columns) - (space * (columns - 1))
        return CGSize(width: width, height: width)
    }

    //위아래 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return space
    }

    //좌우 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return space
    }
    
     
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.photo.delegate = self
        //cell.Image.image = UIImage(named: images[indexPath.row])
        let userName = UserDefaultsProvider.getValueFromUserDefaults(key: "userName") ?? ""
        let birthDate = UserDefaultsProvider.getValueFromUserDefaults(key: "birthDate") ?? ""
        //cell당 하나씩 해야함! -> 이건 하나의 셀에서 다 욱여넣는 방시인듯
        //print(self.images2.count)
        //print(indexPath.item)
        let dicData = ["user":["name":userName, "birthday":birthDate]] as Dictionary<String, Any>? // 딕셔너리 사용해 json 데이터 만든다
        let sendData = try! JSONSerialization.data(withJSONObject: dicData, options: [])
        var urlComponents = URLComponents(string:"http://api.xalute.org:8080/data/getimage")
        var requestURL = URLRequest(url: (urlComponents?.url)!)
        requestURL.httpMethod = "POST" // GET
        requestURL.setValue("application/json", forHTTPHeaderField: "Content-Type")
        requestURL.httpBody = sendData
    

        URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
            
            guard error == nil else {
                print("Error: error calling GET")
                print(error!)
                self.showAlertMessage (title: "", message: "이미지 데이터 전송 실패")
                return
            }
            guard let data = data else {
                print("Error: Did not receive data")
                self.showAlertMessage (title: "", message: "이미지 데이터 전송 실패")
                return
            }

            //print(String(data: data, encoding: .utf8)!)
            
            guard let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode else {
                print("Error: HTTP request failed")
                self.showAlertMessage (title: "", message: "이미지 데이터 전송 실패")
                return
            }

            // 여기부터 다시 진행하기!
            var nameArr = [String]()
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String : String]] {

                for i in json{
                    //print(i["Data"] as! String)
                    nameArr.append(i["Data"] as! String)
                    if self.images.contains(i["Data"] as! String) == false {
                        self.images.append(i["Data"] as! String)
                        //print(i["Data"] as! String)
                        //print("hello")
                        //영어로만 이루어져있을 경우에는 아래와 같이 전송 한글 방식으로 전송하면 안 받아짐,,
                        //let url = URL(string: "https://storage.googleapis.com/xalute_data/image_%EC%9D%B4%EC%A4%80%EC%84%9D23_2023-06-02_17:14:01.jpg")
                        //        var request = URLRequest(url: url)!
                        
                        //한글을 포함하고 있을 경우에는 아래와 같이
                        let url = i["Data"] as! String
                        //let url = "https://storage.googleapis.com/xalute_data/image_%EC%9D%B4%EC%A4%80%EC%84%9D23_2023-06-02_17:14:01.jpg"
                        
                        let url2 = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                        let url3 = URL(string: url2)!
                        //let url = URL(string: urladd)
                        //한글 포함 주소 변환해야함
                        var request = URLRequest(url: url3)
                        request.httpMethod = "GET"

                        URLSession.shared.dataTask(with: request) { data, response, error in
                            guard
                                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                                let data = data, error == nil,
                                let image = UIImage(data: data)
                                else {
                                    print("Download image fail : \(url)")
                                    return
                            }
                            self.images2.append(image)
                            print(self.images2.count)
  
                            DispatchQueue.main.async() {
                                print("Download image success \(url)")
                                self.collectionView.reloadData()
                                //cell.Image.image = image
                                //self?.imageView.image = image
                                //self.collectionView.

                            }
                        }.resume()
                    }
                }
            }

        }.resume()
      
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
          
    }
    
    func showAlertMessage(title: String, message:String) {
        DispatchQueue.main.async {
            let alertMessage = UIAlertController(title: "", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .cancel)
            
            alertMessage.addAction(okAction)
            self.present(alertMessage, animated: true, completion: nil)
        }
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
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let time = formatter.string(from: Date())
        
        // To-Do List
        // let dataCreatedAt -> 사진이 언제 생성되었는지 확인해야함
        // let 'extension' -> 사진의 형식을 알아내야함
        
        let dicData = ["userName":userName, "birthDate":birthDate,"dataCreatedAt": time, "extension": "jpg", "image": imageBase64String] as Dictionary<String, Any>? // 딕셔너리 사용해 json 데이터 만든다
        
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
                self.showAlertMessage (title: "", message: "이미지 데이터 전송 실패")
                return
            }
            guard let data = data else {
                print("Error: Did not receive data")
                self.showAlertMessage (title: "", message: "이미지 데이터 전송 실패")
                return
            }

            // Failed to upload image일 경우 이미지가 업로드되지 않은 것임
            print(String(data: data, encoding: .utf8)!)
            
            guard let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode else {
                print("Error: HTTP request failed")
                self.showAlertMessage (title: "", message: "이미지 데이터 전송 실패")
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
            self.showAlertMessage (title: "", message: "이미지 데이터 전송 완료!")

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
            self.imageData = img.jpegData(compressionQuality: 0.8) as NSData? // jpeg 압축 품질 설정

            
            
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





