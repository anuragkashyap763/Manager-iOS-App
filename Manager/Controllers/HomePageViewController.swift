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


class HomePageViewController: UIViewController {
    
    @IBOutlet weak var taskTableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    let db = Firestore.firestore()
    /*var tasks : [Tasks] = [Tasks(taskName: "Task 1", taskDescription: "This is my first Task", taskDeadline: "25-Dec-2023 at 10:07 PM", taskPriority: "High"),
                           Tasks(taskName: "Task 2", taskDescription: "This is my second Task", taskDeadline: "25-Dec-2023 at 10:07 PM", taskPriority: "Low")]*/
    var tasks : [Tasks] = []
//    if let userEmail = Auth.auth().currentUser?.email{
//        print(userEmail)
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        taskTableView.delegate = self
        taskTableView.dataSource = self
        navigationItem.hidesBackButton = true
        title = "Manager"
        //title.foregroundColor(nil)
        
        taskTableView.register(UINib(nibName: "TaskCell", bundle: nil), forCellReuseIdentifier: "ReuseableCell")
        loadTasksFromFirestore()

    }
    
    //This code helps in fetching data from firestore
    func loadTasksFromFirestore(){
        if let userEmail = Auth.auth().currentUser?.email{
            db.collection(userEmail).order(by: "Priority", descending: false).addSnapshotListener { querySnapshot, error in
                self.tasks  = []
                if let e = error{
                    print("Issue fetching data from Firestore : \(e)")
                }else{
                    if let snapshotDocuments = querySnapshot?.documents{
                        for doc in snapshotDocuments{
                            //print(doc.data())
                            let data = doc.data()
                            if let TaskName = data["Task Name"] as? String, let TaskDescription = data["Task Description"] as? String, let TaskPriority = data["Priority"] as? String{
                                let TaskDeadline = "Today"
                                let TASKS = Tasks(taskName: TaskName, taskDescription: TaskDescription, taskDeadline: TaskDeadline , taskPriority: TaskPriority)
                                self.tasks.append(TASKS)
                                
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
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = taskTableView.dequeueReusableCell(withIdentifier: "ReuseableCell", for: indexPath) as! TaskCell
        cell.taskNameLabel.text = tasks[indexPath.row].taskName
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

// this code takes to another screen when a cell is selected by tapping
extension HomePageViewController : UITableViewDelegate{
    func tableView(_ tableView : UITableView , didSelectRowAt indexPath : IndexPath){
        print(indexPath.row)
        self.performSegue(withIdentifier: "TaskDetailSegue", sender: self)
    }
}

extension HomePageViewController : UISearchBarDelegate{
    
}
    
    
    

