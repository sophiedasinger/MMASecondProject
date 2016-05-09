//
//  ViewController.swift
//  Bear
//
//  Created by Sophie on 4/10/16.
//  Copyright © 2016 Tufts. All rights reserved.
//

import UIKit
import Foundation


class ViewController: UIViewController/*, UIPickerViewDataSource, UIPickerViewDelegate*/ {
    
    @IBOutlet weak var bearImage: UIImageView!
    @IBOutlet weak var barImage: UIImageView!
    var lastTaskCompleted: Bool = false
    var loadingBar = ["loading1", "loading2", "loading3", "loading4", "loading5", "loading6", "loading7", "loading8", "loading9", "loadingA", "loadingB"]
    //@IBOutlet weak var taskOptions: UIPickerView!
    
    let notif = UILocalNotification()
    var toothbrushAlert_time = NSDate(timeIntervalSinceNow: 5) //take out timeInterval after demo
    var timeTaskCompleted = NSDate()
    var secondTest = 0
    var timer:NSTimer = NSTimer()
    var numBrushes = 0
    
    func set_init_vals() {
        numBrushes = 0
        lastTaskCompleted = false
        self.bearImage.image = UIImage(named: "happy-face")
        self.barImage.image = UIImage(named: "loading0")
        // set computeBearMood to start being called repeatedly at scheduled time
        timer = NSTimer(fireDate: NSDate(timeIntervalSinceNow: 7), interval: 2, target: self, selector: Selector("computeBearMood"), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize bear image
        set_init_vals()
        
        connectToSocket()
        //getBrushTime()
        
        notif.alertAction = "Open"
        notif.alertBody = "Time to brush your teeth"
        let dateFire: NSDateComponents = NSDateComponents()
        dateFire.hour = 6
        dateFire.minute = 0
        notif.fireDate = NSDate(timeIntervalSinceNow: 5)
        //let task = taskTime(hour: 6, minute: 0, notification: notif)
        UIApplication.sharedApplication().scheduleLocalNotification(notif)
        
        
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
        brushComp.day = 07;
        brushComp.hour = 14;
        brushComp.minute = 47;
        let cal:NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let date:NSDate = cal.dateFromComponents(brushComp)!
        toothbrushAlert_time = date
        
    }
    
    /* connect to web socket and handle receiving data
    *
    */
    func connectToSocket(){
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
                let accelerometerData = parsedServerData["accel"] as! String?
                if (side != nil && self.lastTaskCompleted == false) {
                    // change pic based on side, 10x
                    self.timer.invalidate() // invalidate timer that is calling computeBearMood
                    if (self.numBrushes < 10) {     //hasn't finished brushing bear's teeth
                        self.numBrushes += 1
                        self.barImage.image = UIImage(named: self.loadingBar[self.numBrushes + 1])
                        if (side == "l") {
                            let image: UIImage = UIImage(named: "bear-brush-left")!
                            self.bearImage.image = image
                        } else {
                            let image: UIImage = UIImage(named: "bear-brush-right")!
                            self.bearImage.image = image
                        }
                        if (self.numBrushes == 9) { //finished brushing!
                            self.numBrushes = 0 // reset numBrushes
                            self.lastTaskCompleted = true // Receiving data from server - therefore, Alexa has completed the task on the bear
                            self.timeTaskCompleted = NSDate()
                            self.computeBearMood() // call computeBearMood to set to girl image now that task is complete
                            NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(3), target: self, selector: "computeBearMood", userInfo: nil, repeats: false)
                        }
                    }
                } else if (side != nil && self.lastTaskCompleted == true){    //will not be nil if girl is brushing teeth
                    if (self.numBrushes < 10) {     //hasn't finished brushing girl's teeth
                        self.numBrushes += 1
                        self.barImage.image = UIImage(named: self.loadingBar[self.numBrushes + 1])
                        if (side == "l") {
                            let image: UIImage = UIImage(named: "girl-brush-left")!
                            self.bearImage.image = image
                        } else {
                            let image: UIImage = UIImage(named: "girl-brush-right")!
                            self.bearImage.image = image
                        }
                        if (self.numBrushes == 9) { //finished brushing!
                            self.set_init_vals()
                            self.toothbrushAlert_time = NSDate(timeIntervalSinceNow: 5) //take out timeInterval after demo
                        }
                    }
                }
            }
        }
    }
    
    //    func processTask(
    
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
    
    /* computes current bear mood based on time elapsed
    *
    */
    func computeBearMood() {
        let timePassed = calculateTimeElapsed(toothbrushAlert_time)
        print("computeBearMood")
        if (lastTaskCompleted) {
            if (calculateTimeElapsed(timeTaskCompleted) <= 2) {
                setBearMood("happy")
            } else {
                setBearMood("girl")
            }
        } else if (timePassed > 5 && timePassed < 10) {
            setBearMood("reminder")
            self.barImage.image = UIImage(named: self.loadingBar[self.numBrushes])
        } else if (timePassed >= 10 && timePassed < 15) {
            setBearMood("unhappy")
        } else if (timePassed >= 15 && timePassed < 20) {
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
        //        print("time elapsed (seconds , formatted-time): ")
        //        print(stringDiff)
        
        return elapsed
        
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
            let image: UIImage = UIImage(named: "reminder-1")!
            bearImage.image = image
        } else if (mood == "reminder") {
            let image: UIImage = UIImage(named: "reminder-1")!
            bearImage.image = image
        } else if (mood == "unhappy") {
            let image: UIImage = UIImage(named: "reminder-2")!
            bearImage.image = image
        } else if (mood == "sad") {
            let image: UIImage = UIImage(named: "reminder-3")!
            bearImage.image = image
        } else if (mood == "girl") {
            let image: UIImage = UIImage(named: "girl-no-brush")!
            bearImage.image = image
        }
        
    }
    
    /*
    * Add new task functions.
    
    var tasks = ["Brush Teeth", "Get Dressed", "Brush Hair", "Feed Self"]
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return tasks.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
    return tasks[row]
    }*/
    
}

