//
//  RealmWrapper.swift
//  InWorker
//
//  Created by Lusine Khachatryan on 2/4/17.
//  Copyright © 2017 Friends. All rights reserved.
//

import UIKit
import RealmSwift
import FirebaseCrashlytics
//let uiRealm = try? Realm()

class RealmWrapper {

    class var sharedInstance: RealmWrapper {
        struct Singleton {
            static let instance = RealmWrapper()
        }
        return Singleton.instance
    }

    func updateObjects(completation: () -> Void) {
        do {
            try Realm().write({
                completation()
            })
        } catch {
            Crashlytics.crashlytics().setCustomValue("error", forKey: "updateObjects")
            debugPrint("Something went wrong!")
        }
    }

    func getAllObjectsOfModel(_ objectType: Object.Type) -> [Object]? {
        do {
            let objects = try Realm().objects(objectType)

            return Array(objects)
        } catch {
            Crashlytics.crashlytics().setCustomValue("error", forKey: "getAllObjectsOfModel")
            debugPrint("Something went wrong!")
        }

        return nil
    }

    func addObjectInRealmDB(_ object: Object) {
        do {
            try Realm().write({
                try Realm().add(object, update: .all)
            })
        } catch {
            Crashlytics.crashlytics().setCustomValue("error", forKey: "addObjectInRealmDB")
            debugPrint("Something went wrong!")
        }
    }
    
    func addObjectInRealmDB(_ object: Object, _ objectType: Object.Type) {
        do {
            try Realm().write({
                let copy = try Realm().create(objectType, value: object, update: .all)
                try Realm().add(copy, update: .all)
            })
        } catch {
            Crashlytics.crashlytics().setCustomValue("error", forKey: "addObjectInRealmDB")
            debugPrint("Something went wrong!")
        }
    }

    func deleteObjectFromRealmDB(_ object: Object?) {
        guard let object = object else { return }
        do {
            try Realm().write({
                try Realm().delete(object)
            })
        } catch {
            Crashlytics.crashlytics().setCustomValue("error", forKey: "deleteObjectFromRealmDB")
            debugPrint("Something went wrong!")
        }
    }
    
    func deleteObjectsFromRealmDB(_ objectType: Object.Type) {
        do {
            let realm = try Realm()
            try realm.write({
                realm.delete(realm.objects(objectType))
            })
        } catch {
            Crashlytics.crashlytics().setCustomValue("error", forKey: "deleteObjectsFromRealmDB")
            debugPrint("Something went wrong!")
        }
    }

    func deleteAllFromDB(complation: () -> Void) {
        do {
            try Realm().write({
                try Realm().deleteAll()
                complation()
            })
        } catch {
            Crashlytics.crashlytics().setCustomValue("error", forKey: "deleteAllFromDB")
            debugPrint("Something went wrong!")
        }
    }

    func deletePoolTypeModelsFromDB() {
        do {
            let realm = try Realm()
            try realm.write({
                realm.delete(realm.objects(PoolTypeModel.self))
            })
        } catch {
            Crashlytics.crashlytics().setCustomValue("error", forKey: "deletePoolTypeModelsFromDB")
            debugPrint("Something went wrong!")
        }
    }
}
