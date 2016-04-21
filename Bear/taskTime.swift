//
//  taskTime.swift
//  Bear
//
//  Created by Sophie on 4/10/16.
//  Copyright © 2016 Tufts. All rights reserved.
//

import Foundation

class taskTime: NSObject {
    var hour: Int
    var minute: Int
    init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }
}
