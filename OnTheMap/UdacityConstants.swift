//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 8/24/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  Extension of class UdacityClient
//  All the constants used in the API are set here

extension UdacityClient {
	
	// MARK: - Constants
	struct Constants {
		
		// MARK: - URLs
		static let UdacityBaseURL : String = "https://www.udacity.com/api/"
		static let SignUpURL = "https://www.udacity.com/account/auth#!/signup"
	}
	
	// MARK: - Methods
	struct Methods {
		
		static let UdacitySession : String = "session"
		static let UdacityUsers: String = "users"
	}
	
	// MARK: - JSON Response Keys
	struct JSONResponseKeys {
		
		// MARK: - Authentication
		static let Status = "status"
		static let Session = "session"
		static let SessionID = "id"
		static let Account = "account"
		static let Key = "key"
		
		// MARK: - User Public Information
		static let User = "user"
		static let FirstName = "first_name"
		static let LastName = "last_name"
	}
	
	// MARK: - Status Responses
	struct StatusResponse {
		
		// MARK: - Authentication
		static let EmptyField = 400
		static let InvalidField = 403
	}
	
	// MARK: - Error Messages
	struct ErrorMessages {
		static let MessageForStatus = [
			400 : "Empty Email or Password",
			403 : "Invalid Email or Password"
		]
	}
}