# SKRecordView
![record](https://cloud.githubusercontent.com/assets/5552822/19554843/b3d37916-96ba-11e6-8330-53fd63bdb6b0.gif)

Have you ever wanted a new animated recording module for your app which can act like the whats app recording module instead of a static recording button SKRecordView is customisable aimatable recording module which resembles the whats app recording and it's so easy to integrate and use in your project and all it's componants are customizable hope you enjoy using it and contact me for any improvements needed for this module

## Requirements

- iOS 7.0+
- Swift 2.2
- ARC


## Notes

There's included in the repo a demo project for SKRecordView integrated with [JSQMessagesViewController](https://github.com/jessesquires/JSQMessagesViewController) and it shows how you can add the recorder in the chat ViewController's tool bar

## Installation

### Manual
- Simply add the `SKRecordView` folder to your project.
- Create a SKRecordView object give it it's frame.
- Set it's properties (Icon, animating images, animation duration and recordingLabelText).
- Set the current viewContoller as the SKRecordViewDelegate.
- Call the setupRecordingView function
- Add the SKRecordView object to your view.
- Add constrains for it's placing in your view.
- Now you are up and running with using the SKRecordView.


### code

```swift
  		    let recordingView = SKRecordView(frame: CGRectMake(0, UIScreen.mainScreen().bounds.height-100 , UIScreen.mainScreen().bounds.width , 100))
        recordingView.delegate = self
        recordingView.recordingImages = [UIImage(named: "rec-1.png")!,UIImage(named: "rec-2.png")!,UIImage(named: "rec-3.png")!,UIImage(named: "rec-4.png")!,UIImage(named: "rec-5.png")!,UIImage(named: "rec-6.png")!]
        recordingView.normalImage = UIImage(named: "mic.png")!
        
        view.addSubview(recordingView)
        
        let vConsts = NSLayoutConstraint(item:self.recordingView , attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0)
        
        let hConsts = NSLayoutConstraint(item: self.recordingView, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1.0, constant: -10)
        
        view.addConstraints([hConsts])
        view.addConstraints([vConsts])
        recordingView.setupRecordingView()

```

you can get the recorded File path in the SKRecordView object by calling :
- getFileURL()
 which will return an NSURL object with the recorded file url 


## Customizable Properties

- normalImage

 The image that will be used as th button icon in the idle state

- recordingImages

  An array of images to be used while recording to animate the button
 
- recordingAnimationDuration

  A float value which indicates how long the animation of your images you supported will take for one full animation cycle with dafault value of 0.5 second
 
- recordingLabelText'

 The string value that will appear beside the animating button while recording with dafault value of "<<< Slide to cancel"
 
- recordingLabelTextColor

 A color for the label text beside the animating label with default value of black
 
- recordingCounterLabelTextColor

 A color for the recording duration label with default value of red color
 
 ## Delgate methodes
 
- func SKRecordViewDidSelectRecord(sender : SKRecordView, button: UIView)

 This delegate method is called whenever the user starts recording 
- func SKRecordViewDidStopRecord(sender : SKRecordView, button: UIView)
  
  This delegate method is called when the record is completed successfully
  
- func SKRecordViewDidCancelRecord(sender : SKRecordView, button: UIView)

  This delegate method is called when the user canceles the record


