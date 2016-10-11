//
//  JsonToRealm
//
//  Created by TakuyaMano on 2016/10/11.
//  Copyright © 2016年 Intelligence. All rights reserved.
//

import Cocoa
import Realm
import RealmConverter


class ViewController: NSViewController {

    @IBOutlet weak var convertProgress: NSProgressIndicator!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tmpPath = "/tmp"
        let Fmanager = NSFileManager.defaultManager()
        
        var isDir :ObjCBool = false
        
        let isFile = Fmanager.fileExistsAtPath(tmpPath, isDirectory: &isDir)
        
        if !isDir {
            try! Fmanager.createDirectoryAtPath(tmpPath, withIntermediateDirectories: true, attributes: nil)
        }
        
        convertProgress.doubleValue = 0
        // Do any additional setup after loading the view.
    }

    func progressChange(progVal: Double) -> Void {
        convertProgress.doubleValue = progVal
        return
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

