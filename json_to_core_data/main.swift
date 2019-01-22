import Foundation


private func spawnJSONInteractionWith(json: [String: Any]) {
    let path = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("jsonOutput.txt")
    
    if !FileManager.default.fileExists(atPath: path.path) {
        FileManager.default.createFile(atPath: path.path, contents: nil)
    } else {
        try? "".write(to: path, atomically: false, encoding: .utf8)
    }
    
    if let fileUpdater = try? FileHandle(forUpdating: path) {
        for (key, json) in json {
            spawnEntityFor(file: fileUpdater, key: key, with: json)
        }
    }
}

private func spawnEntityFor(file: FileHandle, key: String, with object: Any) {
    var className = String(key[..<String.Index(encodedOffset: key.count - 1)])
    className = className.prefix(1).uppercased() + className.dropFirst()
    var value = [String: Any]()
    
    if let dictArray = object as? [[String: Any]] {
        value = dictArray[0]
    } else if let arrayValues = object as? [String], arrayValues.count > 0 {
        let lowerCasedClassName = className.prefix(1).lowercased() + className.dropFirst()
        value = [lowerCasedClassName: arrayValues[0]]
    } else if let dict = object as? [String: Any] {
        className = key.prefix(1).uppercased() + key.dropFirst()
        value = dict
    }
    
    spawnEntityFor(file: file, className: className, with: value)
}


private func spawnEntityFor(file: FileHandle, className: String, with object: [String: Any]) {
    file.write("\n\n\n".data(using: .utf8)!)
    createClassFor(file: file, name: className, with: object)
    createCoreDataModelFor(file: file, className: className, with: object)
}


private func createClassFor(file: FileHandle, name: String, with values: [String: Any]) {
    file.write("   public class \(name): NSManagedObject, UpdatableEntity {\n".data(using: .utf8)!)
    createConstantsFor(file: file, with: values, className: name)
    file.write("\n\n".data(using: .utf8)!)
    createSpawnMethodFor(file: file, with: values, className: name)
    file.write("\n\n".data(using: .utf8)!)
    createUpdateMethodFor(file: file, with: values, className: name)
    file.write("\n\n".data(using: .utf8)!)
    createToDictionaryMethodFor(file: file, with: values, className: name)
    file.write("\n   }\n".data(using: .utf8)!)
}


private func createCoreDataModelFor(file: FileHandle, className: String, with values: [String: Any]) {
    let entityElement = XMLElement(name: "entity")
    entityElement.addAttribute(XMLNode.attribute(withName: "name",
                                                 stringValue: className) as! XMLNode)
    entityElement.addAttribute(XMLNode.attribute(withName: "representedClassName",
                                                 stringValue: ".\(className)") as! XMLNode)
    
    let entity = XMLDocument(rootElement: entityElement)
    
    for innerObj in values {
        let modifiedKey = forbiddenVariableNames[innerObj.key] ?? innerObj.key
        let type = coreDataTypeFor(value: innerObj)
        let attributes = [
            XMLNode.attribute(withName: "name", stringValue: modifiedKey) as! XMLNode,
            XMLNode.attribute(withName: "optional", stringValue: "YES") as! XMLNode,
            XMLNode.attribute(withName: "attributeType", stringValue: type) as! XMLNode,
            XMLNode.attribute(withName: "defaultValueString", stringValue: "0") as! XMLNode,
            XMLNode.attribute(withName: "usesScalarValueType",
                              stringValue: type == "Date" ? "NO" : "YES") as! XMLNode,
            XMLNode.attribute(withName: "syncable", stringValue: "YES") as! XMLNode
        ]
        
        let node = XMLNode.element(withName: "attribute", children: nil, attributes: attributes) as! XMLNode
        entityElement.addChild(node)
    }
    
    file.write(entity.xmlData(options: .nodePrettyPrint))
    
    for innerObj in values {
        if isStorageType(value: innerObj.1) {
            spawnEntityFor(file: file, key: innerObj.0, with: innerObj.1)
        }
    }
}


private func createConstantsFor(file: FileHandle, with values: [String: Any], className: String) {
    let staticLet = "\tstatic let"
    let staticVar = "\tstatic var"
    file.write("\(staticVar) globalName: String { return \"\(className)\" }".data(using: .utf8)!)
    
    let id = values.keys.first { $0.starts(with: "id") } ?? "id"
    file.write("\(staticVar) globalIdKey: String { return \(id)}".data(using: .utf8)!)
    
    for key in values.keys {
        file.write("\n\(staticLet) \(key)Sync = \"\(key)\"".data(using: .utf8)!)
    }
}


private func createToDictionaryMethodFor(file: FileHandle, with values: [String: Any], className: String) {
    let funcToDictionary = "\tfunc toDictionary() -> [String: Any] {\n"
    
    file.write(funcToDictionary.data(using: .utf8)!)
    file.write("\t   var jsonDict = [String: Any]()".data(using: .utf8)!)
    
    for key in values.keys {
        let modifiedKey = forbiddenVariableNames[key] ?? key
        file.write("\n\t   jsonDict[\(className).\(key)Sync] = \(modifiedKey)".data(using: .utf8)!)
    }
    
    file.write("\n\t   return jsonDict".data(using: .utf8)!)
    file.write("\n\t}".data(using: .utf8)!)
}


private func createSpawnMethodFor(file: FileHandle, with values: [String: Any], className: String) {
    file.write("""
        static func create(from json: [String: Any], in context: NSManagedObjectContext) -> Self {
            let entity = self.init(context: context)
            entity.update(from: json)
            return entity
        }
        """.data(using: .utf8)!)
    
    file.write("\n\t}".data(using: .utf8)!)
}



private func createUpdateMethodFor(file: FileHandle, with values: [String: Any], className: String) {
    let funcSaveData = "func update(from data: [String: Any]) {\n"
    
    file.write(funcSaveData.data(using: .utf8)!)
    
    for innerObj in values {
        let type = cocoaTypeFor(value: innerObj)
        let modifiedKey = forbiddenVariableNames[innerObj.key] ?? innerObj.key
        file.write(("\n\t   \(modifiedKey) = " +
            "AppCredentials.\(type)From(object: data[\(className).\(innerObj.0)Sync])").data(using: .utf8)!)
    }
    
    file.write("\n\t}".data(using: .utf8)!)
}


private func readJson() -> [String: Any]? {
    let path = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("jsonInput.txt")
    if let json = try? JSONSerialization.jsonObject(with: Data(contentsOf: path),
                                                    options: .mutableContainers),
        let jsonDict = json as? [String: Any] {
        return jsonDict
    }
    
    return nil
}


let forbiddenVariableNames = ["isDeleted" : "isDeletedValue",
                              "description": "descriptionValue"]


fileprivate func main() {
    if let json = readJson() {
        spawnJSONInteractionWith(json: json)
    }
}

main()

