//
//  AddressAutoCompleteTableViewController.swift
//  GooglePlacesAutoPopover
//
//  Created by James on 3/12/20.
//  Copyright © 2020 James Syvertsen. All rights reserved.
//

import UIKit

class AddressAutoCompleteTableViewController: UITableViewController {
    
    var googleAutoComplete: GoogleAutoComplete?
    
    weak var delegate: AddressAutoCompleteTableViewControllerDelegate?
        
    init(apiKey: String, predictionLimit: Int = 10) {
        super.init(style: UITableView.Style.plain)
        googleAutoComplete = GoogleAutoComplete(apiKey: apiKey, predictionLimit: predictionLimit)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self as UITableViewDataSource
        tableView.delegate = self as UITableViewDelegate
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return googleAutoComplete?.predictionList.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else { return UITableViewCell() }
        
        cell.textLabel?.textColor = UIColor.gray
        cell.textLabel?.text = googleAutoComplete?.predictionList[indexPath.row]
        cell.backgroundColor = .clear
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        googleAutoComplete?.getPlace(atIndex: indexPath.row, completion: { [weak self] (place) in
            
            DispatchQueue.main.async {
                
                guard let self = self else { return }
                
                self.selectAddress(place)
                
                // reset session token after place detail request is selected
                self.googleAutoComplete?.setSessionID()
            }
            
            }, failure: { error in
                
                let error: String = "Place Selection Error"
                
                debugPrint(error)
        })
    }
    
    ///
    /// Get address predictions and update tableView.
    ///
    func updateAddresses(_ address: String) {
        
        googleAutoComplete?.updateAddressPredictions(textInput: address, completion: { [weak self] _ in
            
            DispatchQueue.main.async {
                
                guard let self = self else { return }
                
                self.tableView.reloadData()
            }
            
            }, failure: { (_) in
                
                DispatchQueue.main.async {
                    
                    if !address.isEmpty {
                        
                        let error: String = "Error Updating Predictions - Address Prediction Error"
                        
                        debugPrint("Address Prediction Error: ", error)
                    }
                }
        })
    }
    
    ///
    /// Inform delegate of address selection and clear prediction list and table view
    ///
    func selectAddress(_ address: Place) {
        
        // inform text field that address was selected
        delegate?.addressAutoCompleteTableViewController(self, didSelectAddress: address)

        googleAutoComplete?.predictionList = []
        tableView?.reloadData()
    }
}

