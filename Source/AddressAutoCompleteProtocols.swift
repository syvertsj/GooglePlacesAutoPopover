//
//  AddressAutoCompleteProtocols.swift
//  GooglePlacesAutoPopover
//
//  Created by James on 3/12/20.
//  Copyright © 2020 James Syvertsen. All rights reserved.
//

// implemented by text field to respond to address selections
protocol AddressAutoCompleteTableViewControllerDelegate: class {
    func addressAutoCompleteTableViewController(_ tableViewController: AddressAutoCompleteTableViewController, didSelectAddress address: Place)
}

// implemented by host view controller
protocol AddressAutoCompleteDelegate: class {
    func addressAutoCompleteTextField(_ textField: AddressAutoCompleteTextField, didSelectAddress address: Place)
    func addressAutoCompleteTextFieldDidClear(_ textField: AddressAutoCompleteTextField)
}
