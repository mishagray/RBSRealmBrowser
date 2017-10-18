//
//  RBSRealmBrowserObjectViewController.swift
//  Pods
//
//  Created by Max Baumbach on 06/04/16.
//
//

import UIKit
import RealmSwift
import Realm

class RBSRealmPropertyBrowser: UITableViewController, RBSRealmPropertyCellDelegate {
    
    private var object: Object
    private var schema: ObjectSchema
    private var properties: Array <Property>
    private let cellIdentifier = "objectCell"
    private var isEditMode = false
    private var realm:Realm
    
    init(object: Object, realm: Realm) {
        self.object = object
        self.realm = realm
        schema = object.objectSchema
        properties = schema.properties
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = self.schema.className
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        let bbi = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(RBSRealmPropertyBrowser.actionToggleEdit(_:)))
        navigationItem.rightBarButtonItem = bbi
        tableView.register(RBSRealmPropertyCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: TableView Datasource & Delegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let property = properties[indexPath.row] 
        let stringvalue = RBSTools.stringForProperty(property, object: object)
        let isArray = (property.type == .linkingObjects)
        (cell as! RBSRealmPropertyCell).cellWithAttributes(property.name, propertyValue: stringvalue, editMode:isEditMode, property:property, isArray:isArray)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: cellIdentifier) as! RBSRealmPropertyCell
        }
        (cell as! RBSRealmPropertyCell).delegate = self
        cell?.isUserInteractionEnabled = true
        return cell!
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return properties.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isEditMode {
            tableView.deselectRow(at: indexPath, animated: true)
            let property = properties[indexPath.row]

            let value = object[property.name]
            if let obj = value as? Object {
                let objectsViewController = RBSRealmPropertyBrowser(object: obj, realm: realm)
                navigationController?.pushViewController(objectsViewController, animated: true)
            } else if let _ = value as? ListBase {
                let objects = Array(object.dynamicList(property.name))
                if objects.count == 1 {
                    let objectsViewController = RBSRealmPropertyBrowser(object: objects[0], realm: realm)
                    navigationController?.pushViewController(objectsViewController, animated: true)
                }
                else if objects.count > 0 {
                    let objectsViewController = RBSRealmObjectsBrowser(objects: objects, realm: realm)
                    navigationController?.pushViewController(objectsViewController, animated: true)
                }
            }
        }
        
    }
    
    func textFieldDidFinishEdit(_ input: String, property: Property) {
        self.savePropertyChangesInRealm(input, property: property)
        
        //        self.actionToggleEdit((self.navigationItem.rightBarButtonItem)!)
    }
    
    //MARK: private Methods
    
    private func savePropertyChangesInRealm(_ newValue: String, property: Property) {
        let letters = CharacterSet.letters

        switch property.type {
        case .bool:
            let propertyValue = Int(newValue)!
            saveValueForProperty(value: propertyValue, propertyName: property.name)
            break
        case .int:
            let range = newValue.rangeOfCharacter(from: letters)
            if  range == nil {
                let propertyValue = Int(newValue)!
                saveValueForProperty(value: propertyValue, propertyName: property.name)
            }
            break
        case .float:
            let propertyValue = Float(newValue)!
            saveValueForProperty(value: propertyValue, propertyName: property.name)
            break
        case .double:
            let propertyValue:Double = Double(newValue)!
            saveValueForProperty(value: propertyValue, propertyName: property.name)
            break
        case .string:
            let propertyValue:String = newValue as String
            saveValueForProperty(value: propertyValue, propertyName: property.name)
            break
        case .linkingObjects:
            
            break
        case .object:
            
            break
        default:
            break
        }
        
    }
    
    private func saveValueForProperty(value:Any, propertyName:String) {
        do {
            try realm.write {
            object.setValue(value, forKey: propertyName)
            }
        }catch {
            print("saving failed")
        }
    }
    
    @objc func actionToggleEdit(_ id: UIBarButtonItem) {
        isEditMode = !isEditMode
        if isEditMode {
            id.title = "Finish"
        } else {
            id.title = "Edit"
        }
        tableView.reloadData()
    }
    
}
