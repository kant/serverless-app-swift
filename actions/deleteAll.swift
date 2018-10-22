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

    return delete(url: baseURL, database: database)
}

/// Delete an entry in the database
func delete(url: String, database: String) -> [String: Any] {

    let databaseURL = url + "/" + database

    // Drop Database
    guard let deleteResponse = request(databaseURL, method: "DELETE"),
          JSON(data: deleteResponse)["ok"].bool == true else {
        print("Error: Could not delete database - \(database)")
        return ["ok": false]
    }

    // Recreate Database
    guard let createResponse = request(databaseURL, method: "PUT") else {
        print("Error: Could not recreate database - \(database)")
        return ["ok": false]
    }

    return ["ok": JSON(data: createResponse)["ok"].bool == true]
}

/// Networking Wrapper Method
func request(_ url: String, method: String = "GET") -> Data? {
  var data = Data()

  /// Construct HTTP Request to retrieve object
  let req = HTTP.request(url) { response in
      guard let response = response, let _ = try? response.readAllData(into: &data) else {
          print("Error: Missing or invalid response from Cloudant")
          return
      }

  }

  // Set headers and execute request
  req.set(.headers(["Accept": "application/json", "Content-Type": "application/json"]))
  req.set(.method(method))
  req.end()

  return data.count != 0 ? data : nil
}
