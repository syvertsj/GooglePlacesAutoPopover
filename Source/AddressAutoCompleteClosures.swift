//
//  AddressAutoCompleteClosures.swift
//  GooglePlacesAutoPopover
//
//  Created by James on 3/12/20.
//  Copyright © 2020 James Syvertsen. All rights reserved.
//

typealias ClosureWithError = (_ error: String) -> Void
typealias ClosureWithListOfPlacePredictions = (_ placePredictionList: [PlacePrediction]) -> Void
typealias ClosureWithPlace = (_ place: Place) -> Void
