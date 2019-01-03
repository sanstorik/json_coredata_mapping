import Foundation


private func spawnJSONIncteractionWith(json: [String: Any]) {
    let path = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("jsonOutput.txt")
    try? "".write(to: path, atomically: false, encoding: .utf8)
    
    if let fileUpdater = try? FileHandle(forUpdating: path) {
        fileUpdater.seekToEndOfFile()
        
        for obj in json {
            var className = String(obj.key[..<String.Index(encodedOffset: obj.key.count - 1)])
            className = className.prefix(1).uppercased() + className.dropFirst()
            
            if let dictArray = obj.value as? [[String: Any]], obj.key != "map" {
                let dict = dictArray[0]
                
                createClassFor(file: fileUpdater, name: className, with: dict)
                createCoreDataModelFor(file: fileUpdater, className: className, with: dict)
                fileUpdater.write("\n\n\n".data(using: .utf8)!)
            } else if let arrayValues = obj.value as? [String] {
                let value = arrayValues[0]
                
                let lowerCasedClassName = className.prefix(1).lowercased() + className.dropFirst()
                createClassFor(file: fileUpdater, name: className, with: [lowerCasedClassName: value])
                createCoreDataModelFor(file: fileUpdater, className: className, with: [lowerCasedClassName: value])
                fileUpdater.write("\n\n\n".data(using: .utf8)!)
            }
        }
    }
}


private func createClassFor(file: FileHandle, name: String, with object: [String: Any]) {
    file.write("   @objc(\(name))\n".data(using: .utf8)!)
    file.write("   public class \(name): NSManagedObject {\n".data(using: .utf8)!)
    createConstantsFor(file: file, with: object, className: name)
    file.write("\n\n".data(using: .utf8)!)
    createSaveDataMethodFor(file: file, with: object, className: name)
    file.write("\n\n".data(using: .utf8)!)
    createToDictionaryMethodFor(file: file, with: object, className: name)
    file.write("\n   }\n".data(using: .utf8)!)
}


private func createCoreDataModelFor(file: FileHandle, className: String, with object: [String: Any]) {
    let entityElement = XMLElement(name: "entity")
    entityElement.addAttribute(XMLNode.attribute(withName: "name",
                                                 stringValue: className) as! XMLNode)
    entityElement.addAttribute(XMLNode.attribute(withName: "representedClassName",
                                                 stringValue: ".\(className)") as! XMLNode)
    
    let entity = XMLDocument(rootElement: entityElement)
    
    for innerObj in object {
        var attributes = [XMLNode]()
        attributes.append(XMLNode.attribute(withName: "name",
                                             stringValue: innerObj.key) as! XMLNode)
        attributes.append(XMLNode.attribute(withName: "optional",
                                            stringValue: "YES") as! XMLNode)
        attributes.append(XMLNode.attribute(withName: "attributeType",
                                            stringValue: entityTypeFor(value: innerObj)) as! XMLNode)
        attributes.append(XMLNode.attribute(withName: "defaultValueString",
                                            stringValue: "0") as! XMLNode)
        attributes.append(XMLNode.attribute(withName: "usesScalarValueType",
                                            stringValue: entityTypeFor(value: innerObj) != "Date" ? "YES" : "NO") as! XMLNode)
        attributes.append(XMLNode.attribute(withName: "syncable",
                                            stringValue: "YES") as! XMLNode)
        
        let node = XMLNode.element(withName: "attribute", children: nil, attributes: attributes) as! XMLNode
        entityElement.addChild(node)
    }
    
    file.write(entity.xmlData(options: .nodePrettyPrint))
}


private func createConstantsFor(file: FileHandle, with object: [String: Any], className: String) {
    let staticLet = "\tstatic let"
    file.write("\(staticLet) SQL_TABLE = \"\(className)\"".data(using: .utf8)!)
    
    for key in object.keys {
        file.write("\n\(staticLet) \(key)Sync = \"\(key)\"".data(using: .utf8)!)
    }
}


private func createToDictionaryMethodFor(file: FileHandle, with object: [String: Any], className: String) {
    let funcToDictionary = "\tfunc toDictionary() -> [String: Any] {\n"
    
    file.write(funcToDictionary.data(using: .utf8)!)
    file.write("\t  var jsonDict = [String: Any]()".data(using: .utf8)!)
    
    for key in object.keys {
        file.write("\n\t  jsonDict[\(className).\(key)Sync] = \(key)".data(using: .utf8)!)
    }
    
    file.write("\n\t  return jsonDict".data(using: .utf8)!)
    file.write("\n\t}".data(using: .utf8)!)
}


private func createSaveDataMethodFor(file: FileHandle, with object: [String: Any], className: String) {
    let funcSaveData = "\tstatic func saveData(data: [String: Any], " +
            "with context: NSManagedObjectContext, \n\tisFromSync: Bool) -> \(className) {\n"
    
    file.write(funcSaveData.data(using: .utf8)!)
    file.write("\t  let object = \(className)(context: context)".data(using: .utf8)!)
    
    for innerObj in object {
        file.write(("\n\t  object.\(innerObj.key) = " +
            "AppCredentials.\(typeFor(value: innerObj))FromObject(object: data[\(innerObj.0)Sync])").data(using: .utf8)!)
    }
    
    file.write("\n\t  return object".data(using: .utf8)!)
    file.write("\n\t}".data(using: .utf8)!)
}


private func readJson() -> [String: Any]? {
    let path = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("jsonInput.txt")
    if let json = try? JSONSerialization.jsonObject(
        with: Data(contentsOf: path), options: JSONSerialization.ReadingOptions.mutableContainers),
        let jsonDict = json as? [String: Any] {
        return jsonDict
    }
    
    return nil
}


private func typeFor(value: (String, Any)) -> String {
    var type = "string"
    if value.1 is String {
        if NSDate.from(string: value.1 as! String) != nil {
            type = "date"
        } else {
            type = "string"
        }
    } else if value.1 is Int64 || value.1 is Int {
        type = "integer"
    } else if value.1 is Float || value.1 is Double {
        type = "float"
    } else if value.1 is Bool {
        type = "boolean"
    } else {
        type = "none"
    }
    
    return type
}


private func entityTypeFor(value: (String, Any)) -> String {
    var type = "String"
    if value.1 is String {
        if NSDate.from(string: value.1 as! String) != nil {
            type = "Date"
        } else {
            type = "String"
        }
    } else if value.1 is Int64 || value.1 is Int {
        type = "Integer 64"
    } else if value.1 is Float || value.1 is Double {
        type = "Float"
    } else if value.1 is Bool {
        type = "Boolean"
    }
    
    return type
}


fileprivate func main() {
    if let json = readJson() {
        spawnJSONIncteractionWith(json: json)
    }
}

main()

