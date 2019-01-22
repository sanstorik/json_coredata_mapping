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
public class OrderDecedentLink: NSManagedObject, UpdatableEntity {
	static var globalName: String { return "OrderDecedentLink" }
	static var globalIdKey: String { return idOrder }
	static let idOrderSync = "idOrder"
	static let isDeletedSync = "isDeleted"
	static let idSync = "id"
	static let createdSync = "created"
	static let idDecedentSync = "idDecedent"
	static let modifiedSync = "modified"

	static func create(from json: [String: Any], in context: NSManagedObjectContext) -> Self {
    	  let entity = self.init(context: context)
    	  entity.update(from: json)
    	  return entity
	}

	func update(from data: [String: Any]) {
	   idOrder = AppCredentials.int64From(object: data[OrderDecedentLink.idOrderSync])
	   isDeletedValue = AppCredentials.boolFrom(object: data[OrderDecedentLink.isDeletedSync])
	   id = AppCredentials.int64From(object: data[OrderDecedentLink.idSync])
	   created = AppCredentials.dateFrom(object: data[OrderDecedentLink.createdSync])
	   idDecedent = AppCredentials.int64From(object: data[OrderDecedentLink.idDecedentSync])
	   modified = AppCredentials.dateFrom(object: data[OrderDecedentLink.modifiedSync])
	}

	func toDictionary() -> [String: Any] {
	   var jsonDict = [String: Any]()
	   jsonDict[OrderDecedentLink.idOrderSync] = idOrder
	   jsonDict[OrderDecedentLink.isDeletedSync] = isDeletedValue
	   jsonDict[OrderDecedentLink.idSync] = id
	   jsonDict[OrderDecedentLink.createdSync] = created
	   jsonDict[OrderDecedentLink.idDecedentSync] = idDecedent
	   jsonDict[OrderDecedentLink.modifiedSync] = modified
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
public class Volume: NSManagedObject, UpdatableEntity {
	static var globalName: String { return "Volume" }
	static var globalIdKey: String { return id }
	static let lengthSync = "length"
	static let widthSync = "width"
	static let idSync = "id"
	static let heightSync = "height"

	static func create(from json: [String: Any], in context: NSManagedObjectContext) -> Self {
    	  let entity = self.init(context: context)
    	  entity.update(from: json)
    	  return entity
	}

	func update(from data: [String: Any]) {
	   length = AppCredentials.int64From(object: data[Volume.lengthSync])
	   width = AppCredentials.int64From(object: data[Volume.widthSync])
	   id = AppCredentials.int64From(object: data[Volume.idSync])
	   height = AppCredentials.int64From(object: data[Volume.heightSync])
	}

	func toDictionary() -> [String: Any] {
	   var jsonDict = [String: Any]()
	   jsonDict[Volume.lengthSync] = length
	   jsonDict[Volume.widthSync] = width
	   jsonDict[Volume.idSync] = id
	   jsonDict[Volume.heightSync] = height
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
