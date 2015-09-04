//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 8/24/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  This is a SINGLETON class responsible for the use of Udacity API.
//  GET and POST methods are provided to make HTTP requests to the server using the Udacity API.

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
				completionHandler(result: nil, error: error)
			} else {
				JSONConvenience.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
			}
		}
		
		/* 7. Start the request */
		task.resume()
		
		return task
	}
	
	// MARK: - Shared Instance
	
	class func sharedInstance() -> UdacityClient {
		
		struct Singleton {
			static var sharedInstance = UdacityClient()
		}
		
		return Singleton.sharedInstance
	}
}