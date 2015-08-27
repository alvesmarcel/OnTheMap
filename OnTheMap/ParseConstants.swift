//
//  ParseConstants.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 8/26/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//

extension ParseClient {
	
	struct ErrorMessages {

	}
	
	struct Constants {

		// URLs
		static let parseBaseUrl : String = "https://api.parse.com/1/classes/"
		
		static let appID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
		static let apiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
	}
	
	struct Methods {
		
		static let studenteLocation : String = "StudentLocation"
	}
	
	struct JSONResponseKeys {
		static let status = "status"
		static let session = "session"
		static let sessionID = "id"
		static let account = "account"
		static let key = "key"
	}
	
	struct StatusResponse {
		static let emptyField = 400
		static let invalidField = 403
	}
}