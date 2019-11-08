//
//  AuthorizationViewController.swift
//  Tatsi
//
//  Created by Rens Verhoeven on 07/07/2017.
//  Copyright © 2017 Awkward BV. All rights reserved.
//

import UIKit
import Photos

final internal class AuthorizationViewController: UIViewController, PickerViewController {

    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.textColor = self.config?.colors.label ?? TatsiConfig.default.colors.label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy private var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = self.config?.colors.secondaryLabel ?? TatsiConfig.default.colors.secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy private var settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(LocalizableStrings.authorizationViewSettingsButton, for: .normal)
        button.addTarget(self, action: #selector(openSettings(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = "tatsi.button.openSettings"

        let color = self.config?.colors.link ?? TatsiConfig.default.colors.link
        button.setTitleColor(color, for: .normal)
        return button
    }()
    
    lazy private var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [self.titleLabel, self.messageLabel, self.settingsButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.config?.preferredStatusBarStyle ?? .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = self.config?.colors.background ?? TatsiConfig.default.colors.background

        self.setupView()
    }
    
    private func setupView() {
        self.view.addSubview(self.stackView)
        
        self.reloadContents()
        
        self.setupConstraints()
    }
    
    private func setupConstraints() {
        let constraints = [
            self.stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.stackView.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.leadingAnchor),
            self.view.trailingAnchor.constraint(greaterThanOrEqualTo: self.stackView.trailingAnchor),
            self.stackView.widthAnchor.constraint(lessThanOrEqualToConstant: 200)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        PHPhotoLibrary.requestAuthorization { [weak self] (status) in
            DispatchQueue.main.async {
                if status == .authorized {
                    self?.pickerViewController?.setIntialViewController()
                } else {
                    self?.reloadContents()
                }
            }
        }
    }
    
    private func reloadContents() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            self.titleLabel.text = LocalizableStrings.authorizationViewRequestingAccessTitle
            self.messageLabel.text = LocalizableStrings.authorizationViewRequestingAccessMessage
            self.settingsButton.isHidden = true
        case .denied, .restricted:
            self.titleLabel.text = LocalizableStrings.authorizationViewNoAccessTitle
            self.messageLabel.text = LocalizableStrings.authorizationViewNoAccessMessage
            self.settingsButton.isHidden = false
        default:
            break
        }
    }
    
    @objc private func openSettings(_ sender: UIButton) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        
    }

}
