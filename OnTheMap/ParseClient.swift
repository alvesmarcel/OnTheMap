//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 8/26/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//

import Foundation

class ParseClient {
	
	var studentLocations: [StudentLocation] = [StudentLocation]()
	
	func getStudentsLocations(limit: Int, skip: Int, completionHandler: (result: [StudentLocation]?, error: NSError?) -> Void) {
		let parameters = [
			ParameterKeys.Limit : limit,
			ParameterKeys.Skip : skip
		]
		
		taskForGETMethod(Methods.StudenteLocation, parameters: parameters) { JSONResult, error in
		
			/* 3. Send the desired value(s) to completion handler */
			if let error = error {
				completionHandler(result: nil, error: error)
			} else {
				if let results = JSONResult.valueForKey(JSONResponseKeys.Results) as? [[String : AnyObject]] {
					self.studentLocations = StudentLocation.studentLocationsFromResults(results)
					completionHandler(result: self.studentLocations, error: nil)
				} else {
					completionHandler(result: nil, error: NSError(domain: "getStudentsLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentsLocations"]))
				}
			}
		}

	}
	
	func taskForGETMethod(method: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
		
		/* 1. Set the parameters */
		var mutableParameters = parameters
		
		/* 2/3. Build the URL and configure the request */
		let urlString = Constants.ParseBaseUrl + method + JSONConvenience.escapedParameters(mutableParameters)
		let url = NSURL(string: urlString)!
		let request = NSMutableURLRequest(URL: url)
		request.addValue(Constants.AppID, forHTTPHeaderField: HTTPHeaderField.AppID)
		request.addValue(Constants.ApiKey, forHTTPHeaderField: HTTPHeaderField.ApiKey)
		let session = NSURLSession.sharedSession()
		
		/* 4. Make the request */
		let task = session.dataTaskWithRequest(request) {data, response, downloadError in
			
			/* 5/6. Parse the data and use the data (happens in completion handler) */
			if let error = downloadError {
				completionHandler(result: nil, error: downloadError)
			} else {
				JSONConvenience.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
			}
		}
		
		/* 7. Start the request */
		task.resume()
		
		return task
	}
	
	// MARK: - Shared Instance
	
	class func sharedInstance() -> ParseClient {
		
		struct Singleton {
			static var sharedInstance = ParseClient()
		}
		
		return Singleton.sharedInstance
	}
}