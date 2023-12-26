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
//import Network


class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        //making placeholder visible in forgot password screen
        emailField.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        
        /*this code is for making keyboard disappear when tapped on empty spaces on screen*/
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false
        
        /*this code is for making the view shift a bit when keyboard appears*/
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    /*this code is for making the view shift a bit when keyboard appears*/
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= (keyboardSize.height-182)
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
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
