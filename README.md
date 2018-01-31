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

### Querying Work Orders from a Resource Set (MXWODETAIL)

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
var rs : ResourceSet = mc.resourceSet(osName: "mxwodetail").select(
   {"wonum", "status"})._where(QueryWhere()._where("status").equalTo("APPR")).fetch()
```

By RESTful URI:
  
```swift
var rs : ResourceSet = mc.resourceSet(url: "http://127.0.0.1:7001/maximo/oslc/os/mxwodetail").select(
   {"wonum", "status"})._where(QueryWhere()._where("status").equalTo("APPR")).fetch()
```

* There is a paging API for available in this framework, that allows forward and backward paging of data by the client.
  * For the page size = 10: 
  
```swift
var rs : ResourceSet = mc.resourceSet(osName: "mxwodetail").select(
   {"wonum", "status"})._where(QueryWhere()._where("status").equalTo("APPR")).pageSize(10).fetch()
```

* For the default paging strategy (this framework assumes a default page size is configured on the Resource's Object Structure.
If no page size is configured, this directive is ignored and all records matching the query filter are returned): 

```swift
var rs : ResourceSet = mc.resourceSet(osName: "mxwodetail").select(
   {"wonum", "status"})._where(QueryWhere()._where("status").equalTo("APPR")).paging(true).fetch()
```

* For the stable paging:

```swift
var rs : ResourceSet = mc.resourceSet(osName: "mxwodetail").select(
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
var re : Resource = rs.fetchMember(uri: woUri, properties: nil)
```

Or using a MaximoConnector object
  
```swift
var re : Resource = mc.resource(uri: woUri, properties: nil)
```

By index (this method searches for a member Resource into the ResourceSet collection. This is an in-memory operation, no round trip to the server is required):
  
```swift
var re : Resource = rs.member(index: 0)
```

* In order to fetch additional information from the server for this Resource, consider using the load() and reload() methods available on the Resource object.

```swift
re.reload(properties: {"wonum", "status", "assetnum", "location", "wplabor.craft"})
```

Or simply
  
```swift
re.reload(properties: {"*"})
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
var rs : ResourceSet = mc.resourceSet(osName: "mxwodetail").pageSize(10)
```
 
* Navigate through the Work Order records that are kept in current page.

```swift
let count = rs.count()
for index in 0...count {
	var re : Resource = rs.member(index: index)
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
		var re : Resource = rs.member(index: index)
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

### Create a new Work Order (MXWODETAIL)
The following instructions show how to create a new work order by using the Maximo REST SDK.

#### Get a Work Order set
Using a previously obtained instance of the MaximoConnector object, perform the following operations:

* Get the ResourceSet for the MXWODETAIL object structure.

```swift
var rs : ResourceSet = mc.resourceSet(osName: "mxwodetail")
```

#### Creating a new Work Order
* Create a valid JSON object with the essential work order information such as: SITEID, ORGID, STATUS, etc.

For non-lean format, add the prefix before the attribute:
  
```swift
var jo : [String: Any] = [:]
jo["spi:siteid"] = "BEDFORD"
jo["spi:orgid"] = "EAGLENA"
jo["spi:status"] = "WAPPR"
var re : Resource = rs.create(jo: jo, properties: nil)
```

For lean, skip the prefix, using the attribute directly:
  
```swift
var jo : [String: Any] = [:]
jo["siteid"] = "BEDFORD"
jo["orgid"] = "EAGLENA"
jo["status"] = "WAPPR"
var re : Resource = rs.create(jo: jo, properties: nil)
```

* Working with children objects is just as simple. They may be part of the work order JSON as nested objects. The following example illustrates the creation of a Planned Labor record/object that is a child of the work order JSON object.

```swift
var wplJo : [String: Any] = ["skilllevel": "FIRSTCLASS", "craft": "ELECT"]
var wpLaborArray : [Any] = [wplJo]
jo["wplabor"] = wpLaborArray
```

#### Returning attribute values when creating a new Work Order
By default, the create operation does not return any content for the new created work order. Since many attribute values are auto-generated or automatically assigned at the server side based on the Maximo business logic, it often makes sense to get the final representation of the newly created resource.

Instead of re-selecting the work order again (which makes another round-trip to the server), it is simpler and faster just to get the resource content as part of the response for the work order creation process. You can do that by using one of the following statements:

For non-lean,

```swift
var re : Resource = rs.create(jo: jo, 
   properties: {"spi:wonum", "spi:status","spi:statusdate","spi:description"})
```

Or simply
		
```swift
var re : Resource = rs.create(jo: jo, properties: {"*"})
```

For lean,

```swift
var re : Resource = rs.create(jo: jo, properties: {"wonum", "status","statusdate", "description"})
```
 
Or simply
  
```swift
var re : Resource = rs.create(jo: jo, properties: {"*"})
```

### Update a Purchase Order (MXPO)

To update a resource, we can use either the update() or the merge() API methods. The difference between them is about how they handle the related child objects contained in the Resource. In this section, we discuss an example using the PO Resource (MXPO) to best illustrate which method you should use for each scenario. This example refers to two of the Maximo Business Object contained in the Resource, the PO (Parent) and the POLINE (Child).

Say you have an existing purchase order with 1 PO Line child object. If you need to update the PO to add a new PO Line entry, you should use the merge() API method. The merge process goes through the request <i>poline</i> object array and matches them up with the existing set of POLINE's (which is currently 1) and it determines which ones are new by comparing the value of the <i>rdf:about</i> property for each entry. If it finds a new entry on the request <i>poline</i> array, it creates a new POLINE and as result the PO object now contains 2 POLINE's. If it finds a match on the existing POLINE set, it updates the matched one with the request's POLINE content. If there are other POLINE's on the existing set that have no matches, they will be kept as is and won't be updated by this process.

Considering the same scenario described above, if we use the update() API method instead, only a single PO Line is kept as result. If there are other PO Lines, they are deleted during the method's execution. This occurs because the update process treats the request <i>poline</i> array as an atomic object. Therefore, it updates the whole POLINE set as a complete replacement. Thus, the update() method inserts the new PO Line or updates the matching PO Line and deletes all the other existing ones for that PO.

It is important to mention that this behavior applies exclusively for child objects. Root objects may be updated using either API methods.

In another scenario, suppose we have an existing PO with 3 POLINE's (1, 2, 3) and we would like to:

```
1. Delete POLINE #1
2. Update POLINE #3 
3. Create a new POLINE #4
```

To accomplish that, we could:

- Use the update() API method and send 3 POLINE's (2, 3, 4).
  - PO Line 2 is unchanged, PO Line 3 is modified and PO Line 4 is new.

The update() API method would verify that the request does not contain PO Line 1 and hence it deletes it, it skips the update of PO Line 2 (as there are no attributes that have been changed), updates PO Line 3 and adds the new one PO Line 4.

The resulting set now contains PO Lines 2, 3 and 4.

- So if we use the merge() API method instead - the only difference is that PO Line 1 is not be deleted and remains on the POLINE set.

Hence, the PO object now contains PO lines 1, 2, 3 and 4.

#### Update the POLINE in the Purchase Order

In this section, we create and add a new PO Line to the Purchase Order, and then call the update() API method for the PO object to either: update the existing PO Line or replace the existing PO Line by the a new one.

If the POLINE is matched, Maximo updates the existing <i>poline</i> with the new array.</br>
If the POLINE is not matched, Maximo deletes the existing <i>poline</i> array and creates a new one with the new array.

* Get a Resource from ResourceSet

```swift
var reSet : ResourceSet = mc.resourceSet(osName: "MXPO").fetch()
var poRes : Resource = reSet.member(index: 0)
```

* Build PO object hierarchy for adding a new child object

```swift
var polineObjIn : [String: Any] = ["polinenum": 1, "itemnum": "560-00", "storeloc": "CENTRAL"]
var polineArray : [Any] = [polineObjIn]
var poObj : [String: Any] = ["poline": polineArray]
```
* Create a new POLINE

```swift
poRes.update(jo: poObj, properties: nil)
```

* Build PO object hierarchy for updating a child object

```swift
var polineObjIn2 : [String: Any] = ["polinenum": 2, "itemnum": "0-0031", "storeloc": "CENTRAL"]
var polineArray2 : [Any] = [polineObjIn2]
var poObj : [String: Any] = ["poline": polineArray2]
```

* Update the Resource

```swift
poRes.update(jo: polineObj2, properties: nil)
```

After these statement's execution, we now have a PO with 1 POLINE. The execution flow is described as follows:

```
1. The server side framework attempts to locate a POLINE with the <i>polinenum</i> 2 and does not find any (as there is only a single POLINE with polinenum 1).
2. Then it adds a new POLINE with <i>polinenum</i> 2.
3. At last, it deletes all the remaining POLINE's that are missing from the <i>poline</i> array, that causes the removal of PO Line 1 from the POLINE set.
```

#### Merge the POLINE in the Purchase Order

In this section, we create and add a new PO Line to the Purchase Order, and then call the update() API method for the PO object to create a brand new POLINE set. Later, we create and add another PO Line to the same Purchase Order, and then call the merge() API method for the PO object to either: update the existing PO Line or add a new one.

If the POLINE is matched, Maximo updates the existing POLINE set with the updated elements in the array.
If the POLINE is not matched, Maximo adds the new elements contained in the <i>poline</i> array to the existing POLINE set and keeps the existing ones on the set.

* Get a Resource from ResourceSet

```swift
var reSet : ResourceSet = mc.resourceSet(osName: "MXPO").fetch()
var poRes : Resource = reSet.member(index: 1)
```

* Build PO object hierarchy for adding a new child object

```swift
var polineObjIn : [String: Any] = ["polinenum": 1, "itemnum": "560-00", "storeloc": "CENTRAL"]
var polineArray : [Any] = [polineObjIn]
var poObj : [String: Any] = ["poline": polineArray]
```

* Update the Resource	

```swift
poRes.update(jo: poObj, properties: nil) //This creates a POLINE with <i>polinenum</i> 1.
```

* Build PO object hierarchy for adding a new child object

```swift
var polineObjIn3 : [String: Any] = ["polinenum": 2, "itemnum": "0-0031", "storeloc": "CENTRAL"]
var polineArray3 : [Any] = [polineObjIn3]
var polineObj3 : [String: Any] = ["poline": polineArray3]
```

* Merge the Resource

```swift
poRes.merge(jo: polineObj3, properties: nil) //This creates a POLINE with <i>polinenum</i> 2.
```

After these statement's execution, we now have a PO with 2 POLINE's. The execution flow is described as follows:

```
1. The server side framework attempts to locate a POLINE with the <i>polinenum</i> 2 and does not find any (as there is only a POLINE with <i>polinenum</i> 1).
2. Then it adds a new POLINE with <i>polinenum</i> 2.
3. At last, it keeps the remaining PO Lines (e.g. in this case POLINE with <i>polinenum</i> 1) as is.
```
