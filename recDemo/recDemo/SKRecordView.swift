//
//  SKRecordView.swift
//  SKRecordView
//
//  Created by sherif_khaled on 10/5/16.
//  Copyright © 2016 sherif khaled. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

protocol SKRecordViewDelegate: class {
    
    func SKRecordViewDidSelectRecord(_ sender : SKRecordView, button: UIView)
    func SKRecordViewDidStopRecord(_ sender : SKRecordView, button: UIView)
    func SKRecordViewDidCancelRecord(_ sender : SKRecordView, button: UIView)
    
}

class SKRecordView: UIView, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    enum SKRecordViewState {
        
        case recording
        case none
        
    }
    
    var state : SKRecordViewState = .none {
        
        didSet {
            if state != .recording{
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    
                    self.slideToCancel.alpha = 1.0
                    self.countDownLabel.alpha = 1.0
                    
                    self.invalidateIntrinsicContentSize()
                    self.setNeedsLayout()
                    self.layoutIfNeeded()
                    
                }) 
                
            }else{
                self.slideToCancel.alpha = 1.0
                self.countDownLabel.alpha = 1.0
                
                self.invalidateIntrinsicContentSize()
                self.setNeedsLayout()
                self.layoutIfNeeded()
                
            }
        }
    }
    
    let recordButton : UIButton = UIButton(type: .custom)
    let slideToCancel : UILabel = UILabel(frame: CGRect.zero)
    let countDownLabel : UILabel = UILabel(frame: CGRect.zero)
    var timer:Timer!
    var recordSeconds = 0
    var recordMinutes = 0
    var audioRecorder: AVAudioRecorder?
    
    var normalImage = UIImage(named: "mic.png")!
    var recordingImages = [UIImage(named: "rec-1.png")!,UIImage(named: "rec-2.png")!,UIImage(named: "rec-3.png")!,UIImage(named: "rec-4.png")!,UIImage(named: "rec-5.png")!,UIImage(named: "rec-6.png")!]
    var fileName = "audioFile.m4a"
    var recordingAnimationDuration = 0.5
    var recordingLabelText = "<<< Slide to cancel"
    
    weak var delegate : SKRecordViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        setupRecordButton(normalImage)
        setupLabel()
        setupCountDownLabel()
        setupRecorder()
    }
    
    func setupRecordButton(_ image:UIImage) {
        
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(recordButton)
        
        
        let vConsts = NSLayoutConstraint(item: recordButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0)
        let hConsts = NSLayoutConstraint(item: recordButton, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 10)
        
        self.addConstraints([vConsts])
        self.addConstraints([hConsts])
        
        recordButton.setImage(image, for: UIControlState())
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(SKRecordView.userDidTapRecord(_:)))
        longPress.cancelsTouchesInView = false
        longPress.allowableMovement = 10
        longPress.minimumPressDuration = 0.2
        recordButton.addGestureRecognizer(longPress)
        
        recordButton.imageView?.animationImages = recordingImages
        recordButton.imageView?.animationDuration = recordingAnimationDuration
        
    }
    
    func setupLabel() {
        
        slideToCancel.translatesAutoresizingMaskIntoConstraints = false
        slideToCancel.textAlignment = .center
        addSubview(slideToCancel)
        backgroundColor = UIColor.clear
        let vConsts = NSLayoutConstraint(item: slideToCancel, attribute: .bottom, relatedBy: .equal, toItem: recordButton, attribute: .bottom, multiplier: 1.0, constant: -10)
        let hConsts = NSLayoutConstraint(item: slideToCancel, attribute: .trailing, relatedBy: .equal, toItem: recordButton, attribute: .leading, multiplier: 1.0, constant: -5)
        
        
        self.addConstraints([vConsts])
        self.addConstraints([hConsts])
        
        slideToCancel.alpha = 0.0
        slideToCancel.font = UIFont.boldSystemFont(ofSize: 14)
        slideToCancel.textAlignment = .center
        slideToCancel.textColor = UIColor.black
    }
    
    
    func setupCountDownLabel() {
        
        countDownLabel.translatesAutoresizingMaskIntoConstraints = false
        countDownLabel.textAlignment = .center
        addSubview(countDownLabel)
        backgroundColor = UIColor.clear
        let vConsts = NSLayoutConstraint(item: countDownLabel, attribute: .bottom, relatedBy: .equal, toItem: slideToCancel, attribute: .bottom, multiplier: 1.0, constant: 0)
        let hConsts = NSLayoutConstraint(item: countDownLabel, attribute: .trailing, relatedBy: .equal, toItem: slideToCancel, attribute: .leading, multiplier: 1.0, constant: -5)
        
        
        self.addConstraints([vConsts])
        self.addConstraints([hConsts])
        
        countDownLabel.alpha = 0.0
        countDownLabel.font = UIFont.systemFont(ofSize: 15)
        countDownLabel.textAlignment = .center
        countDownLabel.textColor = UIColor.red
        
        
        
    }
    func setupRecorder(){
        let recordSettings =
            [AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
             AVEncoderBitRateKey: 16,
             AVNumberOfChannelsKey: 2,
             AVSampleRateKey: 44100.0] as [String : Any]
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(
                AVAudioSessionCategoryPlayAndRecord)
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
        
        do {
            try audioRecorder = AVAudioRecorder(url: getFileURL(),
                                                settings: recordSettings as [String : AnyObject])
            audioRecorder?.prepareToRecord()
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
        
    }
    
    
    
    func getCacheDirectory() -> String {
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        
        return paths[0]
    }
    
    func getFileURL() -> URL{
        
        let fileMgr = FileManager.default
        
        let dirPaths = fileMgr.urls(for: .documentDirectory,
                                    in: .userDomainMask)
        
        let soundFileURL = dirPaths[0].appendingPathComponent("sound.caf")

        return soundFileURL
    }
    
    
    override var intrinsicContentSize : CGSize {
        
        if state == .none {
            return recordButton.intrinsicContentSize
        } else {
            
            return CGSize(width: recordButton.intrinsicContentSize.width * 3, height: recordButton.intrinsicContentSize.height)
        }
    }
    
    func userDidTapRecordThenSwipe(_ sender: UIButton) {
        slideToCancel.text = nil
        countDownLabel.text = nil
        timer.invalidate()
        audioRecorder?.stop()

        delegate?.SKRecordViewDidCancelRecord(self, button: sender)
    }
    
    func userDidStopRecording(_ sender: UIButton) {
        slideToCancel.text = nil
        countDownLabel.text = nil
        timer.invalidate()
        audioRecorder?.stop()

        delegate?.SKRecordViewDidStopRecord(self, button: sender)
    }
    
    func userDidBeginRecord(_ sender : UIButton) {
        slideToCancel.text = self.recordingLabelText
        recordMinutes = 0
        recordSeconds = 0
        
        countdown()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(SKRecordView.countdown) , userInfo: nil, repeats: true)
        self.audioRecorder?.record()
        delegate?.SKRecordViewDidSelectRecord(self, button: sender)
        
    }
    
    func countdown() {
        
        var seconds = "\(recordSeconds)"
        if recordSeconds < 10 {
            seconds = "0\(recordSeconds)"
        }
        var minutes = "\(recordMinutes)"
        if recordMinutes < 10 {
            minutes = "0\(recordMinutes)"
        }
        
        countDownLabel.text = "● \(minutes):\(seconds)"
        
        recordSeconds += 1
        
        if recordSeconds == 60 {
            recordMinutes += 1
            recordSeconds = 0
        }
        
    }
    
    func userDidTapRecord(_ gesture: UIGestureRecognizer) {
        
        let button = gesture.view as! UIButton
        
        let location = gesture.location(in: button)
        
        var startLocation = CGPoint.zero
        
        switch gesture.state {
            
        case .began:
            startLocation = location
            userDidBeginRecord(button)
        case .changed:
            
            let translate = CGPoint(x: location.x - startLocation.x, y: location.y - startLocation.y)
            
            if !button.bounds.contains(translate) {
                
                if state == .recording {
                    userDidTapRecordThenSwipe(button)
                }
            }
            
        case .ended:
            
            if state == .none { return }
            
            let translate = CGPoint(x: location.x - startLocation.x, y: location.y - startLocation.y)
            
            if !button.frame.contains(translate) {
                
                userDidStopRecording(button)
                
            }
            
        case .failed, .possible ,.cancelled : if state == .recording { userDidStopRecording(button) } else { userDidTapRecordThenSwipe(button)}
        }
        
        
    }
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

