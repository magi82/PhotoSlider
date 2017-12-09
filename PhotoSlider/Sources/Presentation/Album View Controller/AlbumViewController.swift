//
//  AlbumViewController.swift
//  PhotoSlider
//
//  Created by Dooho Chang on 2017. 12. 9..
//  Copyright © 2017년 Dooho Chang. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

protocol AlbumViewControllerBindable {
    var photoSliderViewModel: PhotoSliderViewBindable { get } // property for subview binding
    
    // States
    var isLoading: Driver<Bool> { get }
    var dismiss: Signal<Void> { get }
    
    // Actions
    var viewDidAppear: PublishSubject<Void> { get }
    var exitButtonTapped: PublishSubject<Void> { get }
}

class AlbumViewController: UIViewController {
    private var disposeBag = DisposeBag()
    
    let photoSliderView: PhotoSliderView
    
    let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    let exitButton = UIButton()
    
    init(photoSliderView: PhotoSliderView) {
        self.photoSliderView = photoSliderView
        super.init(nibName: nil, bundle: nil)
    }
    
    func bind(_ viewModel: AlbumViewControllerBindable) {
        self.disposeBag = DisposeBag()
        
        photoSliderView.bind(viewModel.photoSliderViewModel) // bind subview
        
        // States
        viewModel.isLoading
            .drive(self.rx.isLoading)
            .disposed(by: disposeBag)
        
        viewModel.dismiss
            .emit(to: self.rx.dismiss)
            .disposed(by: disposeBag)
        
        // Actions
        self.rx.viewDidAppear
            .bind(to: viewModel.viewDidAppear)
            .disposed(by: disposeBag)
        
        exitButton.rx.tap
            .bind(to: viewModel.exitButtonTapped)
            .disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
    }
    
    private func layout() {
        view.backgroundColor = .black
        photoSliderView.contentMode = .scaleAspectFit
        exitButton.setTitle("Exit", for: .normal)
        
        view.addSubview(photoSliderView)
        view.addSubview(loadingIndicator)
        view.addSubview(exitButton)
        
        photoSliderView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        loadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        exitButton.snp.makeConstraints {
            $0.top.equalTo(topLayoutGuide.snp.bottom).offset(4)
            $0.right.equalToSuperview().inset(16)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Reactive where Base: AlbumViewController {
    var isLoading: Binder<Bool> {
        return Binder(base.loadingIndicator) { indicator, isLoading in
            indicator.isHidden = !isLoading
            
            if isLoading {
                indicator.startAnimating()
            } else {
                indicator.stopAnimating()
            }
        }
    }
}
