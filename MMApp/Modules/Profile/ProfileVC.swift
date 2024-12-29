//
//  ProfileVC.swift
//  MMApp
//
//  Created by artem on 18.12.2024.
//

import UIKit
import SnapKit
import Combine
import WebKit

class ProfileVC: UIViewController, SubscriptionStore {
    // MARK: Live cicle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureLayout()
        bind()
        self.view.backgroundColor = .gray
    }
    
    //  MARK: Private propertis
    private let contentView = UIView().apply {
        $0.backgroundColor = .systemIndigo
        $0.setCornerRadius(8)
    }
    
    private let testLabel = UILabel().apply {
        $0.text = "Text"
        $0.backgroundColor = .red
        $0.setCornerRadius(4)
        
    }
    
    private func bind() {
        testLabel.publisher
            .handleEvents(
                receiveSubscription: {_ in
                    print("Neshko receiveSubscription")
                },
                receiveOutput: {_ in
                    print("Neshko receiveOutput")
                },
                receiveCompletion: {_ in
                    print("Neshko receiveCompletion")
                },
                receiveCancel: {
                    print("Neshko receiveCancel")
                },
                receiveRequest: {_ in
                    print("Neshko receiveRequest")
                }
            )
            .sink{ [weak self] _ in
                print("Neshko Hui")
                
            }
            .store(in: &subscriptions)
        
        contentView.publisher
            .handleEvents(
                receiveSubscription: {_ in
                    print("0Neshko receiveSubscription")
                },
                receiveOutput: {_ in
                    print("0Neshko receiveOutput")
                },
                receiveCompletion: {_ in
                    print("0Neshko receiveCompletion")
                },
                receiveCancel: {
                    print("0Neshko receiveCancel")
                },
                receiveRequest: {_ in
                    print("0Neshko receiveRequest")
                }
            )
            .sink{ [weak self] _ in
                print("Neshko Hui")
            }
            .store(in: &subscriptions)
    }
    
    private func configureViews() {
        contentView.addSubviews(testLabel)
        view.addSubviews(contentView)
    }
    
    private func configureLayout() {
        configureViews()
        
        contentView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(self.view.snp.centerY).offset(50)
        }
        
        testLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(16)
        }
    }
}
