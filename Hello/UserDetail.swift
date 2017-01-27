//
//  UserDetail.swift
//  Hello
//
//  Created by Akash Ungarala on 9/9/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit
import Firebase

class UserDetail: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var mobile: UILabel!
    @IBOutlet weak var edit: UIButton!
    @IBOutlet weak var changeAvatar: UIButton!
    @IBOutlet weak var cancel: UIButton!
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var editMobile: UITextField!

    var user: User!
    var selectedImage: UIImage!
    var activityIndicatorView: ActivityIndicatorView!
    let ref = FIRDatabase.database().reference(withPath: "users/").child((FIRAuth.auth()?.currentUser?.uid)!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstName.delegate = self
        lastName.delegate = self
        editMobile.delegate = self
        if let imageURL:URL? = URL(string: user.avatar) {
            if let url = imageURL {
                self.activityIndicatorView = ActivityIndicatorView(title: "Loading...", center: self.view.center)
                self.view.addSubview(self.activityIndicatorView.getViewActivityIndicator())
                self.activityIndicatorView.startAnimating()
                self.avatar.sd_setImage(with: url)
                self.activityIndicatorView.stopAnimating()
            }
        }
        email.text = user.email
        fullName.text = "\(user.firstName) \(user.lastName)"
        mobile.text = user.mobile
        editOff()
        if (user.id == (FIRAuth.auth()?.currentUser?.uid)!) {
            edit.isHidden = false
        } else {
            edit.isHidden = true
        }
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
    
    @IBAction func EditProfile(_ sender: UIButton) {
        editOn()
    }
    
    @IBAction func Cancel(_ sender: UIButton) {
        editOff()
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
            self.user.mobile = self.editMobile.text!
            if selectedImage != nil {
                let imageName = UUID().uuidString
                let storageRef = FIRStorage.storage().reference().child("photos").child("\(imageName).png")
                let uploadData = UIImagePNGRepresentation(self.selectedImage)
                storageRef.put(uploadData!, metadata: nil, completion: { (metadata, error) in
                    if (error == nil) {
                        if let image = metadata?.downloadURL()?.absoluteString {
                            self.ref.setValue(["id": self.user.id, "avatar": image, "email": self.user.email, "mobile": self.user.mobile, "first_name": self.user.firstName, "last_name": self.user.lastName, "created_at": self.user.createdAt, "updated_at": FIRServerValue.timestamp()])
                            self.activityIndicatorView.stopAnimating()
                            self.fullName.text = "\(self.user.firstName) \(self.user.lastName)"
                            self.mobile.text = self.user.mobile
                            self.editOff()
                        }
                    } else {
                        self.ref.setValue(["id": self.user.id, "avatar": self.user.avatar, "email": self.user.email, "mobile": self.user.mobile, "first_name": self.user.firstName, "last_name": self.user.lastName, "created_at": self.user.createdAt, "updated_at": FIRServerValue.timestamp()])
                        self.activityIndicatorView.stopAnimating()
                        self.fullName.text = "\(self.user.firstName) \(self.user.lastName)"
                        self.mobile.text = self.user.mobile
                        self.editOff()
                    }
                })
                self.selectedImage = nil
            } else {
                self.ref.setValue(["id": self.user.id, "avatar": self.user.avatar, "email": self.user.email, "mobile": self.user.mobile, "first_name": self.user.firstName, "last_name": self.user.lastName, "created_at": self.user.createdAt, "updated_at": FIRServerValue.timestamp()])
                self.activityIndicatorView.stopAnimating()
                self.fullName.text = "\(self.user.firstName) \(self.user.lastName)"
                self.mobile.text = self.user.mobile
                self.editOff()
            }
        }
    }
    
    func alert(_ alertMessage: String) {
        let alert = UIAlertController(title: "Alert", message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func editOn() {
        email.isHidden = true
        fullName.isHidden = true
        mobile.isHidden = true
        edit.isHidden = true
        changeAvatar.isHidden = false
        cancel.isHidden = false
        save.isHidden = false
        firstName.isHidden = false
        lastName.isHidden = false
        editMobile.isHidden = false
        firstName.text = user.firstName
        lastName.text = user.lastName
        editMobile.text = user.mobile
    }
    
    func editOff() {
        email.isHidden = false
        fullName.isHidden = false
        mobile.isHidden = false
        edit.isHidden = false
        changeAvatar.isHidden = true
        cancel.isHidden = true
        save.isHidden = true
        firstName.isHidden = true
        lastName.isHidden = true
        editMobile.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UserMessageSegue" {
            let destination = segue.destination as! UserMessage
            destination.user = user
        }
    }
    
    @IBAction func cancelToUserDetail(_ sender: UIStoryboardSegue) {}
    
    @IBAction func sendToUserDetail(_ sender: UIStoryboardSegue) {}

}
