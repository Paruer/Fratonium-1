//
//  Assessment.swift
//  Fratonium
//
//  Created by Michael Parker on 8/30/19.
//  Copyright © 2019 Michael Parker. All rights reserved.
//

import Foundation

class Assessment {
    let categories: [Category]
    var categoryIterator: IndexingIterator<[Category]>
    var currentCategory: Category
    var questionIterator: IndexingIterator<[Question]>
    var currentQuestion: Question? //nil is a signal to users that we have iterated through all the categories and questions
    
    /**
     The initializer throws an error if it cannot load and parse the JSON containing the assessment data
    */
    init () throws {
        let url = Bundle.main.url(forResource: "AssessmentData", withExtension: "json")
        let json = try Data(contentsOf: url!)
        let decoder = JSONDecoder()
        categories = try decoder.decode([Category].self, from: json)
        for category in categories {
            print("Category name = \(category.name)")
            for question in category.questions {
                print("\tQuestion name = \(question.name)")
                for answer in question.answers {
                    print("\t\tAnswer text = \(answer.text), value = \(answer.value)")
                }
            }
        }
        categoryIterator = categories.makeIterator()
        currentCategory = categoryIterator.next()!
        questionIterator = currentCategory.questions.makeIterator()
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
    
    func resetAssessment() {
        categoryIterator = categories.makeIterator()
        currentCategory = categoryIterator.next()!
        questionIterator = currentCategory.questions.makeIterator()
    }
}

//=====================================
// MARK: Model classes
//=====================================

class Answer: Codable {
    var text: String
    var value: Int
}

class Question: Codable {
    var name: String
    var answers: [Answer]
}

class Category: Codable {
    var name: String
    var questions: [Question]
}

