import UIKit

class HomeTableViewCell: UITableViewCell {
    @IBOutlet var gameRating: UILabel!
    @IBOutlet var gameDate: UILabel!
    @IBOutlet var gameTitle: UILabel!
    @IBOutlet var gameImage: UIImageView!
    @IBOutlet var visualView: UIVisualEffectView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
