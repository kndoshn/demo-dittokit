import UIKit

final class OpponentMessageTableViewCell: UITableViewCell {
    @IBOutlet private(set) weak var messageLabel: UILabel!
    @IBOutlet private weak var bubbleImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        transform = CGAffineTransform.identity.rotated(by: .pi)

        bubbleImageView?.image = UIImage(named: "left_bubble")!.resizableImage(withCapInsets: UIEdgeInsets(top: 17, left: 21, bottom: 21, right: 17)).withRenderingMode(.alwaysTemplate)
        bubbleImageView.tintColor = UIColor(named: "gray09")
    }
}
