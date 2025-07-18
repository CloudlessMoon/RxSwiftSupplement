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
        
        self.test1()
        self.test2()
    }
    
}

extension ExampleViewController {
    
    private func test1() {
        print("开始")
        
        /// 注意以下场景，BehaviorRelayWrapper使用ReadWriteTask set/get-value时
        /// 如果并行队列里set-value，在当前线程（主线程）监听里获取get-value，会导致死锁
        /// ① 在当前线程subscribe(onNext:)会自动执行一次回调，执行BehaviorSubject.synchronized_subscribe，此方法会lock操作
        /// ② 与此同时，set-value会执行BehaviorSubject.synchronized_on，此方法里也会执行lock操作，此时等待①解锁
        /// ① 里会执行get-value，ReadWriteTask.sync，此时会等待②也就是set-value的解锁
        /// 由此可见，①和②相互等待导致死锁，断点可以打到synchronized_on，synchronized_subscribe去查看堆栈
        let queue = DispatchQueue(label: "test", attributes: .concurrent)
        for item in 0...1 {
            queue.async {
                self.name = "\(item)"
            }
        }
        
        self.$name.observable
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                _ = self.name
            })
            .disposed(by: self.rx.disposeBag)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.name = "成功"
            print("\(self.name)")
        }
    }
    
    private func test2() {
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
    
}
