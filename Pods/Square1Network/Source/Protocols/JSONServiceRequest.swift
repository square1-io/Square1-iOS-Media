/*
 Copyright 2017 Roberto Pastor Ortiz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation

public protocol JSONServiceResponse: WebServiceResponse {
  init(jsonObject:Decodable)
}

public protocol JSONServiceRequest: WebServiceRequest where Task: URLSessionDataTask, Response: JSONServiceResponse {
  func handleResponse(_ data: Data?, response: URLResponse?, error: NSError?) -> WebServiceResult<Response>
}

public extension JSONServiceRequest {
  var accept: MIMEType? { return .json }
  
  @discardableResult
  func executeInSession(_ session: URLSession? = URLSession.shared,
                        completion: @escaping (WebServiceResult<Response>) -> ()) -> URLSessionDataTask? {
    let request = createRequest() as URLRequest
    
    let task = session!.dataTask(with: request) { data, response, error in
      let result = self.handleResponse(data, response: response, error: error as NSError?)
      DispatchQueue.main.async {
        completion(result)
      }
    }
    
    task.resume()
    return task
  }
}
