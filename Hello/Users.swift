//
//  Users.swift
//  Hello
//
//  Created by Akash Ungarala on 9/2/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class Users: UITableViewController {
    
    var users = [User]()
    let ref = FIRDatabase.database().reference(withPath: "users/")
    var activityIndicatorView: ActivityIndicatorView!
    
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
            } else {
                user.lastName = ""
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
        let downloader = ImageDownloader()
        let urlRequest = URLRequest(url: URL(string: users[(indexPath as NSIndexPath).row].avatar!)!)
        downloader.download(urlRequest) { response in
            if let image = response.result.value {
                cell.avatar.image = image
            }
        }
        if users[(indexPath as NSIndexPath).row].lastName != nil {
            cell.name.text = "\(users[(indexPath as NSIndexPath).row].firstName!) \(users[(indexPath as NSIndexPath).row].lastName!)"
        } else {
            cell.name.text = users[(indexPath as NSIndexPath).row].firstName!
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UserDetailSegue" {
            let destination = segue.destination as! UserDetail
            destination.user = users[((self.tableView.indexPathForSelectedRow as NSIndexPath?)?.row)!]
        }
    }
    
    @IBAction func cancelToUsers(_ sender: UIStoryboardSegue) {}
    
    @IBAction func submitToUsers(_ sender: UIStoryboardSegue) {}
    
    @IBAction func backToUsers(_ sender: UIStoryboardSegue) {}
    
    @IBAction func saveToUsers(_ sender: UIStoryboardSegue) {}
    
}
