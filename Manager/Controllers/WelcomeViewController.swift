//
//  WelcomeViewController.swift
//  Manager
//
//  Created by Anurag Kashyap on 12/12/2023.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var characterIndex = 0.0
        titleLabel.text = ""
        
        let titleText = "Manager"
        for letter in titleText{
            Timer.scheduledTimer(withTimeInterval: 0.1 * characterIndex, repeats: false) { (timer) in
                self.titleLabel.text?.append(letter)
            }
            characterIndex += 1.0
        }
       
    }
    

}
