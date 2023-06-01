//
//  ExampleView.swift
//  RxPropertyWrapperExample
//
//  Created by jiasong on 2023/6/1.
//

import UIKit
import RxPropertyWrapper
import RxSwift

class ExampleView: UIView {
    
    @BehaviorRelayed fileprivate(set) var text: String = "1"
    
}

extension ExampleView {
    
    func setText(_ text: String) {
        self.text = text
    }
    
}
