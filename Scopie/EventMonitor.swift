//
//  EventMonitor.swift
//  MenuMirror
//
//  Created by Krishan Patel on 29/07/2015.
//  Copyright (c) 2015 Rocko Labs. All rights reserved.
//

import Cocoa

public class EventMonitor {
    private var monitor: AnyObject?
    private let mask: NSEventMask
    private let handler: NSEvent? -> ()

    public init(mask: NSEventMask, handler: NSEvent? -> ()) {
        self.mask = mask
        self.handler = handler
    }

    deinit {
        self.stop()
    }

    public func start() {
        self.monitor = NSEvent.addGlobalMonitorForEventsMatchingMask(self.mask, handler:self.handler)
    }

    public func stop() {
        if (self.monitor != nil) {
            NSEvent.removeMonitor(self.monitor!)
            self.monitor = nil
        }
    }
}
