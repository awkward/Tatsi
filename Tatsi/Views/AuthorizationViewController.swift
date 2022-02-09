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
    label.textColor = config?.colors.label ?? TatsiConfig.default.colors.label
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  lazy private var messageLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    label.textAlignment = .center
    label.font = UIFont.preferredFont(forTextStyle: .body)
    label.textColor = config?.colors.secondaryLabel ?? TatsiConfig.default.colors.secondaryLabel
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  lazy private var settingsButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle(LocalizableStrings.authorizationViewSettingsButton, for: .normal)
    button.addTarget(self, action: #selector(openSettings(_:)), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.accessibilityIdentifier = "tatsi.button.openSettings"
    
    let color = config?.colors.link ?? TatsiConfig.default.colors.link
    button.setTitleColor(color, for: .normal)
    return button
  }()
  
  lazy private var stackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [titleLabel, messageLabel, settingsButton])
    stackView.axis = .vertical
    stackView.spacing = 10
    stackView.translatesAutoresizingMaskIntoConstraints = false
    
    return stackView
  }()
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return config?.preferredStatusBarStyle ?? .default
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = config?.colors.background ?? TatsiConfig.default.colors.background
    
    setupView()
  }
  
  private func setupView() {
    view.addSubview(stackView)
    
    reloadContents()
    
    setupConstraints()
  }
  
  private func setupConstraints() {
    let constraints = [
      stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      stackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor),
      view.trailingAnchor.constraint(greaterThanOrEqualTo: stackView.trailingAnchor),
      stackView.widthAnchor.constraint(lessThanOrEqualToConstant: 200)
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
      titleLabel.text = LocalizableStrings.authorizationViewRequestingAccessTitle
      messageLabel.text = LocalizableStrings.authorizationViewRequestingAccessMessage
      settingsButton.isHidden = true
    case .denied, .restricted:
      titleLabel.text = LocalizableStrings.authorizationViewNoAccessTitle
      messageLabel.text = LocalizableStrings.authorizationViewNoAccessMessage
      settingsButton.isHidden = false
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
