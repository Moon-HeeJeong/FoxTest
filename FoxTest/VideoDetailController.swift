//
//  VideoDetailController.swift
//  FoxTest
//
//  Created by 정문희 on 2021/09/30.
//

import UIKit
import AVFoundation
import AVKit

class VideoDetailController : UIViewController{
    

    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var gridCollectionView: UICollectionView!
    

    var userName: String?
    var videoLink: String?
    var picturesUrl: String?
    var videoPictures: Array<Dictionary<String, Any>>?
    
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    private var isVideoPlaying = false
    
    private var playPauseButton: PlayPauseButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* 타이틀 이름 설정 */
        self.navigationItem.title = userName
       // self.navigationController?.navigationBar.topItem?.title = userName
        
        /* 비디오 재생 */
        playVideo()
          
        /*콜렉션뷰의 레이아웃 설정*/
        self.gridCollectionView.collectionViewLayout = createCompositionalLayout()
        
        
        /* 비디오 재생, 일시정지 버튼 */
        playPauseButton = PlayPauseButton()
        playPauseButton.avPlayer = player
        view.addSubview(playPauseButton)
        playPauseButton.setup(in: self)
        
    }
    
    
    
  /*  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        playPauseButton.updateUI()
    }*/
    
    
    /* 비디오 버튼 클래스*/
    private class PlayPauseButton: UIView {
        private var kvoRateContext = 0
        var avPlayer: AVPlayer?
        private var isPlaying: Bool {
            return avPlayer?.rate != 0 && avPlayer?.error == nil
        }
        
        //노티피케이션 추가
        func addObservers() {
            avPlayer?.addObserver(self, forKeyPath: "rate", options: .new, context: &kvoRateContext)
        }

        func setup(in container: UIViewController) {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(self.tapped(_:)))
            addGestureRecognizer(gesture)

            updatePosition()
            updateUI()
            addObservers()
        }

        //탭하면 상태(재생,일시정지)와 UI이미지 변경
        @objc func tapped(_ sender: UITapGestureRecognizer) {
            updateStatus()
            updateUI()
        }

        private func updateStatus() {
            if isPlaying {
                avPlayer?.pause()
            } else {
                avPlayer?.play()
            }
        }

        private func updateUI() {
            if isPlaying {
                setBackgroundImage(name: "pause")
            } else {
                setBackgroundImage(name: "play")
            }
        }
        
        //view 위치 지정
        private func updatePosition() {
            guard let superview = superview else { return }
            translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([
                widthAnchor.constraint(equalToConstant: 50),
                heightAnchor.constraint(equalToConstant: 50),
                centerXAnchor.constraint(equalTo: superview.centerXAnchor),
                centerYAnchor.constraint(equalTo: superview.centerYAnchor, constant: -260)
                
                ])
        }

        private func setBackgroundImage(name: String) {
            UIGraphicsBeginImageContext(frame.size)
            UIImage(named: name)?.draw(in: bounds)
            guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return }
            UIGraphicsEndImageContext()
            backgroundColor = UIColor(patternImage: image)
        }

        private func handleRateChanged() {
            updateUI()
        }

        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            guard let context = context else { return }

            switch context {
            case &kvoRateContext:
                handleRateChanged()
            default:
                break
            }
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    
        playerLayer.frame = videoView.bounds
        
        gridCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        gridCollectionView.delegate = self
        gridCollectionView.dataSource = self
    }
    
    
    /* 비디오 재생, 일시정지 버튼 */
    /*
    @IBAction func playPressed(_ sender: UIButton) {
        if isVideoPlaying{
            player.pause()
         
            pausePlayButton.setImage(UIImage(named: "play"), for: .normal)
        }else {
            player.play()
          
               pausePlayButton.setImage(UIImage(named: "pause"), for: .normal)
                        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                            self.pausePlayButton.setImage(UIImage(named: "play"), for: .normal)
                        }
        }
        
        isVideoPlaying = !isVideoPlaying
        
    }*/
    /*
    
    private var pausePlayButton : UIButton = {//플레이 스톱버튼 생성.
            let button = UIButton(type: .system)
        let image = UIImage(named : "pause")
            button.setImage(image, for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tintColor = .white
        //    button.isHidden = true
            
        button.addTarget(self, action: #selector(playPressed), for: .touchUpInside)
            return button
        }()
   
    */
    private func playVideo() {
        
        if let link = videoLink{
            let url = URL(string: link)!
              
            player = AVPlayer(url: url)}
        
        playPauseButton = PlayPauseButton()
        playPauseButton.avPlayer = player
        view.addSubview(playPauseButton)
        playPauseButton.setup(in: self)
    
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resize
        videoView.layer.addSublayer(playerLayer)
    }
}





//콜렉션뷰 컴포지셔널 레이아웃 관련
extension VideoDetailController{
    
    //컴포지셔널 레이아웃 설정
    fileprivate func createCompositionalLayout() -> UICollectionViewLayout{
        //컴포지셔널 레이아웃 생성
        let layout = UICollectionViewCompositionalLayout{
            //만들게 되면 튜플(키:값,키:값)의 묶음으로 들어옴 반환하는 것은
            //NSCollectionLayoutSection 콜렉션 레이아웃 섹션을 반환해야함
            //레이아웃 > 섹션 > 그룹 > 아이템
            (sectionIndex:Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            //아이템에 대한 사이즈 - absoulute고정값, estimated추측, fraction퍼센트
            //.fractionWidth(1/3)이면 가로로 3개가 나옴
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
       
            //위에서 만든 아이템 사이즈로 아이템 만들기
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            //아이템 간의 간격 설정
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            //아이템을 감싸는 그룹 사이즈 지정
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1/3))
            
            //그룹사이즈로 그룹 만들기
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)
            
            //그룹으로 섹션 만들기
            let section = NSCollectionLayoutSection(group: group)
            
            //섹션에 대한 간격 설정
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            
            return section
            
        }
        return layout
    }
}


//데이터 소스 설정 - 데이터과 관련된 것들
extension VideoDetailController: UICollectionViewDataSource{
    
    //각 섹션에 들어가는 아이템 갯수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 15
    }
    
    //각 콜렉션뷰 셀에 대한 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //한 객체의 인스턴스의 이름을 그대로 가져오는 방법
        let cellId = String(describing: GridCollectionViewCell.self)
 
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! GridCollectionViewCell
        
  
        /* videoPictures Json데이터에서 picture의 이미지 url값 뽑기 */
        let pictures = videoPictures?[indexPath.row]
        let picturesUrls = pictures?["picture"] as? String
        picturesUrl = picturesUrls
        
    
        /* 콜렉션뷰 image 출력 */
        if let img = picturesUrl {
              if let data = try? Data(contentsOf: URL(string: img)!){
              
                  //Main Thread로
                  DispatchQueue.main.async {
                      cell.gridImage.image = UIImage(data: data)
                  }
              }
          }
        return cell
    }
    
    
}

//콜렉션뷰 델리겟 - 액션과 관련된 것들
extension VideoDetailController: UICollectionViewDelegate{
    
}



