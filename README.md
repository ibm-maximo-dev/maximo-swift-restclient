# MaximoRESTSDK

The Maximo REST SDK framework provides a set of driver API's which can be consumed by an iOS based application that would like to interface with a Maximo instance. The SDK API's use the Maximo NextGen REST/JSON API's which were originally inspired by Linked Data principles. Using this API you would be able to create, update, delete and query Maximo business objects (Using Maximo Integration Framework Object Structures).

The main components of this SDK framework include:

- [MaximoConnector]: The driver API that establishes the authenticated HTTP session with the Maximo server. It is used by the other API's to create, update, delete and query Maximo data. The authentication and the other basic information can be configured using an [Options] object.

- [ResourceSet]: This API represents a collection of Maximo resources of a given type. The type is determined by the Object Structure definition it refers to. In effect this API is equivalent to the concept of Maximo's MboSet.

- [Resource]: Each member of a ResourceSet is represented by an instance of this class. This is equivalent to to the concept of Mbo in Maximo.

- [Attachment and AttachmentSet]: These API's represent the attached docs (doclinks) in Maximo. These are always associated with some Resource.

Currently the only supported data format is JSON and we have 2 flavors of JSON – the lean and the namespaced. The lean format is supported starting with the Maximo 7.6 version and is the recommended format to use (as it uses less bandwidth).

## Prerequisites

- Xcode
- Cocoapods
- Maximo 7.6

## Getting Started

### Cocoapods Installation

Open Terminal and enter the following command:
```
sudo gem install cocoapods
```

### Add SSH Key to your GitHub Account

Generate RSA key for your GitHub user account:
```
ssh-keygen -t rsa -b 4096 -C git@github.ibm.com
```

Paste the contents of the <i>id_rsa.pub</i> file as mentioned here: https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/


### Project Setup

1. In a Terminal session, navigate to the directory that contains your Xcode project.

> **Note**: If your project is already configured to use Cocoapods, you can skip the next step.

2. Next, enter the following command:
```
pod init
```

3. Finally, type the following command to open the Podfile using Xcode for editing:
```
open -a Xcode Podfile
```

The default Podfile looks like this:

```
# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target '<YOUR PROJECT NAME>' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for <YOUR PROJECT NAME>

end
```

Delete the # and space before platform, and delete the other lines starting with #.
Your Podfile should now look like this:

```
platform :ios, '9.0'

target '<YOUR PROJECT NAME>' do
  use_frameworks!

end
```
4. Add the following line to your Podfile, right after use_frameworks!:
```
pod 'MaximoRESTSDK', '1.0.0'
```

5. You now need to tell CocoaPods to install the dependencies for your project.
Enter the following command in Terminal:
```
pod install
```

6. After the dependencies have been successfully installed, Cocoapods creates a new <YOUR PROJECT NAME>.xcworkspace file and a Pods folder that contains all the project's dependencies.
Now just open the .xcworkspace file with Xcode and you are all set!

## Usage

Maximo Resources (Object Structures) represent a graph of related Maximo objects (Mbo's) that provides an atomic view/object to create/update/delete/query the releated set of Mbos. 
We will use Work Order, Purchase Order and Companies Resource as examples to show you how to use the Maximo Rest SDK.

>**Note**: The use cases can be found at MaximoRESTSDKTests.swift

### Query a Work Order for Work Order Set (MXWODETAIL)

The following instructions shows how to query a work order from Maximo by using Maximo REST SDK framework.

#### Connect to Maximo

In order to establish a connection with Maximo, it is required that we set up authentication and environment information in the Options object;

* For authentication, we need to provide the user credentials and the authentication mechanism. The following authentication methods are supported: "maxauth", "basic" and "form". The sample code is as following,

```swift
var option : Options = Options().user("maxadmin").password("maxadmin").auth("maxauth")
```

> **Note**: For Maximo Multi-Tenancy, take the tenant code = "00" as an example, using the following statement.

```swift
var option : Options = 
  Options().user("maxadmin").password("maxadmin").auth("maxauth").mt(true).tenantCode("00")
```

* For environment, it needs the data mode setting, host, port and if it the debug is enabled. The sample code is as following,

```swift
option.host("127.0.0.1").port(7001).lean(true)
```

* Based on this configuration, connect to the Maximo using a MaximoConnector instance.

```swift
var mc : MaximoConnector = MaximoConnector(options: option).debug(true)
mc.connect()
```

* Or directly use the following code,

```swift
var mc : MaximoConnector = 
  MaximoConnector(options: Options().user("maxadmin").password("maxadmin").
    lean(true).auth("maxauth").host("127.0.0.1").port(7001))
mc.connect()
```

#### Querying Work Orders

* Create a ResourceSet which holds the results for an "Approved" Work Order set. The selected records are composed by the WONUM and STATUS properties.

By object structure name:
  
```swift
var rs : ResourceSet = mc.resourceSet("mxwodetail").select(
   {"wonum", "status"})._where(QueryWhere()._where("status").equalTo("APPR")).fetch()
```

By RESTful URI :
  
```swift
var rs : ResourceSet = mc.resourceSet("http://127.0.0.1:7001/maximo/oslc/os/mxwodetail").select(
   {"wonum", "status"})._where(QueryWhere()._where("status").equalTo("APPR")).fetch()
```

* There is a paging API for available in this framework, that allows forward and backward paging of data by the client.
  * For the page size = 10: 
  
```swift
var rs : ResourceSet = mc.resourceSet("mxwodetail").select(
   {"wonum", "status"})._where(QueryWhere()._where("status").equalTo("APPR")).pageSize(10).fetch()
```

* For the default paging strategy (this framework assumes a default page size is configured on the Resource's Object Structure.
If no page size is configured, this directive is ignored and all records matching the query filter are returned): 

```swift
var rs : ResourceSet = mc.resourceSet("mxwodetail").select(
   {"wonum", "status"})._where(QueryWhere()._where("status").equalTo("APPR")).paging(true).fetch()
```

* For the stable paging:

```swift
var rs : ResourceSet = mc.resourceSet("mxwodetail").select(
   {"wonum", "status"})._where(QueryWhere()._where("status").equalTo("APPR")).stablePaging(true).fetch()
```

* Move to the next or to the previous page.

```swift 
rs.nextPage()
rs.previousPage()
```

For stable paging, this framework currently supports only forward scrolling, a call to previousPage() would result in an API error.

* Get the ResourceSet in JSON:

```swift
var jo : [String: Any] = rs.toJSON()
```

> **Note**: We support JSON output as Data objects. This can be accomplished by the following code snippet,

```swift
var jodata : Data = rs.toJSONBytes()
```

* Each Resource object is associated with a unique URI. It is fairly simple to get the specific Work Order record by using it's URI. In the following example, we try to fetch a Work Order (_QkVERk9SRC8xMDAw) directly.

By specific URI:
  
```swift
var woUri : String = "http://host:port/maximo/oslc/os/mxwodetail/_QkVERk9SRC8xMDAw"
```

Using ResourceSet
  
```swift
var re : Resource = rs.fetchMember(uri: woUri)
```

Or using a MaximoConnector object
  
```swift
var re : Resource = mc.resource(woUri)
```

By index (this method searches for a member Resource into the ResourceSet collection. This is an in-memory operation, no round trip to the server is required):
  
```swift
var re : Resource = rs.member(index: 0)
```

* In order to fetch additional information from the server for this Resource, consider using the load() and reload() methods available on the Resource object.

```swift
re.reload({"wonum", "status", "assetnum", "location", "wplabor.craft"})
```

Or simply
  
```swift
re.reload("*")
```

* Get the Work Order as JSON (Dictionary) or Data objects:

```swift
var jo : [String: Any] = re.toJSON()
var joBytes : Data = re.toJSONBytes()
```

#### Traversing Work Orders 
In some cases, you may be required to traverse the Work Order hierarchy. In this section, we introduce some helpful methods available in this framework, that can be used for this purpose.

* Get a Work Order set from the Maximo Server.

```swift
var rs : ResourceSet = mc.resourceSet("mxwodetail").pageSize(10)
```
 
* Navigate through the Work Order records that are kept in current page.

```swift
let count = rs.count()
for index in 0...count {
	var re : Resource = rs.member(index)
	// Perform operations with the Resource object.
}
```

* Navigate through all of the Work Order records available in the ResourceSet.

```swift
let pageSize = rs.configuredPageSize()
let totalRecordCount = rs.totalCount()
let pageCount = (totalRecordCount + pageSize - 1) / pageSize
while pageCount > 0 {
	let recordCountInPage = rs.count()
	for index in 0...recordCountInPage
	{
		var re : Resource = rs.member(index)
	}
	if !rs.hasNextPage() {
		break
	}
	pageCount -= 1
	rs.nextPage()
}
```

#### Disconnect from Maximo

* End the user session with Maximo after you are done.

```swift
mc.disconnect()
```
