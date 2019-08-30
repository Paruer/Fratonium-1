//
//  ViewController.swift
//  Fratonium
//
//  Created by Michael Parker on 8/30/19.
//  Copyright © 2019 Michael Parker. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    //MARK: UI Properties
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var thirdButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    
    //MARK: Programmatic properties
    var score: Int = 0
    
    //MARK: ViewController functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        categoryLabel.text = "Physical"
        firstButton.setTitle("No problems. Physically in shape", for: .normal)
    }
    
    //MARK: UI actions
    @IBAction func questionSelected(sender: UIButton) {
        if sender == firstButton {
            addToScore(1)
        } else if sender == secondButton {
            addToScore(3)
        } else if sender == thirdButton {
            addToScore(5)
        }
        
    }
    
    //MARK: Helper functions
    func addToScore(_ value: Int) {
        score += value
        scoreLabel.text = String(score)
    }


}

