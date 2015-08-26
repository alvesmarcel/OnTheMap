//
//  UdacityConvenience.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 8/24/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//

import UIKit
import Foundation

extension UdacityClient {
	
	func authenticateWithUdacity(username: String, password: String, completionHandler: (success: Bool, error: NSString?) -> Void) {
		
		let request = NSMutableURLRequest(URL: NSURL(string: Constants.udacityBaseUrl + Methods.udacitySession)!)
		request.HTTPMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
		
		let task = session.dataTaskWithRequest(request) { data, response, error in
			/* Connection error */
			if error != nil {
				completionHandler(success: false, error: error.localizedDescription)
			} else {
				/* Treating Udacity data */
				let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
				
				/* Parsing JSON data and checking what kind of error has happened */
				var parsingError: NSError? = nil
				if let jsonData = NSJSONSerialization.JSONObjectWithData(newData, options: nil, error: &parsingError) as? NSDictionary {
					if let status = jsonData.valueForKey(JSONResponseKeys.status) as? Int {
						if status == StatusResponse.emptyField {
							completionHandler(success: false, error: "Empty Email or Password")
						} else if status == StatusResponse.invalidField {
							completionHandler(success: false, error: "Invalid Email or Password")
						} else {
							completionHandler(success: false, error: "Unknown Error")
						}
					} else {
						/* When there is no "status", the operation was succesful */
						UdacityClient.sharedInstance().userID = jsonData.valueForKey(JSONResponseKeys.account)?.valueForKey(JSONResponseKeys.key) as? String
						UdacityClient.sharedInstance().sessionID = jsonData.valueForKey(JSONResponseKeys.session)?.valueForKey(JSONResponseKeys.sessionID) as? String
						completionHandler(success: true, error: nil)
					}
				} else {
					println("Parsing JSON error.")
				}
			}
		}
		
		task.resume()
	}
	
	func authenticateWithFacebook() {
		
	}
}