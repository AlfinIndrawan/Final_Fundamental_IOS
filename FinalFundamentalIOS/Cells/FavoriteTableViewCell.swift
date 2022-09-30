import UIKit

class FavoriteTableViewCell: UITableViewCell {
  @IBOutlet var favoriteImage: CustomImageView!
  @IBOutlet var visualView: CustomBlurView!
  @IBOutlet var favoriteDate: UILabel!
  @IBOutlet var favoriteTitle: UILabel!
  @IBOutlet var favoriteRating: UILabel!
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
  }
}
