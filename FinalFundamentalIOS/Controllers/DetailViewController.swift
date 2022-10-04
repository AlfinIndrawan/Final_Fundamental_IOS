import UIKit

class DetailViewController: UIViewController, GamesManagerDelegate {
  private var gameModelsDetail: GamesModel?
  private var gamesManager = GamesManager()
  private var gamesProvider = GamesProvider()
  private var dataIdFav = [Int32]()
  var detailID = Int32()
  
  @IBOutlet var favoriteButton: UIButton!
  @IBOutlet var gameBanner: UIImageView!
  @IBOutlet var gameTitle: UILabel!
  @IBOutlet var gameRating: Ratings!
  @IBOutlet var gameDate: UILabel!
  @IBOutlet var gameUrl: UILabel!
  @IBOutlet var gameDescription: UILabel!
  @IBOutlet var gameImagePreview: UIImageView!
  override func viewDidLoad() {
    super.viewDidLoad()
    gamesManager.delegate = self
    gameRating.backgroundColor = UIColor.clear
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    UIMode()
    DispatchQueue.main.async {
      self.gamesProvider.getAllGames { (results) in
        if !results.isEmpty {
          for result in results {
            guard let id = result.id else { return }
            self.dataIdFav.append(id)
          }
        } else {
//          self.dataIdFav.removeAll()
        }
      }
    }
    if dataIdFav.isEmpty {
//      gameModelsDetail?.selected = false
//      favoriteButton.isSelected = false
      self.favoriteButton.reloadInputViews()
    }
    gamesManager.detailGame(detailId: String(detailID))
  }
  func UIMode( ) {
    if AccountModel.stateUI {
      overrideUserInterfaceStyle = .dark
      self.favoriteButton.tintColor = UIColor(named: "TabBarDarkTint")
      navigationController?.navigationBar.tintColor = UIColor(named: "TabBarDarkTint")
    } else {
      overrideUserInterfaceStyle = .light
      self.favoriteButton.tintColor = UIColor(named: "AccentColor")
      navigationController?.navigationBar.tintColor = UIColor(named: "TabBarTint")
    }
  }
  func didUpdateGames(gamesManager: GamesManager, gamesModel: [GamesModel]) {
    DispatchQueue.main.async {
      self.gameModelsDetail = gamesModel[0]
      print(self.dataIdFav)
      for data in self.dataIdFav {
        if self.gameModelsDetail?.id == data {
          self.gameModelsDetail?.selected = true
          self.favoriteButton.isSelected = true
          self.favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
          self.favoriteButton.reloadInputViews()
          break
        } else {
          self.gameModelsDetail?.selected = false
          self.favoriteButton.isSelected = false
          self.favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
          self.favoriteButton.reloadInputViews()
        }
      }
      self.updateUI()
    }
  }
  private func updateUI() {
    if let result = gameModelsDetail, let bgimage = result.backgroundImage {
      guard let urlString = URL(string: bgimage) else { return }
      URLSession.shared.dataTask(with: urlString) { (data, _, _) in
        guard let safeData = data else { return }
        DispatchQueue.main.async {
          self.gameImagePreview.image = UIImage(data: safeData)
          self.gameBanner.image = UIImage(data: safeData)
        }
      }.resume()
      
      if let title = result.title,
         let description = result.description,
         let dateReleased = result.dateReleased,
         let rating = result.rating,
         let website = result.website,
         let selected = result.selected {
        let Text = description.replacingOccurrences(of: "<p>", with: "")
        let Text2 = Text.replacingOccurrences(of: "</p>", with: "   ")
        let Text3 = Text2.replacingOccurrences(of: "<br />", with: "\n")
        gameDescription.text = Text3
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        gameDate.text = dateFormatter.string(from: dateReleased)
        gameTitle.text = title
        gameRating.rating = rating
        gameUrl.text = "\(website)"
        
        if selected == true {
          favoriteButton.isSelected = true
          favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        } else {
          favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
          favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        }
      }
      
    }
  }
  
  @IBAction func favoriteTapped(_ sender: UIButton) {
    guard let gameIdFav = gameModelsDetail?.id,
          let gameTitleFav = gameModelsDetail?.title,
          let gameDescription = gameModelsDetail?.description,
          let gameRealesedFav = gameModelsDetail?.dateReleased,
          let gameImageFav = gameModelsDetail?.backgroundImage,
          let gameWebsite = gameModelsDetail?.website,
          let gameRatingFav = gameModelsDetail?.rating,
          let gameSelected = gameModelsDetail?.selected
    else { return }
    
    if gameSelected == true {
      
      // Selected true (Game has been added to favorite)
      let alert = UIAlertController(title: "Confirmation", message: "Do You want to remove \(gameTitleFav) from Favorites?", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
        self.gamesProvider.deleteGamesById(gameIdFav) {
          DispatchQueue.main.async {
            let alert = UIAlertController(title: "Succesfull", message: "Your games \(gameTitleFav) has been removed from favorites", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
              
              self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true)
          }
        }
        sender.isSelected = false
      }))
      alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (_) in
        print("doesn't cancel")
      }))
      self.present(alert, animated: true, completion: nil)
    } else {
      //                 Selected false (not yet added to favorite)
      
      let alert = UIAlertController(title: "Alert", message: "do You want to add \(gameTitleFav) to favorite?", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
        sender.isSelected = true
        print("succesfully added")
        // Add games to Core Data
        self.gamesProvider.addGames(gameIdFav, true, gameDescription, gameRealesedFav, gameImageFav, gameWebsite, gameRatingFav, gameTitleFav)
        self.dataIdFav.append(gameIdFav)
      }))
      alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (_) in
        
        sender.isSelected = false
      }))
      self.present(alert, animated: true, completion: nil)
      
    }
  }
}
