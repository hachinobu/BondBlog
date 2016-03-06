//
//  ViewController.swift
//  BondBlog
//
//  Created by Takahiro Nishinobu on 2016/03/05.
//  Copyright © 2016年 hachinobu. All rights reserved.
//

import UIKit
import Bond

class ViewController: UIViewController {

    enum RequestState {
        case None
        case Requesting
        case Success
        case Error
        
        func isRequesting() -> Bool {
            return self == .Requesting
        }
    }
    
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var characterLimitLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var requestIndicator: UIActivityIndicatorView!
    
//    let CharacterLimit = 30
    let requestState = Observable<RequestState>(.None)
//    var requestState: RequestState = .None {
//        didSet {
//            updateRequestIndicator()
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        setupUI()
        bindUI()
    }


}


//MARK: Use Bond
extension ViewController {
    
    func bindUI() {
        
        let CharacterLimit = 30
        //
        combineLatest(destinationTextField.bnd_text, subjectTextField.bnd_text, messageTextView.bnd_text, requestState).map { (destination, subject, message, reqState) -> (isEnabled: Bool, alpha: CGFloat) in
            
            let disableState: (Bool, CGFloat) = (false, 0.5)
            if reqState == .Requesting {
                return disableState
            }
            
            guard let destinationCount = destination?.characters.count, subjectCount = subject?.characters.count, messageCount = message?.characters.count
                where destinationCount > 0 && subjectCount > 0 && (1...CharacterLimit) ~= messageCount else {
                    
                return disableState
                    
            }
            
            return (true, 1.0)
            
        }.observe { [unowned self] (isEnabled, alpha) -> Void in
            self.sendButton.enabled = isEnabled
            self.sendButton.alpha = alpha
        }
        
        //
        messageTextView.bnd_text.map { message -> (count: String, color: UIColor) in
            
            let messageCount = message?.characters.count ?? 0
            let diffCount = CharacterLimit - messageCount
            if diffCount >= 0 {
                return (diffCount.description, UIColor.blackColor())
            }
            return (diffCount.description, UIColor.redColor())
            
        }.observe { [unowned self] (count, color) -> Void in
            
            self.characterLimitLabel.text = count
            self.characterLimitLabel.textColor = color
            
        }
        
        requestState.map { reqState -> Bool in
            return reqState == .Requesting
        }.bindTo(requestIndicator.bnd_animating)
        
        requestState.map { reqState -> Bool in
            return reqState != .Requesting
        }.bindTo(requestIndicator.bnd_hidden)
        
        requestState.filter { reqState -> Bool in
            return reqState == .Success
        }.observe { [unowned self] _ -> Void in
            self.finishSendMessage("送信成功しました")
        }
        
        requestState.filter { reqState -> Bool in
            return reqState == .Error
        }.observe { [unowned self] _ -> Void in
            self.finishSendMessage("送信失敗しました")
        }
        
        sendButton.bnd_tap.observe { [unowned self] _ -> Void in
            
            self.requestState.next(.Requesting)
            
            //擬似通信処理
            let delay = 1.5 * Double(NSEC_PER_SEC)
            let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue()) { [unowned self] in
                //通信処理終了
                if arc4random_uniform(2) == 0 {
                    self.requestState.next(.Success)
                    return
                }
                self.requestState.next(.Error)
            }
            
        }
        
    }
    
    func finishSendMessage(resultMessage: String) {
        let alert = UIAlertController(title: "", message: resultMessage, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
}

//MARK: Unused Bond
//extension ViewController {
//    
//    func setupUI() {
//        destinationTextField.addTarget(self, action: Selector("destinationTextChange:"), forControlEvents: .EditingChanged)
//        subjectTextField.addTarget(self, action: Selector("subjectTextChange:"), forControlEvents: .EditingChanged)
//        messageTextView.delegate = self
//        disableSendButton()
//        sendButton.addTarget(self, action: Selector("sendMessage"), forControlEvents: .TouchUpInside)
//        endRequestIndicator()
//    }
//    
//    func disableSendButton() {
//        sendButton.enabled = false
//        sendButton.alpha = 0.5
//    }
//    
//    func enableSendButton() {
//        sendButton.enabled = true
//        sendButton.alpha = 1.0
//    }
//    
//    func startRequestIndicator() {
//        requestIndicator.hidden = false
//        requestIndicator.startAnimating()
//    }
//    
//    func endRequestIndicator() {
//        requestIndicator.hidden = true
//        requestIndicator.stopAnimating()
//    }
//    
//    func updateSendButtonState() {
//        
//        if requestState == .Requesting {
//            disableSendButton()
//            return
//        }
//        
//        let messageCount = messageTextView.text.characters.count
//        guard let destinationCount = destinationTextField.text?.characters.count, subjectCount = subjectTextField.text?.characters.count
//            where destinationCount > 0 && subjectCount > 0 && (1...CharacterLimit) ~= messageCount else {
//                disableSendButton()
//                return
//        }
//        
//        enableSendButton()
//        
//    }
//    
//    func updateCharacterLimitLabel() {
//        
//        let messageCount = messageTextView.text.characters.count
//        let diffCount = CharacterLimit - messageCount
//        characterLimitLabel.text = diffCount.description
//        if diffCount >= 0 {
//            characterLimitLabel.textColor = UIColor.blackColor()
//        }
//        else {
//            characterLimitLabel.textColor = UIColor.redColor()
//        }
//        
//    }
//    
//    func updateRequestIndicator() {
//        requestState.isRequesting() ? startRequestIndicator() : endRequestIndicator()
//    }
//    
//    func destinationTextChange(destinationText: UITextField) {
//        updateSendButtonState()
//    }
//    
//    func subjectTextChange(subjectText: UITextField) {
//        updateSendButtonState()
//    }
//    
//    func sendMessage() {
//        
//        requestState = .Requesting
//        let delay = 1.5 * Double(NSEC_PER_SEC)
//        let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
//        dispatch_after(time, dispatch_get_main_queue()) { [unowned self] in
//            //通信処理終了
//            if arc4random_uniform(2) == 0 {
//                self.requestState = .Success
//                self.finishSendMessage("送信成功しました")
//                return
//            }
//            self.requestState = .Error
//            self.finishSendMessage("送信失敗しました")
//        }
//    }
//    
//    func finishSendMessage(resultMessage: String) {
//        
//        let alert = UIAlertController(title: "", message: resultMessage, preferredStyle: .Alert)
//        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
//        alert.addAction(action)
//        presentViewController(alert, animated: true, completion: nil)
//        
//    }
//    
//}
//
//extension ViewController: UITextViewDelegate {
//    
//    func textViewDidChange(textView: UITextView) {
//        updateSendButtonState()
//        updateCharacterLimitLabel()
//    }
//    
//}