//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 8/24/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//

extension UdacityClient {
	
	struct Constants {
		
		/* Button tags */
		static let udacityLoginButtonTag : Int = 1
		static let facebookLoginButtonTag : Int = 2
		
		// URLs
		static let udacityBaseUrl : String = "https://www.udacity.com/api/"
		
	}
	
	struct Methods {
		
		static let udacitySession : String = "session"
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