/*
 Copyright 2017 Roberto Pastor Ortiz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation

public enum HTTPMethod : String {
  case GET
  case POST
  case PUT
  case DELETE
}

public enum MIMEType : String {
  case json = "application/json"
}

public typealias HeaderItem = URLQueryItem

public enum WebServiceResult<T> {
  case success(T)
  case successNoData
  case failure(NSError)
}

// MARK: - WebResource
public protocol WebServiceRequest {
  associatedtype Task: URLSessionTask
  associatedtype Response: WebServiceResponse
  
  var baseUrl: URL { get }
  var method: HTTPMethod { get }
  var path: [String] { get }
  var queryParams: [URLQueryItem] { get }
  var accept: MIMEType? { get }
  var headerParams: [HeaderItem] { get }
  var requestBody: AnyObject? { get }
  var taskID: String { get }
  
  @discardableResult
  func executeInSession(_ session: URLSession? , completion: @escaping (_ response: WebServiceResult<Response>) -> Void ) -> Task?
}

// MARK: Default values
public extension WebServiceRequest {
  var method: HTTPMethod { return .GET }
  var path: [String] { return [String]() }
  var queryParams: [URLQueryItem] { return [URLQueryItem]() }
  var accept: MIMEType? { return nil }
  var headerParams: [HeaderItem] { return [HeaderItem]() }
  var requestBody: AnyObject? { return nil }
  var taskID: String { return String(describing: type(of: self))}
}

// MARK: Request
public extension WebServiceRequest {
  
  var requestDescription: String { return String(describing: type(of: self)) }
  
  func createRequest() -> NSMutableURLRequest {
    var url = baseUrl
    
    // Path
    for component in path {
      url.appendPathComponent(component)
    }
    
    // Query Params
    if !queryParams.isEmpty {
      var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)!
      urlComponents.queryItems = queryParams.map {
        URLQueryItem(name: $0.name, value: $0.value)
      }
      url = urlComponents.url!
    }
    
    // Create Request
    let mutableUrlRequest = NSMutableURLRequest(url: url)
    mutableUrlRequest.httpMethod = method.rawValue
    
    // Accept MIME Type
    if let accept =  accept {
      mutableUrlRequest.setValue(accept.rawValue, forHTTPHeaderField: "Accept")
    }
    
    // Header Parameters
    for headerParam in headerParams {
       mutableUrlRequest.setValue(headerParam.value, forHTTPHeaderField: headerParam.name)
    }
    
    // Request Body
    if let requestBody = requestBody {
      let data = try! JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted)
      mutableUrlRequest.httpBody = data
    }
    
    return mutableUrlRequest
  }

}

// MARK: Web Service Response
public protocol WebServiceResponse {}
