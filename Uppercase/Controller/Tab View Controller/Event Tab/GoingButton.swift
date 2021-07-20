//
//  GoingButton.swift
//  Uppercase
//
//  Created by The Techy Hub on 08/01/2018.
//  Copyright © 2018 The Techy Hub. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

var event : Event?

class GoingButton: UIButton {

    var isGoing = goingState
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initButton()
    }
    
    func initButton() {
        setTitleColor(UIColor.white, for: .normal)
        
        addTarget(self, action: #selector(GoingButton.buttonPressed), for: .touchUpInside)
    }
    
    @objc func buttonPressed() {
        activateButton(bool: !isGoing)
    }
    
    func activateButton(bool: Bool) {
        isGoing = bool
        
        let color = bool ? UIColor.green : UIColor.red
        let title = bool ? "I am going!" : "I am NOT going"
        let titleColor = bool ? UIColor.black : UIColor.white
        goingState = bool ? true : false
    
        print("Current state is: \(goingState)")
        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        backgroundColor = color
    }
    
}

