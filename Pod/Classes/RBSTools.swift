//
//  RBSTools.swift
//  Pods
//
//  Created by Max Baumbach on 03/05/2017.
//
//

import RealmSwift
import AVFoundation

extension Object {
    var primaryProperty: Property? {
        return objectSchema.primaryKeyProperty ?? objectSchema.properties.first
    }

    var primaryValueText: String {
        guard let property = primaryProperty else { return "no properties" }
        return valueText(property: property)
    }

    var primaryPropertyText: String {
        guard let property = primaryProperty else { return "no properties" }
        return propertyText(property)
    }

    var propertiesText: String {
        guard let property = primaryProperty else { return "" }
        return objectSchema.properties.filter { $0.name != property.name }
            .map { propertyText($0) }
            .joined(separator: ", ")
    }

    private func propertyText(_ property: Property) -> String {
        return "\(property.name): \(valueText(property: property))"
    }

    func valueText(property: Property) -> String {
        var propertyValue = ""
        switch property.type {
        case .bool:
            if self[property.name] as! Bool == false {
                propertyValue = "false"
            } else {
                propertyValue = "true"
            }
            break
        case .int, .float, .double:
            propertyValue = String(describing: self[property.name] as! NSNumber)
            break
        case .string:
            propertyValue = self[property.name] as! String
            break
            //        case .array:
            //            let array = object.dynamicList(property.name)
            //            propertyValue = String.localizedStringWithFormat("%li objects  ->", array.count)
        //            break
        case .linkingObjects:
            let array = self.dynamicList(property.name)
            propertyValue = String.localizedStringWithFormat("%li objects  ->", array.count)
            break
        case .object:
            guard let objAsProperty = self[property.name] else {
                return ""
            }
            if let list = objAsProperty as? ListBase {
                propertyValue = String.localizedStringWithFormat("%li objects  ->", list.count)
            }
            else if let obj = objAsProperty as? Object  {
                if let subProperty = obj.primaryProperty {
                    propertyValue = obj.valueText(property: subProperty)
                } else {
                    propertyValue = property.objectClassName ?? ""
                }
            } else {
                propertyValue = property.objectClassName ?? ""
            }
            break
        case .any:
            let data =  self[property.name]
            propertyValue = String((data as AnyObject).description)
            break
        default:
            return ""
        }
        return propertyValue
    }
}

class RBSTools {
    
    static let localVersion = "v0.2.0"
    
    class func stringForProperty(_ property: Property, object: Object) -> String {
        return object.valueText(property: property)
    }
    
    static func checkForUpdates() {
        if isPlayground() {
            return
        }
        let url = "https://img.shields.io/cocoapods/v/RBSRealmBrowser.svg"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request, completionHandler: { (data:Data?, response:URLResponse?, error:Error?) in
            guard let callback = response else {
                print("no response")
                return
            }
            if (callback as! HTTPURLResponse).statusCode != 200 {
                return
            }
            let websiteData = String.init(data: data!, encoding: .utf8)
            guard let gitVersion = websiteData?.contains(localVersion) else {
                return
            }
            if (!gitVersion) {
                print("A new version of RBSRealmBrowser is now available: https://github.com/bearjaw/RBSRealmBrowser/blob/master/CHANGELOG.md")
            }
        }).resume()
    }
    static func isPlayground() -> Bool {
        guard let isInPlayground = (Bundle.main.bundleIdentifier?.hasPrefix("com.apple.dt.playground")) else {
            return false
        }
        return isInPlayground;
    }
}
