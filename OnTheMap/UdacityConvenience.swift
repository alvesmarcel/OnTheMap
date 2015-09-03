//
//  UdacityConvenience.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 8/24/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  Extension of class UdacityClient
//  The convenient methods (specific GET and POST methods provided by the Udacity API) are here

import UIKit
import Foundation

extension UdacityClient {
	
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
}