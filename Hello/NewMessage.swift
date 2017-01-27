//
//  NewMessage.swift
//  Hello
//
//  Created by Akash Ungarala on 9/10/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase

class NewMessage: UIViewController {
    
    var user: User!
    var userId: String!
    var activityIndicatorView: ActivityIndicatorView!
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var message: UITextField!
    @IBOutlet weak var selectUser: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = FIRAuth.auth()?.currentUser {
            userId = user.uid
        }
        user = nil
        selectUser.isHidden = false
        name.isHidden = true
        avatar.isHidden = true
    }
    
    @IBAction func SendMessage(_ sender: UIButton) {
        if selectUser.isHidden == false {
            alert("Please select the user")
        } else if message.text == "" {
            alert("Please enter the message")
        } else {
            let ref = FIRDatabase.database().reference(withPath: "users/").child(user.id).child("messages")
            let id = ref.childByAutoId().key
            ref.child(id).setValue(["id": id, "user": userId, "message": message.text!, "read": "false", "created_at": FIRServerValue.timestamp()])
            self.performSegue(withIdentifier: "SendNewMessageSegue", sender: sender)
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "SendNewMessageSegue" {
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
    
    @IBAction func doneToNewMessage(_ sender: UIStoryboardSegue) {
        selectUser.isHidden = true
        name.isHidden = false
        avatar.isHidden = false
        if let imageURL:URL? = URL(string: user.avatar) {
            if let url = imageURL {
                avatar.sd_setImage(with: url)
            }
        }
        name.text = "\(user.firstName) \(user.lastName)"
    }
    
}
