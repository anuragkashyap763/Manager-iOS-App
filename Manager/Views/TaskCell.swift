//
//  TaskCell.swift
//  Manager
//
//  Created by ANURAG KASHYAP on 21/12/23.
//

import UIKit

protocol TaskCellDelegate: AnyObject {
    func editButtonTapped(at indexPath: IndexPath)
    func deleteButtonTapped(at indexPath: IndexPath)
}

class TaskCell: UITableViewCell {

    @IBOutlet weak var TaskBubbleView: UIView!
    
    @IBOutlet weak var taskNameLabel: UILabel!
    
    @IBOutlet weak var editView: UIView!
    
    @IBOutlet weak var DeleteView: UIView!
    
    weak var delegate: TaskCellDelegate?
    var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        TaskBubbleView.layer.cornerRadius = TaskBubbleView.frame.size.height / 5
        editView.layer.cornerRadius = editView.frame.size.height / 5
        DeleteView.layer.cornerRadius = DeleteView.frame.size.height / 5
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        if let indexPath = indexPath {
            delegate?.editButtonTapped(at: indexPath)
        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        if let indexPath = indexPath {
            delegate?.deleteButtonTapped(at: indexPath)
        }
        
    }
    
    
}
