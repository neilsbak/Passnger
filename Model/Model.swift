//
//  Model.swift
//  Passenger
//
//  Created by Neil Bakhle on 2020-04-12.
//  Copyright © 2020 Neil. All rights reserved.
//

import Foundation
import Combine

public class Model: ObservableObject {

    static let masterPasswordsKeychainAccountName = "MasterPasswords"
    static let passwordItemsKeychainAccountName = "PasswordItems"

    private static func passwordKeychainItem(keychainService: String) -> KeychainPasswordItem {
        return KeychainPasswordItem(service: keychainService, account: Model.passwordItemsKeychainAccountName, sync: true, passcodeProtected: false)
    }

    private static func masterKeychainItem(keychainService: String) -> KeychainPasswordItem {
        return KeychainPasswordItem(service: keychainService, account: Model.masterPasswordsKeychainAccountName, sync: true, passcodeProtected: false)
    }

    let keychainService: String
    private let passwordKeychainItem: KeychainPasswordItem
    private let masterKeychainItem: KeychainPasswordItem
    @Published private(set) var passwordItems = [PasswordItem]()
    @Published private(set) var masterPasswords = [MasterPassword]()
    @Published var searchText: String = ""
    @Published private(set) var shownPasswordItems = [PasswordItem]()
    private var shownPasswordItemsCancellable: Cancellable? = nil
    private var shownSelectedPasswordCancellable: Cancellable? = nil

    private var shownPasswordItemsPublisher: AnyPublisher<[PasswordItem], Never> {
        Publishers.CombineLatest($passwordItems, $searchText)
        .debounce(for: 0.2, scheduler: RunLoop.main)
        .map { items, text in
            if text == "" {
                return items
            }
            return items.filter { ($0.userName + $0.resourceDescription + $0.url).range(of: text, options: .caseInsensitive) != nil }
        }.eraseToAnyPublisher()
    }

    init(keychainService: String = PassngerKeychainItem.service) {
        self.keychainService = keychainService
        self.passwordKeychainItem = Model.passwordKeychainItem(keychainService: keychainService)
        self.masterKeychainItem = Model.masterKeychainItem(keychainService: keychainService)
        self.shownPasswordItemsCancellable = shownPasswordItemsPublisher.assign(to: \.shownPasswordItems, on: self)
    }

    func addPasswordItem(_ passwordItem: PasswordItem, hashedMasterPassword: String, onComplete: @escaping (Result<Void, Error>) -> Void) {
        assert(MasterPassword.hashPasswordData(Data(base64Encoded: hashedMasterPassword)!) == passwordItem.masterPassword.doubleHashedPassword)
        DispatchQueue.global(qos: .background).async {
            let result = Result { try passwordItem.storePasswordFromHashedMasterPassword(hashedMasterPassword) }
            DispatchQueue.main.async {
                switch result {
                case .success(()):
                    if let index = self.passwordItems.firstIndex(where: { $0.id == passwordItem.id }) {
                        self.passwordItems[index] = passwordItem
                    } else {
                        self.passwordItems.append(passwordItem)
                    }
                    self.saveModel()
                case .failure(_): break
                }
                onComplete(result)
            }
        }
    }

    func addMasterPassword(_ masterPassword: MasterPassword, passwordText: String, saveOnDevice: Bool) {
        if let index = masterPasswords.firstIndex(where: { $0.id == masterPassword.id }) {
            masterPasswords[index] = masterPassword
        } else {
            masterPasswords.append(masterPassword)
        }
        if (saveOnDevice) {
            try! masterPasswords[masterPasswords.firstIndex(of: masterPassword)!].savePassword(passwordText)
        }
        saveModel()
    }
    
    func removePasswordItem(_ passwordItem: PasswordItem) {
        guard let index = passwordItems.firstIndex(where: { $0.id == passwordItem.id }) else { return }
        removePasswordItems(atOffsets: IndexSet(integer: index))
    }

    func removeMasterPassword(_ masterPassword: MasterPassword) {
        guard let index = masterPasswords.firstIndex(where: { $0.id == masterPassword.id }) else { return }
        removeMasterPasswordKeychainItems(atOffsets: IndexSet(integer: index))
        removeMasterPasswords(atOffsets: IndexSet(integer: index))
    }
    
    func removeMasterPasswordKeychainItem(_ masterPassword: MasterPassword) {
        guard let index = masterPasswords.firstIndex(where: { $0.id == masterPassword.id }) else { return }
        removeMasterPasswordKeychainItems(atOffsets: IndexSet(integer: index))

    }

    func removePasswordItems(atOffsets indexSet: IndexSet) {
        for index in indexSet {
            do { try passwordItems[index].deletePassword() } catch {}
        }
        passwordItems.remove(atOffsets: indexSet)
        saveModel()
    }

    func removeMasterPasswords(atOffsets indexSet: IndexSet) {
        masterPasswords.remove(atOffsets: indexSet)
        saveModel()
    }
    
    func removeMasterPasswordKeychainItems(atOffsets indexSet: IndexSet) {
        for index in indexSet {
            do { try masterPasswords[index].deletePassword() } catch {}
        }
        saveModel()
    }

    func saveModel() {
        let masterPasswordData = try! JSONEncoder().encode(masterPasswords)
        let masterPasswordJson = String(data: masterPasswordData, encoding: .utf8)!
        try! masterKeychainItem.savePassword(masterPasswordJson)

        let passwordItemData = try! JSONEncoder().encode(passwordItems)
        let passwordItemJson = String(data: passwordItemData, encoding: .utf8)!
        try! passwordKeychainItem.savePassword(passwordItemJson)
    }

    func loadModel() {
        let decoder = JSONDecoder()
        decoder.userInfo = [
            MasterPassword.keychainServiceUserInfoKey: keychainService,
            PasswordItem.keychainServiceUserInfoKey: keychainService
        ]
        if let masterPasswordsJson = try? masterKeychainItem.readPassword(),
           let masterPasswords = try? decoder.decode([MasterPassword].self, from: masterPasswordsJson.data(using: .utf8)!) {
            self.masterPasswords = masterPasswords
        }
        if let passwordItemsJson = try? passwordKeychainItem.readPassword(),
           let passwordItems = try? decoder.decode([PasswordItem].self, from: passwordItemsJson.data(using: .utf8)!) {
            self.passwordItems = passwordItems
        }
    }

    static func loadModel(keychainService: String = PassngerKeychainItem.service) -> Model {
        let model = Model(keychainService: keychainService)
        model.loadModel()
        return model
    }

    static func testModel() -> Model {
        let keychainService = "PassengerTest"
        let model = Model(keychainService: keychainService)
        let masterPasswords = [
            "Regular Password": "regular",
            "Secure Password": "secure"
        ]
        
        model.masterPasswords = masterPasswords.keys.map {
            MasterPassword(name: $0, password: masterPasswords[$0]!, keychainService: keychainService, securityLevel: .save)
        }
        model.passwordItems = [
            PasswordItem(userName: "pw_smith", masterPassword: model.masterPasswords[0], url: "gmail.com", resourceDescription: "Gmail", passwordScheme: PasswordScheme(), keychainService: keychainService),
            PasswordItem(userName: "pw_smith.to", masterPassword: model.masterPasswords[1], url: "amazon.com", resourceDescription: "Amazon", passwordScheme: PasswordScheme(), keychainService: keychainService),
            PasswordItem(userName: "pw_smith", masterPassword: model.masterPasswords[0], url: "sunbank.com", resourceDescription: "Sun Bank", passwordScheme: PasswordScheme(), keychainService: keychainService),
            PasswordItem(userName: "pw_smith@gmail.com", masterPassword: model.masterPasswords[1], url: "apple.com", resourceDescription: "Apple", passwordScheme: PasswordScheme(), keychainService: keychainService),
            PasswordItem(userName: "pw_smith@gmail.com", masterPassword: model.masterPasswords[1], url: "github.com", resourceDescription: "GitHub", passwordScheme: PasswordScheme(), keychainService: keychainService),
            PasswordItem(userName: "pwsmithto@hotmail.com", masterPassword: model.masterPasswords[0], url: "facebook.com", resourceDescription: "Facebook", passwordScheme: PasswordScheme(), keychainService: keychainService),
            PasswordItem(userName: "pw_smith@gmail.com", masterPassword: model.masterPasswords[0], url: "turbotax.com", resourceDescription: "Turbo Tax", passwordScheme: PasswordScheme(), keychainService: keychainService),
            PasswordItem(userName: "pwsmithto", masterPassword: model.masterPasswords[1], url: "hotmail.com", resourceDescription: "Hotmail", passwordScheme: PasswordScheme(), keychainService: keychainService),
            PasswordItem(userName: "jencarford", masterPassword: model.masterPasswords[1], url: "gmail.com", resourceDescription: "Jen Gmail", passwordScheme: PasswordScheme(), keychainService: keychainService),
            PasswordItem(userName: "pwsmithto@hotmail.com", masterPassword: model.masterPasswords[0], url: "twitter.com", resourceDescription: "Twitter", passwordScheme: PasswordScheme(), keychainService: keychainService),
            PasswordItem(userName: "pw_smith@gmail.com", masterPassword: model.masterPasswords[1], url: "starbucks.com", resourceDescription: "Starbucks", passwordScheme: PasswordScheme(), keychainService: keychainService),
            PasswordItem(userName: "pw_smith", masterPassword: model.masterPasswords[1], url: "yahoo.com", resourceDescription: "Yahoo", passwordScheme: PasswordScheme(), keychainService: keychainService),
            PasswordItem(userName: "pw_smith@gmail.com", masterPassword: model.masterPasswords[0], url: "slack.com", resourceDescription: "Slack", passwordScheme: PasswordScheme(), keychainService: keychainService),
        ]
        try! model.masterPasswords[0].savePassword(masterPasswords[model.masterPasswords[0].name]!)
        for p in model.passwordItems {
            let hashedMasterPassword = MasterPassword.hashPassword(masterPasswords[p.masterPassword.name]!)
            try! p.storePasswordFromHashedMasterPassword(hashedMasterPassword)
        }
        // manually set shownPasswordItems for previews, since combine debounce publisher
        // won't work in a regular preview
        model.shownPasswordItems = model.passwordItems
        return model
    }
}
