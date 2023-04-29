import UIKit
import Security

class PasswordManagerViewController: UIViewController {

    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var passwordListTableView: UITableView!
    
    var passwords: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPasswords()
    }

    @IBAction func savePassword(_ sender: Any) {
        guard let password = passwordField.text else {
            return
        }
        
        savePasswordToKeychain(password: password)
        passwords.append(password)
        passwordListTableView.reloadData()
    }
    
    func loadPasswords() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: kSecMatchLimitAll
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess, let items = result as? [[String: Any]] {
            for item in items {
                if let passwordData = item[kSecValueData as String] as? Data,
                    let password = String(data: passwordData, encoding: .utf8) {
                    passwords.append(password)
                }
            }
        }
        
        passwordListTableView.reloadData()
    }
    
    func savePasswordToKeychain(password: String) {
        let passwordData = password.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "Password",
            kSecValueData as String: passwordData
        ]
        
        SecItemAdd(query as CFDictionary, nil)
    }
}

extension PasswordManagerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passwords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PasswordCell", for: indexPath)
        
        cell.textLabel?.text = passwords[indexPath.row]
        
        return cell
    }
}
