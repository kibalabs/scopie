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

    let statusItem = NSStatusBar.system.statusItem(withLength: -2)
    let popover = NSPopover()
    var eventMonitor: EventMonitor?

    func applicationDidFinishLaunching(_ notification: Notification) {
        if let button = self.statusItem.button {
            button.image = NSImage(named:"menu_icon_glasses")
            button.action = #selector(AppDelegate.togglePopover(_:))
        }

        self.popover.contentViewController = CameraViewController(nibName:"CameraViewController", bundle:nil)

        self.eventMonitor = EventMonitor(mask: [NSEvent.EventTypeMask.leftMouseDown, NSEvent.EventTypeMask.rightMouseDown]) { event in
            if self.popover.isShown {
                self.closePopover(event)
            }
        }
        self.eventMonitor?.start()
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        self.togglePopover(self.statusItem.button)
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        print("togglePopover: \(String(describing: sender))")
        if self.popover.isShown {
            self.closePopover(sender)
        } else {
            self.showPopover(sender)
        }
    }

    func showPopover(_ sender: AnyObject?) {
        if let button = self.statusItem.button {
            self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
        self.eventMonitor?.start()
    }

    func closePopover(_ sender: AnyObject?) {
        self.popover.performClose(sender)
        self.eventMonitor?.stop()
    }
    
}

