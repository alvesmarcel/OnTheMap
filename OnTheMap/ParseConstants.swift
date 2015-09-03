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
	
	struct Constants {

		// URLs
		static let ParseBaseUrl : String = "https://api.parse.com/1/classes/"
		
		static let AppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
		static let ApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
	}
	
	struct Methods {
		
		static let StudentLocation : String = "StudentLocation"
	}
	
	struct ParameterKeys {
		static let Limit = "limit"
		static let Skip = "skip"
	}
	
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
	
	struct JSONResponseKeys {
		static let Results = "results"
		
		static let ObjectID = "objectId"
		static let UniqueKey = "uniqueKey"
		static let FirstName = "firstName"
		static let LastName = "lastName"
		static let MapString = "mapString"
		static let MediaURL = "mediaURL"
		static let Latitude = "latitude"
		static let Longitude = "longitude"
	}
	
	struct HTTPHeaderField {
		static let AppID = "X-Parse-Application-Id"
		static let ApiKey = "X-Parse-REST-API-Key"
	}
}