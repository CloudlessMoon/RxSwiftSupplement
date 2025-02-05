//
//  ExampleViewController.swift
//  RxSwiftSupplementExample
//
//  Created by jiasong on 2023/6/1.
//

import UIKit
import RxSwiftSupplement
import RxSwift

class ExampleViewController: UIViewController {
    
    lazy var exampleView: ExampleView = {
        return ExampleView()
    }()
    
    @BehaviorRelayWrapper
    var name: String = "1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.exampleView.$text.observable
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                print("\(self.exampleView.text)")
                print("\(text)")
            })
            .disposed(by: self.rx.disposeBag)
        
        self.exampleView.$text.observable
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                print("\(self.exampleView.text)")
                print("\(text)")
            })
            .disposed(by: self.rx.disposeBag)
        
        self.exampleView.setText("12")
        
        self.$name.observable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                print("name \($0)")
            })
            .disposed(by: self.rx.disposeBag)
        
        for item in 0...1000 {
            self.name = "\(item)"
        }
        for item in 1001...2000 {
            DispatchQueue.global().async {
                self.name = "\(item)"
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.exampleView = ExampleView()
    }
    
}
