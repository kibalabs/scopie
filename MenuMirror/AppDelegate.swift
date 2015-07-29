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

    @IBOutlet weak var window: NSWindow!
    var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        self.statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2) // workaround for NSSquareStatusItemLength
        self.statusItem.image = NSImage(named:"menu_icon")
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

