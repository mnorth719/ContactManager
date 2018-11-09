//
//  ContactService.swift
//  ContactManager
//
//  Created by Burner on 11/8/18.
//  Copyright © 2018 mnn. All rights reserved.
//

import Foundation
import Contacts

class ContactService {
    enum AuthStatus {
        case unknown
        case granted
        case denied
    }
    enum ErrorType: Error {
        case authDenied
    }

    private var store: CNContactStore = CNContactStore()
    private(set) var authStatus: AuthStatus = .unknown

    func requestAccess() {
        store.requestAccess(for: .contacts) {[weak self] (granted, error) in
            if granted {
                self?.authStatus = .granted
            } else {
                self?.authStatus = .denied
            }
        }
    }

    func deleteContacts(contactName: String) throws {
        guard authStatus == .granted else { throw ErrorType.authDenied }
        let predicate = CNContact.predicateForContacts(matchingName: contactName)
        let toFetch = [CNContactFamilyNameKey, CNContactGivenNameKey]

        do {
            let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: toFetch as [CNKeyDescriptor])
            guard !contacts.isEmpty else {
                print("No contacts found")
                return
            }

            print("contact count: \(contacts.count)")
            let req = CNSaveRequest()
            for contact in contacts {
                let mutableContact = contact.mutableCopy() as! CNMutableContact
                req.delete(mutableContact)
            }

            do {
                try store.execute(req)
                print("Success, You deleted the contacts")                
            } catch let e {
                print("Error = \(e)")
            }
        } catch let err{
            print(err)
        }
    }

    func getContactCount(matching name: String) throws -> Int {
        guard authStatus == .granted else { throw ErrorType.authDenied }
        let predicate = CNContact.predicateForContacts(matchingName: name)
        let toFetch = [CNContactFamilyNameKey, CNContactGivenNameKey]

        do {
            let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: toFetch as [CNKeyDescriptor])
            return contacts.count
        } catch let err{
            print(err)
        }

        return 0
    }
 }
