//
//  ViewController.swift
//  Bear
//
//  Created by Sophie on 4/10/16.
//  Copyright © 2016 Tufts. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var bearImage: UIImageView!
    var lastTaskCompleted: Bool = true
    var timePassed = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        setBearMood("happy")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func getData() {
        // get data from server
        // check if task was completed, and how much time has passed
    }
    
    func interpretData() {
        // check if task was completed, and how much time has passed
        
    }
    
    func computeBearMood() {
        if (lastTaskCompleted && timePassed <= 30) {
            setBearMood("happy")
        } else if (lastTaskCompleted && timePassed > 30) {
            setBearMood("neutral")
        } else if (!lastTaskCompleted && timePassed <= 30) {
            setBearMood("unhappy")
        } else if (!lastTaskCompleted && timePassed > 30) {
            setBearMood("sad")
        }
    }
    
    func setBearMood(mood: String) {
        if (mood ==  "happy") {
            let image: UIImage = UIImage(named: "superhappy-face")!
            bearImage.image = image
        } else if (mood == "neutral") {
            let image: UIImage = UIImage(named: "happy-face")!
            bearImage.image = image
        } else if (mood == "unhappy") {
            let image: UIImage = UIImage(named: "unhappy-face")!
            bearImage.image = image
        } else if (mood == "sad") {
            let image: UIImage = UIImage(named: "sad-face")!
            bearImage.image = image
        }
        
    }
}

