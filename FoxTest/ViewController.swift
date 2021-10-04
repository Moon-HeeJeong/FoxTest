//
//  ViewController.swift
//  FoxTest
//
//  Created by 정문희 on 2021/09/30.
//

import UIKit

class ViewController: UIViewController{
    
    
    private var videoData :Array<Dictionary<String, Any>>?
    
    func getVideos() {
        
        /* api 통신 */
        let baseUrl = URL(string:"https://api.pexels.com/videos/popular")!
        var request = URLRequest(url: baseUrl)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("563492ad6f9170000100000130d4d4134d934e1ab03e08d12a6716ac", forHTTPHeaderField: "Authorization")
        
        
        let task = URLSession.shared.dataTask(with:request) { data, response, error in
            
            //옵셔널 바인딩
            if let dataJson = data{
                do{
                    //Json데이터를 가져와서 videoData에 넣기
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
    

    //화면이동(보낼 값 미리 셋팅)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier, "VideoDetail" == id {
            if let controller = segue.destination as? VideoDetailController{
                
                if let indexPath = TableViewVideo.indexPathForSelectedRow{
                    let videos = videoData?[indexPath.row]
                    
                    //user name 보내기
                    let user = videos?["user"] as? Dictionary<String, Any>
                    let userName = user?["name"] as? String
                    controller.userName = userName
                    
                    //video link 보내기
                    let videoFiles = videos?["video_files"] as? Array<Dictionary<String, Any>>
                    let firstVideoFile = videoFiles?[0]
                    let videoLink = firstVideoFile?["link"] as? String
                    controller.videoLink = videoLink
                    
                    //video pictures의 이미지들 보내기
                    if let videoPictures = videos?["video_pictures"] as? Array<Dictionary<String, Any>>
                    {
                     controller.videoPictures = videoPictures
                    }
                }
            }
           
        }
    }
            
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.navigationItem.title = "video play test"
        TableViewVideo.delegate = self
        TableViewVideo.dataSource = self
        
        getVideos()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    
    //데이터 몇개인지 설정
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let videos = videoData{
            return videos.count
        }
        else{
            return 0
        }
    }
    
    //데이터 무엇인지 설정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = TableViewVideo.dequeueReusableCell(withIdentifier: "ListCell1", for: indexPath) as! ListCell1
        
       
        /* 테이블뷰의 데이터 : 1. 리스트의 유저이름 videos.user.name 2. 리스트의 이미지 videos.image */
        let videos = videoData?[indexPath.row]
        let user = videos?["user"] as? Dictionary<String, Any>
        let userName = user?["name"] as? String
        cell.LabelText.text = userName
        
        let imageUrl = videos?["image"] as? String
        if let img = imageUrl {
            if let data = try? Data(contentsOf: URL(string: img)!){
                DispatchQueue.main.async {
                    cell.ImageMain.image = UIImage(data: data)
                }
            }
        }

        return cell
    }
}
