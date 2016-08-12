//
//  ChatViewController.swift
//  PokeTrainerApp
//
//  Created by iParth on 7/30/16.
//  Copyright © 2016 iParth. All rights reserved.
//


import UIKit
import Firebase
import JSQMessagesViewController
import SDWebImage

class ChatViewController: JSQMessagesViewController {
  
    // MARK: Properties
    var city: String!
    
    let rootRef = FIRDatabase.database().reference()
    var messageRef: FIRDatabaseReference!
    var messages = [JSQMessage]()

    
    var userIsTypingRef: FIRDatabaseReference!
    var usersTypingQuery: FIRDatabaseQuery!
    private var localTyping = false
    var isTyping: Bool {
    get {
      return localTyping
    }
    set {
      localTyping = newValue
      userIsTypingRef.setValue(newValue)
    }
    }

    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!

    var navigationBar = UINavigationBar()


    override func viewDidLoad() {
        super.viewDidLoad()
        setupBubbles()
        messageRef = rootRef.child("Chat_\(self.city)")

        self.inputToolbar.contentView.leftBarButtonItem = nil
        self.topContentAdditionalInset = 44

        // No avatars
        //collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero

        // Create the navigation bar
        navigationBar = UINavigationBar(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 64))
        // Offset by 20 pixels vertically to take the status bar into account
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationBar.tintColor = UIColor.whiteColor()
        navigationBar.barTintColor = AppState.sharedInstance.appBlueColor
        navigationBar.translucent = false
        
        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
        navigationItem.title = "Chat"
        let leftButton =  UIBarButtonItem(title: "Back", style:   UIBarButtonItemStyle.Plain, target: self, action: #selector(self.ActionGoBack(_:)))
        leftButton.tintColor = UIColor.whiteColor()
        navigationItem.leftBarButtonItem = leftButton
        navigationBar.items = [navigationItem]
        
        self.view.addSubview(navigationBar)
        
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        observeMessages()
        observeTyping()
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func  preferredStatusBarStyle()-> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    //Go Back to Previous screen
    @IBAction func ActionGoBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("sdfasdfdfasdfasdf")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell

        let message = messages[indexPath.item]

        if message.senderId == senderId {
            cell.textView!.textColor = UIColor.whiteColor()
        } else {
            cell.textView!.textColor = UIColor.blackColor()
            
            //let cell:JSQMessagesCollectionViewCell = super.collectionView(collectionView, avatarImageDataForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
            //return JSQMessagesAvatarImageFactory.circularAvatarHighlightedImage(UIImage(named: "POKE-TRAINER-LOGO.png"), withDiameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
            FIRDatabase.database().reference().child("users").child(message.senderId).child("profileData").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                AppState.sharedInstance.currentUser = snapshot
                if let base64String = snapshot.value!["userPhoto"] as? String {
                    cell.avatarImageView.image = JSQMessagesAvatarImageFactory.circularAvatarImage(CommonUtils.sharedUtils.decodeImage(base64String), withDiameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
                } else {
                    if let facebookData = snapshot.value!["facebookData"] as? [String : String] {
                        if let image_url = facebookData["profilePhotoURL"]  {
                            print(image_url)
                            let image_url_string = image_url
                            let url = NSURL(string: "\(image_url_string)")
                            cell.avatarImageView.sd_setImageWithURL(url)
                        }
                    }
                }})
            //cell.avatarImageView.sd_setImageWithURL(NSURL.init(string:self.userSession.profilePictureUrl), placeholderImage: UIImage(named: "POKE-TRAINER-LOGO.png"))
        }

        
        
        return cell
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath) -> NSAttributedString?
    {
        if (indexPath.item % 3 == 0) {
            //let message = self.messages[indexPath.item]
            //return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }
        
        return nil
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.item % 3 == 0 {
            //return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let currentMessage = self.messages[indexPath.item]
        
        if currentMessage.senderId == self.senderId {
            return 0.0
        }
        
        if indexPath.item - 1 > 0 {
            let previousMessage = self.messages[indexPath.item - 1]
            if previousMessage.senderId == currentMessage.senderId {
                return 0.0
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath) -> NSAttributedString? {
        let message = messages[indexPath.item]
        
        if message.senderId == self.senderId {
            //return nil
        }
        
        //let range = message.senderDisplayName.rangeOfString(message.senderDisplayName)
        let attributedString = NSMutableAttributedString(string:message.senderDisplayName)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.lightGrayColor() , range: NSRangeFromString(message.senderDisplayName))
        return attributedString
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            return nil
        }
        else
        {
            var jsqAvtarImg = JSQMessagesAvatarImage.avatarWithImage(UIImage(named: "POKE-TRAINER-LOGO.png"))
            return jsqAvtarImg
        }
    }
    
    
    private func observeMessages() {
        let messagesQuery = messageRef.queryLimitedToLast(25)
        messagesQuery.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            let id = snapshot.value!["senderId"] as! String
            let text = snapshot.value!["text"] as! String
            let senderName = snapshot.value!["senderName"] as? String ?? id
            let createdAt = snapshot.value!["createdAt"] as? String ?? ""
            
            self.addMessage(id, text: text,displayName: senderName,createdAt: createdAt)
            self.finishReceivingMessage()
        })
    }

    private func observeTyping()
    {
        let typingIndicatorRef = rootRef.child("typingIndicator")
        userIsTypingRef = typingIndicatorRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        usersTypingQuery = typingIndicatorRef.queryOrderedByValue().queryEqualToValue(true)

        usersTypingQuery.observeEventType(.ChildAdded, withBlock: { (data) in
          
            if data.childrenCount == 1 && self.isTyping {
                return
            }

            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottomAnimated(true)
        })

    }

    func addMessage(id: String, text: String,displayName: String,createdAt: String) {
        
        let message = JSQMessage(senderId: id, senderDisplayName: displayName, date: createdAt.asDate, text: text)
        //JSQMessage(senderId: id, displayName: id, text: text)

        messages.append(message)
    }

        override func textViewDidChange(textView: UITextView) {
        super.textViewDidChange(textView)
        isTyping = textView.text != ""
    }

    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {

        let itemRef = messageRef.childByAutoId()
        let messageItem = [
          "text": text,
          "senderId": senderId,
          "senderName": AppState.sharedInstance.displayName ?? "",
          "createdAt": NSDate().customFormatted
        ]
        itemRef.setValue(messageItem)

        JSQSystemSoundPlayer.jsq_playMessageSentSound()

        finishSendingMessage()
        isTyping = false
    }

    private func setupBubbles() {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = bubbleImageFactory.outgoingMessagesBubbleImageWithColor(AppState.sharedInstance.appBlueColor)
        incomingBubbleImageView = bubbleImageFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    }
  
}