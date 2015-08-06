//
//  AppDelegate.swift
//  MenuMirror
//
//  Created by Krishan Patel on 29/07/2015.
//  Copyright (c) 2015 Rocko Labs. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
    let popover = NSPopover()
    var eventMonitor: EventMonitor?

    func applicationDidFinishLaunching(notification: NSNotification) {
        if (NSAppKitVersionNumber <= Double(NSAppKitVersionNumber10_10)) {
            self.statusItem.image = NSImage(named:"menu_icon_glasses")
            self.statusItem.action = Selector("togglePopover:")
        } else {
            if let button = self.statusItem.button {
                button.image = NSImage(named:"menu_icon_glasses")
                button.action = Selector("togglePopover:")
            }
        }

        self.popover.contentViewController = CameraViewController(nibName:"CameraViewController", bundle:nil)

        self.eventMonitor = EventMonitor(mask: .LeftMouseDownMask | .RightMouseDownMask) { [unowned self] event in
            if self.popover.shown {
                self.closePopover(event)
            }
        }
        self.eventMonitor?.start()
    }

    func applicationDidBecomeActive(notification: NSNotification) {
        if (NSAppKitVersionNumber <= Double(NSAppKitVersionNumber10_10)) {

        } else {
            self.togglePopover(self.statusItem.button)
        }
    }

    func togglePopover(sender: AnyObject?) {
        println("togglePopover: \(sender)")
        if self.popover.shown {
            self.closePopover(sender)
        } else {
            self.showPopover(sender)
        }
    }

    func showPopover(sender: AnyObject?) {
        if let button = self.statusItem.button {
            self.popover.showRelativeToRect(button.bounds, ofView: button, preferredEdge: NSMinYEdge)
        }
        self.eventMonitor?.start()
    }

    func closePopover(sender: AnyObject?) {
        self.popover.performClose(sender)
        self.eventMonitor?.stop()
    }
    
}

