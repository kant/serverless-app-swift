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
          let id = args["id"] as? String else {

        print("Error: missing a required parameter for creating a entry in a Cloudant document.")
        return ["ok": false]

    }

    return delete(url: baseURL, database: database, docId: id)
}

/// Delete an entry in the database
func delete(url: String, database: String, docId: String) -> [String: Any] {

    /// Endpoint for document with ID
    let documentURL = url + "/" + database + "/" + docId

    /// Retrieve the document for the specified ID and get its revision #
    guard let docResponse = request(documentURL), let rev = JSON(data: docResponse)["_rev"].string else {
        print("Error: Entry does not exist in cloudant")
        return ["ok": false, "error": "not found"]
    }

    /// Endpoint to delete document with ID and revision #
    let deleteURL = documentURL + "?rev=\(rev)"

    /// Delete the document from the database
    guard let deleteResponseData = request(deleteURL, method: "DELETE") else {
        print("Error: Missing or invalid response from Cloudant")
        return ["ok": false]
    }

    let json = JSON(data: deleteResponseData)
    return ["ok": json["ok"].bool == true]
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
