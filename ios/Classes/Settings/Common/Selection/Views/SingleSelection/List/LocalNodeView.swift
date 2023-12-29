// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   LocalNodeView.swift

import Foundation
import SwiftUI
import KeychainAccess

final class LocalNodeView: UIView, UITextFieldDelegate {
    var urlTextField = UITextField()
    var apiKeyTextField = UITextField()
    var portTextField = UITextField()
    
    @AppStorage("urlString") var urlString = ""
    @AppStorage("portString") var portString = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let urlText = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 32))
        urlText.text = "URL"
        urlText.font = UIFont(name: Fonts.DMSans.bold.name, size: 22)
        
        urlTextField = UITextField(frame: CGRect(x: 0, y: 0, width: 400, height: 50))
        urlTextField.placeholder = "192.168.32.0"
        urlTextField.text = urlString
        urlTextField.autocapitalizationType = .none
        urlTextField.keyboardType = .URL
        urlTextField.delegate = self
        urlTextField.font = UIFont(name: Fonts.DMSans.regular.name, size: 16)
        
        let portText = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 32))
        portText.text = "Port"
        portText.font = UIFont(name: Fonts.DMSans.bold.name, size: 22)
        
        portTextField = UITextField(frame: CGRect(x: 0, y: 0, width: 400, height: 50))
        portTextField.placeholder = "1234"
        portTextField.text = portString
        portTextField.delegate = self
        portTextField.keyboardType = .numberPad
        portTextField.font = UIFont(name: Fonts.DMSans.regular.name, size: 16)
        
        let apiKeyText = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 32))
        apiKeyText.text = "API Key"
        apiKeyText.font = UIFont(name: Fonts.DMSans.bold.name, size: 22)
        
        apiKeyTextField = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        apiKeyTextField.placeholder = "XXXXXXXXXXXXX"
        
        let keychain = KeychainAccess.Keychain(service: "com.algorand.algorand.token.private").accessibility(.whenUnlocked)
        let token = keychain.string(for: "algodLocalToken") ?? ""
        
        apiKeyTextField.text = token
        apiKeyTextField.autocapitalizationType = .none
        //apiKeyTextField.isSecureTextEntry = true
        apiKeyTextField.delegate = self
        apiKeyTextField.font = UIFont(name: Fonts.DMSans.regular.name, size: 16)
        
        let spacer = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 8))
        let stackView = UIStackView(arrangedSubviews: [urlText, urlTextField, spacer,
                                                       portText, portTextField, spacer,
                                                       apiKeyText, apiKeyTextField, spacer])
        stackView.spacing = 12
        stackView.axis = .vertical
        
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(0)
            make.leading.equalTo(12)
            make.size.equalTo(400)
       }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.endEditing(true)
        updatedLocalNetValues()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func textFieldDidBeginEditing(textField: UITextField) {
        updatedLocalNetValues()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        updatedLocalNetValues()
        return true
    }

    private func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        return true
    }

    private func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        updatedLocalNetValues()
        
        return true
    }
    
    func updatedLocalNetValues() {
        urlString = urlTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        
        let apiKeyString = apiKeyTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let keychain = KeychainAccess.Keychain(service: "com.algorand.algorand.token.private").accessibility(.whenUnlocked)
         keychain.set(apiKeyString, for: "algodLocalToken")
        
        portString = portTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name.updateLocalNetNotification, object: nil)
    }
}
