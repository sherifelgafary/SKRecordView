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
    
    func SKRecordViewDidSelectRecord(sender : SKRecordView, button: UIView)
    func SKRecordViewDidStopRecord(sender : SKRecordView, button: UIView)
    func SKRecordViewDidCancelRecord(sender : SKRecordView, button: UIView)
    
}

class SKRecordView: UIView, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    enum SKRecordViewState {
        
        case Recording
        case None
        
    }
    
    var state : SKRecordViewState = .None {
        
        didSet {
            if state != .Recording{
                UIView.animateWithDuration(0.3) { () -> Void in
                    
                    self.slideToCancel.alpha = 1.0
                    self.countDownLabel.alpha = 1.0
                    
                    self.invalidateIntrinsicContentSize()
                    self.setNeedsLayout()
                    self.layoutIfNeeded()
                    
                }
                
            }else{
                self.slideToCancel.alpha = 1.0
                self.countDownLabel.alpha = 1.0
                
                self.invalidateIntrinsicContentSize()
                self.setNeedsLayout()
                self.layoutIfNeeded()
                
            }
        }
    }
    
        let recordButton : UIButton = UIButton(type: .Custom)
        let slideToCancel : UILabel = UILabel(frame: CGRectZero)
        let countDownLabel : UILabel = UILabel(frame: CGRectZero)
        var timer:NSTimer!
        var recordSeconds = 0
        var recordMinutes = 0
        var soundRecorder : AVAudioRecorder!
        
        var normalImage = UIImage()
        var recordingImages : [UIImage] = []
        var fileName = "audioFile.m4a"
        var recordingAnimationDuration = 0.5
        var recordingLabelText = "<<< Slide to cancel"
        
        weak var delegate : SKRecordViewDelegate?
        
        override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        
        }
    
    func setupRecordingView()  {
        setupRecordButton(normalImage)
        setupLabel()
        setupCountDownLabel()
        setupRecorder()
    }
    
        func setupRecordButton(image:UIImage) {
        
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(recordButton)
        
        
        let vConsts = NSLayoutConstraint(item: recordButton, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0)
        let hConsts = NSLayoutConstraint(item: recordButton, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1.0, constant: 10)
        
        self.addConstraints([vConsts])
        self.addConstraints([hConsts])
        
        recordButton.setImage(image, forState: .Normal)
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
        slideToCancel.textAlignment = .Center
        addSubview(slideToCancel)
        backgroundColor = UIColor.clearColor()
        let vConsts = NSLayoutConstraint(item: slideToCancel, attribute: .Bottom, relatedBy: .Equal, toItem: recordButton, attribute: .Bottom, multiplier: 1.0, constant: -10)
        let hConsts = NSLayoutConstraint(item: slideToCancel, attribute: .Trailing, relatedBy: .Equal, toItem: recordButton, attribute: .Leading, multiplier: 1.0, constant: -20)
        
        
        self.addConstraints([vConsts])
        self.addConstraints([hConsts])
        
        slideToCancel.alpha = 0.0
        slideToCancel.font = UIFont(name: "Lato-Bold", size: 17)
        slideToCancel.textAlignment = .Center
        slideToCancel.textColor = UIColor.blackColor()
        }
        
        
        func setupCountDownLabel() {
        
        countDownLabel.translatesAutoresizingMaskIntoConstraints = false
        countDownLabel.textAlignment = .Center
        addSubview(countDownLabel)
        backgroundColor = UIColor.clearColor()
        let vConsts = NSLayoutConstraint(item: countDownLabel, attribute: .Bottom, relatedBy: .Equal, toItem: slideToCancel, attribute: .Bottom, multiplier: 1.0, constant: 0)
        let hConsts = NSLayoutConstraint(item: countDownLabel, attribute: .Trailing, relatedBy: .Equal, toItem: slideToCancel, attribute: .Leading, multiplier: 1.0, constant: -5)
        
        
        self.addConstraints([vConsts])
        self.addConstraints([hConsts])
        
        countDownLabel.alpha = 0.0
        countDownLabel.font = UIFont(name: "Lato-Bold", size: 17)
        countDownLabel.textAlignment = .Center
        countDownLabel.textColor = UIColor.redColor()
        
        
        
        }
        func setupRecorder(){
        let recordSettings : [String : AnyObject] =
        [
        AVFormatIDKey: NSNumber(unsignedInt: kAudioFormatMPEG4AAC),
        AVEncoderAudioQualityKey : AVAudioQuality.Max.rawValue as NSNumber,
        AVEncoderBitRateKey : 320000 as NSNumber,
        AVNumberOfChannelsKey: 2 as NSNumber,
        AVSampleRateKey : 44100.0 as NSNumber
        ]
        
        
        
        do {
        try  soundRecorder = AVAudioRecorder(URL: getFileURL(), settings: recordSettings)
        soundRecorder.delegate = self
        soundRecorder.prepareToRecord()
        
        } catch {
        }
        
        }
        
        
        
        func getCacheDirectory() -> String {
        
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        
        return paths[0]
        
        }
        
        func getFileURL() -> NSURL{
        
        
        return NSURL(fileURLWithPath: getCacheDirectory()).URLByAppendingPathComponent(fileName)!
        }
        
        
        override func intrinsicContentSize() -> CGSize {
        
        if state == .None {
        return recordButton.intrinsicContentSize()
        } else {
        
        return CGSizeMake(recordButton.intrinsicContentSize().width * 3, recordButton.intrinsicContentSize().height)
        }
        }
        
        func userDidTapRecordThenSwipe(sender: UIButton) {
        slideToCancel.text = nil
        countDownLabel.text = nil
        timer.invalidate()
        
        delegate?.SKRecordViewDidCancelRecord(self, button: sender)
        }
        
        func userDidStopRecording(sender: UIButton) {
        slideToCancel.text = nil
        countDownLabel.text = nil
        timer.invalidate()
        delegate?.SKRecordViewDidStopRecord(self, button: sender)
        }
        
        func userDidBeginRecord(sender : UIButton) {
        slideToCancel.text = self.recordingLabelText
        recordMinutes = 0
        recordSeconds = 0
        
        countdown()
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(SKRecordView.countdown) , userInfo: nil, repeats: true)
        
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
        
        func userDidTapRecord(gesture: UIGestureRecognizer) {
        
        let button = gesture.view as! UIButton
        
        let location = gesture.locationInView(button)
        
        var startLocation = CGPointZero
        
        switch gesture.state {
        
        case .Began:
        startLocation = location
        userDidBeginRecord(button)
        case .Changed:
        
        let translate = CGPoint(x: location.x - startLocation.x, y: location.y - startLocation.y)
        
        if !CGRectContainsPoint(button.bounds, translate) {
        
        if state == .Recording {
        userDidTapRecordThenSwipe(button)
        }
        }
        
        case .Ended:
        
        if state == .None { return }
        
        let translate = CGPoint(x: location.x - startLocation.x, y: location.y - startLocation.y)
        
        if !CGRectContainsPoint(button.frame, translate) {
        
        userDidStopRecording(button)
        
        }
        
        case .Failed, .Possible ,.Cancelled : if state == .Recording { userDidStopRecording(button) } else { userDidTapRecordThenSwipe(button)}
        }
        
        
        }
        func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        
        }
        
        required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        }
}

