![Cloud Functions](https://developer.ibm.com/code/wp-content/uploads/sites/118/2017/10/IBM-CLOUD-FUNCTIONS-35.png)

## iosserverlessexample
iOS Project using Swift Cloud Functions 

[![](https://img.shields.io/badge/ibmcloud-powered-blue.svg)](https://bluemix.net)
[![Platform](https://img.shields.io/badge/platform-swift-lightgrey.svg?style=flat)](https://developer.ibm.com/swift/)


### Table of Contents
* [Summary](#summary)
* [Requirements](#requirements)
* [Configuration](#configuration)
* [Run](#run)
* [Services](#services)
* [Cloud Functions Apis](#cloud-functions-apis)
* [License](#license)

### Summary
iOS Project using Swift Cloud Functions 

### Requirements
- [IBM Cloud CLI](https://console.bluemix.net/docs/cli/reference/bluemix_cli/download_cli.html)

- Cloud Functions Plugin:

      bx plugin install Cloud-Functions -r Bluemix
            
- Whisk Deploy CLI [Download](https://github.com/apache/incubator-openwhisk-wskdeploy/releases)
### Configuration
The .bluemix directory contains all of the configuration files that the toolchain requires to function. At a minimum, the .bluemix directory must contain the following files:

- toolchain.yml
- deploy.json
- pipeline.yml

Detailed information regarding toolchain configuration can be found in our [docs](https://console.bluemix.net/docs/services/ContinuousDelivery/toolchains_custom.html#toolchains_custom).

1. Update the toolchain with your desired changes.

2. After updating the toolchain files with your desired changes push your application to restage the toolchain
        bx app push

### Deployment
Your application is deployed using the IBM Continuous Delivery pipeline. Your toolchain provides an integrated set of tools to build, deploy, and manage your apps.

#### Managing Cloud Functions and API Connect Manually

1. Download your code locally by navigate to your App dashboard from the [Apple Development Console](https://console.bluemix.net/developer/appledevelopment/apps) or [Web Apps Console](https://console.bluemix.net/developer/appservice/apps) and select `Download Code`.

2. Login into the IBM Cloud

        bx login -a <api> -o <org> -s <space>

3. **Local Deployment:** Execute the deploy script.  If you're on Mac or linux, you can run the `deploy.sh` helper script.

        chmod +x deploy.sh
        ./deploy.sh

   Or, if you'd rather run the `wskdeploy` command directly, you use the `--param` command line flags to provide values for the `services.cloudant.database` and `services.cloudant.url` values.

        /wskdeploy -m "manifest.yml" --param "services.cloudant.url" "<url>" --param "services.cloudant.database" "products"

   Where &lt;url&gt; is the URL value from your Cloudant service credentials.

   **IBM DevOps Deployment:** Once you have connected your app to IBM Devops by clicking on the "Deploy To Cloud" you need to add your Cloudant URL to the delivery pipeline environment varaibles. Note: this is a one-time action.

   First click on the "Cloudant" service link when viewing the app dashboard.  Then click on "Service Credentials", and then click on the "View Credentials" link for your Cloudant instance.  Copy the "url" value for use in the delivery pipeline.

   Next, go back to your app dashboard and click "View Toolchain", then click on the "Delivery Pipeline".   The delivery pipeline may have executed without any errors, but you need to specify the Cloudant URL before the Cloud Functions actions will operate as expected.  Next, click on the gear icon for the "DEPLOY" phase, then click "Configure Phase" and click "Environment Properties".  Paste the Cloudant url for the "DATABASE_URL" environment variable.  

   Next, run your DEPLOY phase again to complete the deployment.

        
4. Review the actions in the IBM Cloud Console [Cloud Functions](https://console.bluemix.net/openwhisk/actions)
 
5. Review API for the actions in the IBM Cloud Console [Cloud Functions APIs](https://console.bluemix.net/openwhisk/apimanagement)  



### Services
This application is configured to connect with the following services:

##### Cloudant
Cloudant NoSQL DB provides access to a fully managed NoSQL JSON data layer that's always on. This service is compatible with CouchDB, and accessible through a simple to use HTTP interface for mobile and web application models.
  ### Cloud Function Apis
##### Cloudant Actions

<table>
  <thead>
      <tr>
        <th>Method</th>
        <th>HTTP request</th>
        <th>Description</th>
      </tr>
  </thead>
  <tbody>
    <tr>
      <td colspan="3">
      URIs relative to https://openwhiskibm.com/api/v1/web/undefined_undefined/iosserverlessexample </td>
    </tr>
    <tr>
      <td>Create</td>
      <td>POST /database </td>
      <td>Inserts an object</td>
    </tr>
    <tr>
      <td>Read</td>
      <td>GET /database/<font color="#ec407a">objectId</font></td>
      <td>Retrieves an object</td>
    </tr>
    <tr>
      <td>ReadAll</td>
      <td>GET /database </td>
      <td>Retrieves all objects</td>
    </tr>
    <tr>
      <td>Delete </td>
      <td>DELETE /database/<font color="#ec407a">objectId</font></td>
      <td>Deletes an object</td>
    </tr>
    <tr>
      <td>DeleteAll</td>
      <td>DELETE /database </td>
      <td>Deletes all objects</td>
    </tr>
    <tr>
      <td>update</td>
      <td>PUT /database/<font color="#ec407a">objectId</font></td>
      <td>Updates content of an object</td>
    </tr>
  </tbody>
</table>
  ### License
This package contains code licensed under the Apache License, Version 2.0 (the "License"). You may obtain a copy of the License [here](http://www.apache.org/licenses/LICENSE-2.0) and may also view the License in the LICENSE file within this package.

