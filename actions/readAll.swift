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
          let database = args["services.cloudant.database"] as? String else {

        print("Error: missing a required parameter for creating a entry in a Cloudant document.")
        return [ "ok": false ]
    }

    return readAll(url: baseURL, database: database)
}

/// Retrieve all documents from the cloudant db
func readAll(url: String, database: String) -> [String: Any] {
  var result: [String: Any] = ["ok": false]

  /// Construct HTTP Request to retrieve object
  let req = HTTP.request(url + "/" + database + "/_all_docs?include_docs=true") { response in

      /// Check for a valid response
      guard let response = response, let responseStr = try? response.readString(), let str = responseStr else {
          print("Error: Invalid or Missing response from Cloudant")
          return
      }

      let json = JSON.parse(string: str)

      /// Check for an error response
      if let error = json["error"].string {
          print("Error: \(error)")
          result = ["ok": false, "error": error]
          return
      }

      /// Parse Cloudant documents
      let docs = json["rows"].reduce([]) { (list, json) in
        if let doc = json.1["doc"].rawString() {
          return list + [doc]
        }
        return list
      }

      result = ["document": docs]
  }

  // Set headers and execute request
  req.set(.headers(["Accept": "application/json", "Content-Type": "application/json"]))
  req.set(.method("GET"))
  req.end()

  return result
}
