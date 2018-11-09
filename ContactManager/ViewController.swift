//
//  ViewController.swift
//  ContactManager
//
//  Created by Burner on 11/8/18.
//  Copyright © 2018 mnn. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchField: UITextField!

    private let contactService: ContactService = ContactService()

    override func viewDidLoad() {
        super.viewDidLoad()
        searchField.delegate = self
        contactService.requestAccess()
    }

    @IBAction func search(_ sender: Any) {
        guard let text = searchField.text, !text.isEmpty else {
            showError("Enter in a valid search term idiot!")
            return
        }

        let count = try? contactService.getContactCount(matching: text)
        guard let unwrappedCount = count else {
            showError("No contacts found!")
            return
        }

        let alert = UIAlertController(title: "yo!", message: "Found \(unwrappedCount) contact(s). Continue?", preferredStyle: .alert)
        let cont = UIAlertAction(title: "Go", style: .default) { (action) in
            try? self.contactService.deleteContacts(contactName: text)
            let alert = UIAlertController(title: "yo!", message: "all done!", preferredStyle: .alert)
            let close = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(close)
            self.present(alert, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cont)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

    private func showError(_ string: String) {
        let alert = UIAlertController(title: "yo!", message: string, preferredStyle: .alert)
        let close = UIAlertAction(title: "Sorry...", style: .cancel, handler: nil)
        alert.addAction(close)
        self.present(alert, animated: true, completion: nil)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

