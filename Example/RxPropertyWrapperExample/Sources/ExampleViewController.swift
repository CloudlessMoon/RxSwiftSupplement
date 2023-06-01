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
        self.view.backgroundColor = .white
        
        self.exampleView.$text
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                print("\(self.exampleView.text)")
                print("\(text)")
            })
            .disposed(by: self.disposeBag)
        
        self.exampleView.setText("12")
    }
    
}

