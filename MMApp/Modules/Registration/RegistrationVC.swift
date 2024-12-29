//
//  RegistrationVC.swift
//  MMApp
//
//  Created by artem on 18.12.2024.
//

import Foundation
import  UIKit

class RegistrationVC: UIViewController, SubscriptionStore {
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
    
    func configureLayout() {
        
    }
    
    func bind() {

    }
    
    
}
