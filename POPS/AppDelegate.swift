//
//  AppDelegate.swift
//  POPS
//
//  Created by Mike Santiago on 6/1/17.
//  Copyright © 2017 Mike Santiago. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    @IBAction func viewCue2popsMacSourceClicked(_ sender: Any) {
        NSWorkspace.shared().open(URL(string: "https://github.com/ErikAndren/cue2pops-mac")!)
    }
    @IBAction func onHelpClick(_ sender: Any) {
        let alert = NSAlert()
        alert.messageText = "help me";
        alert.runModal()
    }
}

