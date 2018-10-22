/**
 * Copyright 2018 IBM Corp. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the “License”);
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an “AS IS” BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
*/

import KituraNet
import Dispatch
import Foundation
import SwiftyJSON

func main(args: [String: Any]) -> [String: Any] {

    /// Retreive required parameters
    guard let baseURL = args["services.cloudant.url"] as? String,
          let database = args["services.cloudant.database"] as? String,
          let body = args["body"] as? String else {

        print("Error: missing a required parameter for creating a entry in a Cloudant document.")
        return ["ok": false]
    }

    /// Parse json payload
    var updatedJSON = JSON.parse(string: body)

    /// Ensure an object id has been provided
    guard let id = updatedJSON["id"].string else {
      print("Error: No ID provided in json object.")
      return ["ok": false]
    }

    /// Remove the duplicate id value
    updatedJSON.dictionaryObject?.removeValue(forKey: "id")

    /// Endpoint to Cloudant document
    let documentURL = baseURL + "/" + database + "/" + id

    return update(url: documentURL, updatedJSON: updatedJSON)
}

/// Updates a cloudant json object with updated data
func update(url: String, updatedJSON: JSON) -> [String: Any] {

  let errorResult: [String: Any] = ["ok": false]

  /// Retrieve original object from Cloudant
  guard let originalJSON = get(url) else {
    print("Error: Cloudant document does not exist.")
    return errorResult
  }

  /// Updated Cloudant entry
  let mergedJSON = originalJSON.union(json: updatedJSON)

  /// Encode JSONPayload as data
  guard let data = try? mergedJSON.rawData(), let jsonString = mergedJSON.rawString() else {
      print("Error: Could not encode body.")
      return errorResult
  }

  /// Make update request
  guard let docData = request(url, body: data) else {
    print("Error: Invalid or missing response from Cloudant.")
    return errorResult
  }

  /// Parse update request response
  guard JSON(data: docData)["ok"].bool == true else {
    return errorResult
  }

  return ["ok": true, "document": jsonString]
}

/// Read an entry in the database
func get(_ url: String) -> JSON? {
    /// Make request to retrieve
    guard let responseData = request(url) else {
      return nil
    }

    return JSON(data: responseData)
}

/// Networking Wrapper Method
func request(_ url: String, body: Data? = nil) -> Data? {
  var data = Data()

  let method = body == nil ? "GET" : "PUT"

  /// Construct HTTP Request to retrieve object
  let req = HTTP.request(url) { response in
      guard let response = response, let _ = try? response.readAllData(into: &data) else {
        print("Error: Missing or invalid response from Cloudant.")
        return
      }
  }

  // Set headers and execute request
  req.set(.headers(["Accept": "application/json", "Content-Type": "application/json"]))
  req.set(.method(method))

  /// Pass data if necessary
  if let body = body {
    req.end(body)
  } else {
    req.end()
  }

  return data.count != 0 ? data : nil
}

/// JSON Extensions
extension JSON {

    /// Merges two json objects
    func union(json: JSON) -> JSON {
        var merged = self
        for (key, value) in json {
            merged[key] = value
        }
        return merged
    }
}
