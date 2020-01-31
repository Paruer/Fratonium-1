//
//  ViewController.swift
//  Fratonium
//
//  Created by Michael Parker on 8/30/19.
//  Copyright © 2019 Michael Parker. All rights reserved.
//

import UIKit
import os

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
    
    //--------------------------------------
    //MARK: Programmatic properties
    //--------------------------------------
    /** assessment is an implicitly unwrapped optional because it relies on a JSON file that could fail to load but we check during viewDidAppear to make sure it is initialized and if not we block further use of the app */
    var assessment: Assessment!
    var currentQuestion: Question?
    
    /** assessment must be initialized here otherwise we get a complier error. Since we have no way to alert the user at this point we have to be
        able to leave init with nil assessment*/
    required init?(coder aDecoder: NSCoder) {
        do {
            try assessment = Assessment()
        } catch {
            os_log("Exception thrown by Assessment during initialization. Error: %{public}s", log: Log.controller, type: .error, error.localizedDescription)
            assessment = nil
        }
        super.init(coder: aDecoder)
    }
    
    //--------------------------------------
    //MARK: ViewController functions
    //--------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startView.isHidden = false
        pageView.isHidden = true
        resultView.isHidden = true
    }

    /** Used viewDidAppear so that we can show an error message.  viewDidLoad is too early in the lifecycle to show the popup.
        Note that this is where self.assessment is checked for nil so that it does not need to be done elsewhere **/
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if assessment == nil {
            showUnableToLoadMessage()
        } else {
            // Set the name of the assessment on the start view
            let text = NSMutableAttributedString(string: "Currently installed assessment:\n\n")
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.init(named: "kombuGreen") as Any]
            let name = NSAttributedString(string: assessment.getAssessmentName(), attributes: attributes)
            text.append(name)
            assessmentNameLabel.attributedText = text
        }
    }

    //--------------------------------------
    //MARK: UI actions
    //--------------------------------------
    @IBAction func startAssessment(sender: UIButton) {
        if assessment == nil {
            showUnableToLoadMessage()
        } else {
            pageView.isHidden = false
            startView.isHidden = true
            resultView.isHidden = true
            displayNextQuestion()
        }
    }
    
    @IBAction func questionSelected(sender: UIButton) {
        /** Force unwrap currentQuestion because it really cannot be nil here: the answer buttons cannot be created if it is*/
        if sender == firstButton {
            currentQuestion!.selectAnswer(0)
        } else if sender == secondButton {
            currentQuestion!.selectAnswer(1)
        } else if sender == thirdButton {
            currentQuestion!.selectAnswer(2)
        }
        displayNextQuestion()
    }
    
    @IBAction func resetAssessment(sender: UIButton) {
        assessment.resetAssessment()
        displayNextQuestion()
    }
    
    @IBAction func backToStart(sender: UIButton) {
        assessment.backToStart()
        displayNextQuestion()
    }
    
    /** Called when the Done button on the ResultView is pressed */
    @IBAction func assessmentComplete(sender: UIButton) {
        assessment.resetAssessment()
        startView.isHidden = false
        pageView.isHidden = true
        resultView.isHidden = true
    }
    
    //--------------------------------------
    //MARK: Helper functions
    //--------------------------------------
    func showUnableToLoadMessage () {
        let alertController = UIAlertController(title: "Initialization error", message: "Unable to load assessment data", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func displayNextQuestion() {
        if let q = assessment.getNextQuestion() {
            currentQuestion = q
            categoryLabel.text = assessment.currentCategory.name
            questionLabel.text = q.name
            let buttons = [firstButton, secondButton, thirdButton]
            for i in 0...2 {
                let button = buttons[i]!
                let answer = q.answers[i]
                button.setTitle(answer.text, for: .normal)
                if let val = answer.selected, val {
                    button.backgroundColor = UIColor.init(named: "mediumGreen")
                } else {
                    button.backgroundColor = UIColor.init(named: "mauve")
                }
            }
        } else {
            // There are no more questions so show the results view
            currentQuestion = nil
            resultView.isHidden = false
            startView.isHidden = true
            pageView.isHidden = true
        }
        resetScoreLabels()
    }
    
    func resetScoreLabels() {
        let scoreInt = assessment.computeScore()
        let scoreStr = String(scoreInt)
        
        scoreLabel.text = scoreStr
        resultLabel.text = scoreStr
        
        let color: UIColor
        switch scoreInt {
        case 0..<assessment.caution:
            color = UIColor.green
        case assessment.caution..<assessment.highRisk:
            color = UIColor.yellow
        default:
            color = UIColor.red
        }
        scoreLabel.backgroundColor = color
        resultLabel.backgroundColor = color
    }
}

