//
//  Profile.swift
//  Hello
//
//  Created by Akash Ungarala on 9/8/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit
import Firebase

class Profile: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var mobile: UITextField!
    
    var user = User()
    var selectedImage: UIImage!
    var activityIndicatorView: ActivityIndicatorView!
    let ref = FIRDatabase.database().reference(withPath: "users/").child((FIRAuth.auth()?.currentUser?.uid)!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstName.delegate = self
        lastName.delegate = self
        mobile.delegate = self
        avatar.layer.masksToBounds = false
        avatar.layer.cornerRadius = avatar.frame.height/2
        avatar.clipsToBounds = true
        self.activityIndicatorView = ActivityIndicatorView(title: "Loading...", center: self.view.center)
        self.view.addSubview(self.activityIndicatorView.getViewActivityIndicator())
        self.activityIndicatorView.startAnimating()
        ref.observe(.value, with: { snapshotValue in
            let snapshot = snapshotValue.value as? NSDictionary
            self.user.id = snapshot!["id"] as! String
            self.user.email = snapshot!["email"] as! String
            self.user.avatar = snapshot!["avatar"] as! String
            self.user.mobile = snapshot!["mobile"] as! String
            self.user.firstName = snapshot!["first_name"] as! String
            self.user.lastName = snapshot!["last_name"] as! String
            self.user.createdAt = snapshot!["created_at"] as! TimeInterval
            self.firstName.text = self.user.firstName
            self.lastName.text = self.user.lastName
            self.mobile.text = self.user.mobile
            if let imageURL: URL? = URL(string: self.user.avatar) {
                if let url = imageURL {
                    self.avatar.sd_setImage(with: url)
                }
            }
            self.activityIndicatorView.stopAnimating()
            }, withCancel: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func ChangeAvatar(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
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
    
    @IBAction func SaveProfile(_ sender: UIButton) {
        if self.firstName.text == "" {
            alert("Please enter the First Name")
        } else if self.mobile.text == "" {
            alert("Please enter the Mobile Number")
        } else {
            self.activityIndicatorView = ActivityIndicatorView(title: "Saving...", center: self.view.center)
            self.view.addSubview(self.activityIndicatorView.getViewActivityIndicator())
            self.activityIndicatorView.startAnimating()
            self.user.firstName = self.firstName.text!
            self.user.lastName = self.lastName.text!
            self.user.mobile = self.mobile.text!
            if selectedImage != nil {
                let imageName = UUID().uuidString
                let storageRef = FIRStorage.storage().reference().child("photos").child("\(imageName).png")
                let uploadData = UIImagePNGRepresentation(self.selectedImage)
                storageRef.put(uploadData!, metadata: nil, completion: { (metadata, error) in
                    if (error == nil) {
                        if let image = metadata?.downloadURL()?.absoluteString {
                            FIRDatabase.database().reference(withPath: "users/").child(self.user.id).setValue(["id": self.user.id, "avatar": image, "email": self.user.email, "mobile": self.user.mobile, "first_name": self.user.firstName, "last_name": self.user.lastName, "created_at": self.user.createdAt, "updated_at": FIRServerValue.timestamp()])
                            self.activityIndicatorView.stopAnimating()
                            self.performSegue(withIdentifier: "ProfileSegue", sender: sender)
                        }
                    } else {
                        FIRDatabase.database().reference(withPath: "users/").child(self.user.id).setValue(["id": self.user.id, "avatar": self.user.avatar, "email": self.user.email, "mobile": self.user.mobile, "first_name": self.user.firstName, "last_name": self.user.lastName, "created_at": self.user.createdAt, "updated_at": FIRServerValue.timestamp()])
                        self.activityIndicatorView.stopAnimating()
                        self.performSegue(withIdentifier: "ProfileSegue", sender: sender)
                    }
                })
                self.selectedImage = nil
            } else {
                FIRDatabase.database().reference(withPath: "users/").child(self.user.id).setValue(["id": self.user.id, "avatar": self.user.avatar, "email": self.user.email, "mobile": self.user.mobile, "first_name": self.user.firstName, "last_name": self.user.lastName, "created_at": self.user.createdAt, "updated_at": FIRServerValue.timestamp()])
                self.activityIndicatorView.stopAnimating()
                self.performSegue(withIdentifier: "ProfileSegue", sender: sender)
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "ProfileSegue" {
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
