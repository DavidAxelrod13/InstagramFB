//
//  ChatLogController.swift
//  InstagramFB
//
//  Created by David on 10/10/2017.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout, ChatMessageCellDelegate {
    
    var chatPartner: User? {
        didSet {
            navigationItem.title = chatPartner?.username
            
            observeMessages()
        }
    }
    
    var messages = [Message]()
    
    private func observeMessages() {
        
        guard let currentUserUID = Auth.auth().currentUser?.uid, let chatPartnerUID = chatPartner?.uid else { return }
        
        let userMessagesRef = Database.database().reference().child("user-messages").child(currentUserUID).child(chatPartnerUID)
        
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messagesRef = Database.database().reference().child("messages").child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dict = snapshot.value as? [String:AnyObject] else { return }
                let message = Message(dictionary: dict)
                //NEW
                message.messageUID = snapshot.key
                
                    self.messages.append(message)
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                        if self.messages.count > 0 {
                            let indexPathOfLastItem = IndexPath(item: self.messages.count - 1, section: 0)
                            if self.indexPathIsValid(indexPath: indexPathOfLastItem) {
                                self.collectionView?.scrollToItem(at: indexPathOfLastItem, at: UICollectionViewScrollPosition.top, animated: true)
                            }
                        }
                    }
                
            }, withCancel: { (error) in
                 print("Error fetching users messages from FB DB (messages node): ", error.localizedDescription)
            })
        }) { (error) in
            print("Error fetching users messages from FB DB(user-messages node): ", error.localizedDescription)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveLastReadMessage()
    }
    
    func saveLastReadMessage() {
        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }
        guard let lastMessageUserUID = self.messages.last?.fromUserUID else { return }
        
        if lastMessageUserUID == currentUserUID {
            return
        } else {
            guard let lastMessageUID = self.messages.last?.messageUID else { return }
            
            let values = ["lastReadMessage": lastMessageUID]
            Database.database().reference().child("users").child(currentUserUID).updateChildValues(values)
        }
    }
    
    let chatCellId = "chatCellId"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: chatCellId)
        
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.keyboardDismissMode = .interactive
        
        setupKeyboardObservers()
        
        self.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.becomeFirstResponder()
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: .UIKeyboardDidShow, object: nil)
    }
    
    @objc func handleKeyboardDidShow() {
        if messages.count > 0 {
            let indexPathOfLastItem = IndexPath(item: messages.count - 1, section: 0)
            if indexPathIsValid(indexPath: indexPathOfLastItem) {
                collectionView?.scrollToItem(at: indexPathOfLastItem, at: UICollectionViewScrollPosition.top, animated: true)
            }
        }
    }
    
    private func indexPathIsValid(indexPath: IndexPath) -> Bool {
        if indexPath.section >= (collectionView?.numberOfSections)! {
            return false
        }
        
        if indexPath.item >= (collectionView?.numberOfItems(inSection: 0))! {
            return false
        }
        
        return true
    }

    lazy var inputContainerView: ChatInputContainerView = {
        
        let chatLogInputContainerView = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        
        chatLogInputContainerView.delegate = self
        
        return chatLogInputContainerView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
           return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    @objc func handleSend() {
        let inputString = inputContainerView.inputTextField.text
        
        if (inputString?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? "").isEmpty {
            print("String is nil or empty")
        } else {
            let properties = ["text" : inputString!] as [String : AnyObject]
            sendMessageWithProperties(properties: properties)
        }
    }
    
    private func sendMessageWithImageUrl(imageUrl: String, image: UIImage) {
        
        let properties = ["imageUrl": imageUrl, "imageWidth" : image.size.width, "imageHeight" : image.size.height] as [String : AnyObject]
        sendMessageWithProperties(properties: properties)
        
    }
    
    private func sendMessageWithVideoUrl(videoUrl: String, thumbnailImage: UIImage, thumbnailImageUrl: String) {
        let properties = ["videoUrl": videoUrl, "imageUrl": thumbnailImageUrl, "imageWidth" : thumbnailImage.size.width, "imageHeight" : thumbnailImage.size.height] as [String : AnyObject]
        sendMessageWithProperties(properties: properties)
    }
    
    private func sendMessageWithProperties(properties: [String: AnyObject]) {
        
        guard let fromUserUID = Auth.auth().currentUser?.uid else { return }
        
        guard let toUserUID = chatPartner?.uid else { return }
        
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        
        let timeStamp = Int(Date().timeIntervalSince1970)
        
        var values = ["fromUserUID": fromUserUID, "toUserUID" : toUserUID, "timeStamp": timeStamp] as [String: AnyObject]
        
        properties.forEach({ (keyInProperties: String, valueInProperties: AnyObject) in
            values[keyInProperties] = valueInProperties
        })
        
        childRef.updateChildValues(values) { (error: Error?, ref) in
            
            if let err = error {
                print("Error saving the message to FB DB: ", err.localizedDescription)
                return
            }
            
            self.inputContainerView.inputTextField.text = nil
            
            print("Success saving the message in FB DB")
            
            let userMessageRef = Database.database().reference().child("user-messages").child(fromUserUID).child(toUserUID)
            
            let messageUID = childRef.key
            userMessageRef.updateChildValues([messageUID : 1])
            
            let recipientUserMesssagesRef = Database.database().reference().child("user-messages").child(toUserUID).child(fromUserUID)
            recipientUserMesssagesRef.updateChildValues([messageUID : 1])
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: chatCellId, for: indexPath) as! ChatMessageCell
        
        cell.delegate = self
        
        let message = messages[indexPath.item]
        cell.message = message
        
        setupCell(cell: cell, message: message)
        
        if let messageText = message.text {
            cell.bubbleWidthAnchor?.constant = self.estimatedFrameForText(text: messageText).width + 22
        } else if message.imageUrl != nil {
            cell.bubbleWidthAnchor?.constant = 200
        }
                        
        return cell
    }
    
    private func setupCell(cell: ChatMessageCell, message: Message) {
        if let chatPartnerImageURL = self.chatPartner?.profileImageDownloadUrl {
            cell.profileImageView.loadImageWithUrlString(urlString: chatPartnerImageURL)
        }
        
        if message.fromUserUID == Auth.auth().currentUser?.uid {
            // outgoing message
            cell.bubbleView.backgroundColor = UIColor.instagramBlueChatMessageBubble
            cell.textView.textColor = UIColor.white
            
            cell.profileImageView.isHidden = true
            
            cell.bubbleViewTrailingAnchor?.isActive = true
            cell.bubbleViewLeadingAnchor?.isActive = false
        } else {
            // incoming message
            cell.bubbleView.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
            cell.textView.textColor = UIColor.black
            
            cell.profileImageView.isHidden = false
            
            cell.bubbleViewTrailingAnchor?.isActive = false
            cell.bubbleViewLeadingAnchor?.isActive = true
        }
        
        if let messageImageURL = message.imageUrl {
            cell.messageImageView.loadImageWithUrlString(urlString: messageImageURL)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
            cell.textView.isHidden = true
        } else {
            cell.messageImageView.isHidden = true
            cell.textView.isHidden = false
        }
        
        if message.videoUrl != nil {
            cell.playButton.isHidden = false
        } else {
            cell.playButton.isHidden = true
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        let message = messages[indexPath.item]
        
        if let text = message.text {
           height = estimatedFrameForText(text: text).height + 20
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            
            let bubbleViewWidth: Float = 200
            
            height = CGFloat(imageHeight / imageWidth * bubbleViewWidth)
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    private func estimatedFrameForText(text: String) -> CGRect {
        
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16)]
        
        let estimatedRect = NSString(string: text).boundingRect(with: size, options: options, attributes: attributes, context: nil)
        return estimatedRect
    }
    
    func didTapOnMessageToZoomIn(messageImageView: UIImageView) {
        performZoomInLogicForStartingImageView(startingImageView: messageImageView)
    }
    
    var startingFrame: CGRect?
    var blackBackground: UIView?
    var startingImageView: UIImageView?
    
    func performZoomInLogicForStartingImageView(startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        self.startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        if let startingFrame = self.startingFrame {
            let zoomingImageView = UIImageView(frame: startingFrame)
            zoomingImageView.backgroundColor = .red
            zoomingImageView.image = startingImageView.image
            zoomingImageView.isUserInteractionEnabled = true
            zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
            
            if let keyWindow = UIApplication.shared.keyWindow {
                
                self.blackBackground = UIView(frame: keyWindow.frame)
                guard let blackBackground = self.blackBackground else { return }
                
                blackBackground.backgroundColor = .black
                blackBackground.alpha = 0
                keyWindow.addSubview(blackBackground)
                
                keyWindow.addSubview(zoomingImageView)
                
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    
                    blackBackground.alpha = 1
                    self.inputContainerView.alpha = 0
                    
                    let zoomingImageViewWidth = keyWindow.frame.width
                    let startingImageViewWidth = startingFrame.width
                    let startingImageViewHeight = startingFrame.height
                    
                    let zoomingImageViewHeight = startingImageViewHeight / startingImageViewWidth * zoomingImageViewWidth
                    
                    zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: zoomingImageViewHeight)
                    zoomingImageView.center = keyWindow.center
                    
                }, completion: nil)
                
            }
        }
    
    }
    @objc func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        
        guard let zoomOutImageView = tapGesture.view else { return }
        guard let startingFrame = self.startingFrame else { return }
        guard let blackBackground = self.blackBackground else { return }
        
        zoomOutImageView.layer.cornerRadius = 16
        zoomOutImageView.clipsToBounds = true
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            zoomOutImageView.frame = startingFrame
            blackBackground.alpha = 0
            self.inputContainerView.alpha = 1
            
        }) { (completed: Bool) in
            zoomOutImageView.removeFromSuperview()
            self.startingImageView?.isHidden = false
        }
    }
}

extension ChatLogController: ChatInputContainerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func didTapOnSendButton() {
        self.handleSend()
    }
    
    func didTapOnUploadImageView() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let url = info[UIImagePickerControllerMediaURL] as? URL {
            // user selected a video
           self.handleVideoSelectedForUrl(url: url)
        } else {
            // user selected an image
            self.handleImageSelectedForInfoDict(info: info)
        }
        dismiss(animated: true, completion: nil)
    }
    
    private func handleVideoSelectedForUrl(url: URL) {
        let filename = UUID().uuidString + ".mov"
        
        let uploadTaks = Storage.storage().reference().child("message_videos").child(filename).putFile(from: url, metadata: nil, completion: { (metadata, error) in
            if let error = error {
                print("Error uploading the video message to FB S: ", error.localizedDescription)
                return
            }
            
            if let videoUrl = metadata?.downloadURL()?.absoluteString {
                if let thumbnailImage = self.thumbnailImageForVideoUrl(url: url) {
                    self.uploadImageToFirebaseStorage(image: thumbnailImage, completion: { (thumbnailImageUrl) in
                        self.sendMessageWithVideoUrl(videoUrl: videoUrl, thumbnailImage: thumbnailImage, thumbnailImageUrl: thumbnailImageUrl)
                    })
                }
            }
        })
        
        uploadTaks.observe(.progress) { (snapshot) in
            if let completedUnitCount = snapshot.progress?.completedUnitCount, let totalUnitCount = snapshot.progress?.totalUnitCount {
                let percentComplete = (Float64(completedUnitCount)/Float64(totalUnitCount)) * 100
                self.navigationItem.title = ("\(percentComplete.rounded())%")
            }
        }
        
        uploadTaks.observe(.success) { (_) in
            self.navigationItem.title = self.chatPartner?.username
        }
    }
    
    private func thumbnailImageForVideoUrl(url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        let cmTime = CMTime(value: 1, timescale: 60)
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: cmTime, actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch let err {
            print(err.localizedDescription)
        }
        
        return nil
    }
    
    private func handleImageSelectedForInfoDict(info: [String : Any]) {
        var selectedImageFromImagePicker: UIImage?
        if let edditedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImageFromImagePicker = edditedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImageFromImagePicker = originalImage
        }
        
        if let selectedImage = selectedImageFromImagePicker {
            uploadImageToFirebaseStorage(image: selectedImage, completion: { (imageDownloadUrl) in
                self.sendMessageWithImageUrl(imageUrl: imageDownloadUrl, image: selectedImage)
            })
        }
    }
    
    private func uploadImageToFirebaseStorage(image: UIImage, completion: @escaping (_ imageDownloadUrl: String) -> ()) {
       
        guard let uploadData = UIImageJPEGRepresentation(image, 0.3) else { return }
        let imageUID = UUID().uuidString
        
        let storageRef = Storage.storage().reference().child("message_images").child(imageUID)
        
        storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Error uploading Image Data to FB S: ", error.localizedDescription)
                return
            }
            
            if let imageDownloadUrl = metadata?.downloadURL()?.absoluteString {
              completion(imageDownloadUrl)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}






















