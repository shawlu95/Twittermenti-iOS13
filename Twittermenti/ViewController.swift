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
        let swifter = Swifter(consumerKey: apiKey, consumerSecret: apiSecret)
        swifter.searchTweet(using: "@Apple", lang: "en", count: 100, tweetMode: .extended, success: { (results, metadata) in
            print(results)
            
            var tweets = [String]()
            for i in 0..<100 {
                if let tweet = results[0]["full_text"].string {
                    tweets.append(tweet)
                }
            }
            print(tweets)
        }) { (error) in
            print("There was an error with the Twitter API Request, \(error)")
        }
        
        let prediction = try! sentimentClassifier.prediction(text: "@Apple is a terrible company!")
        print(prediction.label)
    }

    @IBAction func predictPressed(_ sender: Any) {
    
    
    }
    
}

