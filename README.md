# JSON to Core Data Core Generation. JSON Mapping.
Script helps to manage Core Data entities that are tightly connected with JSON model, received from server.
Creating a lot of varibles and creating a mapping model for them is painful, but using that script you can
spawn it to omit a lot of work.

HOW TO USE:
Create inputJson.txt and outputJson.txt in your homedirectory. Put your JSON inside inputJson file.

EXAMPLE:
Let's take a look at json first. We have one array of entity orderDecedentLink.
```
{
 "orderDecedentLinks": [
    {
      "id": 0,
      "idOrder": 0,
      "idDecedent": 0,
      "created": "2019-01-03T09:21:19.356Z",
      "modified": "2019-01-03T09:21:19.356Z",
      "isDeleted": true,
      "volume": {
        "id": 0,
        "length": 0,
        "width": 0,
        "height": 0
      }
    }
  ]
}
```

It will cause to spawn OrderDecedentLink with all variables and JSON mapping model inside.

```swift
public class OrderDecedentLink: NSManagedObject {
	static let SQL_TABLE = "OrderDecedentLink"
	static let idDecedentSync = "idDecedent"
	static let isDeletedSync = "isDeletedSync"
	static let modifiedSync = "modified"
	static let idSync = "id"
	static let idOrderSync = "idOrder"
	static let createdSync = "created"
  static let volumeSync = "volume"

	static func saveData(data: [String: Any], with context: NSManagedObjectContext, 
	       isFromSync: Bool) -> OrderDecedentLink {
	   let object = OrderDecedentLink(context: context)
	   object.idDecedent = AppCredentials.integerFromObject(object: data[idDecedentSync])
	   object.isDeletedSync = AppCredentials.booleanFromObject(object: data[isDeletedSync])
	   object.modified = AppCredentials.dateFromObject(object: data[modifiedSync])
	   object.id = AppCredentials.integerFromObject(object: data[idSync])
	   object.idOrder = AppCredentials.integerFromObject(object: data[idOrderSync])
	   object.created = AppCredentials.dateFromObject(object: data[createdSync])
     object.volume = AppCredentials.stringFromObject(object: data[volumeSync])
	   return object
	}

 	func toDictionary() -> [String: Any] {
	   var jsonDict = [String: Any]()
	   jsonDict[OrderDecedentLink.idDecedentSync] = idDecedent
	   jsonDict[OrderDecedentLink.isDeletedSync] = isDeletedSync
	   jsonDict[OrderDecedentLink.modifiedSync] = modified
	   jsonDict[OrderDecedentLink.idSync] = id
	   jsonDict[OrderDecedentLink.idOrderSync] = idOrder
	   jsonDict[OrderDecedentLink.createdSync] = created
     jsonDict[OrderItem.volumeSync] = volume
	   return jsonDict
	}
}

<entity name="OrderDecedentLink" representedClassName=".OrderDecedentLink">
    <attribute name="idDecedent" optional="YES" attributeType="Integer 64" defaultValueString="0" usesScalarValueType="YES" syncable="YES"></attribute>
    <attribute name="isDeletedSync" optional="YES" attributeType="Boolean" defaultValueString="0" usesScalarValueType="YES" syncable="YES"></attribute>
    <attribute name="modified" optional="YES" attributeType="Date" defaultValueString="0" usesScalarValueType="NO" syncable="YES"></attribute>
    <attribute name="id" optional="YES" attributeType="Integer 64" defaultValueString="0" usesScalarValueType="YES" syncable="YES"></attribute>
    <attribute name="idOrder" optional="YES" attributeType="Integer 64" defaultValueString="0" usesScalarValueType="YES" syncable="YES"></attribute>
    <attribute name="created" optional="YES" attributeType="Date" defaultValueString="0" usesScalarValueType="NO" syncable="YES"></attribute>
    <attribute name="volume" optional="YES" attributeType="String" defaultValueString="0" usesScalarValueType="YES" syncable="YES"></attribute>
</entity>

```


Also there is a volume DTO inside OrderDecedentLink, so volume class will be created as well.

```swift
public class Volume: NSManagedObject {
	static let SQL_TABLE = "Volume"
	static let widthSync = "width"
	static let heightSync = "height"
	static let idSync = "id"
	static let lengthSync = "length"

	static func saveData(data: [String: Any], with context: NSManagedObjectContext, 
	   isFromSync: Bool) -> Volume {
	  let object = Volume(context: context)
	  object.width = AppCredentials.integerFromObject(object: data[widthSync])
	  object.height = AppCredentials.integerFromObject(object: data[heightSync])
	  object.id = AppCredentials.integerFromObject(object: data[idSync])
	  object.length = AppCredentials.integerFromObject(object: data[lengthSync])
	  return object
	}

	func toDictionary() -> [String: Any] {
	  var jsonDict = [String: Any]()
	  jsonDict[Volume.widthSync] = width
	  jsonDict[Volume.heightSync] = height
	  jsonDict[Volume.idSync] = id
	  jsonDict[Volume.lengthSync] = length
	  return jsonDict
	}
}

<entity name="Volume" representedClassName=".Volume">
    <attribute name="width" optional="YES" attributeType="Integer 64" defaultValueString="0" usesScalarValueType="YES" syncable="YES"></attribute>
    <attribute name="height" optional="YES" attributeType="Integer 64" defaultValueString="0" usesScalarValueType="YES" syncable="YES"></attribute>
    <attribute name="id" optional="YES" attributeType="Integer 64" defaultValueString="0" usesScalarValueType="YES" syncable="YES"></attribute>
    <attribute name="length" optional="YES" attributeType="Integer 64" defaultValueString="0" usesScalarValueType="YES" syncable="YES"></attribute>
</entity>
```

NOTE: Currently It doesn't deal with relationships in core data (so you'll have to handle them manually).
