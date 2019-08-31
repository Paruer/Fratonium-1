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
    
    init (categories: [Category]) {
        self.categories = categories
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

class Category {
    let name: String
    let questions: [Question]
    
    init (name: String, questions: [Question]) {
        self.name = name
        self.questions = questions
    }
}

class Question {
    let name: String
    let answers: [Answer]
    
    init (name: String, answers: [Answer]) {
        self.name = name
        self.answers = answers
    }
}

class Answer {
    let text: String
    let value: Int
    
    init (text: String, value: Int) {
        self.text = text
        self.value = value
    }
}
