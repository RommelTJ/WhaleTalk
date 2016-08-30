//
//  SignUpViewController.swift
//  WhaleTalk
//
//  Created by Rommel Rico on 8/29/16.
//  Copyright © 2016 Rommel Rico. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    private let phoneNumberField = UITextField()
    private let emailField = UITextField()
    private let passwordField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.whiteColor()
        
        let label = UILabel()
        label.text = "Sign up with WhaleTalk"
        label.font = UIFont.systemFontOfSize(24)
        view.addSubview(label)
        
        let continueButton = UIButton()
        continueButton.setTitle("Continue", forState: .Normal)
        continueButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        continueButton.addTarget(self, action: #selector(SignUpViewController.pressedContinue(_:)), forControlEvents: .TouchUpInside)
        view.addSubview(continueButton)
        
        phoneNumberField.keyboardType = .PhonePad
        label.translatesAutoresizingMaskIntoConstraints = false
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        
        let fields = [
            (phoneNumberField, "Phone Number"),
            (emailField, "Email"),
            (passwordField, "Password")
        ]
        fields.forEach {
            $0.0.placeholder = $0.1
        }
        
        passwordField.secureTextEntry = true
        
        let stackView = UIStackView(arrangedSubviews: fields.map{$0.0})
        stackView.axis = .Vertical
        stackView.alignment = .Fill
        stackView.spacing = 20
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pressedContinue(sender: UIButton) {
        //TODO
    }

}
