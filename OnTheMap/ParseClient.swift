//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Marcel Oliveira Alves on 8/26/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  This is a SINGLETON class responsible for the use of Parse API. 
//  GET and POST methods are provided to make HTTP requests to the server using the Parse API.
//  This class also saves all student informations that is returned by the Parse API.
//  - Probably it would be better to use other kind of persistence for studentsInformation in the future
//  - For now, these locations are stored here because they are used by many ViewControllers and need to be accessible

import Foundation

class ParseClient {
	
	/* Array of student locations */
	var studentsInformation: [StudentInformation] = [StudentInformation]()
	
	// MARK: - GET
	
	func taskForGETMethod(method: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
		
		/* 1. Set the parameters */
		var mutableParameters = parameters
		
		/* 2/3. Build the URL and configure the request */
		let urlString = Constants.ParseBaseURL + method + JSONConvenience.escapedParameters(mutableParameters)
		let url = NSURL(string: urlString)!
		let request = NSMutableURLRequest(URL: url)
		request.addValue(Constants.AppID, forHTTPHeaderField: HTTPHeaderField.AppID)
		request.addValue(Constants.APIKey, forHTTPHeaderField: HTTPHeaderField.ApiKey)
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
	
	// MARK: - POST
	
	func taskForPOSTMethod(method: String, parameters: [String : AnyObject], jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
		
		/* 1. Set the parameters */
		var mutableParameters = parameters
		
		/* 2/3. Build the URL and configure the request */
		let urlString = Constants.ParseBaseURL + method + JSONConvenience.escapedParameters(mutableParameters)
		let url = NSURL(string: urlString)!
		let request = NSMutableURLRequest(URL: url)
		request.HTTPMethod = "POST"
		request.addValue(Constants.AppID, forHTTPHeaderField: HTTPHeaderField.AppID)
		request.addValue(Constants.APIKey, forHTTPHeaderField: HTTPHeaderField.ApiKey)
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		let session = NSURLSession.sharedSession()
		
		var jsonifyError: NSError? = nil
		request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
		
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
	
	// MARK: - PUT
	
	func taskForPUTMethod(method: String, parameters: [String : AnyObject], objectID: String, jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
		
		/* 1. Set the parameters */
		var mutableParameters = parameters
	
		/* 2/3. Build the URL and configure the request */
		let urlString = Constants.ParseBaseURL + method + "/\(objectID)"
		let url = NSURL(string: urlString)
		let request = NSMutableURLRequest(URL: url!)
		request.HTTPMethod = "PUT"
		request.addValue(Constants.AppID, forHTTPHeaderField: HTTPHeaderField.AppID)
		request.addValue(Constants.APIKey, forHTTPHeaderField: HTTPHeaderField.ApiKey)
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		let session = NSURLSession.sharedSession()
		
		var jsonifyError: NSError? = nil
		request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
		
		/* 4. Make the request */
		let task = session.dataTaskWithRequest(request) { data, response, downloadError in
			
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