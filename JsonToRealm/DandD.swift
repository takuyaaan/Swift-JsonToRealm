//
//  JsonToRealm
//
//  Created by TakuyaMano on 2016/10/11.
//  Copyright © 2016年 Intelligence. All rights reserved.
//

import Foundation
import Cocoa

import Realm
import RealmConverter


class DnDClass: NSImageView, NSDraggingSource {

    var mouseDown: NSEvent?
    var canDrop: Bool = false
    
    override init(frame frameRect: NSRect){
        super.init(frame: frameRect)
        self.registerForDraggedTypes([NSFilenamesPboardType, NSURLPboardType, NSPasteboardTypeTIFF])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //Drag
    func draggingSession(session: NSDraggingSession, sourceOperationMaskForDraggingContext context: NSDraggingContext) -> NSDragOperation {
        return .Delete
    }

    override func mouseDown(theEvent: NSEvent) {
        mouseDown = theEvent
    }

    override func mouseDragged(theEvent: NSEvent) {
        let down = mouseDown!.locationInWindow
        let drag = theEvent.locationInWindow
        let dist = hypot(down.x - drag.x, down.y - drag.y)

        if dist < 5 {
            return
        }

        let img = self.image
        let frameOrigin = convertPoint(down, fromView: nil)
        let frame = NSRect(origin: frameOrigin, size: (img?.size)!).offsetBy(dx: -(75), dy: -(75))

        let item = NSDraggingItem(pasteboardWriter: "Bild geloscht")
        item.draggingFrame = frame
        item.imageComponentsProvider = {
            let component = NSDraggingImageComponent(key: NSDraggingImageComponentIconKey)
            component.contents = img!
            component.frame = NSRect(origin: NSPoint(), size: NSSize(width: 150, height: 150))
            return [component]
        }
        beginDraggingSessionWithItems([item], event: mouseDown!, source: self)
    }

    //Drop
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        if check(sender) {
            canDrop = true
            return .Copy
        }
        else {
            canDrop = false
            return .None
        }
    }
    
    override func draggingUpdated(sender: NSDraggingInfo) -> NSDragOperation {
        if canDrop {
            return .Copy
        }
        else {
            return .None
        }
    }

    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        
        let pboard = sender.draggingPasteboard().propertyListForType(NSFilenamesPboardType)
        let DragFileList:[String] = pboard as! [String]
        Swift.print("DragFileList = \(DragFileList)")
        
        let numberOfFiles = Double(DragFileList.count)
        var loopCount:Double = 1
        for var convertFilePath in DragFileList {
        
            //String
            let DraggedPath = convertFilePath
            Swift.print("DraggedPath = \(DraggedPath)")
        
            //保存先
            let destinationPath = NSString(string: DraggedPath).stringByDeletingLastPathComponent
            Swift.print("destinationPath = \(destinationPath)")
            //ファイル名
            let fileName = NSString(string: DraggedPath).lastPathComponent.componentsSeparatedByString(".")[0]
            Swift.print("fileName = \(fileName)")
        
            //Convert JSON to Realm
            let generator =  ImportSchemaGenerator(file: DraggedPath)
            let schema = try! generator.generate()
            let jsonDataImporter = JSONDataImporter(file: DraggedPath)
            try! jsonDataImporter.importToPath(destinationPath, schema: schema)
    
            //viewC.progressChange((loopCount/numberOfFiles)*100.0)
            Swift.print("loopCount \(loopCount) / \(numberOfFiles) * 100 = \((loopCount / numberOfFiles) * 100)")
            loopCount = loopCount + 1
        }
        
        //viewC.progressChange(0.0)
        return true
    }
    
    func check(drop: NSDraggingInfo) -> Bool {
        if let board = drop.draggingPasteboard().propertyListForType("NSFilenamesPboardType") as? NSArray, let path = board[0] as? String {
            let url = NSURL(fileURLWithPath: path)
            if let suffix = url.pathExtension {
                if suffix == "json" {
                    return true
                }
            }
        
        }
        return false
    }
}



