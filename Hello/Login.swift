//
//  Login.swift
//  Hello
//
//  Created by Akash Ungarala on 9/1/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit
import Firebase

class Login: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    var activityIndicatorView: ActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        email.delegate = self
        password.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (FIRAuth.auth()?.currentUser != nil) {
            performSegue(withIdentifier: "HomeSegue", sender: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func login(_ sender: UIButton) {
        if email.text == "" {
            alert("Please enter the Email")
        } else if password.text == "" {
            alert("Please enter the Password");
        } else {
            self.activityIndicatorView = ActivityIndicatorView(title: "Signing In...", center: self.view.center)
            self.view.addSubview(self.activityIndicatorView.getViewActivityIndicator())
            self.activityIndicatorView.startAnimating()
            FIRAuth.auth()!.signIn(withEmail: self.email.text!, password: self.password.text!, completion: { (user, error) in
                if error != nil {
                    self.activityIndicatorView.stopAnimating()
                    self.alert("Firebase Login Error")
                } else {
                    self.performSegue(withIdentifier: "HomeSegue", sender: sender)
                    self.activityIndicatorView.stopAnimating()
                }
            })
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "HomeSegue" {
            return false
        }
        return true
    }
    
    @IBAction func cancelUnwindToLogin(_ sender: UIStoryboardSegue) {}
    
    @IBAction func submitUnwindToLogin(_ sender: UIStoryboardSegue) {
        performSegue(withIdentifier: "HomeSegue", sender: nil)
    }
    
    @IBAction func logoutUnwindToLogin(_ sender: UIStoryboardSegue) {
        try! FIRAuth.auth()!.signOut()
    }
    
    func alert(_ alertMessage: String) {
        let alert = UIAlertController(title: "Alert", message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }

}
