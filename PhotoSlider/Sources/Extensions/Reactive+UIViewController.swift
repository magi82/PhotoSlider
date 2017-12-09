//
//  Reactive+UIViewController.swift
//  PhotoSlider
//
//  Created by Dooho Chang on 2017. 12. 9..
//  Copyright © 2017년 Dooho Chang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIViewController {
    var viewDidAppear: ControlEvent<Void> {
        let signal = methodInvoked(#selector(Base.viewDidAppear))
            .map { _ in Void() }
            .takeUntil(deallocated)
        
        return ControlEvent(events: signal)
    }
    
    var dismiss: Binder<Void> {
        return Binder(base) { viewController, _ in
            viewController.dismiss(animated: true, completion: nil)
        }
    }
}
