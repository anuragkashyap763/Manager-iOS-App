//
//  TaskDetailViewController.swift
//  Manager
//
//  Created by ANURAG KASHYAP on 24/12/23.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class TaskDetailViewController : UIViewController{
    
    let db = Firestore.firestore()
    var docRef: DocumentReference?
    
    var docArr : [String] = []
    var index : Int?
    
    @IBOutlet weak var taskNameDetail: UILabel!
    
    
    @IBOutlet weak var taskDescriptionDetail: UITextView!
    
    @IBOutlet weak var taskPriorityDetail: UILabel!
    
    
    @IBOutlet weak var taskDeadlineDetail: UILabel!
    
    var taskName : String?
    var taskDescription : String?
    var taskPriority : String?
    var taskDeadline : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchDocumentReference()
        //taskNameDetail.text = "Task 1"
        //taskDescriptionDetail.text = "sdhfvsjahdvfjhsdvfjhsdvfhjsavdfjhsvdfjhfsdv"
        
        taskNameDetail.text = taskName
        taskDescriptionDetail.text = taskDescription
        taskPriorityDetail.text = taskPriority
        taskDeadlineDetail.text = taskDeadline
        
        //print("47\(docArr)")
    }
    
    func fetchDocumentReference() {
            guard let userEmail = Auth.auth().currentUser?.email else { return }
        
        docRef = db.collection(userEmail).document(docArr[index ?? 0]) // Replace "Your_Document_ID" with the specific document ID
        //print("53\(docRef as Any)")
        }
    
    @IBAction func backArrowPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func MarkAsDone(_ sender: UIButton) {
        docRef?.updateData(["Task Status": "Complete"]) { [weak self] error in
            if let error = error {
                print("Error updating document: \(error.localizedDescription)")
            } else {
                print("Document successfully updated!")
                // Show an alert confirming the update
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Task Status Updated", message: "The task status has been updated to 'Complete'.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    
                    // Present the alert
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
