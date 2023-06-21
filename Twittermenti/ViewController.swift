//
//  ViewController.swift
//  Twittermenti
//
//  Created by Angela Yu on 17/07/2019.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit
import SwifteriOS

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    let tweetCount = 100
    
    private var apiKey: String {
      get {
        guard let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist") else {
          fatalError("Couldn't find file 'Secrets.plist'.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "API_KEY") as? String else {
          fatalError("Couldn't find key 'API_KEY' in 'Secrets.plist'.")
        }
        return value
      }
    }
    
    private var apiSecret: String {
      get {
        guard let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist") else {
          fatalError("Couldn't find file 'Secrets.plist'.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "API_SECRET") as? String else {
          fatalError("Couldn't find key 'API_SECRET' in 'Secrets.plist'.")
        }
        return value
      }
    }
    
    let sentimentClassifier = TweetSentimentClassifier()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func predictPressed(_ sender: Any) {
        if let searchText = textField.text {
            getTweets(with: searchText)
        }
    }
    
    func getTweets(with query: String) {
        let swifter = Swifter(consumerKey: apiKey, consumerSecret: apiSecret)
        swifter.searchTweet(using: "@Apple", lang: "en", count: tweetCount, tweetMode: .extended, success: { (results, metadata) in
            var tweets = [TweetSentimentClassifierInput]()
            for i in 0..<self.tweetCount {
                if let tweet = results[0]["full_text"].string {
                    tweets.append(TweetSentimentClassifierInput(text: tweet))
                }
            }
            self.getPredictions(with: tweets)
        }) { (error) in
            print("There was an error with the Twitter API Request, \(error)")
            var tweets = [TweetSentimentClassifierInput]()
            tweets.append(TweetSentimentClassifierInput(text: "I love Apple"))
            tweets.append(TweetSentimentClassifierInput(text: "I hate Apple"))
            tweets.append(TweetSentimentClassifierInput(text: "I am neutral about Apple"))
            self.getPredictions(with: tweets)
        }
    }
    
    func getPredictions(with tweets: [TweetSentimentClassifierInput]) {
        do {
            var score = 0
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            for prediction in predictions {
                print(prediction.label)
                let sentiment = prediction.label
                if sentiment == "Pos" {
                    score += 1
                } else if sentiment == "Neg" {
                    score -= 1
                }
            }
            updateUI(with: score)
        } catch {
            print("There was an error with making a prediction, \(error)")
        }
    }
    
    func updateUI(with score: Int) {
        if score > 0 {
            self.sentimentLabel.text = "😍"
        } else if score == 0 {
            self.sentimentLabel.text = "😐"
        } else {
            self.sentimentLabel.text = "☹️"
        }
    }
}

