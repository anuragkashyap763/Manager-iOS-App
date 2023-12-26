//
//  TaskDetailViewController.swift
//  Manager
//
//  Created by ANURAG KASHYAP on 24/12/23.
//

import UIKit
class TaskViewDetailController : UIViewController{
    
    @IBOutlet weak var taskNameDetail: UILabel!
    
    
    @IBOutlet weak var taskDescriptionDetail: UILabel!
    
    @IBOutlet weak var taskPriorityDetail: UILabel!
    
    
    @IBOutlet weak var taskDeadlineDetail: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskNameDetail.text = "Task 1"
        taskDescriptionDetail.text = "sdhfvsjahdvfjhsdvfjhsdvfhjsavdfjhsvdfjhfsdv"
        
    }
    
    @IBAction func backArrowPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
