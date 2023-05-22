
/*
 * Copyright 2022 Korea University(os.korea.ac.kr). All rights reserved.
 *
 * HeartBeat - Digital Health Platform Project
 *
 */


import UIKit

extension UIViewController {
    // Executes the provided closure on the current view controller
    // and on all of its descendants in the view controller hierarchy.
    func enumerateHierarchy(_ closure: (UIViewController) -> Void) {
        closure(self)
        
        for child in children {
            child.enumerateHierarchy(closure)
        }
    }
}

