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
		
		let session = NSURLSession.sharedSession()
		
		let task = session.dataTaskWithRequest(request) { data, response, error in
			/* Connection error */
			if error != nil {
				println("Connection error. \(error.localizedDescription)")
				completionHandler(success: false, error: error.localizedDescription)
			} else {
				/* Handling Udacity data - taking a subset of the data */
				let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
				
				/* Parsing JSON data and checking what kind of error has happened */
				var parsingError: NSError? = nil
				if let jsonData = NSJSONSerialization.JSONObjectWithData(newData, options: nil, error: &parsingError) as? NSDictionary {
					if let status = jsonData.valueForKey(JSONResponseKeys.status) as? Int {
						if let errorString = ErrorMessages.messageForStatus[status] {
							println("Status error: \(status) (\(ErrorMessages.messageForStatus[status]!))")
							completionHandler(success: false, error: ErrorMessages.messageForStatus[status])
						} else {
							println("Status error: \(status) (Unknown error)")
							completionHandler(success: false, error: "Unknown Error")
						}
					} else {
						/* When there is no "status", the operation was succesful */
						if let accountKey = jsonData.valueForKey(JSONResponseKeys.account)?.valueForKey(JSONResponseKeys.key) as? String {
							println("Conection was successful")
							completionHandler(success: true, error: nil)
						} else {
							println("Could not find account key")
							completionHandler(success: false, error: "Could not find account key (API error)")
						}
					}
				} else {
					println("Parsing JSON error.")
					completionHandler(success: false, error: "Parsing JSON error")
				}
			}
		}
		
		task.resume()
	}
}