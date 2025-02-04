//
//  ViewController.swift
//  MMText
//
//  Created by MillmanY on 06/01/2019.
//  Copyright (c) 2019 MillmanY. All rights reserved.
//

import UIKit
import MMText

class ViewController: UIViewController {
    @IBOutlet weak var txtAccount1: MMTextField!
    @IBOutlet weak var txtPwd1: MMTextField!
    @IBOutlet weak var txtAccount2: MMTextField!
    @IBOutlet weak var txtPwd2: MMTextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtAccount1.delegate = self
        txtPwd2.lineType = .right
        txtAccount2.lineType = .center
        txtAccount1.errorFont = UIFont(name: "PingFangTC-Regular", size: 12.0)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func errorAction() {
        txtPwd1.errorTitle = "Mutiple line error\nMutiple line error\nMutiple line error\nMutiple line error"
        txtAccount1.errorTitle = "Your account is error"
//
        txtAccount2.errorTitle = "Your account is error"
        txtPwd2.errorTitle = "Mutiple line error\nMutiple line error\nMutiple line error\nMutiple line error"
    }
    
    @IBAction func clearAction() {
        txtAccount1.errorTitle = nil
        txtPwd1.errorTitle = nil
        txtAccount2.errorTitle = nil
        txtPwd2.errorTitle = nil
    }
    
    @IBAction func inputBorderAction() {
        txtAccount1.inputViewStyle = .border
        txtPwd1.inputViewStyle = .border
        txtAccount2.inputViewStyle = .border
        txtPwd2.inputViewStyle = .border

    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ViewController: MMTextFieldProtocol {
    func textLayoutChanged(text: MMTextField) {
        
    }
}
