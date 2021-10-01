//
//  VideoPlayer.swift
//  FoxTest
//
//  Created by 정문희 on 2021/09/30.
//

import UIKit
import AVKit

class VideoPlayer: UIView {
    
    @IBOutlet weak var vwPlayer: UIView!
    
    var player: AVPlayer?

    override init(frame: CGRect){
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder){
        super.init(coder: coder)
        commonInit()
    }
    
    fileprivate func commonInit(){
        let viewFormXib = Bundle.main.loadNibNamed("VideoPlayer", owner: self, options: nil)![0] as! UIView
        viewFormXib.frame = self.bounds
        addSubview(viewFormXib)
        addPlayerToView(self.vwPlayer)
    }
    

    fileprivate func addPlayerToView(_ view: UIView){
        player = AVPlayer()
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.bounds
        playerLayer.videoGravity = .resizeAspect
        view.layer.addSublayer(playerLayer)
        NotificationCenter.default.addObserver(self, selector: #selector(playerEndPlay), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    func playerVideoWithFileName(_ fileName: String, ofType type:String){
        guard let filePath = Bundle.main.path(forResource: fileName, ofType: type) else {return}
        let videoURL = URL(fileURLWithPath: filePath)
        let playerItem = AVPlayerItem(url: videoURL)
        player?.replaceCurrentItem(with: playerItem)
        player?.play()
    }
    
    @objc func playerEndPlay(){
        print("Player ends playing video")
    }
}
