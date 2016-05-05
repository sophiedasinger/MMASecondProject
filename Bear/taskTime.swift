//
//  taskTime.swift
//  Bear
//
//  Created by Sophie on 4/10/16.
//  Copyright © 2016 Tufts. All rights reserved.
//

import Foundation
import UIKit

class taskTime: NSObject {
    var hour: Int
    var minute: Int
    var notification: UILocalNotification
    init(hour: Int, minute: Int, notification: UILocalNotification) {
        self.hour = hour
        self.minute = minute
        self.notification = notification
    }
}

