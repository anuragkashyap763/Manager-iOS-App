//
//  LoginViewController.swift
//  Manager
//
//  Created by Anurag Kashyap on 12/12/2023.
//
import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    
    //let passwordTextField = UITextField()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //passwordTextfield.isSecureTextEntry.toggle()
        emailTextfield.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        passwordTextfield.attributedPlaceholder = NSAttributedString(
            string: "Password",
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

    
    @IBAction func eyeButtonPressed(_ sender: UIButton) {
        passwordTextfield.isSecureTextEntry.toggle()
            
            // Change the button image based on the password visibility
            if passwordTextfield.isSecureTextEntry {
                sender.setImage(UIImage(systemName: "eye"), for: .normal)
            } else {
                sender.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            }
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        if let email = emailTextfield.text, let password = passwordTextfield.text {
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                if let err = error {
                    // Show an alert with the error description
                    let alert = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self?.present(alert, animated: true, completion: nil)
                    
                    print(err)
                } else {
                    // Navigate to homePageViewController
                    self?.performSegue(withIdentifier: "LoginToChat", sender: self)
                }
            }
        }
    }
}
