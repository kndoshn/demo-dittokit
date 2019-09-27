import UIKit

final class MyMessageTableViewCell: UITableViewCell {
    @IBOutlet private(set) weak var messageLabel: UILabel!
    @IBOutlet private weak var bubbleImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        transform = CGAffineTransform.identity.rotated(by: .pi)

        bubbleImageView?.image = UIImage(named: "right_bubble")!.resizableImage(withCapInsets: UIEdgeInsets(top: 17, left: 17, bottom: 21, right: 21))
    }
}
