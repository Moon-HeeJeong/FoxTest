//
//  ViewController.swift
//  FoxTest
//
//  Created by 정문희 on 2021/09/30.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var videoData :Array<Dictionary<String, Any>>?
    
    func getVideos() {
        
        
        let baseUrl = URL(string:"https://api.pexels.com/videos/popular")!
        var request = URLRequest(url: baseUrl)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("563492ad6f9170000100000130d4d4134d934e1ab03e08d12a6716ac", forHTTPHeaderField: "Authorization")
        
        
        let task = URLSession.shared.dataTask(with:request) { data, response, error in
            
            //옵셔널 바인딩
            if let dataJson = data{
           
                do{
                    let json = try JSONSerialization.jsonObject(with: dataJson, options: []) as! Dictionary<String, Any>
                    
                   
                    let videos = json["videos"] as? Array<Dictionary<String, Any>>
                    self.videoData = videos
                    
                    
            
                    DispatchQueue.main.async {
                        //메인에서 하도록 하는 코드,
                        //어싱크는 비동기로, 가져오면 바로 띄워라
                        
                        self.TableViewVideo.reloadData() //데이터 가져왔다고 통보 //Main에서 하도록 해야함
                    }
                }
                catch{}
            }
        }
        task.resume()
    }
    
    
    
    @IBOutlet weak var TableViewVideo: UITableView!
    
    
    //데이터 몇개
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let videos = videoData{
            return videos.count //뉴스 수 많큼 돌아
        }
        else{
            return 0
        }
    }
    
    //데이터 무엇
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = TableViewVideo.dequeueReusableCell(withIdentifier: "ListCell1", for: indexPath) as! ListCell1
        
        
     /*   let idx = indexPath.row
        if let videos = videoData{
            let row = videos[idx]
           
            if let r = row as? Dictionary<String, Any> {
                if let name = r["id"] as? String{ //optional쓰인거 없애기
                    cell.LabelText.text = name
                }
            }
        
        }*/
        
        
        let idx = indexPath.row
        if let videos = videoData{
            let row = videos[idx]
            if let r = row as? Dictionary<String, Any> {
                
              //  if let id = r["id"] as? String{
                    
                    
                if let user = r["user"] as? Dictionary<String, Any> {
                    
                    if let userName = user["name"] as? String{
                    
                    cell.LabelText.text = userName
                    
                    let imageUrl = r["image"] as? String
                    if let img = imageUrl {
                        if let data = try? Data(contentsOf: URL(string: img)!){
                        
                            //Main Thread로
                            DispatchQueue.main.async {
                                cell.ImageMain.image = UIImage(data: data)
    
                            }
                            
                        }
                    }
                    }
                }
        }
        }
        return cell
        
    }
    
    
    
    //화면이동(값 이미 셋팅)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier, "VideoDetail" == id {
            if let controller = segue.destination as? VideoDetailController{
            
               
                if let videos = videoData{
                    if let indexPath = TableViewVideo.indexPathForSelectedRow{
                        let row = videos[indexPath.row]
                        if let r = row as? Dictionary<String, Any> {
           
                            //유저이름 보내기
                            if let user = r["user"] as? Dictionary<String, Any> {
                                
                                if let userName = user["name"] as? String{
                                    controller.userName = userName
                                }
                            }
                                
                                if let imageUrl = r["image"] as? String{
                                    controller.imageUrl = imageUrl
                                   // print("imageUrl \(imageUrl)")
                                }
                         
                            //비디오 링크 보내기
                            if let videoFiles = r["video_files"] as? Array<Dictionary<String, Any>>? {
                                
                                let firstVideoFiles = videoFiles![0] as? Dictionary<String, Any>
                                
                                
                                if let firstVideo = firstVideoFiles {
                                
                                    if let videoLink = firstVideo["link"] as? String{
                                          controller.videoLink = videoLink
                                    
                                }
                                if let videoType = firstVideo["file_type"] as? String{
                                    //print("videoType \(videoType)")
                                    controller.videoType = videoType
                           
                                }
                                }
                                
                            }
                                
                            }
                    }
                    
                }
                
                
 
            }
            
        
        }
        
        
    }
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
       
        TableViewVideo.delegate = self
        TableViewVideo.dataSource = self
        
        getVideos()
    }


}

