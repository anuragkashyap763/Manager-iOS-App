//
//  RegisterViewController.swift
//  Manager
//
//  Created by Anurag Kashyap on 12/12/2023.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseFirestoreInternal

class RegisterViewController: UIViewController {
    
    let db = Firestore.firestore()
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        nameTextField.attributedPlaceholder = NSAttributedString(
            string: "Name",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        
        
        emailTextField.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        
        //passwordTextField.autocorrectionType = .no
        confirmPasswordTextField.attributedPlaceholder = NSAttributedString(
            string: "Confirm Password",
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
    
    //this code is for making password text fields visible
    @IBAction func eyeButtonPressed(_ sender: UIButton) {
        
        if sender.tag == 1 {
            passwordTextField.isSecureTextEntry.toggle()
            if passwordTextField.isSecureTextEntry {
                sender.setImage(UIImage(systemName: "eye"), for: .normal)
            } else {
                sender.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            }
        } else if sender.tag == 2 {
            confirmPasswordTextField.isSecureTextEntry.toggle()
            if confirmPasswordTextField.isSecureTextEntry {
                sender.setImage(UIImage(systemName: "eye"), for: .normal)
            } else {
                sender.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            }
        }
        
    }
    
    
    /*this code is for making the view shift a bit when keyboard appears*/
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= (keyboardSize.height-160)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    //This code is to validate an email address
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    
    
    @IBAction func registerPressed(_ sender: UIButton) {
        if let name = nameTextField.text,
           let email = emailTextField.text,
           let password = passwordTextField.text {
            
            if isValidEmail(email) {
                if passwordTextField.text == confirmPasswordTextField.text {
                    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                        if let err = error {
                            // Show an alert with the error description
                            let alertController = UIAlertController(title: "Error",
                                                                    message: err.localizedDescription,
                                                                    preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(okAction)
                            
                            // Present the alert
                            self.present(alertController, animated: true, completion: nil)
                        } else {
                            // Firebase user creation successful
                            // Store name in Firestore
                            
                            if let user = Auth.auth().currentUser {
                                //let db = Firestore.firestore()
                                
                                // Collection reference with user's email as the collection ID
                                let userCollection = self.db.collection(user.email ?? "")
                                
                                // Document reference inside the collection
                                let nameDocument = userCollection.document("Name")
                                
                                // Data to be stored (NameOfUser : nameTextField.text)
                                let data: [String: Any] = ["NameOfUser": name]
                                
                                // Set the data inside the document
                                nameDocument.setData(data) { error in
                                    if let error = error {
                                        print("Error writing document: \(error.localizedDescription)")
                                    } else {
                                        print("Document successfully written!")
                                    }
                                }
                            }
                            
                            // Navigate to homePageViewController or perform any other actions
                            self.performSegue(withIdentifier: "RegisterToChat", sender: self)
                        }
                    }
                } else {
                    let alertController = UIAlertController(title: "Passwords Do Not Match",
                                                            message: "Please make sure the passwords match.",
                                                            preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    
                    // Present the alert
                    present(alertController, animated: true, completion: nil)
                }
            } else {
                let alertController = UIAlertController(title: "Invalid Email",
                                                        message: "Please enter a valid email address.",
                                                        preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                
                // Present the alert
                present(alertController, animated: true, completion: nil)
            }
        }
    }
    
}
