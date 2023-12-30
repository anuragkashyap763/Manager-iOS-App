//
//  EditTaskViewController.swift
//  Manager
//
//  Created by ANURAG KASHYAP on 29/12/23.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class EditTaskViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var taskNameTextField: UITextField!
    
    @IBOutlet weak var taskDeadline: UIDatePicker!
    
    @IBOutlet weak var taskDescriptionTextView: UITextView!
    
    @IBOutlet weak var taskPriority: UISegmentedControl!
    var docArr : [String] = [] 
    var index : Int?
    
    var taskName : String?
    var taskDesc : String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskNameTextField.attributedPlaceholder = NSAttributedString(
            string: "Task Name Cannot be empty",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        
        taskDeadline.locale = .current
        taskDeadline.date = Date()
        taskDeadline.preferredDatePickerStyle = .compact
        taskDeadline.addTarget(self, action: #selector(dateSelected), for: .valueChanged)

        
        /*this code is for making keyboard disappear when tapped on empty spaces on screen*/
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false
        
        /*this code is for making the view shift a bit when keyboard appears*/
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        // Do any additional setup after loading the view.
        
        taskNameTextField.text = taskName
        taskDescriptionTextView.text = taskDesc
    }
    
    @objc func dateSelected(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let date = dateFormatter.string(from: taskDeadline.date)
        print(date)
    }
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBAction func saveChangesPressed(_ sender: UIButton) {
        
        if let userEmail = Auth.auth().currentUser?.email{
            if taskNameTextField.text != "" {
                let date = taskDeadline.date
                let priorityIndex = taskPriority.selectedSegmentIndex
                let priority = taskPriority.titleForSegment(at: priorityIndex)
                let taskDescription = taskDescriptionTextView.text
                db.collection(userEmail).document(docArr[index ?? 0]).updateData(["Task Name":taskNameTextField.text as Any, "Task Description":taskDescription as Any,"Priority":priority as Any,"DeadLine":date,"isDeleted":false,"Task Status":"In Progress"]){error in
                    if let e = error{
                        print("Issue saving data: \(e.localizedDescription)")
                    }else{
                        print("Data Saved")
                    }
                }
                self.dismiss(animated: true, completion: nil)
            }
            else {
                let alertController = UIAlertController(title: "Error", message: "Task Name Cannot Be Empty", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                    self.taskNameTextField.placeholder = "Task Name Cannot Be Empty"
                }
                alertController.addAction(okAction)
                
                present(alertController, animated: true, completion: nil)
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
}
