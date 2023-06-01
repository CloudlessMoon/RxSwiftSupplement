//
//  ViewController.swift
//  RxPropertyWrapperExample
//
//  Created by jiasong on 2023/6/1.
//

import UIKit
import RxPropertyWrapper
import RxSwift

class ExampleViewController: UIViewController {
    
    lazy var exampleView: ExampleView = {
        return ExampleView()
    }()
    
    fileprivate var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.exampleView.$text
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { text in
                print("\(text)")
            })
            .disposed(by: self.disposeBag)
        
        self.exampleView.setText("12")
    }
    
}

