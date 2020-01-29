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
    // Views on the pageView
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var thirdButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    // Main views
    @IBOutlet weak var startView: UIStackView! // The starting view with assessment selection and start
    @IBOutlet weak var pageView: UIStackView! // The view containting the assessment questions
    @IBOutlet weak var resultView: UIView! // The final view showing the result
    // Other views
    @IBOutlet weak var startLabelView: UIView! // The labels in the starting view
    @IBOutlet weak var resultLabel: UILabel! // The label on the result page
    @IBOutlet weak var assessmentNameLabel: UILabel! // On the start view
    
    //MARK: Programmatic properties
    // assessment is optional because it relies on a JSON file that could fail to load. We check during viewDidAppear
    // to make sure it is initialized so other parts of the program can use forced unwrapping.
    var assessment: Assessment?
    
    required init?(coder aDecoder: NSCoder) {
        do {
            try assessment = Assessment()
        } catch {
            // If we are unable to create an assessment then we will leave here with it nil.  Since the UI is not initialized at this point
            // we can't display anything to the user so leave that for later
            assessment = nil
        }
        super.init(coder: aDecoder)
    }
    
    //--------------------------------------
    //MARK: ViewController functions
    //--------------------------------------
    /** Used viewDidAppear so that we can show an error message.  viewDidLoad is too early in the lifecycle to show the popup.
        Note that this is where self.assessment is checked for nil so that it does not need to be done elsewhere **/
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if assessment == nil {
            let alertController = UIAlertController(title: "Initialization error", message: "Unable to load assessment data", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        } else {
            assessmentNameLabel.text = assessment!.getAssessmentName()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startView.isHidden = false
        pageView.isHidden = true
        resultView.isHidden = true
        /* did not work
        startLabelView.backgroundColor = UIColor.lightGray
        startLabelView.alpha = 0.8
         */
    }
    
    //--------------------------------------
    //MARK: UI actions
    //--------------------------------------
    @IBAction func startAssessment(sender: UIButton) {
        pageView.isHidden = false
        startView.isHidden = true
        resultView.isHidden = true
        displayNextQuestion()
    }
    
    @IBAction func questionSelected(sender: UIButton) {
        if let q = assessment!.currentQuestion {
            if sender == firstButton {
                q.selectAnswer(0)
            } else if sender == secondButton {
                q.selectAnswer(1)
            } else if sender == thirdButton {
                q.selectAnswer(2)
            }
            displayNextQuestion()
        }
        //TODO: If the current question is nil we have a genuine error case since the display next question function is supposed
        // to transition to the final view.  Need to figure out proper error response here
    }
    
    @IBAction func resetAssessment(sender: UIButton) {
        assessment!.resetAssessment()
        displayNextQuestion()
    }
    
    @IBAction func backToStart(sender: UIButton) {
        assessment!.backToStart()
        displayNextQuestion()
    }
    
    /** Called when the Done button on the ResultView is pressed */
    @IBAction func assessmentComplete(sender: UIButton) {
        assessment!.resetAssessment()
        startView.isHidden = false
        pageView.isHidden = true
        resultView.isHidden = true
    }
    
    //--------------------------------------
    //MARK: Helper functions
    //--------------------------------------
    func displayNextQuestion() {
        if let q = assessment!.getNextQuestion() {
            categoryLabel.text = assessment!.currentCategory.name
            questionLabel.text = q.name
            let buttons = [firstButton, secondButton, thirdButton]
            for i in 0...2 {
                let button = buttons[i]!
                let answer = q.answers[i]
                button.setTitle(answer.text, for: .normal)
                if let val = answer.selected, val {
                    button.backgroundColor = UIColor.green
                } else {
                    button.backgroundColor = UIColor.blue
                }
            }
        } else {
            // There are no more questions so show the results view
            resultView.isHidden = false
            startView.isHidden = true
            pageView.isHidden = true
        }
        resetScoreLabels()
    }
    
    func resetScoreLabels() {
        let score = String(assessment!.computeScore())
        scoreLabel.text = score
        resultLabel.text = score
        
        let scoreInt: Int = Int(score)!
        let color: UIColor
        switch scoreInt {
        case 0..<assessment!.caution:
            color = UIColor.green
        case assessment!.caution..<assessment!.highRisk:
            color = UIColor.yellow
        default:
            color = UIColor.red
        }
        scoreLabel.backgroundColor = color
        resultLabel.backgroundColor = color
    }
}

