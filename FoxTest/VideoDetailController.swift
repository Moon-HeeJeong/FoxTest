//
//  VideoDetailController.swift
//  FoxTest
//
//  Created by 정문희 on 2021/09/30.
//

import UIKit
import AVFoundation


class VideoDetailController : UIViewController{
    
    
    
     
    @IBOutlet weak var videoView: UIView!
    var imageUrl: String?
    var userName: String?
    var videoLink: String?
    var videoType: String?
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
  
    var isVideoPlaying = false
    
    
    //컨트롤버튼 올릴 뷰 생성
    let controlsContainerView:UIView = {
         let view = UIView()
         view.backgroundColor = UIColor(white: 0, alpha: 1)
         return view
     }()
    
    lazy var pausePlayButton : UIButton = {//플레이 스톱버튼 생성.
            let button = UIButton(type: .system)
        let image = UIImage(named : "pause")
              //  UIImage(named: pause)
            button.setImage(image, for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tintColor = .black
            button.isHidden = true
            
            button.addTarget(self, action: #selector(playPressed), for: .touchUpInside)
            return button
        }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = userName
       // self.navigationController?.navigationBar.topItem?.title = userName
        /*
        if let img = imageUrl {
            //이미지 가져와서 뿌리기 (Data)
            if let data = try? Data(contentsOf: URL(string: img)!){
                //Mian Thread
                DispatchQueue.main.async {
                   // self.SecondImageMain.image = UIImage(data: data)
                }
            }
            
        }*/
     
        
        if let link = videoLink{
            let url = URL(string: link)!
            print("url link ::: \(url)")
            player = AVPlayer(url: url)
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resize
        
        videoView.layer.addSublayer(playerLayer)
       
          
            
            
            
    }
    }
    /*
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player.play()
    }
    */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    
        playerLayer.frame = videoView.bounds
        
                
        
        
        
        
    }
    
    
    @IBAction func playPressed(_ sender: UIButton) {
        if isVideoPlaying{
            player.pause()
            sender.setTitle("Play", for: .normal)
            
            
            pausePlayButton.setImage(UIImage(named: "play"), for: .normal)
        }else {
            player.play()
            sender.setTitle("Pause", for: .normal)

            pausePlayButton.setImage(UIImage(named: "pause"), for: .normal)
                        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                            self.pausePlayButton.setImage(UIImage(named: ""), for: .normal)
                        }

        }
        
        isVideoPlaying = !isVideoPlaying
    }
    
    
}

/*
extension VideoDetailController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // CollectionView item 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImageName.count
    }
    
    // CollectionView Cell의 Object
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridCollectionViewCell", for: indexPath) as! GridCollectionViewCell
        
        cell.GridImageView.image = UIImage(named: arrImageName[indexPath.row]) ?? UIImage()
        
        return cell
    }
    
    // CollectionView Cell의 Size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: CGFloat = collectionView.frame.width / 3 - 1.0
        
        return CGSize(width: width, height: width)
    }
    
    // CollectionView Cell의 위아래 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    // CollectionView Cell의 옆 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
}
*/
