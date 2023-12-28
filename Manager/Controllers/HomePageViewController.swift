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


class HomePageViewController: UIViewController , UISearchBarDelegate{
    
    @IBOutlet weak var taskTableView: UITableView!
    
    @IBOutlet weak var searchBarField: UISearchBar!
    
    
    let db = Firestore.firestore()
    
    var tasks : [Tasks] = []
    var filteredData : [Tasks] = []
    var isSearching = false
    
    let UserEmail  = Auth.auth().currentUser?.email
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskTableView.delegate = self
        taskTableView.dataSource = self
        searchBarField.delegate = self
        navigationItem.hidesBackButton = true
        title = "Manager"
        //title.foregroundColor(nil)
        
        taskTableView.register(UINib(nibName: "TaskCell", bundle: nil), forCellReuseIdentifier: "ReuseableCell")
        loadTasksFromFirestore()
        filteredData = tasks
        
        
        
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
    
    //This code is for deleting the task cell
    func deleteSubcollection(collectionPath: String, completion: @escaping (Error?) -> Void) {
        //let db = Firestore.firestore()
        let collectionRef = db.collection(collectionPath)
        
        collectionRef.getDocuments { snapshot, error in
            if let error = error {
                completion(error)
            } else {
                guard let snapshot = snapshot else {
                    completion(nil)
                    return
                }
                
                let batch = self.db.batch()
                
                for document in snapshot.documents {
                    let docRef = collectionRef.document(document.documentID)
                    batch.deleteDocument(docRef)
                }
                
                // Commit the batch delete
                batch.commit { batchError in
                    completion(batchError)
                }
            }
        }
    }
    
    
    //This code helps in fetching data from firestore
    func loadTasksFromFirestore(){
        if let userEmail = Auth.auth().currentUser?.email{
            db.collection(userEmail).order(by: "Priority").order(by: "DeadLine").addSnapshotListener { querySnapshot, error in
                self.tasks  = []
                if let e = error{
                    print("Issue fetching data from Firestore : \(e.localizedDescription)")
                }else{
                    if let snapshotDocuments = querySnapshot?.documents{
                        for doc in snapshotDocuments{
                            //print(doc.data())
                            let data = doc.data()
                            if let TaskName = data["Task Name"] as? String, let TaskDescription = data["Task Description"] as? String, let TaskPriority = data["Priority"] as? String, let Delete = data["isDeleted"] , let status = data["Task Status"] as? String{
                                let TaskDeadline = "Today"
                                //let TaskDeadline: Date = data["DeadLine"] as? Date ?? nil
                                let TASKS = Tasks(taskName: TaskName, taskDescription: TaskDescription, taskDeadline: TaskDeadline , taskPriority: TaskPriority, isDeleted: Delete as! Bool, taskStatus: status)
                                if TASKS.isDeleted == false{
                                    self.tasks.append(TASKS)
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
        
        let task: Tasks
        if isSearching {
            task = filteredData[indexPath.row]
        } else {
            task = tasks[indexPath.row]
        }
        
        cell.taskNameLabel.text = task.taskName
        /*if task.taskStatus == "Complete"{
            cell.backgroundColor = UIColor(named: "C1F2B0")
        }*/
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}



// this code takes to another screen when a cell is selected by tapping to display its details , also it has functions to print the path of the data being stored in firebase
extension HomePageViewController : UITableViewDelegate{
    
    
    func tableView(_ tableView : UITableView , didSelectRowAt indexPath : IndexPath){
        print(indexPath.row)
        
        
        let selectedItem = tasks[indexPath.row]
        var fullPath : String = ""
        var pathSubstring : String = ""
        print(selectedItem)
        
        db.collection(UserEmail ?? "").addSnapshotListener { querySnapshot, error in
            
            //if let documentRef = querySnapshot.reference {
            if let selectedSnapshot = querySnapshot?.documents[indexPath.row]{
                
                let documentRef = selectedSnapshot.reference
                fullPath = documentRef.path
                print("Full Path: \(fullPath)")
                
                let originalString = fullPath
                let UserEmailLength = self.UserEmail?.count
                
                // Getting a substring after userEmail to the end of the string as it is the name of the document
                pathSubstring = String(originalString[originalString.index(originalString.startIndex, offsetBy: (UserEmailLength ?? 0) + 1)...])
                print(pathSubstring)
                // Perform any further actions using the fullPath
            } else {
                print("Document reference not found")
            }
        }
        
        
        
        
        
        /*self.deleteSubcollection(collectionPath: "\(fullPath)/Priority" ) { error in
            if let error = error {
                print("Error deleting subcollection: \(error)")
            } else {
                print("Subcollection deleted successfully!")
                // Handle success
            }
        }*/
        
        //self.tasks.remove(at: indexPath.row)
        //tableView.deleteRows(at: [indexPath], with: .automatic)
        self.performSegue(withIdentifier: "TaskDetailSegue", sender: self)
    }
    //self.performSegue(withIdentifier: "TaskDetailSegue", sender: self)
}





