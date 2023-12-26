//
//  AddNewTaskViewController.swift
//  Manager
//
//  Created by ANURAG KASHYAP on 22/12/23.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth


class AddNewTaskViewController : UIViewController{
    
    let db = Firestore.firestore()
    //var counter = 0
    //let homePage = HomePageViewController()
    @IBOutlet weak var taskNameTextField: UITextField!
    
    @IBOutlet weak var descriptionText: UITextView!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var taskPriority: UISegmentedControl!
    
    /*let tasks : [Tasks] = [Tasks(taskName: "Task 1", taskDescription: "This is my first Task", taskDeadline: "25-Dec-2023 at 10:07 PM", taskPriority: "High"),
                           Tasks(taskName: "Task 2", taskDescription: "This is my second Task", taskDeadline: "25-Dec-2023 at 10:07 PM", taskPriority: "Low")]*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskNameTextField.text = nil
        //This code is for placeholder text
        taskNameTextField.attributedPlaceholder = NSAttributedString(
            string: "Enter Task Name",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        
        //this code is for setting the datePicker
        datePicker.locale = .current
        datePicker.date = Date()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(dateSelected), for: .valueChanged)
        
        /*this code is for making keyboard disappear when tapped on empty spaces on screen*/
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false
        
        /*this code is for making the view shift a bit when keyboard appears*/
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //This code make multiline in text field entry
        //descriptionTextField.
        
    }
    
    @objc func dateSelected(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let date = dateFormatter.string(from: datePicker.date)
        print(date)
    }
    /*this code is for making the view shift a bit when keyboard appears*/
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= (keyboardSize.height-235)
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @IBAction func createButtonPressed(_ sender: UIButton) {
        //counter+=1
       
        if let userEmail = Auth.auth().currentUser?.email{
            if taskNameTextField.text != nil{
                let date = datePicker.date
                let priorityIndex = taskPriority.selectedSegmentIndex
                let priority = taskPriority.titleForSegment(at: priorityIndex)
                let taskDescription = descriptionText.text
                db.collection(userEmail).addDocument(data: ["Task Name":taskNameTextField.text as Any, "Task Description":taskDescription as Any,"Priority":priority as Any,"DeadLine":date]){error in
                    if let e = error{
                        print("Issue saving data")
                    }else{
                        print("Data Saved")
                    }
                }
            }
            else {
                taskNameTextField.placeholder = "Task Name Cannot Be Empty"
            }
        }
        //homePage.viewDidLoad()
        self.dismiss(animated: true, completion: nil)
    }
    
}
