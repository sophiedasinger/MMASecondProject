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
    var timePassed:Double = 0 // time elapsed since task assigned


    let notif = UILocalNotification()
    var toothbrushAlert_time = NSDate()
    var timeTaskCompleted = NSDate()
    var secondTest = 0
    
    
    override func viewDidLoad() {
        echoTest()
        super.viewDidLoad()
        getBrushTime()
        
        notif.alertAction = "Open"
        notif.alertBody = "Time to brush your teeth"
        let dateFire: NSDateComponents = NSDateComponents()
        dateFire.hour = 6
        dateFire.minute = 0
        notif.fireDate = NSDate(timeIntervalSinceNow: 5)
        //let task = taskTime(hour: 6, minute: 0, notification: notif)
        UIApplication.sharedApplication().scheduleLocalNotification(notif)
        
        
        // set computeBearMood to start being called repeatedly at scheduled time
        let timer = NSTimer(fireDate: NSDate(timeIntervalSinceNow: 5), interval: 2, target: self, selector: Selector("computeBearMood"), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getBrushTime() {
        //toothbrush original alert time
        let brushComp:NSDateComponents = NSDateComponents()
        brushComp.timeZone = NSTimeZone.localTimeZone()
        brushComp.year = 2016;
        brushComp.month = 05;
        brushComp.day = 06;
        brushComp.hour = 09;
        brushComp.minute = 30;
        let cal:NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let date:NSDate = cal.dateFromComponents(brushComp)!
        toothbrushAlert_time = date

        print("tooth time: ")
        print(toothbrushAlert_time)
        
        timePassed = calculateTimeElapsed(toothbrushAlert_time)
        computeBearMood()
    }
    
    /* test for web socket
     *
     */
    func echoTest(){
        let ws = WebSocket("wss://ws.pusherapp.com:443/app/cfb59a45c6610968c157?client=iOS-libPusher&version=3.0&protocol=5")
        ws.event.open = {
            print("opened web socket")
            // Open websocket connection
            let jsonObject: [String: AnyObject] = [
                "event": "pusher:subscribe",
                "data": [
                    "channel": "test_channel",
                ]
            ]
            // Subscribe to channel
            ws.send(self.jsonStringify(jsonObject))
        }
        ws.event.close = { code, reason, clean in
            print("close")
        }
        ws.event.error = { error in
            print("error \(error)")
        }
        ws.event.message = { message in
            if let text = message as? String {
                let response = self.jsonParse(text)
                let serverData = response["data"]! as! String?
                let parsedServerData = self.jsonParse(serverData!)
                let side = parsedServerData["side"] as! String?
                if (side != nil) {
                    self.lastTaskCompleted = true // Receiving data from server - therefore, Alexa has completed the task on the bear
                    self.timePassed = self.calculateTimeElapsed(NSDate()) // Reset timePassed based on current time
                    self.computeBearMood()
                }
            }
        }
    }
    
    /* emulates JSON.parse() functionality
     *
     * @param {String} jsonStr
     * @return {Object}
     */
    func jsonParse(jsonStr: String) -> AnyObject {
        let data: NSData = jsonStr.dataUsingEncoding(NSUTF8StringEncoding)!
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            return json
        } catch {
            print("error serializing JSON: \(error)")
            return []
        }
    }

    /* Source: https://medium.com/swift-programming/groundup-json-stringify-in-swift-b2d805458985#.w6el4l4mm
     * emulates JSON.stringify() functionality
     *
     * @param {AnyObject} jsonObject
     * @return {String}
     */
    func jsonStringify(jsonObject: AnyObject) -> String {
        var jsonString: String = ""
        switch jsonObject {
        case _ as [String: AnyObject] :
            let tempObject: [String: AnyObject] = jsonObject as! [String: AnyObject]
            jsonString += "{"
            for (key , value) in tempObject {
                if jsonString.characters.count > 1 {
                    jsonString += ","
                }
                jsonString += "\"" + String(key) + "\":"
                jsonString += jsonStringify(value)
            }
            jsonString += "}"
        case _ as [AnyObject] :
            jsonString += "["
            for i in 0..<jsonObject.count {
                if i > 0 {
                    jsonString += ","
                }
                jsonString += jsonStringify(jsonObject[i])
            }
            jsonString += "]"
        case _ as String :
            jsonString += ("\"" + String(jsonObject) + "\"")
        case _ as NSNumber :
            if jsonObject.isEqualToValue(NSNumber(bool: true)) {
                jsonString += "true"
            } else if jsonObject.isEqualToValue(NSNumber(bool: false)) {
                jsonString += "false"
            } else {
                return String(jsonObject)
            }
        default :
            jsonString += ""
        }
        return jsonString
    }
    
    /* parse a json formatted string
     *
     * @param {String} jsonStr
     */
    func parseData(jsonStr: String) {
        timePassed = calculateTimeElapsed(toothbrushAlert_time)
        
        var data: NSData = jsonStr.dataUsingEncoding(NSUTF8StringEncoding)!
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            if ((json.count) != nil) {
                timeTaskCompleted = NSDate() //current time Completed
                lastTaskCompleted = true
                //computeTimePassed(json[1])
            }
            computeBearMood()
        } catch {
            computeBearMood()
            print("error serializing JSON: \(error)")
        }
    }
    
    /* computes current bear mood based on time elapsed
     *
     */
    func computeBearMood() {
        print("computeBearMood")
        if (lastTaskCompleted) {
            if (timePassed <= 10) {
                setBearMood("happy")
            } else {
                setBearMood("girl")
            }
        } else if (timePassed > 30) {
            setBearMood("neutral")
        } else if (timePassed <= 60) {
            setBearMood("unhappy")
        } else if (timePassed > 120) {
            setBearMood("sad")
        }
    }
    
    /* calculates the time elapsed since scheduled task
     *
     * @param {NSDate} start -- time of assigned task
     * @return {Double}
     */
    //currently returns seconds elapsed, for demo purposes; in the real thing, multiply * 60 to use minutes
    func calculateTimeElapsed(start:NSDate) -> Double{
        let elapsed = abs(start.timeIntervalSinceNow)
        
        let dateComponentsFormatter = NSDateComponentsFormatter()
        dateComponentsFormatter.unitsStyle = NSDateComponentsFormatterUnitsStyle.Abbreviated
        dateComponentsFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehavior.DropAll
        let stringDiff = dateComponentsFormatter.stringFromTimeInterval(elapsed)
        print("time elapsed (seconds , formatted-time): ")
        print(elapsed)
        print(stringDiff)
        
        return elapsed
//        var firstReminderTime = toothbrushAlert_time.dateByAddingTimeInterval(30*60) //30 mins after notif, give icon
//        var secondReminderTime = firstReminderTime.dateByAddingTimeInterval(30*60)

    }
    
    func processNewTask() {
        // set lastTaskCompleted to false
        lastTaskCompleted = false
    }
    
    /* changes the image of the bear
     * 
     * @param {String} mood
     */
    func setBearMood(mood: String) {
        if (mood ==  "happy") {
            let image: UIImage = UIImage(named: "superhappy-face")!
            bearImage.image = image
        } else if (mood == "neutral") {
            print("neutral face")
            let image: UIImage = UIImage(named: "happy-face")!
            bearImage.image = image
        } else if (mood == "unhappy") {
            let image: UIImage = UIImage(named: "unhappy-face")!
            bearImage.image = image
        } else if (mood == "sad") {
            let image: UIImage = UIImage(named: "sad-face")!
            bearImage.image = image
        } else if (mood == "girl") {
            print("here")
            let image: UIImage = UIImage(named: "girl")!
            bearImage.image = image
        }
        
    }
}

