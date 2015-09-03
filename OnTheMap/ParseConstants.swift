//
//  ParseConstants.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 8/26/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  Extension of class ParseClient
//  All the constants used in the API are set here

extension ParseClient {
	
	// MARK: - Constants
	struct Constants {

		// MARK: - URLs
		static let ParseBaseUrl : String = "https://api.parse.com/1/classes/"
		
		// MARK: - AppID and APIKey
		static let AppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
		static let APIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
	}
	
	// MARK: - Methods
	struct Methods {
		
		static let StudentLocation : String = "StudentLocation"
	}
	
	// MARK: - Parameter Keys
	struct ParameterKeys {
		static let Limit = "limit"
		static let Skip = "skip"
	}
	
	// MARK: - JSON Body Keys
	struct JSONBodyKeys {
		
		static let ObjectID = "objectId"
		static let UniqueKey = "uniqueKey"
		static let FirstName = "firstName"
		static let LastName = "lastName"
		static let MapString = "mapString"
		static let MediaURL = "mediaURL"
		static let Latitude = "latitude"
		static let Longitude = "longitude"
	}
	
	// MARK: - JSON Response Keys
	struct JSONResponseKeys {
		static let Results = "results"
	}
	
	// MARK: - HTTP Header Fields
	struct HTTPHeaderField {
		static let AppID = "X-Parse-Application-Id"
		static let ApiKey = "X-Parse-REST-API-Key"
	}
}