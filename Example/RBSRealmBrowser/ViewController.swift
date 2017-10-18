//
//  ViewController.swift
//  RBSRealmBrowser
//
//  Created by Max Baumbach on 04/02/2016.
//  Copyright (c) 2016 Max Baumbach. All rights reserved.
//

import UIKit
import RBSRealmBrowser
import RealmSwift

class ViewController: UIViewController {
    
    private var sampleView = SampleView()
    
    override func loadView() {
        self.view = sampleView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let catNames = ["Garfield", "Lutz", "Squanch"]
        let humanNames = ["Morty", "Rick", "Birdperson"]

        do {
            let realm = try Realm()
            if realm.objects(Cat.self).count == 0 {
                try realm.write {
                    let persons = humanNames.map { personName -> Person in
                        let person = Person()
                        person.personName = personName
                        realm.add(person)
                        return person
                    }
                    for (index,catName) in catNames.enumerated() {
                        let cat = Cat()
                        persons[index].cat = cat;
                        cat.catName = catName
                        cat.isTired = true
                        cat.toys.append(objectsIn: persons[0...index])
                    }
                }
            }
        } catch {
            print("failed creatimg objects with \(error)")
        }

        let bbi = UIBarButtonItem(title: "Open", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.openBrowser))
        self.navigationItem.rightBarButtonItem = bbi
    }
    
    @objc func openBrowser() {
        let rb:UIViewController =  RBSRealmBrowser.realmBrowser()!
        self.present(rb, animated: true) {
        }
        
    }
    
}
