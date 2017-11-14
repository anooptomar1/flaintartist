//
//  Session.swift
//  Flaintartist
//
//  Created by Kerby Jean on 11/14/17.
//  Copyright © 2017 Kerby Jean. All rights reserved.
//

import UIKit

class Session: NSObject {
    fileprivate let maxSessionSize = 50
    fileprivate var undoSessionList = [Drawing]()
    fileprivate var redoSessionList = [Drawing]()
    fileprivate var backgroundSession: Drawing?
    
    override init() {
        super.init()
    }
    
    // MARK: - Private Methods
    fileprivate func appendUndo(_ session: Drawing?) {
        if session == nil {
            return
        }
        
        if self.undoSessionList.count >= self.maxSessionSize {
            self.undoSessionList.removeFirst()
        }
        
        self.undoSessionList.append(session!)
    }
    
    fileprivate func appendRedo(_ session: Drawing?) {
        if session == nil {
            return
        }
        
        if self.redoSessionList.count >= self.maxSessionSize {
            self.redoSessionList.removeFirst()
        }
        
        self.redoSessionList.append(session!)
    }
    
    fileprivate func resetUndo() {
        self.undoSessionList.removeAll()
    }
    
    fileprivate func resetRedo() {
        self.redoSessionList.removeAll()
    }
    
    // MARK: - Public Methods
    @objc func lastSession() -> Drawing? {
        if self.undoSessionList.last != nil {
            return self.undoSessionList.last
        } else if self.backgroundSession != nil {
            return self.backgroundSession
        }
        
        return nil
    }
    
    @objc func appendBackground(_ session: Drawing?) {
        if session != nil {
            self.backgroundSession = session
        }
    }
    
    @objc func append(_ session: Drawing?) {
        self.appendUndo(session)
        self.resetRedo()
    }
    
    @objc func undo() {
        let lastSession = self.undoSessionList.last
        if (lastSession != nil) {
            self.appendRedo(lastSession!)
            self.undoSessionList.removeLast()
        }
    }
    
    @objc func redo() {
        let lastSession = self.redoSessionList.last
        if (lastSession != nil) {
            self.appendUndo(lastSession!)
            self.redoSessionList.removeLast()
        }
    }
    
    @objc func clear() {
        self.resetUndo()
        self.resetRedo()
    }
    
    @objc func canUndo() -> Bool {
        return self.undoSessionList.count > 0
    }
    
    @objc func canRedo() -> Bool {
        return self.redoSessionList.count > 0
    }
    
    @objc func canReset() -> Bool {
        return (self.canUndo() || self.canRedo())
    }
}
