//
//  HomePageViewController.swift
//  Manager
//
//  Created by Anurag Kashyap on 12/12/2023.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth


class HomePageViewController: UIViewController , UISearchBarDelegate , TaskCellDelegate {
    
    
    @IBOutlet weak var taskTableView: UITableView!
    
    @IBOutlet weak var searchBarField: UISearchBar!
    
    
    let db = Firestore.firestore()
    
    var tasks : [Tasks] = [] // Used for fetching data from firestore
    var filteredData : [Tasks] = [] //used for searching data in UISearchBar
    var isSearching = false
    var docArray : [String] = [] //used for deleting data
    var selectedTask = Tasks(taskName: "", taskDescription: "", taskDeadline: "", taskPriority: "", isDeleted: false, taskStatus: "")
    //for transferring data to taskDetailViewController
    
    let UserEmail  = Auth.auth().currentUser?.email
    
    var selectedIndexPath: IndexPath? //for sending row value to TaskDetailViewController for MarkAsDone function
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        taskTableView.delegate = self
        taskTableView.dataSource = self
        searchBarField.delegate = self
        
        
        navigationItem.hidesBackButton = true
        // Customize navigation bar title
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(named: "BrandBlue") ?? .blue, // Change the color here
            .font: UIFont.boldSystemFont(ofSize: 20) // Change the font size and style here
        ]
        navigationController?.navigationBar.titleTextAttributes = attributes
        
        title = "Manager"
        
        taskTableView.register(UINib(nibName: "TaskCell", bundle: nil), forCellReuseIdentifier: "ReuseableCell")
        loadTasksFromFirestore()
        filteredData = tasks
        
    }
    
    // this code if for making edit and delete buttons functional
    func editButtonTapped(at indexPath: IndexPath) {
        print("I will edit this cell")
        //print(selectedTask)
        self.db.collection(self.UserEmail ?? "").document(self.docArray[indexPath.row]).getDocument { (document, error) in
            if let error = error {
                print("Error getting document: \(error.localizedDescription)")
            } else {
                if let document = document, document.exists {
                    // Access the document data
                    let data = document.data()
                    
                    // Perform operations with the retrieved data
                    // Example: Access specific fields if they exist
                    if let taskName = data?["Task Name"] as? String,
                        let taskDescription = data?["Task Description"] as? String,
                        let taskPriority = data?["Priority"] as? String,
                        let isDeleted = data?["isDeleted"] as? Bool,
                        let taskStatus = data?["Task Status"] as? String {
                        
                        let taskDeadline = "Today"
                        // Store data to pass to the next view controller
                        let selectedTask = Tasks(taskName: taskName, taskDescription: taskDescription, taskDeadline: taskDeadline, taskPriority: taskPriority, isDeleted: isDeleted, taskStatus: taskStatus)
                        
                        // Perform segue after data extraction
                        self.selectedIndexPath = indexPath
                        DispatchQueue.main.async {
                            self.selectedTask = selectedTask
                            //print("256\(selectedTask)")
                            self.performSegue(withIdentifier: "editTaskSegue", sender: self)
                        }
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
        
        //self.performSegue(withIdentifier: "editTaskSegue", sender: self)
    }
    

    func deleteButtonTapped(at indexPath: IndexPath) {
        print("I will delete this cell")
        print(indexPath.row)
        print(docArray)
        
        //let docRef = db.collection(UserEmail ?? "").document().documentID
        //print(docRef)
        
        let alertController = UIAlertController(title: "Delete Document",
                                                message: "Are you sure you want to delete this document?",
                                                preferredStyle: .alert)
        
        // Action to delete the document
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.db.collection(self.UserEmail ?? "").document(self.docArray[indexPath.row]).delete { error in
                if let e = error {
                    print("Error deleting document: \(e)")
                } else {
                    print("Document successfully deleted!")
                    //self.docArray = []
                    //print(self.docArray)
                    self.tasks = []
                }
            }
        }
        
        // Action to cancel the deletion
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        // Present the alert
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    //code for searching in table views
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredData = tasks
        } else {
            isSearching = true
            filteredData = tasks.filter { $0.taskName.lowercased().contains(searchText.lowercased()) }
        }
        taskTableView.reloadData()
    }
    
    
    //This code helps in fetching data from firestore
    func loadTasksFromFirestore(){
        
        if let userEmail = Auth.auth().currentUser?.email{
            db.collection(userEmail).order(by: "Priority").order(by: "DeadLine").addSnapshotListener { querySnapshot, error in
                self.tasks  = []
                
                self.docArray = []
                if let e = error{
                    print("Issue fetching data from Firestore : \(e.localizedDescription)")
                }else{
                    print("abc119\(self.tasks)")
                    if let snapshotDocuments = querySnapshot?.documents{
                        
                        
                        //print(snapshotDocuments)
                        for doc in snapshotDocuments{
                            
                            //print(doc.data())
                            self.docArray.append(doc.documentID)
                            //print(doc.documentID)
                            //print(doc.metadata)
                            
                            let data = doc.data()
                            if let TaskName = data["Task Name"] as? String, let TaskDescription = data["Task Description"] as? String, let TaskPriority = data["Priority"] as? String, let Delete = data["isDeleted"] , let status = data["Task Status"] as? String{
                                let TaskDeadline = "Today"
                                //let TaskDeadline: Date = data["DeadLine"] as? Date ?? nil
                                let TASKS = Tasks(taskName: TaskName, taskDescription: TaskDescription, taskDeadline: TaskDeadline , taskPriority: TaskPriority, isDeleted: Delete as! Bool, taskStatus: status)
                                
                                self.tasks.append(TASKS)
                                
                            }
                        }
                        //reloading table views
                        DispatchQueue.main.async{
                            self.taskTableView.reloadData()
                            
                        }
                        
                    }
                }
            }
        }
    }
    
    
    @IBAction func plusPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "HomeScreenToAddTask", sender: self)
    }
    
    @IBAction func LogOutPressed(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
}

//this code adds data in cells of table view
extension HomePageViewController : UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredData.count
        } else {
            return tasks.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = taskTableView.dequeueReusableCell(withIdentifier: "ReuseableCell", for: indexPath) as! TaskCell
        cell.delegate = self
        cell.indexPath = indexPath
        
        let task: Tasks
        if isSearching {
            task = filteredData[indexPath.row]
        } else {
            task = tasks[indexPath.row]
        }
        
        cell.taskNameLabel.text = task.taskName
        
        // Set the default background color for the cell
        cell.TaskBubbleView.backgroundColor = UIColor(named: "BackgroundYellow")
        cell.editView.backgroundColor = UIColor(named: "BackgroundYellow")
        cell.DeleteView.backgroundColor = UIColor(named: "BackgroundYellow")
        
        // Set the background color to green if the task status is "Complete"
        if task.taskStatus == "Complete" {
            cell.TaskBubbleView.backgroundColor = UIColor(named: "BackgroundGreen")
            cell.editView.backgroundColor = UIColor(named: "BackgroundGreen")
            cell.DeleteView.backgroundColor = UIColor(named: "BackgroundGreen")
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}



// this code takes to another screen when a cell is selected by tapping to display its details , also it has functions to print the path of the data being stored in firebase
extension HomePageViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Fetch data from Firestore for the selected cell
        self.db.collection(self.UserEmail ?? "").document(self.docArray[indexPath.row]).getDocument { (document, error) in
            if let error = error {
                print("Error getting document: \(error.localizedDescription)")
            } else {
                if let document = document, document.exists {
                    // Access the document data
                    let data = document.data()
                    
                    // Perform operations with the retrieved data
                    // Example: Access specific fields if they exist
                    if let taskName = data?["Task Name"] as? String,
                        let taskDescription = data?["Task Description"] as? String,
                        let taskPriority = data?["Priority"] as? String,
                        let isDeleted = data?["isDeleted"] as? Bool,
                        let taskStatus = data?["Task Status"] as? String {
                        
                        let taskDeadline = "Today"
                        // Store data to pass to the next view controller
                        let selectedTask = Tasks(taskName: taskName, taskDescription: taskDescription, taskDeadline: taskDeadline, taskPriority: taskPriority, isDeleted: isDeleted, taskStatus: taskStatus)
                        
                        // Perform segue after data extraction
                        self.selectedIndexPath = indexPath
                        DispatchQueue.main.async {
                            self.selectedTask = selectedTask
                            //print("256\(selectedTask)")
                            self.performSegue(withIdentifier: "TaskDetailSegue", sender: self)
                        }
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TaskDetailSegue" {
            if let destinationVC = segue.destination as? TaskDetailViewController {
                // Pass the data to the destination view controller
                //print("271\(selectedTask)")
                destinationVC.taskName = selectedTask.taskName
                destinationVC.taskDescription = selectedTask.taskDescription
                destinationVC.taskPriority = selectedTask.taskPriority
                destinationVC.taskDeadline = selectedTask.taskDeadline
                destinationVC.docArr = docArray
                
                if let selectedIndexPath = selectedIndexPath {
                    destinationVC.index = selectedIndexPath.row
                }
                
            }
        }
        if segue.identifier == "editTaskSegue" {
            if let destinationVC = segue.destination as? EditTaskViewController {
                // Pass the data to the destination view controller
                //print("271\(selectedTask)")
                destinationVC.taskName = selectedTask.taskName
                destinationVC.taskDesc = selectedTask.taskDescription
                //destinationVC.taskPriority.text = selectedTask.taskPriority
                //destinationVC.taskDeadline = Date()
                destinationVC.docArr = docArray
                
                if let selectedIndexPath = selectedIndexPath {
                    destinationVC.index = selectedIndexPath.row
                }
                
            }
        }
    }
}







