//
//  Log.swift
//  Fratonium
//
//  Created by Michael Parker on 1/30/20.
//  Copyright © 2020 Michael Parker. All rights reserved.
//

import os

private let subsystem = "FRATonium"

struct Log {
    static let assessment = OSLog(subsystem: subsystem, category: "Assessment")
    static let controller = OSLog(subsystem: subsystem, category: "controller")
}
