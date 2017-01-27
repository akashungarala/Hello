//
//  UserList.swift
//  Hello
//
//  Created by Akash Ungarala on 9/11/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class UserList: UITableViewController {
    
    var users = [User]()
    let ref = FIRDatabase.database().reference(withPath: "users/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        users.removeAll()
        ref.observe(.childAdded, with: { snapshotValue in
            var user = User()
            let snapshot = snapshotValue.value as? NSDictionary
            user.id = snapshot!["id"] as! String
            user.avatar = snapshot!["avatar"] as! String
            user.email = snapshot!["email"] as! String
            user.mobile = snapshot!["mobile"] as! String
            user.firstName = snapshot!["first_name"] as! String
            if let lastName: String = (snapshot!["last_name"] as? String) {
                user.lastName = lastName
            }
            user.createdAt = snapshot!["created_at"] as! TimeInterval
            self.users.insert(user, at: 0)
            self.tableView.reloadData()
        })
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "User", for: indexPath) as! UserCell
        if let imageURL: URL? = URL(string: users[(indexPath as NSIndexPath).row].avatar) {
            if let url = imageURL {
                cell.avatar.sd_setImage(with: url)
            }
        }
        cell.name.text = "\(users[(indexPath as NSIndexPath).row].firstName) \(users[(indexPath as NSIndexPath).row].lastName)"
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectSegue" {
            let destination = segue.destination as! NewMessage
            destination.user = users[((self.tableView.indexPathForSelectedRow as NSIndexPath?)?.row)!]
        }
    }
    
}
