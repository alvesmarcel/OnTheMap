//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 8/24/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//

extension UdacityClient {
	
	struct ErrorMessages {
		static let messageForStatus = [
			400 : "Empty Email or Password",
			403 : "Invalid Email or Password"
		]
	}
	
	struct Constants {
		
		/* Button tags */
		static let udacityLoginButtonTag : Int = 1
		static let facebookLoginButtonTag : Int = 2
		static let locationTextViewTag: Int = 3
		static let linkTextViewTag: Int = 4
		
		// URLs
		static let udacityBaseUrl : String = "https://www.udacity.com/api/"
		static let signUpUrl = "https://www.udacity.com/account/auth#!/signup"
		
	}
	
	struct Methods {
		
		static let udacitySession : String = "session"
		static let UdacityUsers: String = "users"
	}
	
	struct JSONResponseKeys {
		static let status = "status"
		static let session = "session"
		static let sessionID = "id"
		static let account = "account"
		static let key = "key"
		
		static let User = "user"
		static let FirstName = "first_name"
		static let LastName = "last_name"
	}
	
	struct StatusResponse {
		static let emptyField = 400
		static let invalidField = 403
	}
}