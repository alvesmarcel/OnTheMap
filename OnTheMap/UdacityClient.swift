//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 8/24/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  This is a SINGLETON class responsible for the use of Udacity API.
//  GET and POST methods are provided to make HTTP requests to the server using the Udacity API.
//  This class is also responsible for the authentication with Udacity

import Foundation

class UdacityClient : NSObject {
	
	// The accountKey is needed for every GET request. Its value is set in the authentication (authenticateWithUdacity method)
	var accountKey: NSString?
	
	// MARK: - GET
	
	func taskForGETMethod(method: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
				
		/* 1. Set the parameters */
		var mutableParameters = parameters
		
		/* 2/3. Build the URL and configure the request */
		let urlString = Constants.UdacityBaseURL + method + "/\(accountKey!)"
		let url = NSURL(string: urlString)!
		let request = NSMutableURLRequest(URL: url)
		let session = NSURLSession.sharedSession()
		
		/* 4. Make the request */
		let task = session.dataTaskWithRequest(request) {data, response, downloadError in
			
			/* The first 5 bytes should be ignored, according to the documentation */
			let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
			
			/* 5/6. Parse the data and use the data (happens in completion handler) */
			if let error = downloadError {
				completionHandler(result: nil, error: downloadError)
			} else {
				JSONConvenience.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
			}
		}
		
		/* 7. Start the request */
		task.resume()
		
		return task
	}
	
	// MARK: - POST
	
	func taskForPOSTMethod(method: String, parameters: [String : AnyObject], jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
		
		/* 1. Set the parameters */
		var mutableParameters = parameters
		
		/* 2/3. Build the URL and configure the request */
		let urlString = Constants.UdacityBaseURL + method + JSONConvenience.escapedParameters(mutableParameters)
		let url = NSURL(string: urlString)!
		let request = NSMutableURLRequest(URL: url)
		var jsonifyError: NSError? = nil
		request.HTTPMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
		
		let session = NSURLSession.sharedSession()
		
		/* 4. Make the request */
		let task = session.dataTaskWithRequest(request) {data, response, downloadError in
			
			/* The first 5 bytes should be ignored, according to the documentation */
			let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
			
			/* 5/6. Parse the data and use the data (happens in completion handler) */
			if let error = downloadError {
				completionHandler(result: nil, error: downloadError)
			} else {
				JSONConvenience.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
			}
		}
		
		/* 7. Start the request */
		task.resume()
		
		return task
	}
	
	// MARK: - Authentication
	
	func authenticateWithUdacity(username: String, password: String, completionHandler: (success: Bool, error: NSString?) -> Void) {
		
		let request = NSMutableURLRequest(URL: NSURL(string: Constants.UdacityBaseURL + Methods.UdacitySession)!)
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
				
				/* The first 5 bytes should be ignored, according to the documentation */
				let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
				
				/* Parsing JSON data and checking what kind of error has happened */
				var parsingError: NSError? = nil
				if let jsonData = NSJSONSerialization.JSONObjectWithData(newData, options: nil, error: &parsingError) as? NSDictionary {
					if let status = jsonData.valueForKey(JSONResponseKeys.Status) as? Int {
						if let errorString = ErrorMessages.MessageForStatus[status] {
							println("Status error: \(status) (\(ErrorMessages.MessageForStatus[status]!))")
							completionHandler(success: false, error: ErrorMessages.MessageForStatus[status])
						} else {
							println("Status error: \(status) (Unknown error)")
							completionHandler(success: false, error: "Unknown Error")
						}
					} else {
						
						/* When there is no "status", the operation was succesful */
						if let accountKey = jsonData.valueForKey(JSONResponseKeys.Account)?.valueForKey(JSONResponseKeys.Key) as? String {
							println("Conection was successful")
							self.accountKey = accountKey
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
	
	// MARK: - Shared Instance
	
	class func sharedInstance() -> UdacityClient {
		
		struct Singleton {
			static var sharedInstance = UdacityClient()
		}
		
		return Singleton.sharedInstance
	}
}