//
//  ViewController.swift
//  Bear
//
//  Created by Sophie on 4/10/16.
//  Copyright © 2016 Tufts. All rights reserved.
//

import UIKit
import Foundation


class ViewController: UIViewController {
    
    @IBOutlet weak var bearImage: UIImageView!
    var lastTaskCompleted: Bool = true
    var timePassed = 0 // time elapsed since task assigned
    
    
    let notif = UILocalNotification()

    
    var secondTest = 0
    
    
    override func viewDidLoad() {
        echoTest()
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // getData continuously
        //
        // computeBearMood continuously
        //setBearMood("neutral")
        
        notif.alertAction = "Open"
        notif.alertBody = "Time to brush your teeth"
        let dateFire: NSDateComponents = NSDateComponents()
        dateFire.hour = 6
        dateFire.minute = 0
        notif.fireDate = NSDate(timeIntervalSinceNow: 5)
        let task = taskTime(hour: 6, minute: 0, notification: notif)
        
        var image: UIImage = UIImage(named: "happy-face")!
        bearImage.image = image
//        let getDataTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("getData"), userInfo: nil, repeats: true)
//                let getDataTimer = NSTimer.scheduledTimerWithTimeInterval(9.0, target: self, selector: Selector("setBearMood"), userInfo: nil, repeats: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func echoTest(){
        var messageNum = 0
        let ws = WebSocket("wss://echo.websocket.org")
        let send : ()->() = {
            let msg = "\(++messageNum): \(NSDate().description)"
            print("send: \(msg)")
            ws.send(msg)
        }
        ws.event.open = {
            print("opened")
            send()
        }
        ws.event.close = { code, reason, clean in
            print("close")
        }
        ws.event.error = { error in
            print("error \(error)")
        }
        ws.event.message = { message in
            if let text = message as? String {
                print("recv: \(text)")
                if messageNum == 10 {
                    ws.close()
                } else {
                    send()
                }
            }
        }
    }
    
    func getData() {
        let url = NSURL(string: "https://peaceful-woodland-42419.herokuapp.com/")
        let session = NSURLSession.sharedSession()
        
        let dataTask = session.dataTaskWithURL(url!) {
            data, response, error in
            dispatch_async(dispatch_get_main_queue()) {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = error {
                    print(error.localizedDescription)
                } else if let httpResponse = response as? NSHTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        print("successful request")
                        let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                        self.parseData(dataString! as String)
                    }
                }
            }
            
        }
        dataTask.resume()
        //parseData("1")
    }
    
    func parseData(jsonStr: String) {
        timePassed = calculateTimeElapsed()
        
        print(timePassed)
        var data: NSData = jsonStr.dataUsingEncoding(NSUTF8StringEncoding)!
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            if ((json.count) != nil) {
                lastTaskCompleted = true
                //computeTimePassed(json[1])
            }
            computeBearMood()
        } catch {
            computeBearMood()
            print("error serializing JSON: \(error)")
        }
    }
    
    func computeBearMood() {
        print("computeBearMood")
        if (lastTaskCompleted) {
            if (timePassed <= 10) {
                setBearMood("happy")
            } else {
                setBearMood("girl")
            }
        } else if (timePassed > 30) {
            print("here")
            setBearMood("neutral")
        } else if (timePassed <= 60) {
            setBearMood("unhappy")
        } else if (timePassed > 120) {
            setBearMood("sad")
        }
    }
    
    func calculateTimeElapsed() -> Int{
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour, .Minute, .Second], fromDate: date)
        let hr = components.hour
        let mins = components.minute
        let secs = components.second
        
        //        let hourDiff = hr - task.hour
        //        let minDiff = mins - task.minute
        //
        //        let minElapsed = (hourDiff * 60 + minDiff)
        //        let minElapsed = 45.0
        let secondsElapsed = secs - secondTest
        return secondsElapsed
    }
    
    func processNewTask() {
        // set lastTaskCompleted to false
        lastTaskCompleted = false
    }
    
    func setBearMood(mood: String) {
        if (mood ==  "happy") {
            var image: UIImage = UIImage(named: "superhappy-face")!
            bearImage.image = image
        } else if (mood == "neutral") {
            print("neutral face")
            var image: UIImage = UIImage(named: "happy-face")!
            bearImage.image = image
        } else if (mood == "unhappy") {
            var image: UIImage = UIImage(named: "unhappy-face")!
            bearImage.image = image
        } else if (mood == "sad") {
            var image: UIImage = UIImage(named: "sad-face")!
            bearImage.image = image
        } else if (mood == "girl") {
            var image: UIImage = UIImage(named: "girl")!
            bearImage.image = image
        }
        
    }
}

