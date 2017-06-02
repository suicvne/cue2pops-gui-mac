//
//  ViewController.swift
//  POPS
//
//  Created by Mike Santiago on 6/1/17.
//  Copyright © 2017 Mike Santiago. All rights reserved.
//

import Cocoa

extension String {
    
    func fileName() -> String {
        
        if let fileNameWithoutExtension = NSURL(fileURLWithPath: self).deletingPathExtension?.lastPathComponent {
            return fileNameWithoutExtension
        } else {
            return ""
        }
    }
    
    func fileExtension() -> String {
        
        if let fileExtension = NSURL(fileURLWithPath: self).pathExtension {
            return fileExtension
        } else {
            return ""
        }
    }
}

class ViewController: NSViewController {

    var expanded = true
    
    var allowedFileExtensions: [Any] = ["cue"]
    
    let cue2popsPath = Bundle.main.resourcePath! + "/cue2pops"
    let elfPath = Bundle.main.resourcePath! + "/POPSTARTER.ELF"
    let pfsWrap = Bundle.main.resourcePath! + "/PFS_WRAP.BIN"
    
    /**
     extra options
     */
    
    var gapMode = 0; //0 = disabled, 1 = ++, 2 = --
    var vmode = false;
    var trainer = false;
    var unmountDriveAfter = false;
    
    /**
     extra options
     */
    
    
    @IBOutlet weak var gameFileTextField: NSTextField!
    @IBOutlet weak var externalVolumeTextField: NSTextField!
    //@IBOutlet weak var cue2popsLogTextField: NSTextField!
    @IBOutlet var cue2popsLogTextView: NSTextView!
    
    @IBOutlet weak var selectGameFileButton: NSButton!
    
    @IBOutlet weak var gapDisableRadio: NSButton!
    @IBOutlet weak var gapPlusPlusRadio: NSButton!
    @IBOutlet weak var gapMinusMinusRadio: NSButton!
    
    override func viewDidLoad() {
        toggleResize()
        if #available(OSX 10.10, *) {
            super.viewDidLoad()
        } else {
            // idk actually
            self.viewDidLoad()
        }

        
    }
    @IBAction func showMoreClick(_ sender: Any) {
        toggleResize()
    }
    
    func toggleResize()
    {
        expanded = !expanded
        var frame = self.view.window?.frame
        if(expanded) //expand
        {
            frame?.size.height = 475
        }
        else //shrink
        {
            frame?.size.height = 320
        }
        
        self.view.window?.setFrame(frame!, display: true, animate: true)
    }
    
    @IBAction func selectGameButtonClick(_ sender: Any) {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = allowedFileExtensions as? [String]
        panel.directoryURL = NSURL(fileURLWithPath: NSHomeDirectory()) as URL
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.resolvesAliases = true
        
        panel.beginSheetModal(for: self.view.window!) { (result: Int) in
            if(result == NSFileHandlingPanelOKButton)
            {
                let filePath = panel.urls[0]
                self.gameFileTextField.stringValue = filePath.path;
            }
            else
            {
                panel.close()
            }
        }
    }
    
    @IBAction func gapModeToggle(_ sender: Any) {
        if(gapDisableRadio.state == 1)
        {
            gapMode = 0
        }
        else if(gapPlusPlusRadio.state == 1)
        {
            gapMode = 1
        }
        else if(gapMinusMinusRadio.state == 1)
        {
            gapMode = 2
        }
    }
    
    @IBOutlet weak var vmodeToggle: NSButton!
    @IBOutlet weak var trainerToggle: NSButton!
    @IBOutlet weak var unmountDriveToggle: NSButton!
    
    @IBAction func vmodeToggleClick(_ sender: Any) {
        if(vmodeToggle.state == 1)
        {
            vmode = true
        }
        else
        {
            vmode = false
        }
    }
    @IBAction func trainerToggleClick(_ sender: Any) {
        if(trainerToggle.state == 1)
        {
            trainer = true
        }
        else
        {
            trainer = false
        }
    }
    
    @IBAction func unmountDriveToggleClick(_ sender: Any) {
        if(unmountDriveToggle.state == 1)
        {
            unmountDriveAfter = true
        }
        else
        {
            unmountDriveAfter = false
        }
    }
    
    @IBAction func showMoreOptionsButtonClick(_ sender: Any) {
    }
    func isDirectoryWriteable(path: String) -> Bool {
        let fileManager = FileManager.default
        var destinationString = path //copy so we can mess around with it
        
        if(!destinationString.hasSuffix("/"))
        {
            destinationString += "/"
        }
        
        return fileManager.isWritableFile(atPath: destinationString)
    }
    
    @IBAction func externalVolumeButtonClick(_ sender: Any) {
        let panel = NSOpenPanel()
        //panel.allowedFileTypes = allowedFileExtensions as? [String]
        panel.directoryURL = NSURL(fileURLWithPath: NSHomeDirectory()) as URL
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.resolvesAliases = true
        
        panel.beginSheetModal(for: self.view.window!) { (result: Int) in
            if(result == NSFileHandlingPanelOKButton)
            {
                let filePath = panel.urls[0]
                
                if(self.isDirectoryWriteable(path: filePath.path))
                {
                    self.externalVolumeTextField.stringValue = filePath.path
                }
                else
                {
                    panel.close()
                    
                    let alert = NSAlert()
                    alert.addButton(withTitle: "OK")
                    alert.messageText = "Unable to write to this directory."
                    alert.alertStyle = NSAlertStyle.critical
                    alert.informativeText = "This directory or flash drive is read-only. Please select a location that is writeable by the POPS software."
                    alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
                    NSLog("Directory not writeable")
                }
            }
            else
            {
                panel.close()
            }
        }
    }
    
    
    /**
     
     this function checks the external device to make sure that the POPS folder exists on the flash drive
     
     true if exists
     false if doesn't exist
     
     */
    func checkForPopsPath(path: String) -> Bool {
        let fileManager = FileManager.default
        var directory: ObjCBool = ObjCBool(true)
        return fileManager.fileExists(atPath: path, isDirectory: &directory) //what the fuck swift? i thought swift was supposed to be easier.
    }
    
    func createPopsPath()
    {
        let panel = NSOpenPanel()
        panel.directoryURL = NSURL(fileURLWithPath: NSHomeDirectory() + "/Downloads") as URL
        panel.allowsMultipleSelection = false;
        panel.canChooseFiles = true;
        panel.canChooseDirectories = false;
        panel.resolvesAliases = true
        panel.allowedFileTypes = ["pak"]
        panel.message = "The selected external volume doesn't have a POPS directory present.\n\nPlease select a valid POPS.PAK to copy to the POPS directory.";
        
        panel.beginSheetModal(for: self.view.window!) { (result: Int) in
            if(result == NSFileHandlingPanelOKButton)
            {
                let popsPak = panel.urls[0].path
                let fileManager = FileManager.default
                do
                {
                    try fileManager.createDirectory(atPath: self.externalVolumeTextField.stringValue + "/POPS", withIntermediateDirectories: false, attributes: nil)
                    try fileManager.copyItem(atPath: popsPak, toPath: self.externalVolumeTextField.stringValue + "/POPS/POPS.PAK")
                    try fileManager.copyItem(atPath: self.pfsWrap, toPath: self.externalVolumeTextField.stringValue + "/POPS/PFS_WRAP.BIN")
                }
                catch
                {
                    NSLog("error?")
                    NSLog("\(error.localizedDescription)")
                
                    let alert = NSAlert()
                    alert.addButton(withTitle: "OK")
                    alert.alertStyle = NSAlertStyle.critical
                    alert.messageText = "Error copying POPS.PAK"
                    alert.informativeText = "An unspecified error ocurred: \(error.localizedDescription)"
                    alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
                }
            }
        }
        
    }
    
    func executeCommand(command: String, args: [String]) -> String {
        
        let task = Process()
        
        task.launchPath = command
        task.arguments = args
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String!
        return output        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func createTempDirectory() -> String? {
        
        let tempDirURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("XXXXXX")
        
        do {
            try FileManager.default.createDirectory(at: tempDirURL!, withIntermediateDirectories: true, attributes: nil)
        } catch {
            return nil
        }
        
        return tempDirURL?.path
    }
    
    func removeSpecialCharsFromString(text: String) -> String {
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890._".characters)
        return String(text.characters.filter {okayChars.contains($0) })
    }
    
    func checkAllParameters() -> Bool
    {
        if(gameFileTextField.stringValue.isEmpty)
        {
            let alert = NSAlert()
            alert.addButton(withTitle: "OK")
            alert.alertStyle = NSAlertStyle.critical
            alert.messageText = "Game cue path empty."
            alert.informativeText = "The path specified as your game cue file is empty or invalid."
            alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
            
            return false;
        }
        
        if(!externalVolumeTextField.stringValue.isEmpty) //if it's not empty, then we check for the pops path
        {
            if(!checkForPopsPath(path: externalVolumeTextField.stringValue + "/POPS"))
            {
                createPopsPath();
                
                let alert = NSAlert()
                alert.addButton(withTitle: "OK")
                alert.alertStyle = NSAlertStyle.informational
                alert.messageText = "POPS folder created successfully."
                alert.informativeText = "Please click 'Convert!' again."
                alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
                
                return false;
            }
        }
        else
        {
            let alert = NSAlert()
            alert.addButton(withTitle: "OK")
            alert.alertStyle = NSAlertStyle.critical
            alert.messageText = "External volume path empty"
            alert.informativeText = "The path specified as your external volume is empty or invalid."
            alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
            
            return false;
        }
        
        return true;
    }
    
    func createCue2PopsArgs(tempDir: String) -> [String] {
        var commandLineArgs = [gameFileTextField.stringValue]
        if(gapMode == 1) //++
        {
            commandLineArgs.append("gap++")
        }
        else if(gapMode == 2) //--
        {
            commandLineArgs.append("gap--")
        }
        
        if(vmode)
        {
            commandLineArgs.append("vmode")
        }
        if(trainer)
        {
            commandLineArgs.append("trainer")
        }
        
        commandLineArgs.append(tempDir + "/IMAGE.VCD") //ensures the output file is last
        
        return commandLineArgs
    }
    
    func copyVCDfromTemp(tempDir: String, vcdName: String) -> Bool {
        let fileManager = FileManager.default
        do {
            try fileManager.copyItem(atPath: tempDir + "/IMAGE.VCD", toPath: self.externalVolumeTextField.stringValue + "/POPS/\(vcdName).VCD")
        } catch {
            NSLog("error copying VCD")
            
            let alert = NSAlert()
            alert.addButton(withTitle: "OK")
            alert.alertStyle = NSAlertStyle.informational
            alert.messageText = "Error Copying VCD"
            alert.informativeText = "An unknown error occurred while copying the VCD: \(error.localizedDescription)"
            alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
            return false;
        }
        
        addToLog(log: "conversion complete! copied to \(self.externalVolumeTextField.stringValue + "/POPS/\(vcdName).VCD")")
        return true
    }
    
    func addToLog(log: String) {
        cue2popsLogTextView.string?.append("\n\(log)")
        cue2popsLogTextView.scrollToEndOfDocument(self)
    }
    
    func copyElf(vcdName: String) -> Bool {
        do {
            try FileManager.default.copyItem(atPath: self.elfPath, toPath: self.externalVolumeTextField.stringValue + "/XX." + vcdName + ".ELF")
        } catch {
            NSLog("error copying elf");
            
            let alert = NSAlert()
            alert.addButton(withTitle: "OK")
            alert.alertStyle = NSAlertStyle.critical
            alert.messageText = "Error Copying ELF"
            alert.informativeText = "An unknown error occurred while copying the ELF: \(error.localizedDescription)"
            alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
            return false;
        }
        return true
    }
    
    @IBAction func convertButtonClicked(_ sender: Any) {
        
        cue2popsLogTextView.string = ""; //clear log
        
        if(!checkAllParameters()) {return;} //check all the text boxes to make sure the paths are valid and what-not
        
        
        let pathToCue = gameFileTextField.stringValue
        let vcdNameWithoutExtension = removeSpecialCharsFromString(text: pathToCue.fileName())
        let temporaryDirectory = createTempDirectory()
        
        let commandLineArgs = createCue2PopsArgs(tempDir: temporaryDirectory!)
        
        //1. Run the conversion using execute command
        let output = executeCommand(command: cue2popsPath, args: commandLineArgs)
        addToLog(log: output)
        
        //1.5 let's copy the VCD from the temp directory to the POPS folder
        if(!copyVCDfromTemp(tempDir: temporaryDirectory!, vcdName: vcdNameWithoutExtension)) { return }
        
        //2. at this point, the pops folder is setup. lets copy the elf and of course, rename it
        if(!copyElf(vcdName: vcdNameWithoutExtension)) { return }
        //2.5 delete the temporary directory
        do
        {
            try FileManager.default.removeItem(atPath: temporaryDirectory!) //remove temp directory
        } catch {
            NSLog("error deleting temp directory?? attempting to ignore.")
        }
        
        if(unmountDriveAfter)
        {
            let workspace = NSWorkspace()
            workspace.unmountAndEjectDevice(atPath: externalVolumeTextField.stringValue)
        }
        
        let alert = NSAlert()
        alert.addButton(withTitle: "OK")
        alert.alertStyle = NSAlertStyle.informational
        alert.messageText = "All files copied!"
        alert.informativeText = "Now:\n1. Insert the flash drive into your PlayStation 2\n2. Open uLaunchElf\n3. Navigate to the flashdrive and run \(vcdNameWithoutExtension).elf"
        alert.beginSheetModal(for: self.view.window!) { (result: Int) in
            if(self.unmountDriveAfter) //the drives unmounted, might as well close too....
            {
                self.view.window!.close()
            }
        }
    }

}

