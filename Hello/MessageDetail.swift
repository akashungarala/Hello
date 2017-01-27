//
//  MessageDetail.swift
//  Hello
//
//  Created by Akash Ungarala on 9/9/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit
import SDWebImage

class MessageDetail: UIViewController {
    
    var message: Message!
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var messageText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let imageURL:URL? = URL(string: message.user.avatar) {
            if let url = imageURL {
                avatar.sd_setImage(with: url)
            }
        }
        name.text = "\(message.user.firstName) \(message.user.lastName)"
        messageText.text = message.message
    }

}
