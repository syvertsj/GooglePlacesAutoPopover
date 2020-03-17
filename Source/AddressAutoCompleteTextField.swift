//
//  AddressAutoCompleteTextField.swift
//  GooglePlacesAutoPopover
//
//  Created by James on 3/12/20.
//  Copyright © 2020 James Syvertsen. All rights reserved.
//

import UIKit

class AddressAutoCompleteTextField: UITextField {
    
    var addressAutoCompleteTableViewController: AddressAutoCompleteTableViewController?
    
    weak var addressAutoCompleteDelegate: AddressAutoCompleteDelegate?
    
    var hostViewController: UIViewController?
    
    func initialize(hostViewController: UIViewController, apiKey: String) {
        
        guard !apiKey.isEmpty else { return }
        
        addressAutoCompleteTableViewController = AddressAutoCompleteTableViewController(apiKey: apiKey)
        
        delegate = self //as? UITextFieldDelegate
        
        addressAutoCompleteDelegate = self as? AddressAutoCompleteDelegate  // can replace with host view controller
        
        addressAutoCompleteTableViewController?.delegate = self
        
        self.hostViewController = hostViewController
        
        configureTextField()
    }
    
    func configureTextField() {
        
        placeholder = "Address"
        backgroundColor = UIColor(red: 246.0/255.0, green: 246.0/255.0, blue: 246.0/255.0, alpha: 1.0)
        textColor = UIColor.black
        clearButtonMode = ViewMode.always
    }
    
    func showPopover() {
        
        addressAutoCompleteTableViewController?.modalPresentationStyle = UIModalPresentationStyle.popover
        
        guard let popover: UIPopoverPresentationController = addressAutoCompleteTableViewController?.popoverPresentationController else { return }
        
        popover.delegate = hostViewController as? UIPopoverPresentationControllerDelegate
        popover.sourceView = self
        popover.sourceRect = self.bounds
        
        addressAutoCompleteTableViewController?.preferredContentSize = CGSize(width: self.frame.width, height: self.frame.height * 4)
        
        if let aavc = addressAutoCompleteTableViewController, let sourceVC = hostViewController {
            presentPopover(presentingViewController: sourceVC, popover: aavc)
        }
    }
    
    func presentPopover(presentingViewController: UIViewController, popover: UIViewController) {
        
        presentingViewController.present(popover, animated: true, completion: nil)
    }
    
    func dismissPopover() {
        
        if let aavc = addressAutoCompleteTableViewController {
            aavc.dismiss(animated: true, completion: {})
        }
    }
    
    func setTextField(_ addressString: String) {
        
        guard !addressString.isEmpty else { return }
        
        self.text = addressString
    }
}

// MARK: - UITextFieldDelegate -

extension AddressAutoCompleteTextField: UITextFieldDelegate {
    
    //func textFieldDidBeginEditing(_ textField: UITextField) {}
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = (textField.text?.isEmpty ?? false) ? string : textField.text, !text.isEmpty else { return true }
        
        if text.count == 1 && string.isEmpty {
            dismissPopover()
        }
        
        // invoke text update handling in table view controller
        addressAutoCompleteTableViewController?.updateAddresses(text)
        
        if addressAutoCompleteTableViewController?.presentingViewController == nil {
            showPopover()
        }
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        
        // invoke host view controller action
        addressAutoCompleteDelegate?.addressAutoCompleteTextFieldDidClear(self)
        
        return true
    }
    
    //func textFieldDidEndEditing(_ textField: UITextField) {}
}

// MARK: - AddressAutoCompleteTextFieldDelegate -


extension AddressAutoCompleteTextField: AddressAutoCompleteTableViewControllerDelegate {
    
    /// invoke action in host view controller upon address selection
    ///
    func addressAutoCompleteTableViewController(_ tableViewController: AddressAutoCompleteTableViewController, didSelectAddress address: Place) {
        addressAutoCompleteDelegate?.addressAutoCompleteTextField(self, didSelectAddress: address)
    }
}

// MARK: - AddressAutoCompleteDelegate -
// note: these are not necessary for this text field class, but for a hosting view or view controller
extension AddressAutoCompleteTextField: AddressAutoCompleteDelegate {

    func addressAutoCompleteTextField(_ textField: AddressAutoCompleteTextField, didSelectAddress address: Place) {

        setTextField(address.streetAddress + ", " + address.city + ", " + address.state + ", " + address.zipCode)
        dismissPopover()
    }

    func addressAutoCompleteTextFieldDidClear(_ textField: AddressAutoCompleteTextField) {
        self.text = ""
    }
}


