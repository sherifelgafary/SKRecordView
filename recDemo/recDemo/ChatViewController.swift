//
//  ChatViewController.swift
//  recDemo
//
//  Created by Sherif Khaled on 10/7/16.
//  Copyright © 2016 sherif khaled. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 10/255, green: 180/255, blue: 230/255, alpha: 1.0))
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
    var messages = [JSQMessage]()
    
    let recordingView = SKRecordView(frame: CGRectMake(0, UIScreen.mainScreen().bounds.height-100 , UIScreen.mainScreen().bounds.width , 100))
    
    let sendButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.addDemoMessages()
        self.setupChatToolBar()
        
    }
    
    func reloadMessagesView() {
        self.collectionView?.reloadData()
    }
    
}


extension ChatViewController {
    func addDemoMessages() {
        for i in 1...10 {
            let sender = (i%2 == 0) ? "Server" : self.senderId
            let messageContent = "Message nr. \(i)"
            let message = JSQMessage(senderId: sender, displayName: sender, text: messageContent)
            self.messages += [message]
        }
        self.reloadMessagesView()
    }
    
    func setup() {
        self.senderId = UIDevice.currentDevice().identifierForVendor?.UUIDString
        self.senderDisplayName = UIDevice.currentDevice().identifierForVendor?.UUIDString
    }
    
    func setupChatToolBar()  {
        self.inputToolbar.contentView.rightBarButtonItemWidth = 90
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
        
        self.setupRecordView()
        self.setupNewSendButton()
        
    }
    func setupNewSendButton()  {
        sendButton.setImage(UIImage(named:"send-icon.png"), forState: .Normal)
        self.inputToolbar.contentView.rightBarButtonItem.hidden = true
        self.inputToolbar.contentView.rightBarButtonContainerView.addSubview(sendButton)
        
        sendButton.addTarget(self, action: #selector(ChatViewController.sendPressed), forControlEvents: .TouchUpInside)
        self.sendButton.enabled = false
        
    }
    func setupRecordView()  {
        recordingView.delegate = self
        recordingView.recordingImages = [UIImage(named: "rec-1.png")!,UIImage(named: "rec-2.png")!,UIImage(named: "rec-3.png")!,UIImage(named: "rec-4.png")!,UIImage(named: "rec-5.png")!,UIImage(named: "rec-6.png")!]
        recordingView.normalImage = UIImage(named: "mic.png")!
        
        view.addSubview(recordingView)
        
        let vConsts = NSLayoutConstraint(item:self.recordingView , attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0)
        
        let hConsts = NSLayoutConstraint(item: self.recordingView, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1.0, constant: -10)
        
        
        view.addConstraints([hConsts])
        view.addConstraints([vConsts])
        recordingView.setupRecordingView()
    }
    
    func textChanged(notification: NSNotification){
        if let hasText = notification.object as? NSNumber {
            if Bool(hasText) {
                self.sendButton.enabled = true
            }else{
                self.sendButton.enabled = false
            }
        }
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "textChanged", object: nil)
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.textChanged(_:)), name:"textChanged", object: nil)
    }
    
}


extension ChatViewController {
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        self.messages.removeAtIndex(indexPath.row)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        switch(data.senderId) {
        case self.senderId:
            return self.outgoingBubble
        default:
            return self.incomingBubble
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
}



extension ChatViewController {
    func sendPressed()  {
        if self.inputToolbar.contentView.textView.text.characters.count > 0 {
            self.didPressSendButton(self.inputToolbar.contentView.rightBarButtonItem, withMessageText: self.inputToolbar.contentView.textView.text, senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: NSDate())
        }
    }
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        self.messages += [message]
        self.finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
    }
}


extension ChatViewController : SKRecordViewDelegate {
    
    func SKRecordViewDidCancelRecord(sender: SKRecordView, button: UIView) {
        
        sender.state = .None
        sender.setupRecordButton(UIImage(named: "mic.png")!)
        recordingView.soundRecorder.stop()
        recordingView.recordButton.imageView?.stopAnimating()
        
        print("Cancelled")
    }
    
    func SKRecordViewDidSelectRecord(sender: SKRecordView, button: UIView) {
        
        sender.state = .Recording
        sender.setupRecordButton(UIImage(named: "rec-1.png")!)
        sender.soundRecorder.record()
        recordingView.recordButton.imageView?.startAnimating()
        
        print("Began " + NSUUID().UUIDString)
        
    }
    
    func SKRecordViewDidStopRecord(sender : SKRecordView, button: UIView) {
        recordingView.soundRecorder.stop()
        
        sender.state = .None
        sender.setupRecordButton(UIImage(named: "mic.png")!)
        
        let audioData = JSQAudioMediaItem(data: NSData(contentsOfURL: recordingView.getFileURL()))
        let message = JSQMessage(senderId: self.senderId, senderDisplayName: self.senderDisplayName, date: NSDate(), media: audioData)
        
        self.messages += [message]
        self.finishSendingMessage()
        recordingView.recordButton.imageView?.stopAnimating()
        
        print("Done")
    }
    
    
    
}

