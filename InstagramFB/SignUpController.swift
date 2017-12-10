//
//  ViewController.swift
//  InstagramFB
//
//  Created by David on 25/09/2017.
//  Copyright © 2017 David. All rights reserved.
//

import UIKit
import Firebase

class SignUpController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    lazy var plusPhotoButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        return button
    }()
    
    let errorLabel: LabelWithInsets = {
        let label = LabelWithInsets()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.init(red: 204, green: 0, blue: 0, alpha: 0.65)
        label.clipsToBounds = true
        label.layer.cornerRadius = 6
        label.backgroundColor = .clear
        label.numberOfLines = 0
        return label
    }()
    
    lazy var emailTextField: UITextField = {
        let tf = UITextField()
        tf.clearButtonMode = .whileEditing
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.borderStyle = .roundedRect
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.clearButtonMode = .whileEditing
        tf.placeholder = "Username"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.borderStyle = .roundedRect
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()

    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.clearButtonMode = .whileEditing
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.borderStyle = .roundedRect
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    lazy var signUpButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    @objc func handlePlusPhoto() {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    private func showErrorHUD(error: String) {
        
        errorLabel.isHidden = false
        
        errorLabel.text = error
        
        self.view.addSubview(errorLabel)
        
        
        errorLabel.anchor(top: stackView.bottomAnchor, left: stackView.leftAnchor, bottom: nil, right: stackView.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        errorLabel.sizeToFit()
    }
    
    private func handleError(_ error: Error) {
        if let errorCode = AuthErrorCode(rawValue: error._code) {
            switch errorCode {
            case .userNotFound:
                showErrorHUD(error: "No such user exists, please check the information you have entered.")
            case .internalError:
                showErrorHUD(error: "Sorry, an internal error has occured.")
            case .invalidEmail:
                showErrorHUD(error: "Invalid email has been entered, please check.")
            case .networkError:
                showErrorHUD(error: "A network error has occured please wait and retry.")
            case .emailAlreadyInUse:
                showErrorHUD(error: "The email you have entered is already in use.")
            case .weakPassword:
                showErrorHUD(error: error.localizedDescription)
            default:
                showErrorHUD(error: "Error: \(error.localizedDescription)")
            }
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let edittedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            plusPhotoButton.setImage(edittedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }  else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            plusPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width / 2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.rgb(red: 17, green: 154, blue: 237).cgColor
        plusPhotoButton.layer.borderWidth = 3
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleTextInputChange() {
        
        errorLabel.isHidden = true
        
        let isFormValid: Bool = (emailTextField.text?.count ?? 0) > 0 && (usernameTextField.text?.count ?? 0) > 0 && (passwordTextField.text?.count ?? 0) > 0
        
        if isFormValid == true {
            signUpButton.backgroundColor = UIColor.mainBlue()
            signUpButton.isEnabled = true
        } else {
            signUpButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
            signUpButton.isEnabled = false
        }
    }

    @objc func handleSignUp() {
        
        guard let email = emailTextField.text, email.count > 0 else { return }
        guard let username = usernameTextField.text, username.count > 0 else { return }
        guard let password = passwordTextField.text, password.count > 0 else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error: Error?) in
            
            if let err = error {
                print("Error registering the user: ", err.localizedDescription)
                self.handleError(err)
                return
            }
            
            print("Success registering user with UID: ", user?.uid ?? "")
            
            // Save the Profile Image to FB S
            guard let profileImage = self.plusPhotoButton.currentImage else { return }
            guard let profileImageData = UIImageJPEGRepresentation(profileImage, 0.3)else { return }

            let imageUid = UUID().uuidString
            Storage.storage().reference().child("profile_images").child(imageUid).putData(profileImageData, metadata: nil, completion: { (metadata, error) in
                
                if let err = error {
                    print("Error uploading profile image: ", err.localizedDescription)
                    self.handleError(err)
                    return
                }
                
                guard let profileImageDownloadUrl = metadata?.downloadURL()?.absoluteString else { return }
                print("Success uploading profile image with download Url: ", profileImageDownloadUrl)
                
                
                
                // Save the username + image downl url to FB DB
                guard let uid = user?.uid else { return }
                
                guard let fcmToken = Messaging.messaging().fcmToken else { return }
                
                let dictValues = ["username": username, "profileImageDownloadUrl": profileImageDownloadUrl, "fcmToken": fcmToken]
                let values = [uid: dictValues]
                
                Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (error, ref: DatabaseReference) in
                    
                    if let err = error {
                        print("Error with saving username: ", err.localizedDescription)
                        self.handleError(err)
                        return
                    }
                    print("Success saving username")
                    
                    guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else { return }
                    
                    mainTabBarController.setupViewControllers()
                    
                    self.dismiss(animated: true, completion: nil)
                })

            })
        }
    }
    
    lazy var alreadyHaveAnAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedText = NSMutableAttributedString(string: "Already have an account ? ", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)])
        
        attributedText.append(NSAttributedString(string: "Login", attributes: [NSAttributedStringKey.foregroundColor: UIColor.rgb(red: 17, green: 154, blue: 237), NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)]))
        
        button.setAttributedTitle(attributedText, for: .normal)
        
        button.addTarget(self, action: #selector(handleAlreadyHaveAnAccount), for: .touchUpInside)
        return button
    }()
    
    @objc func handleAlreadyHaveAnAccount() {
        _ = navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(alreadyHaveAnAccountButton)
        view.addSubview(plusPhotoButton)
        
        alreadyHaveAnAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        plusPhotoButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        
        plusPhotoButton.anchorCenterXToSuperview()
        
        setupInputFields()
        
    }
    
    let stackView: UIStackView = {
        let sv = UIStackView()
        sv.distribution = .fillEqually
        sv.axis = .vertical
        sv.spacing = 10
        return sv
    }()
    
    fileprivate func setupInputFields() {
        
        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(usernameTextField)
        stackView.addArrangedSubview(passwordTextField)
        stackView.addArrangedSubview(signUpButton)
        
        view.addSubview(stackView)
        
        stackView.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 200)
        
    }
}












