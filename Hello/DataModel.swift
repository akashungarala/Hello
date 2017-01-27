//
//  DataModel.swift
//  Hello
//
//  Created by Akash Ungarala on 9/2/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import Foundation
import UIKit

struct User {
    
    var id: String!
    var avatar: String!
    var email: String!
    var mobile: String!
    var firstName: String!
    var lastName: String!
    var createdAt: TimeInterval!
    
}

struct Message {
    
    var id: String!
    var user: User!
    var message: String!
    var read: String!
    var createdAt: TimeInterval!
    
}
