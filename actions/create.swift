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

    return create(url: baseURL, database: database, json: body)
}

/// Networking method to insert entry into the database
func create(url: String, database: String, json: String) -> [String: Any] {

    var result: [String: Any] = ["ok": false]

    /// Encode JSONPayload as data
    guard let data = String(describing: json).data(using: .utf8, allowLossyConversion: true) else {
        print("Error: Could not encode body as data")
        return result
    }

    /// Construct HTTP Request
    let req = HTTP.request(url + "/" + database) { response in

        /// Check for a valid response
        guard let response = response, let responseStr = try? response.readString(), let str = responseStr else {
            print("Error: Invalid or missing response from Cloudant")
            return
        }

        let json = JSON.parse(string: str)

        if json["ok"].bool == true {
          result = ["ok": true, "document": str]
        } else {
          result = ["ok": false]
        }
    }

    /// Set headers and execute request
    req.set(.headers(["Accept": "application/json", "Content-Type": "application/json"]))
    req.set(.method("POST"))
    req.end(data)

    return result
}
