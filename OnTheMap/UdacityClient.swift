//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 8/24/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//

import Foundation

class UdacityClient : NSObject {
	
	override init() {
		super.init()
	}
	
	func taskForPOSTMethod(method: String, parameters: [String : AnyObject], jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
		
		/* 1. Set the parameters */
		var mutableParameters = parameters
		
		/* 2/3. Build the URL and configure the request */
		let urlString = Constants.udacityBaseUrl + method + UdacityClient.escapedParameters(mutableParameters)
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
			
			/* 5/6. Parse the data and use the data (happens in completion handler) */
			if let error = downloadError {
				completionHandler(result: nil, error: downloadError)
			} else {
				UdacityClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
			}
		}
		
		/* 7. Start the request */
		task.resume()
		
		return task
	}
	
	// MARK - Helpers
	
	/* Helper: Given raw JSON, return a usable Foundation object */
	class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
		
		var parsingError: NSError? = nil
		
		let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
		
		if let error = parsingError {
			completionHandler(result: nil, error: error)
		} else {
			completionHandler(result: parsedResult, error: nil)
		}
	}
	
	class func escapedParameters(parameters: [String : AnyObject]) -> String {
		
		var urlVars = [String]()
		
		for (key, value) in parameters {
			
			/* Make sure that it is a string value */
			let stringValue = "\(value)"
			
			/* Escape it */
			let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
			
			/* Append it */
			urlVars += [key + "=" + "\(escapedValue!)"]
			
		}
		
		return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
	}
	
	
	// MARK: - Shared Instance
	
	class func sharedInstance() -> UdacityClient {
		
		struct Singleton {
			static var sharedInstance = UdacityClient()
		}
		
		return Singleton.sharedInstance
	}
}