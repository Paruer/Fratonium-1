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
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var thirdButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    
    //MARK: Programmatic properties
    var score: Int = 0
    var assessment: Assessment
    
    required init?(coder aDecoder: NSCoder) {
        let answer1 = Answer(text: "one", value: 1)
        let answer2 = Answer(text: "two", value: 3)
        let answer3 = Answer(text: "three", value: 5)
        
        let question1 = Question(name: "Question one", answers: [answer1, answer2, answer3])
        let question2 = Question(name: "Question two", answers: [answer1, answer2, answer3])
        
        let category1 = Category(name: "Category one", questions: [question1, question2])
        let category2 = Category(name: "Category two", questions: [question1, question2])
        
        self.assessment = Assessment(categories: [category1, category2])
        
        super.init(coder: aDecoder)
    }
    
    //MARK: ViewController functions
    override func viewDidLoad() {
        super.viewDidLoad()
        displayNextQuestion()
    }
    
    //MARK: UI actions
    @IBAction func questionSelected(sender: UIButton) {
        if let q = assessment.currentQuestion {
            if sender == firstButton {
                addToScore(q.answers[0].value)
            } else if sender == secondButton {
                addToScore(q.answers[1].value)
            } else if sender == thirdButton {
                addToScore(q.answers[2].value)
            }
            displayNextQuestion()
        }
        //TODO: If the current question is nil we won't do anything for now.  In the future we will transition to the finished view
    }
    
    //MARK: Helper functions
    func addToScore (_ value: Int) {
        score += value
        scoreLabel.text = String(score)
    }

    //TODO: Figure out if and how to properly handle nil questions
    func displayNextQuestion() {
        if let q = assessment.getNextQuestion() {
            categoryLabel.text = assessment.currentCategory.name
            questionLabel.text = q.name
            firstButton.setTitle(q.answers[0].text, for: .normal)
            secondButton.setTitle(q.answers[1].text, for: .normal)
            thirdButton.setTitle(q.answers[2].text, for: .normal)
        } else {
            let alertController = UIAlertController(title: "Out of questions", message: "No more questions", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }

}

