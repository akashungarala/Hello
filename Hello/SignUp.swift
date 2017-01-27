//
//  SignUp.swift
//  Hello
//
//  Created by Akash Ungarala on 9/2/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit
import Firebase

class SignUp: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var mobile: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    
    var selectedImageUrl: String!
    var selectedImage: UIImage!
    var activityIndicatorView: ActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstName.delegate = self
        lastName.delegate = self
        email.delegate = self
        mobile.delegate = self
        password.delegate = self
        confirmPassword.delegate = self
        avatar.layer.masksToBounds = false
        avatar.layer.cornerRadius = avatar.frame.height/2
        avatar.clipsToBounds = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func ChooseAvatar(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func Submit(_ sender: UIButton) {
        if selectedImage == nil {
            alert("Please choose the Avatar")
        } else if firstName.text == "" {
            alert("Please enter the First Name")
        } else if email.text == "" {
            alert("Please enter the Email")
        } else if mobile.text == "" {
            alert("Please enter the Mobile Number")
        } else if password.text == "" {
            alert("Please enter the Password");
        } else if confirmPassword.text == "" {
            alert("Please enter the Confirmation Password");
        } else if (password.text! != confirmPassword.text!) {
            alert("Confirmation Password doesn't match with Password");
        } else {
            self.activityIndicatorView = ActivityIndicatorView(title: "Signing Up...", center: self.view.center)
            self.view.addSubview(self.activityIndicatorView.getViewActivityIndicator())
            self.activityIndicatorView.startAnimating()
            FIRAuth.auth()!.createUser(withEmail: self.email.text!, password: self.password.text!, completion: { (user, error) in
                if error != nil {
                    self.activityIndicatorView.stopAnimating()
                    self.alert("Firebase Sign Up Error")
                    /*
                    if let errCode = FIRAuthErrorCode(rawValue: error.code) {
                        switch errCode {
                        case .ErrorCodeInvalidEmail:
                            self.alert("Invalid Email")
                        case .ErrorCodeEmailAlreadyInUse:
                            self.alert("Email already in use")
                        default:
                            self.alert("Create User Error: \(error)")
                        }
                    }
                    */
                } else {
                    FIRAuth.auth()!.signIn(withEmail: self.email.text!, password: self.password.text!) {
                        error, authData in
                        if error != nil {
                            self.activityIndicatorView.stopAnimating()
                            self.alert("Firebase Login Error")
                        } else {
                            let imageName = UUID().uuidString
                            let storageRef = FIRStorage.storage().reference().child("photos").child("\(imageName).png")
                            let uploadData = UIImagePNGRepresentation(self.selectedImage)
                            storageRef.put(uploadData!, metadata: nil, completion: { (metadata, error) in
                                if (error == nil) {
                                    if let image = metadata?.downloadURL()?.absoluteString {
                                        self.selectedImageUrl = image
                                        let userId = user?.uid
                                        let userInfo = ["id": "\(userId!)", "avatar": self.selectedImageUrl!, "email": self.email.text!, "mobile": self.mobile.text!, "first_name": self.firstName.text!, "last_name": self.lastName.text!, "created_at": FIRServerValue.timestamp(),"updated_at": FIRServerValue.timestamp()] as [String : Any]
                                        FIRDatabase.database().reference(withPath: "users/").child("\(userId!)").setValue(userInfo)
                                        self.activityIndicatorView.stopAnimating()
                                        self.performSegue(withIdentifier: "LoginSegue", sender: sender)
                                    }
                                }
                            })
                        }
                    }
                }
            })
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.selectedImageUrl = nil
        self.selectedImage = nil
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            self.selectedImage = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            self.selectedImage = originalImage
        }
        dismiss(animated: true, completion: nil)
        self.avatar.image = self.selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "LoginSegue" {
            return false
        }
        return true
    }
    
    func alert(_ alertMessage: String) {
        let alert = UIAlertController(title: "Alert", message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }

}
