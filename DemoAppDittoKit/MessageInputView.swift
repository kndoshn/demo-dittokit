import UIKit

final class MessageInputView: UIView {
    @IBOutlet private(set) weak var textField: UITextField!
    @IBOutlet private(set) weak var sendButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        let nib = UINib(nibName: "MessageInputView", bundle: Bundle(for: type(of: self)))
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        addSubview(view)
    }
}
