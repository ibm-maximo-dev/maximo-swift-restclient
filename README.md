# MaximoRESTClient

The Maximo REST client library provides a set of driver API's which can be consumed by an iOS based application that would like to interface with a Maximo instance. The client API's use the Maximo NextGen REST/JSON API's which were originally inspired by Linked Data principles. Using this API you would be able to create, update, delete and query Maximo business objects (Using Maximo Integration Framework Object Structures).

The main components of this client library include:

- [MaximoConnector]: The driver API that establishes the authenticated HTTP session with the Maximo server. It is used by the other API's to create, update, delete and query Maximo data. The authentication and the other basic information can be configured using an [Options] object.

- [ResourceSet]: This API represents a collection of Maximo resources of a given type. The type is determined by the Object Structure definition it refers to. In effect this API is equivalent to the concept of Maximo's MboSet.

- [Resource]: Each member of a ResourceSet is represented by an instance of this class. This is equivalent to to the concept of Mbo in Maximo.

- [Attachment and AttachmentSet]: These API's represent the attached docs (doclinks) in Maximo. These are always associated with some Resource.

Currently the only supported data format is JSON and we have 2 flavors of JSON – the lean and the namespaced. The lean format is supported starting with the Maximo 7.6 version and is the recommended format to use (as it uses less bandwidth).

## Pre-requisites

- Xcode
- Cocoapods
- Maximo 7.6

## Getting Started

1. Open Terminal and navigate to the directory that contains your Xcode project.

> **Now at this point, if your project is already configured to use Cocoapods, you can skip the next step.**

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
pod 'MaximoRESTClient', '1.0.0'
```

5. You now need to tell CocoaPods to install the dependencies for your project.
Enter the following command in Terminal:
```
pod install
```

6. After the dependencies have been successfully installed, Cocoapods creates a new <YOUR PROJECT NAME>.xcworkspace file and a Pods folder that contains all the project's dependencies.
Now just open the .xcworkspace file with Xcode and you are all set!
