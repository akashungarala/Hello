//
//  Inbox.swift
//  Hello
//
//  Created by Akash Ungarala on 9/9/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class Inbox: UITableViewController {

    var messages = [Message]()
    let ref = FIRDatabase.database().reference(withPath: "users/").child((FIRAuth.auth()?.currentUser?.uid)!).child("messages")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func getMessages() {
        messages.removeAll()
        ref.observe(.childAdded, with: { snapshotValue in
            var message = Message()
            let snapshot = snapshotValue.value as? NSDictionary
            message.id = snapshot!["id"] as! String
            message.message = snapshot!["message"] as! String
            message.read = snapshot!["read"] as! String
            message.createdAt = snapshot!["created_at"] as! TimeInterval
            let userId = snapshot!["user"] as! String
            var user = User()
            FIRDatabase.database().reference(withPath: "users/").child(userId).observe(.value, with: { snapshotValue in
                let snapshot = snapshotValue.value as? NSDictionary
                if let avatar: String? = (snapshot!["avatar"] as! String) {
                    user.avatar = avatar
                }
                user.id = snapshot!["id"] as! String
                user.email = snapshot!["email"] as! String
                user.firstName = snapshot!["first_name"] as! String
                user.lastName = snapshot!["last_name"] as! String
                user.createdAt = snapshot!["created_at"] as! TimeInterval
                message.user = user
                self.messages.insert(message, at: 0)
                self.tableView.reloadData()
                }, withCancel: nil)
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getMessages()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Message", for: indexPath) as! MessageCell
        if let imageURL:URL? = URL(string: messages[(indexPath as NSIndexPath).row].user.avatar) {
            if let url = imageURL {
                cell.avatar.sd_setImage(with: url)
            }
        }
        cell.name.text = "\(messages[(indexPath as NSIndexPath).row].user.firstName) \(messages[(indexPath as NSIndexPath).row].user.lastName)"
        if messages[(indexPath as NSIndexPath).row].read == "true" {
            cell.unread.isHidden = true
        } else if messages[(indexPath as NSIndexPath).row].read == "false" {
            cell.unread.isHidden = false
        }
        cell.message.text = messages[(indexPath as NSIndexPath).row].message
        cell.delete.tag = (indexPath as NSIndexPath).row
        cell.delete.addTarget(self, action: #selector(self.DeleteMessage(_:)), for: .touchUpInside)
        return cell
    }
    
    func DeleteMessage(_ sender: UIButton!) {
        let input = UIAlertController(title: "Inbox Delete", message: "Do you want to delete this message?", preferredStyle: UIAlertControllerStyle.alert)
        input.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        input.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) -> Void in
            self.ref.child(self.messages[sender.tag].id!).setValue(nil)
            self.getMessages()
            self.tableView.reloadData()
        }))
        input.view.setNeedsLayout()
        self.present(input, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MessageDetailSegue" {
            let message = messages[((self.tableView.indexPathForSelectedRow as IndexPath?)?.row)!]
            ref.child(message.id).setValue(["id": message.id, "user": message.user.id, "message": message.message, "read": "true", "created_at": message.createdAt])
            let destination = segue.destination as! MessageDetail
            destination.message = message
        }
    }
    
    @IBAction func backToInbox(_ sender: UIStoryboardSegue) {}
    
    @IBAction func sendToInbox(_ sender: UIStoryboardSegue) {}
    
    @IBAction func cancelToInbox(_ sender: UIStoryboardSegue) {}

}
