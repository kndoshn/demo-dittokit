import UIKit
import DittoKit

final class ViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var messageInputView: MessageInputView!
    @IBOutlet private weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    private let accessLicense = "o2d1c2VyX2lkaHNodW5zdWtlZmV4cGlyeXQyMDE5LTEwLTI1VDAwOjAwOjAwWmlzaWduYXR1cmV4WEtiWksvT0NvMGU1UU1Vazg0bnRuV1hQN3dHWEUyV0k2MTJOR2wxSmxoK3FkMHFCVitaVkM2OTAyY2N2RHZsWTBtb2J2N1h5QWNSckZ1SmZ1N0UvRUh3PT0="
    private var ditto: DittoKit!
    private var collection: DittoCollection!
    private var dateFormatter = ISO8601DateFormatter()
    private var messages: [DittoDocument<[String: Any?]>] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initDitto()
        setupTableView()
        setupMessageList()
        
        startObserveKeyboardNotification()
        addTapGesture()
        messageInputView.sendButton.addTarget(nil, action: #selector(didTapSend), for: .touchUpInside)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        messageInputView.textField.resignFirstResponder()
        removeObserveKeyboardNotification()
    }
    
    private func initDitto() {
        ditto = try! DittoKit()
        ditto.setAccessLicense(accessLicense)
        ditto.delegate = self
        ditto.start()
        collection = try! ditto.store.collection(name: "messages_test01")
    }
    
    private func setupTableView() {
        tableView.transform = CGAffineTransform.identity.rotated(by: .pi)
        tableView.register(UINib(nibName: "MyMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "MyMessageTableViewCell")
        tableView.register(UINib(nibName: "OpponentMessageTableViewCell", bundle: nil), forCellReuseIdentifier:
            "OpponentMessageTableViewCell")
    }
    
    private func startObserveKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeObserveKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        tapGesture.delegate = view as? UIGestureRecognizerDelegate
        tableView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func willShowKeyboard(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            view.layoutIfNeeded()
            bottomLayoutConstraint.constant = keyboardFrame.cgRectValue.height - view.safeAreaInsets.bottom
            view.layoutIfNeeded()
        }
    }
    
    @objc private func willHideKeyboard(notification: NSNotification) {
        view.layoutIfNeeded()
        bottomLayoutConstraint.constant = 0
        view.layoutIfNeeded()
    }
    
    @objc private func viewTapped() {
        messageInputView.textField.resignFirstResponder()
    }
    
    private func setupMessageList() {
        _ = try! collection.findAll().sort("dateCreated", isAscending: false).observeAndSubscribe() { [weak self] docs, event in
            guard let self = self else { return }
            switch event {
            case .update(_, let insertions, _, _, _):
                DispatchQueue.main.async {
                    self.tableView.beginUpdates()
                    self.tableView.performBatchUpdates({
                        let insertionIndexPaths = insertions.map { idx in
                            return IndexPath(row: idx, section: 0)
                        }
                        self.tableView.insertRows(at: insertionIndexPaths, with: .automatic)
                    }) { _ in }
                    self.messages = docs
                    self.tableView.endUpdates()
                }
            case .initial:
                self.messages = docs
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            default: break
            }
        }
    }
    
    @objc func didTapSend() {
        guard let text = messageInputView.textField.text else { return }
        guard !text.isEmpty else { return }
        
        let dateString = self.dateFormatter.string(from: Date())
        _ = try! self.collection.insert([
            "text": text,
            "dateCreated": dateString,
            "uuid": uuidString
        ])
        
        messageInputView.textField.text = ""
    }
    
    var uuidString: String {
        if let stored = UserDefaults.standard.string(forKey: "uuid") {
            return stored
        } else {
            let generated = UUID().uuidString
            UserDefaults.standard.set(generated, forKey: "uuid")
            return generated
        }
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        if message["uuid"].stringValue == uuidString {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyMessageTableViewCell", for: indexPath) as! MyMessageTableViewCell
            cell.messageLabel?.text = messages[indexPath.row]["text"].stringValue
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OpponentMessageTableViewCell", for: indexPath) as! OpponentMessageTableViewCell
            cell.messageLabel?.text = messages[indexPath.row]["text"].stringValue
            return cell
        }
    }
}

// MARK: - DittoKitDelegate
extension ViewController: DittoKitDelegate {
    func transportConditionDidChange(transportID: Int64, condition: DittoTransportCondition) {
        guard condition != .Ok else { return }
        
        let alert = UIAlertController(title: "Connection Error", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}
