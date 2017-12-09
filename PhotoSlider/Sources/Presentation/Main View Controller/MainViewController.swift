//
//  MainViewController.swift
//  PhotoSlider
//
//  Created by Dooho Chang on 2017. 12. 9..
//  Copyright © 2017년 Dooho Chang. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

protocol MainViewControllerBindable {
    // States
    var durationValueLabelText: Driver<String?> { get }
    var presentAlbum: Signal<AlbumViewControllerBindable> { get }
    
    // Actions
    var increaseButtonTapped: PublishSubject<Void> { get }
    var decreaseButtonTapped: PublishSubject<Void> { get }
    var enterButtonTapped: PublishSubject<Void> { get }
}

protocol ContainerForMainViewController {
    func albumViewController() -> AlbumViewController
}

class MainViewController: UIViewController {
    var disposeBag = DisposeBag()
    
    let container: ContainerForMainViewController
    
    let titleLabel = UILabel()
    let durationTitleLabel = UILabel()
    let durationValueLabel = UILabel()
    let increaseButton = UIButton()
    let decreaseButton = UIButton()
    let enterButton = UIButton()
    
    init(container: ContainerForMainViewController) {
        self.container = container
        super.init(nibName: nil, bundle: nil)
    }
    
    func bind(_ viewModel: MainViewControllerBindable) {
        self.disposeBag = DisposeBag()
        
        // States
        viewModel.durationValueLabelText
            .drive(durationValueLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.presentAlbum
            .emit(to: self.rx.presentAlbum)
            .disposed(by: disposeBag)
        
        // Actions
        increaseButton.rx.tap
            .bind(to: viewModel.increaseButtonTapped)
            .disposed(by: disposeBag)
        
        decreaseButton.rx.tap
            .bind(to: viewModel.decreaseButtonTapped)
            .disposed(by: disposeBag)
        
        enterButton.rx.tap
            .bind(to: viewModel.enterButtonTapped)
            .disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
    }
    
    private func layout() {
        view.backgroundColor = .white
        titleLabel.text = "Photo Slider"
        titleLabel.font = .systemFont(ofSize: 30, weight: .bold)
        
        durationTitleLabel.text = "한 사진 당 보이는 시간을 설정하세요(1 ~ 10초)"
        durationTitleLabel.font = .systemFont(ofSize: 14)
        
        durationValueLabel.font = .systemFont(ofSize: 16)
        
        increaseButton.setTitle("▲", for: .normal)
        decreaseButton.setTitle("▼", for: .normal)
        [increaseButton, decreaseButton].forEach {
            $0.titleLabel?.font = .systemFont(ofSize: 30)
            $0.setTitleColor(.black, for: .normal)
            $0.setTitleColor(.red, for: .highlighted)
        }
        
        enterButton.setTitle("시작하기", for: .normal)
        enterButton.titleLabel?.font = .systemFont(ofSize: 20)
        enterButton.backgroundColor = UIColor.blue.withAlphaComponent(0.6)
        enterButton.contentEdgeInsets = .init(top: 7, left: 10, bottom: 7, right: 10)
        enterButton.clipsToBounds = true
        enterButton.layer.cornerRadius = 3
        
        let centerView = UIView()
        [titleLabel, durationTitleLabel, durationValueLabel, increaseButton, decreaseButton, enterButton]
            .forEach { centerView.addSubview($0) }
        
        view.addSubview(centerView)
        
        centerView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.right.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
        }
        
        durationTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
        
        increaseButton.snp.makeConstraints {
            $0.top.equalTo(durationTitleLabel.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
        
        durationValueLabel.snp.makeConstraints {
            $0.top.equalTo(increaseButton.snp.bottom).offset(2)
            $0.centerX.equalToSuperview()
        }
        
        decreaseButton.snp.makeConstraints {
            $0.top.equalTo(durationValueLabel.snp.bottom).offset(2)
            $0.centerX.equalToSuperview()
        }
        
        enterButton.snp.makeConstraints {
            $0.top.equalTo(decreaseButton.snp.bottom).offset(10)
            $0.centerX.bottom.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Reactive where Base: MainViewController {
    var presentAlbum: Binder<AlbumViewControllerBindable> {
        return Binder(base) { base, albumViewModel in
            let albumViewController = base.container.albumViewController()
                .then { $0.bind(albumViewModel) }
            
            base.present(albumViewController, animated: true, completion: nil)
        }
    }
}
