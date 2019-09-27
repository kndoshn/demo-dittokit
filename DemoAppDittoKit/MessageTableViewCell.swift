import UIKit

typealias MessageTableViewCell = MessageTableViewCellType & UITableViewCell

protocol MessageTableViewCellType {
    var messageLabel: UILabel! { get }
    var imageMessageView: UIImageView! { get }
}
