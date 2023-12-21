//
//  ForgotPasswordViewController.swift
//  Manager
//
//  Created by ANURAG KASHYAP on 20/12/23.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import Network


class ForgotPassViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func sendPressed(_ sender: Any) {
        //print("self.emailField.text!")
        //print(self.emailField.text!)
        if let emailFromUser = emailField.text{
        let auth = Auth.auth()
        
            auth.sendPasswordReset(withEmail: emailFromUser) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                    //print(error)
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                        NSLog("The \"OK\" alert occured.")
                    }))
                    self.present(alert, animated: true, completion: nil)
                    
                }else{
                    //print(self.emailField.text!)
                    print(error ?? "No Error")
                    
                    let alert = UIAlertController(title: "Email Sent", message: "A password reset email has been sent!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                        NSLog("The \"OK\" alert occured.")
                    }))
                    self.present(alert, animated: true, completion: nil)
                    
                }
            }
        }
        emailField.text = ""
    }

}
