# MaximoRESTSDK

The Maximo REST SDK framework provides a set of driver APIs that can be consumed by an iOS-based application that interfaces with an instance of IBM Maximo Asset Management. The SDK APIs use the Maximo NextGen REST/JSON APIs, which were originally inspired by Linked Data principles. By using this API, you can create, update, delete, and query Maximo business objects by using Maximo integration framework object structures.

The following components are included in this SDK framework:

- [MaximoConnector]: The driver API that establishes the authenticated HTTP session with the Maximo server. It is used by the other APIs to create, update, delete, and query Maximo data. The authentication and the other basic information can be configured by using an [Options] object.

- [ResourceSet]: This API represents a collection of Maximo resources of a given type. The type is determined by the object structure definition it refers to. This API is equivalent to the concept of the MboSet in Maximo Asset Management.

- [Resource]: Each member of a ResourceSet is represented by an instance of this class. This API is equivalent to the concept of a Maximo business object.

- [Attachment and AttachmentSet]: These APIs represent the attached documents, doclinks, in Maximo Asset Management. These attachments are always associated with a resource object.

Currently the only supported data format is JSON, and there are two types available: the lean and the namespaced. Since the release of Maximo Asset Management version 7.6, the lean format is the recommended format, because it consumes fewer network resources.

## Prerequisites

- Xcode
- Cocoapods
- Maximo Asset Management version 7.6

## Getting started

### Cocoapods installation

Open a terminal session and enter the following command:
```
sudo gem install cocoapods
```

### Add SSH key to your GitHub account

Generate the RSA key for your GitHub user account:
```
ssh-keygen -t rsa -b 4096 -C git@github.ibm.com
```

Paste the contents of the <i>id_rsa.pub</i> file, which is described here: https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/


### Project setup

1. In a terminal session, navigate to the directory that contains your Xcode project.

> **Note**: If your project is already configured to use Cocoapods, you can skip the next step.

2. Enter the following command:
```
pod init
```

3. Type the following command to open the Podfile by using Xcode for editing:
```
open -a Xcode Podfile
```

The following code shows the default Podfile:

```
# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target '<YOUR PROJECT NAME>' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for <YOUR PROJECT NAME>

end
```

Delete the # and space before "platform" and delete the other lines that start with "#".
Your Podfile now looks like the following example:
For this particular example, the application were built in ios version 11.2. 

```
platform :ios, '11.2'

target '<YOUR PROJECT NAME>' do
  use_frameworks!

end
```
4. If your project has dependecies, add the dependency line to your Podfile, immediately after "use_frameworks!":

```
pod '<dependency name>', '1.0.0'
```

>**Note**: In the example for this module, there are no dependencies on the CocoaPods library, so it is not necessary add anything else.


5. Install the dependencies for your project by entering the following command in the terminal session:
```
pod install
```

After the dependencies are successfully installed, Cocoapods creates a new <YOUR PROJECT NAME>.xcworkspace file and a Pods folder that contains all the project's dependencies.
Now, open the .xcworkspace file by using Xcode, and you are ready to go.

## Usage

The Maximo resources, which are object structures, represent a graph of related Maximo objects, which are Maximo business objects (MBOs), that provides an atomic view/object to create, update, delete, and query the related set of MBOs. 
This documentation provides several examples that includes some of the most used Maximo business objects, such as work order, purchase order, and service request, to demonstrate how to use the Maximo REST SDK.

>**Note**: Some of the test cases that are described in this documentation are included in the <i>MaximoRESTSDKTests.swift</i> file.

### Query work orders from a ResourceSet (MXWODETAIL)

The following instructions show how to query a work order from Maximo Asset Management by using the Maximo REST SDK framework.

#### Connect to Maximo Asset Management

In order to establish a connection, you must set up authentication and environment information in the Options object.

* For authentication, provide the user credentials and the authentication mechanism. The following authentication methods are supported: "maxauth", "basic", and "form". The following sample code uses the maxauth authentication method:

```swift
var option : 
   Options = Options().user(user: "maxadmin").password(password: "maxadmin").auth(authMode: "maxauth")
```

> **Note**: For Maximo Asset Management Multitenancy, include the tenant code, "00" in this example, by using the following statement:

```swift
var option : Options = 
  Options().user(user: "maxadmin").password(password: "maxadmin").
  auth(authMode: "maxauth").mt(mtMode: true).tenantCode(tenantCode: "00")
```

* For environment settings, specify the JSON format type, host or IP, and port number to use, as shown in the following sample code:

```swift
option.host(host: "127.0.0.1").port(port: 7001).lean(lean: true)
```

* By using the Options object that you created in the previous steps, connect to Maximo Asset Management by using a MaximoConnector instance. You can also enable the debug mode to increase the level of verbosity in the system logs.

```swift
var mc : MaximoConnector = MaximoConnector(options: option).debug(enabled: true)
mc.connect()
```

* Or, you can directly use the following code statement:

```swift
var mc : MaximoConnector = 
  MaximoConnector(options: Options().user(user: "maxadmin").password(password: "maxadmin").
    lean(lean: true).auth(authMode: "maxauth").host(host: "127.0.0.1").port(port: 7001))
mc.connect()
```

#### Query work orders

* Create a ResourceSet object that holds a collection of work orders that are in the <i>Approved</i> state. The selected records are identified by the WONUM and STATUS properties. You can use a couple of strategies to create the object.

By object structure name:
  
```swift
var rs : ResourceSet = mc.resourceSet(osName: "mxwodetail").select(properties: {"wonum", "status"}).
   _where(whereClause: QueryWhere()._where(name: "status").equalTo(value: "APPR")).fetch()
```

By RESTful URI:
  
```swift
var rs : ResourceSet = mc.resourceSet(url: "http://127.0.0.1:7001/maximo/oslc/os/mxwodetail").select(
   properties: {"wonum", "status"})._where(whereClause: QueryWhere()._where(name: "status").
   equalTo(value: "APPR")).fetch()
```

For handling large data sets, a set of pagination methods are available in this framework that allows you to navigate back and forth through your data records.

* You can define an arbitrary page size, and the obtained results are be limited by this value.
  
```swift
var rs : ResourceSet = mc.resourceSet(osName: "mxwodetail").select(properties: {"wonum", "status"}).
   _where(whereClause: QueryWhere()._where(name: "status").equalTo(value: "APPR")).
   pageSize(10).fetch()
```

* You can also use the default paging strategy, which assumes that a default page size is configured in the Resource's object structure. If no page size is configured, this directive is ignored, and all the records that match the query are immediately returned:

```swift
var rs : ResourceSet = mc.resourceSet(osName: "mxwodetail").select(properties: {"wonum", "status"}).
   _where(whereClause: QueryWhere()._where(name: "status").equalTo(value: "APPR")).
   paging(type: true).fetch()
```

* Another paging strategy that is available in this framework is named <i>stable paging</i>.
The stable paging keeps a server-side reference to an MboSet object, which allows you to navigate through the records in an isolated session:

```swift
var rs : ResourceSet = mc.resourceSet(osName: "mxwodetail").select(properties: {"wonum", "status"}).
   _where(whereClause: QueryWhere()._where(name: "status").equalTo(value: "APPR")).
   stablePaging(type: true).fetch()
```

* Move to the next or to the previous page:

```swift 
rs.nextPage()
rs.previousPage()
```

** For stable paging, this framework currently supports only forward scrolling, so a call to the previousPage() method results in an API error.

* Get the full ResourceSet as a JSON object:

```swift
var jo : [String: Any] = rs.toJSON()
```

> **Note**: This API supports the conversion of JSON to Data objects by using the following statement:

```swift
var jodata : Data = rs.toJSONBytes()
```

* Each Resource object is associated with a unique URI. You can get one specific work order record by using its unique URI. By using the following example, you can directly fetch the work order object that has the _QkVERk9SRC8xMDAw URI:
  
```swift
var woUri : String = "http://127.0.0.1:7001/maximo/oslc/os/mxwodetail/_QkVERk9SRC8xMDAw"
```

By using the ResourceSet object:
  
```swift
var re : Resource = rs.fetchMember(uri: woUri, properties: nil)
```

Or by using a MaximoConnector object:
  
```swift
var re : Resource = mc.resource(uri: woUri, properties: nil)
```

By index, which searches for a member of the Resource object in the ResourceSet collection. The index method is an in-memory operation, so no round trip to the server is required:
  
```swift
var re : Resource = rs.member(index: 0)
```

* To fetch additional information from the server for this Resource object, you can use the load() and reload() methods that are available on the Resource object:

```swift
re.reload(properties: {"wonum", "status", "assetnum", "location", "wplabor.craft"})
```

Or you can use use * to fetch all properties:
  
```swift
re.reload(properties: {"*"})
```

* Get the work order as a JSON dictionary or as a Data object:

```swift
var jo : [String: Any] = re.toJSON()
var joBytes : Data = re.toJSONBytes()
```

#### Traverse work orders 
In some cases, you might be required to traverse a work order collection. This section introduces some helpful methods that are available in this framework and that can be used for iterating over a ResourceSet.

* Get a work order set from the Maximo server:

```swift
var rs : ResourceSet = mc.resourceSet(osName: "mxwodetail").pageSize(pageSize: 10)
```
 
* Navigate through the work order records that are kept in the current page:

```swift
let count = rs.count()
for index in 0...count {
	var re : Resource = rs.member(index: index)
	// Perform operations with the obtained Resource object.
}
```

* Navigate through all of the work order records that are available in the ResourceSet object:

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

#### Disconnect from Maximo Asset Management

* When you are done, end the Maximo Asset Management user session.

```swift
mc.disconnect()
```

### Create a new work order (MXWODETAIL)
The instructions that are contained in this section show how to create a new work order record by using the Maximo REST SDK.

#### Get a work order ResourceSet object
By using a previously obtained instance of the MaximoConnector object, you can use the following statement:

* Get the ResourceSet object for the MXWODETAIL object structure.

```swift
var rs : ResourceSet = mc.resourceSet(osName: "mxwodetail")
```

#### Create a work order
* Create a valid JSON object that contains the essential work order information, such as the SITEID, ORGID, STATUS, ESTDUR fields.

For the namespaced format, add the prefix before the attribute name:
  
```swift
var jo : [String: Any] = [:]
jo["spi:siteid"] = "BEDFORD"
jo["spi:orgid"] = "EAGLENA"
jo["spi:status"] = "WAPPR"
jo["spi:estdur"] = 5.0
var re : Resource = rs.create(jo: jo, properties: nil)
```

For the lean format, skip the prefix by using the attribute name directly:
  
```swift
var jo : [String: Any] = [:]
jo["siteid"] = "BEDFORD"
jo["orgid"] = "EAGLENA"
jo["status"] = "WAPPR"
jo["estdur"] = 5.0
var re : Resource = rs.create(jo: jo, properties: nil)
```

* Working with child objects is just as simple. They can be part of the work order JSON object as nested objects. The following example shows the creation of a Planned Labor object that is a child of the work order object:

```swift
var wplJo : [String: Any] = ["skilllevel": "FIRSTCLASS", "craft": "ELECT"] // Planned Labor object
var wpLaborArray : [Any] = [wplJo] // Planned Labor array
woJo["wplabor"] = wpLaborArray // Assigning Planned Labor array to Work Order object
```

#### Return attribute values when creating a work order
By default, the create operation does not return any content for the newly created work order. Because many attribute values are autogenerated or automatically assigned on the server-side based on the Maximo business logic, it often makes sense to get the final representation of the newly created resource.

Instead of reselecting the work order, which makes another round trip to the server, it is usually faster to get the resource content as part of the response for the work order creation process. You can do that by using one of the following statements:

For the namespaced format, use:

```swift
var re : Resource = rs.create(jo: jo, 
   properties: {"spi:wonum", "spi:status","spi:statusdate","spi:description"})
```

For the lean format, use:

```swift
var re : Resource = rs.create(jo: jo, properties: {"wonum", "status","statusdate", "description"})
```
 
Or simply use * to fetch all attributes:
  
```swift
var re : Resource = rs.create(jo: jo, properties: {"*"})
```

### Update a purchase order (MXPO)

To update a resource, you can use the update() or the merge() API methods. The difference between them is how they handle the related child objects that are contained in the resource. This section discusses an example of using the PO resource (MXPO) to illustrate which method you might use for each scenario. This example refers to two of the Maximo business object that are contained in the resource: the PO, which is a parent object, and the POLINE, which is a child object.

For example, you have an existing purchase order that contains one POLINE child object.

If you need to update the PO to add a new POLINE object, you must use the merge() API method. The merge process goes through the request <i>poline</i> object array and matches them up with the existing set of POLINE objects, which is currently only one, and it determines which objects are new by comparing the value of the <i>rdf:about</i> property for each entry. If the merge process finds a new entry on the request <i>poline</i> array, it creates a new POLINE object, and, as a result, the PO object now contains two POLINE objects. If the merge process finds a match on the existing POLINE set, it updates the matched one with the request's POLINE content. If there are other POLINE objects in the existing set that have no matches, they are kept as is and are not updated by this process.

Now, consider an example in which you have the same purchase order with one PO Line entry, and you're assigning a new <i>poline</i> array, which contains a new PO Line, to the PO object, but this time you are using the update() API method instead. What is the expected result for this operation?

The update() method behaves differently in the way that it handles existing child objects. Thus, any existing PO Lines are deleted during this method's execution. This deletion occurs because the update process treats the request's <i>poline</i> array as an atomic object. Therefore, it updates the whole POLINE set as a complete replacement. Therefore, the update() method inserts the new PO Line or updates the matching PO Line and deletes all the existing lines for that PO.

It is important to mention that this behavior applies exclusively for child objects. Root objects can be updated by using either API methods.

In another scenario, suppose you have an existing PO object that has three POLINE child objects (1, 2, 3), and you want to complete the following tasks:

```
1. Delete POLINE #1
2. Update POLINE #3 
3. Create a new POLINE #4
```

To complete these tasks, you must take the following actions:

- Use the update() API method and send three POLINE objects: 2, 3, 4.
  - PO Line 2 is unchanged, PO Line 3 is modified, and PO Line 4 is new.

The update() API method verifies that the request does not contain PO Line 1 and deletes it. The update() method then skips the update of PO Line 2, because no attributes were changed, and it updates PO Line 3 and adds the new PO Line 4.

The resulting set now contains PO Lines 2, 3, and 4.

- So, if you use the merge() API method instead, the only difference is that PO Line 1 is not deleted and remains in the POLINE set.

Hence, the PO object now contains PO lines 1, 2, 3, and 4.

#### Update the POLINE object in the purchase order

In this section, you create and add a new PO Line to the purchase order and then call the update() API method for the PO object to either update the existing PO Line or replace the existing PO Line with a new one.

If the POLINE is matched, Maximo Asset Management updates the existing <i>poline</i> with the new array.</br>
If the POLINE is not matched, Maximo Asset Management deletes the existing <i>poline</i> array and creates a new one with the new array.

* Get a Resource from the ResourceSet:

```swift
var reSet : ResourceSet = mc.resourceSet(osName: "MXPO").fetch()
var poRes : Resource = reSet.member(index: 0)
```

* Build the PO object hierarchy for adding a new child object:

```swift
var polineObjIn : [String: Any] = ["polinenum": 1, "itemnum": "560-00", "storeloc": "CENTRAL"]
var polineArray : [Any] = [polineObjIn]
var poObj : [String: Any] = ["poline": polineArray]
```
* Create a new POLINE:

```swift
poRes.update(jo: poObj, properties: nil)
```

> **Note**: At this point, you must have a PO object that has a single POLINE whose <i>polinenum</i> is 1.

* Build the PO object hierarchy for updating a child object:

```swift
var polineObjIn2 : [String: Any] = ["polinenum": 2, "itemnum": "0-0031", "storeloc": "CENTRAL"]
var polineArray2 : [Any] = [polineObjIn2]
var poObj : [String: Any] = ["poline": polineArray2]
```

* Update the Resource:

```swift
poRes.update(jo: polineObj2, properties: nil)
```

After these statements are executed, you now have a PO object that contains POLINE 1. The following steps describe the execution flow:

```
1. The server-side framework attempts to locate a POLINE that has the polinenum 2 and 
does not find any, because there is only a single POLINE that has polinenum 1.

2. Then, it adds a new POLINE that has polinenum 2.

3. At last, it deletes all the remaining POLINEs that are missing from the poline array, 
which causes the removal of PO Line 1 from the POLINE set.
```

#### Merge the POLINE in the purchase order

In this section, you create and add a new PO Line to the purchase order and then call the update() API method for the PO object to create a brand new POLINE set. Later, you create and add another PO Line to the same purchase order and then call the merge() API method for the PO object to either update the existing PO Line or add a new one.

If the POLINE is matched, Maximo Asset Management updates the existing POLINE set with the updated elements in the array.
If the POLINE is not matched, Maximo Asset Management adds the new elements that are contained in the <i>poline</i> array to the existing POLINE set and keeps the existing ones in the set.

* Get a Resource from the ResourceSet object:

```swift
var reSet : ResourceSet = mc.resourceSet(osName: "MXPO").fetch()
var poRes : Resource = reSet.member(index: 1)
```

* Build the PO object hierarchy for adding a new child object:

```swift
var polineObjIn : [String: Any] = ["polinenum": 1, "itemnum": "560-00", "storeloc": "CENTRAL"]
var polineArray : [Any] = [polineObjIn]
var poObj : [String: Any] = ["poline": polineArray]
```

* Update the Resource:

```swift
poRes.update(jo: poObj, properties: nil) //This creates a POLINE with polinenum 1.
```

> **Note**: At this point, you must have a PO object that has a single POLINE with <i>polinenum</i> 1.

* Build the PO object hierarchy for adding a new child object:

```swift
var polineObjIn3 : [String: Any] = ["polinenum": 2, "itemnum": "0-0031", "storeloc": "CENTRAL"]
var polineArray3 : [Any] = [polineObjIn3]
var polineObj3 : [String: Any] = ["poline": polineArray3]
```

* Merge the Resource:

```swift
poRes.merge(jo: polineObj3, properties: nil) //This creates a POLINE with polinenum 2.
```

After these statements are run, you now have a PO object that has two POLINE objects. The following steps describe the execution flow:

```
1. The server-side framework attempts to locate a POLINE that has the polinenum 2 and 
does not find any, because there is only a POLINE with polinenum 1.

2. Then, it adds a new POLINE that has polinenum 2.

3. At last, it keeps the remaining PO Lines, in this case POLINE with polinenum 1, as is.
```

### Delete a service request (MXSR)
This section briefly demonstrates how to delete an existing service request by using the Maximo REST SDK.

#### Get an existing service request
* Get a ResourceSet for the service request object:

```swift
var rs : ResourceSet = mc.resourceSet(osName: "mxsr")
```

* Get an existing service request object:

The following example is a unique service request URI:
  
```swift
var venUri : String = "http://localhost:7001/maximo/oslc/os/mxsr/_U1IvMTE3Mw--"
```

By using the ResourceSet object:
  
```swift
var re : Resource = rs.fetchMember(uri: srUri)
```

Or by using a MaximoConnector object:
  
```swift
var re : Resource = mc.resource(uri: srUri)
```

Fetch a Resource object by index:
  
```swift
var re : Resource = rs.member(index: 0)
```

#### Delete the service request
A resource removal can be done by the following methods:

* Calling the deleteResource() method of the MaximoConnector object:

```swift
mc.deleteResource(uri: srUri)
```

* Calling the delete() method of the Resource object:

```swift
re.delete()
```
### Attachments
Attachments in Maximo Asset Management are documents, files, or images that are attached to a resource, such as a work order or a service request.
The following examples show how to add and delete an attachment from a work order.

#### Create an attachment for an existing work order.
* Get a work order ResourceSet:

```swift
var rs : ResultSet = mc.resourceSet(osName: "mxwodetail")
```

* Get an existing work order from a ResourceSet:

The following example is of a unique URI for a work order:
  
```swift
String woUri = "http://127.0.0.1:7001/maximo/oslc/os/mxwodetail/_QkVERk9SRC8xMDAw"
```

By using the ResourceSet object:
  
```swift 
var re : Resource = rs.fetchMember(uri: woUri)
```

Or by using the MaximoConnector object:
  
```swift
var re : Resource = mc.resource(uri: woUri)
```

Fetching a Resource object by index number:
  
```swift 	
var re : Resource = rs.member(index: 0)
```

* Get the attachment set for the selected work order:

```swift
var ats : AttachmentSet = re.attachmentSet()
```

* Create sample document data:

```swift
var str : String = "This is a sample text file used to validate the Maximo REST SDK"
let data : Data = str.data(using: .utf8)
```

* Create a new Attachment object:

```swift
var att : Attachment = Attachment().name(name: "attachment.txt").description(description: "test")
   .data(data: data).meta(type: "FILE", storeas: "Attachments")
```

* Attach the file to the work order:

By default, you can use the following statement:
  
```swift
att = ats.create(att: att)
```

Or you can use its variant, which allows you to create attachments inside a given subfolder:
  
```swift
att = ats.create(relation: "customdoclink", att: att)
```

#### Get the data from the attachment
* Get an attachment from an AttachmentSet
* Get an existing attachment from Maximo Asset Management:

```swift
var att : Attachment = ats.member(index: 0)
```

* Get the attachment document data:

```swift
var data : Data = att.toDoc()
```

* Get the attachment metadata:

```swift
var attMeta : [String: Any] = att.toDocMeta()
var attMeta : [String: Any] = att.fetchDocMeta()
```

* Get the attachment by using the MaximoConnector object directly by calling the attachment URI:
Attachments are also uniquely identified by a URI. The following example shows how to get attachment 28, which is attached to a work order whose URI is _QkVERk9SRC8xMDAw:

```swift
var attUri : String = "http://host/maximo/oslc/os/mxwodetail/_QkVERk9SRC8xMDAw/DOCLINKS/28"
var att : Attachment = mc.attachment(uri: attUri)
var data : Data = mc.attachedDoc(uri: attUri)
var attMeta : [String: Any] = mc.attachmentDocMeta(uri: attUri)
```

#### Delete an attachment

* Get the Attachment object from the AttachmentSet:

Fetch an Attachment object by index number:
  
```swift
var att : Attachment = ats.member(index: 0)
```

Fetch an Attachment object by attachment URI:
  
```swift  
var att : Attachment = ats.fetchMember(uri: attUri)
var att : Attachment = mc.attachment(uri: attUri)
```

* Delete the Attachment object:

By using the Attachment object itself:
  
```swift
att.delete()
```

By using the MaximoConnector object to delete by using the Attachment URI:
  
```swift
mc.deleteAttachment(uri: attUri)
```

### Saved query
Maximo Asset Management supports a feature that is called a <i>Saved Query</i> where the user can define a prebuilt query for an application, such as the Work Order Tracking appplication, to retrieve a common set of data, such as a list of approved work orders. When publicly saved queries are available for Maximo applications, you can use the savedQuery() API method to select records by using defined filter criteria.
To use this feature, the user must grant the applicable permissions between the object structures and the authorized Maximo applications.

For example, consider the "OWNER IS ME" query for the WOTRACK application. If the MXWODETAIL object structure is set up to grant permissions to the WOTRACK application, you can do the following actions:

* Query the data:

```swift
var rs : ResourceSet = mc.resourceSet(osName: "mxwodetail").savedQuery(qsaved: SavedQuery().
   name(name: "WOTRACK:OWNER IS ME")).select(selectClause: "*").fetch()
```

This select clause queries all attributes for the filtered set of the MXWODETAIL object structure. As mentioned earlier, you can do a partial resource selection, such as select(selectClause: ["wonum", "status"]).

You can also do further filtering with the saved query.

* Query the data:

```swift
var rs : ResourceSet = mc.resourceSet(osName: "mxwodetail").savedQuery(qsaved: SavedQuery().
  name(name: "WOTRACK:OWNER IS ME"))._where(_where: QueryWhere()._where(name: "status").
  _in(values: ["APPR","WAPPR"])).select(selectClause: ["wonum", "status", "statusdate"]).fetch()
```

### Terms search
This feature allows you to perform a record-wide text search. To use it, you need to define a list of searchable attributes for the object structure.
In the following example, consider that the "description" field is marked as a searchable attribute for the OSLCMXSR object structure.
Now you can use the hasTerms() API method to define which terms you're searching for.

* Fetch the ResourceSet:
```swift
var res : ResourceSet = mc.resourceSet(osName: "oslcmxsr").hasTerms(terms: ["email", "finance"]).
   select(selectClause: ["description", "ticketid"]).pageSize(pageSize: 5).fetch()
```

The code statement selects all the OSLCMXSR records whose description contains either "email" or "finance".

### Action

Actions are functional components of a resource that perform specific tasks, such as changing the status of a resource or moving a resource from one location to another.
These tasks usually contain business logic.
The following example illustrates the use of the changeStatus action for the MXWODETAIL object structure.

* Get the ResourceSet for the MXWODETAIL object structure where status is Waiting for Approval:
```swift
var reSet : ResourceSet = mc.resourceSet(osName: "mxwodetail")._where(_where: QueryWhere().
   _where(name: "status").equalTo(value: "WAPPR")).fetch()
```

* Get the first member of the ResourceSet:
```swift
var re : Resource = reSet.member(index: 0)
```

* Build the request JSON object:
```swift
var jo : [String: Any] = ["status" : "APPR", "memo" : "This work order is approved."]
```

* Invoke the action:
```swift
re.invokeAction(actionName: "wsmethod:changeStatus", jo: jo)
```
