//
//  JHRecordView.swift
//  NEKitChatUI
//
//  Created by lqy on 2022/9/25.
//

import UIKit
import NIMSDK
import NEKitCommonUI
import NEKitChatUI
protocol JHRecordViewDelegate: AnyObject {
    func hiddenJHRecordView()
    func isPlayVoice(isPlay:Bool ,path:String)
    func limitTimedAutoSend(path:String)
    func finishRecordAndSendVocie(path:String)
    func speekSoSort()
}

class JHRecordView: UIView {
    var voiceBtn = UIButton(type: .custom)
    var bottomBtn = UIButton(type: .custom)
    var timeLab = UILabel()
    var sendOrDeleteView = UIImageView(image: UIImage(named: "Slice 48"))
    var filePath = String()
    var recordTime = TimeInterval()
    var playBtn = UIButton(type: .custom)
    
    public weak var delegate: JHRecordViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func commonUI() {
        backgroundColor = UIColor(red: 26.0/255.0, green: 26.0/255.0, blue: 26.0/255.0, alpha: 0.8)
        
        timeLab.text = "0″"
        timeLab.textAlignment = .center
        timeLab.textColor = UIColor.white
        timeLab.frame = CGRect(x: UIScreen.main.bounds.width/2 - 50, y: UIScreen.main.bounds.height/2-44 - 44, width: 100, height: 20)
        addSubview(timeLab)
        
        voiceBtn.setBackgroundImage(UIImage(named: "Slice 40"), for: .normal)
        voiceBtn.frame = CGRect(x: UIScreen.main.bounds.width/2-44, y: UIScreen.main.bounds.height/2-44, width: 88, height: 88)
        voiceBtn.contentMode = .scaleAspectFill
        voiceBtn.clipsToBounds = true
        voiceBtn.isHidden = true
        addSubview(voiceBtn)
        
        bottomBtn.frame = CGRect(x: 0, y: UIScreen.main.bounds.height-125, width: UIScreen.main.bounds.width, height: 125)
        bottomBtn.setBackgroundImage(UIImage(named: "Slice 34"), for: .normal)
        bottomBtn.isHidden = true
        addSubview(bottomBtn)
        
        sendOrDeleteView.frame = CGRect(x: 16, y: UIScreen.main.bounds.height - 84-72, width: UIScreen.main.bounds.width - 32, height: 72)
        sendOrDeleteView.isHidden = true
        sendOrDeleteView.isUserInteractionEnabled = true
        
        playBtn.frame = CGRect(x: (UIScreen.main.bounds.width - 32 - 72)/2, y: 0, width: 72, height: 72)
        playBtn.setBackgroundImage(UIImage(named: "Slice 43"), for: .normal)
        playBtn.setImage(UIImage(named: "Slice 44"), for: .normal)
        playBtn.setImage(UIImage(named: "Slice 25"), for: .selected)
        playBtn.addTarget(self, action: #selector(playVoiceEvent), for: .touchUpInside)
        sendOrDeleteView.addSubview(playBtn)
        
        let deletBtn = UIButton(frame: CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width - 32 - 72)/2, height: 72))
        deletBtn.setTitle("删除", for: .normal)
        deletBtn.setTitleColor(.white, for: .normal)
        deletBtn.titleLabel?.font = UIFont(name: "PingFang SC", size: 18)
        deletBtn.addTarget(self, action: #selector(deletClickEvent), for: .touchUpInside)
        sendOrDeleteView.addSubview(deletBtn)
        
        let sendBtn = UIButton(frame: CGRect(x: (UIScreen.main.bounds.width - 32 - 72)/2 + 72, y:0 , width: (UIScreen.main.bounds.width - 32 - 72)/2, height: 72))
        sendBtn.setTitle("发送", for: .normal)
        sendBtn.setTitleColor(UIColor(hexString: "#818ADD"), for: .normal)
        sendBtn.titleLabel?.font = UIFont(name: "PingFang SC", size: 18)
        sendBtn.addTarget(self, action: #selector(sendClickEvent), for: .touchUpInside)
        sendOrDeleteView.addSubview(sendBtn)
        addSubview(sendOrDeleteView)
    }
    
    public func starRecord(dur:TimeInterval){
        recordTime = dur
        let time = Int(dur)
        if time<59 {
            timeLab.text = "\(time)″"
        }else{
            //直接发送
            delegate?.limitTimedAutoSend(path: filePath)
        }
        
    }
    
    public func showVoice(){
        voiceBtn.isHidden = false
        bottomBtn.isHidden = false
        timeLab.isHidden = false
        sendOrDeleteView.isHidden = true
        timeLab.frame.origin.y = UIScreen.main.bounds.height/2-44 - 44;
    }
    //松手
    public func finishRecord(){
        if recordTime>2{
            timeLab.frame.origin.y = UIScreen.main.bounds.height-224;
            voiceBtn.isHidden = true
            bottomBtn.isHidden = true
            sendOrDeleteView.isHidden = false
        }else{
            delegate?.speekSoSort()
        }
    }
    
    @objc func deletClickEvent(button:UIButton) {
        delegate?.hiddenJHRecordView()
    }
    
    @objc func sendClickEvent(button:UIButton){
        delegate?.finishRecordAndSendVocie(path: filePath)
    }
    
    @objc func playVoiceEvent(button:UIButton){
        button.isSelected = !button.isSelected
        delegate?.isPlayVoice(isPlay: button.isSelected ,path: filePath)
//        let dur = recordDuration(filePath: filePath)
//        if recordTime == dur{
//            //播放完成
//            button.isSelected = false;
//        }else{
//            //正在播放
//            button.isSelected = true;
//            
//        }
        if button.isSelected {
            playBtn.imageView?.startAnimating()
        }
    }
    
    private func recordDuration(filePath: String) -> Float64 {
      let avAsset = AVURLAsset(url: URL(fileURLWithPath: filePath))
      return CMTimeGetSeconds(avAsset.duration)
    }
    
    
      
}
