//
//  UdacityConvenience.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 8/24/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  Extension of class UdacityClient
//  The convenient methods (specific GET and POST methods provided by the Udacity API) are here
//  This class is also responsible for the authentication with Udacity

import UIKit
import Foundation

extension UdacityClient {
	
	// MARK: - GET Convenience Methods
	
	/* This method gets the user public data and returns through the completionHandler */
	/* The user accountKey (needed for public data) was already saved in the authentication process */
	func getPublicUserData(completionHandler: (result: [String : AnyObject]?, error: NSError?) -> Void) {
		
		/* 1. Specify parameters, method and HTTP body (if POST) */
		let parameters = [String : AnyObject]()
		
		/* 2. Make the request */
		taskForGETMethod(Methods.UdacityUsers, parameters: parameters) { JSONResult, error in
			
			/* 3. Send the desired value(s) to completion handler */
			if let error = error {
				completionHandler(result: nil, error: error)
			} else {
				if let userInfo = JSONResult.valueForKey(JSONResponseKeys.User) as? [String : AnyObject] {					
					completionHandler(result: userInfo, error: nil)
				} else {
					completionHandler(result: nil, error: NSError(domain: "getPublicUserData parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getPublicUserData"]))
				}
			}
		}
	}
	
	// MARK: - Authentication
	
	func authenticateWithUdacity(username: String, password: String, completionHandler: (success: Bool, errorString: NSString?) -> Void) {
		
		/* 1. Specify parameters, method and HTTP body (if POST) */
		let parameters = [String:AnyObject]()
		let jsonBody = [
			JSONBodyKeys.Udacity : [
				JSONBodyKeys.Username : username,
				JSONBodyKeys.Password : password
			]
		]
		
		/* 2. Make the request */
		taskForPOSTMethod(Methods.UdacitySession, parameters: parameters, jsonBody: jsonBody) { result, error in
			
			/* 3. Send the desired value(s) to completion handler */
			if let error = error {
				/* There was a connection error */
				completionHandler(success: false, errorString: error.localizedDescription)
			} else {
				if let status = result.valueForKey(JSONResponseKeys.Status) as? Int {
					
					/* Checks the response's status and return the appropriate error message */
					if let errorMessage = ErrorMessages.MessageForStatus[status] {
						println("Status error: \(status) (\(ErrorMessages.MessageForStatus[status]!))")
						completionHandler(success: false, errorString: ErrorMessages.MessageForStatus[status])
					} else {
						println("Status error: \(status) (Unknown error)")
						completionHandler(success: false, errorString: "Unknown Error")
					}
				} else {
					
					/* When there is no "status", the operation was succesful. Checks for account key */
					if let accountKey = result.valueForKey(JSONResponseKeys.Account)?.valueForKey(JSONResponseKeys.Key) as? String {
						println("Connection was successful")
						self.accountKey = accountKey
						completionHandler(success: true, errorString: nil)
					} else {
						println("Could not find account key")
						completionHandler(success: false, errorString: "Could not find account key (API error)")
					}
				}
			}
		}
	}
}