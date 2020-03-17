//
//  GoogleAutoComplete.swift
//  GooglePlacesAutoPopover
//
//  Created by James on 3/12/20.
//  Copyright © 2020 James Syvertsen. All rights reserved.
//

import Foundation
import GooglePlaces
import GoogleMapsBase

// MARK: - Typealias PlacePrediction -

typealias PlacePrediction = String

// MARK: - Struct Place -

struct Place {
    
    let political, locality, subpremise, premise, sublocality2, streetNumber, streetName, city, state, country, zipCode: String
    
    var streetAddress: String { return streetNumber + " " + streetName + "" + political + "" + locality + "" + sublocality2 + "" + subpremise + "" + premise }
}

// MARK: - Class GoogleAutoComplete -

final class GoogleAutoComplete {
    
    // MARK: - Private Members -
    
    private let predictionLimit: Int
    
    private var sessionToken: GMSAutocompleteSessionToken?
    
    private var addressFilter: GMSAutocompleteFilter?
    
    // MARK: - Public Members -
    
    public var googleAutoCompleteKeyOK: Bool = true
    
    public var predictionList: [PlacePrediction] = []
    
    public var placePredictionList: [GMSAutocompletePrediction] = []
    
    // MARK: - Initializers -
    
    init(apiKey: String, predictionLimit: Int = 10) {
        
        GMSPlacesClient.provideAPIKey(apiKey)
        
        self.predictionLimit = predictionLimit
        
        self.sessionToken = GMSAutocompleteSessionToken.init()

        self.addressFilter = GMSAutocompleteFilter()
        self.addressFilter?.type = .noFilter
    }
    
    // MARK: - Public Methods -
    
    ///
    /// Set session id
    ///
    func setSessionID() {
        sessionToken = GMSAutocompleteSessionToken.init()
    }
    
    ///
    /// Get address predictions from google based on textInput provided. If unable to get new predictions, the old list is passed in completion handler along with an error object.
    ///
    /// - parameter textInput: Text value to get addresses for.
    /// - parameter completion: Completion handler containing list of predictions and optional error object.
    ///
    func updateAddressPredictions(textInput: String, completion: @escaping ClosureWithListOfPlacePredictions, failure: @escaping ClosureWithError) {
        
        guard !textInput.isEmpty else {
            failure("address search text is empty")
            return
        }
        
        if googleAutoCompleteKeyOK {
            
            if let sessionToken = sessionToken {
                
                GMSPlacesClient.shared().findAutocompletePredictions(fromQuery: textInput, bounds: nil, boundsMode: GMSAutocompleteBoundsMode.bias, filter: addressFilter, sessionToken: sessionToken, callback: { (results, error) in
                    
                    guard error == nil, let results = results else {
                        
                        completion(self.predictionList)
                        return
                    }
                    
                    // save predictions based on limit
                    self.placePredictionList = Array(results.prefix(upTo: min(results.count, self.predictionLimit)))
                    self.predictionList = self.placePredictionList.map { $0.attributedFullText.string }
                    
                    completion(self.predictionList)
                })
            }
        }
    }
    
    ///
    /// Get Place at specified index in predictions list, as a Place struct.
    ///
    /// - parameter completion: Completion handler containing Place struct.
    /// - parameter failure: Failure handler containing KWIError.
    ///
    func getPlace(atIndex index: Int, completion: @escaping ClosureWithPlace, failure: @escaping ClosureWithError) {
        
        let placeID = placePredictionList[index].placeID
        
        guard !placeID.isEmpty  else {
            
            failure("getPlace failure")
            return
        }

        
        if let sessionToken = sessionToken {
            
            // specify the place data types to return
            let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.addressComponents.rawValue) | UInt(GMSPlaceField.placeID.rawValue))!
            
            GMSPlacesClient.shared().fetchPlace(fromPlaceID: placeID, placeFields: fields, sessionToken: sessionToken, callback: {
                (place: GMSPlace?, error: Error?) in

                if error != nil {
                    failure("placeDetails request failure")
                    return
                }
                
                guard let place = place, let addressComponents = place.addressComponents else {
                    failure("placeDetails request failure")
                    return
                }
                    
                guard let selectedPlace = self.buildPlace(withAddressComponents: addressComponents) else { return }
                    
                completion(selectedPlace)
            })
        }
    }
    
    ///
    /// Build Place struct from address components.
    ///
    /// - parameter addressComponents: struct of components returned from google.
    ///
    /// - returns: Place struct containing address data.
    ///
    func buildPlace(withAddressComponents addressComponents: [GMSAddressComponent]) -> Place? {
    
        // Required
        var streetNumber: String?
        var streetName: String?
        var sublocality2: String?
        var sublocality: String?
        var political: String?
        var subpremise: String?
        var premise: String?
        
        // Optional
        var city = ""
        var state = ""
        var country = ""
        var zipCode = ""
        
        for component in addressComponents {
            
            switch component.types.count > 0 ? component.types[0] : "" {
            case "subpremise": subpremise = component.name
            case "premise": premise = component.name
            case "sublocality_level_2": sublocality2 = component.name
            case "sublocality": sublocality = component.name
            case "political": political = component.name
            case "street_number": streetNumber = component.name
            case "route": streetName = component.name
            case "locality": city = component.name
            case "neighborhood": city = component.name
            case "administrative_area_level_1": state = component.shortName?.uppercased() ?? ""
            case "country": country = component.shortName ?? ""
            case "postal_code": zipCode = component.shortName ?? ""
            default: break
            }
        }
        
        return Place(
            political: political ?? "", locality: sublocality ?? "", subpremise: subpremise ?? "", premise: premise ?? "",  sublocality2: sublocality2 ?? "" , streetNumber: streetNumber ?? "", streetName: streetName ?? "", city: city, state: state, country: country, zipCode: zipCode)
    }
}


