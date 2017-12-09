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
    // Properties for View
    var photoSliderViewModel: PhotoSliderViewBindable { get }
    
    // View Actions
    var viewDidAppear: PublishSubject<Void> { get }
}

class AlbumViewController: UIViewController {
    private var disposeBag = DisposeBag()
    
    let photoSliderView: PhotoSliderView
    
    init(photoSliderView: PhotoSliderView) {
        self.photoSliderView = photoSliderView
        super.init(nibName: nil, bundle: nil)
    }
    
    func bind(_ viewModel: AlbumViewControllerBindable) {
        self.disposeBag = DisposeBag()
        
        photoSliderView.bind(viewModel.photoSliderViewModel) // Bind subview
        
        self.rx.viewDidAppear
            .bind(to: viewModel.viewDidAppear)
            .disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
    }
    
    private func layout() {
        view.backgroundColor = .black
        photoSliderView.contentMode = .scaleAspectFit
        
        view.addSubview(photoSliderView)
        
        photoSliderView.snp.makeConstraints {
            $0.top.equalTo(topLayoutGuide.snp.bottom)
            $0.bottom.equalTo(bottomLayoutGuide.snp.top)
            $0.left.right.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
