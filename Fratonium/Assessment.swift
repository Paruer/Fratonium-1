//
//  Assessment.swift
//  Fratonium
//
//  Created by Michael Parker on 8/30/19.
//  Copyright © 2019 Michael Parker. All rights reserved.
//

import Foundation

class Assessment {
    private let categories: [Category]
    private var categoryIterator: IndexingIterator<[Category]>
    private var questionIterator: IndexingIterator<[Question]>
    private var answers: [Answer] = []
    
    var currentCategory: Category
    var currentQuestion: Question? //nil is a signal to users that we have iterated through all the categories and questions

    /**
     The initializer throws an error if it cannot load and parse the JSON containing the assessment data
    */
    init () throws {
        do {
            let url = Bundle.main.url(forResource: "AssessmentData", withExtension: "json")
            let json = try Data(contentsOf: url!)
            let decoder = JSONDecoder()
            categories = try decoder.decode([Category].self, from: json)

            categoryIterator = categories.makeIterator()
            currentCategory = categoryIterator.next()!
            questionIterator = currentCategory.questions.makeIterator()
            for category in categories {
                for question in category.questions {
                    for answer in question.answers {
                        answers.append(answer)
                    }
                }
            }
        } catch {
            print("Error initializing Assessment = \(error)")
            throw error
        }
    }
    
    func getNextQuestion() -> Question? {
        if let question = questionIterator.next() {
            currentQuestion = question
            return question
        } else {
            //Out of questions for this category so get a new category and question iterator
            if let category = categoryIterator.next() {
                currentCategory = category
                questionIterator = currentCategory.questions.makeIterator()
                if let question = questionIterator.next() {
                    currentQuestion = question
                    return question
                } else {
                    //An empty question set for a new category.  Something is wrong
                    //TODO: error handler
                    currentQuestion = nil
                    return nil
                }
            } else {
                //We're out of categories so return a nil to signal to the app
                currentQuestion = nil
                return nil
            }
        }
    }
    
    // Restarts the iterators and current items but leaves the answers selected
    func backToStart() {
        categoryIterator = categories.makeIterator()
        currentCategory = categoryIterator.next()!
        questionIterator = currentCategory.questions.makeIterator()
    }
    
    // Restarts the iterators and current items and sets all answers as not selected
    func resetAssessment() {
        backToStart()
        for answer in answers {
            answer.selected = false
        }
    }
    
    // Iterates through the answers adding the value of all the selected ones
    func computeScore() -> Int {
        var score: Int = 0
        for answer in answers {
            if let val = answer.selected, val {
                score += answer.value
            }
        }
        return score
    }
    
    //=====================================
    // MARK: Private methods
    //=====================================
    private func printJSONData() {
        for category in categories {
            print("Category name = \(category.name)")
            for question in category.questions {
                print("\tQuestion name = \(question.name)")
                    for answer in question.answers {
                        print("\t\tAnswer text = \(answer.text), value = \(answer.value)")
                    }
            }
        }
    }
    
}

//=====================================
// MARK: Model classes
//=====================================

class Answer: Codable {
    var text: String
    var value: Int
    var selected: Bool?
}

class Question: Codable {
    var name: String
    var answers: [Answer]
    
    // Mark the question (between 0 and 2) as selected and the others as not selected
    func selectAnswer(_ answerNum: Int) {
        for i in 0...2 {
            if i == answerNum {
                answers[i].selected = true
            } else {
                answers[i].selected = false
            }
        }
    }
}

class Category: Codable {
    var name: String
    var questions: [Question]
}

