//
//  UserMessage.swift
//  Hello
//
//  Created by Akash Ungarala on 9/9/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit
import Firebase

class UserMessage: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var message: UITextField!

    var user: User!
    var userId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        message.delegate = self
        avatar.layer.masksToBounds = false
        avatar.layer.cornerRadius = avatar.frame.height/2
        avatar.clipsToBounds = true
        if let user = FIRAuth.auth()?.currentUser {
            userId = user.uid
        }
        if let imageURL:URL? = URL(string: user.avatar) {
            if let url = imageURL {
                self.avatar.sd_setImage(with: url)
            }
        }
        fullName.text = "\(user.firstName) \(user.lastName)"
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @IBAction func Send(_ sender: UIButton) {
        if message.text == "" {
            alert("Please enter the message")
        } else {
            let ref = FIRDatabase.database().reference(withPath: "users/").child(user.id).child("messages")
            let id = ref.childByAutoId().key
            ref.child(id).setValue(["id": id, "user": userId, "message": message.text!, "read": "false", "created_at": FIRServerValue.timestamp()])
            self.performSegue(withIdentifier: "SendUserMessageSegue", sender: sender)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "SendUserMessageSegue" {
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
