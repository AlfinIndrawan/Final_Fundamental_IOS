import UIKit
// swiftlint:disable line_length

class FavoriteViewController: UIViewController {
  var gamesModelFav = [GamesModel]()

  private lazy var gamesProvider: GamesProvider = {
    return GamesProvider()
  }()
  @IBOutlet var favoriteTitle: UILabel!
  @IBOutlet var favoriteCard: CustomView!
  @IBOutlet var favoriteTable: UITableView!
  override func viewDidLoad() {
    super.viewDidLoad()
    initTable()

  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    UIMode()
    configureNavigationItem()
    loadGames()
  }
  private func configureNavigationItem() {
    let editingItem = UIBarButtonItem(image: favoriteTable.isEditing ? UIImage(systemName: "trash.fill") : UIImage(systemName: "trash"), style: .done, target: self, action: #selector(self.toggleEditing))
    // i cant change the color in UIMode so i put here
    if AccountModel.stateUI {
      editingItem.tintColor = UIColor(named: "TabBarDarkTint")
    } else {
      editingItem.tintColor = UIColor(named: "AccentColor")
    }
    navigationItem.rightBarButtonItems = [editingItem]
  }
  
  @objc private func toggleEditing() {
    favoriteTable.setEditing(!favoriteTable.isEditing, animated: true)
    configureNavigationItem()
  }
  
  private func loadGames() {
    self.gamesProvider.getAllGames { (result) in
      DispatchQueue.main.async {
        if result.isEmpty {
          self.favoriteTable.isHidden = true
          let alert = UIAlertController(title: "Your favorite doesn't exist", message: "add games anything you like to favorite by clicking heart", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
          self.present(alert, animated: true)
        } else {
          self.gamesModelFav = result
          self.favoriteTable.isHidden = false
          self.favoriteTable.reloadData()
        }
        
      }
    }
  }
  private func initTable() {
    favoriteTable.delegate = self
    favoriteTable.dataSource = self
  }
  func UIMode() {
    if AccountModel.stateUI {
      overrideUserInterfaceStyle = .dark
      self.favoriteTitle.textColor = UIColor(named: "TabBarDarkTint")
    } else {
      overrideUserInterfaceStyle = .light
      self.favoriteTitle.textColor = UIColor(named: "AccentColor")
      favoriteTitle.setNeedsDisplay()
    }
  }
}

// MARK: - TableView
extension FavoriteViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return gamesModelFav.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as? FavoriteTableViewCell {
      cell.visualView.layer.masksToBounds = true
      cell.visualView.layer.cornerRadius = 30
      cell.visualView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
      let games = gamesModelFav[indexPath.row]
      
      if let bgImage = games.backgroundImage, let urlString = URL(string: bgImage), let defaultImage = bgImage.first?.description {
        if games.backgroundImage == "", let urlFirstImage = URL(string: defaultImage) {
          URLSession.shared.dataTask(with: urlFirstImage) { (data, _, _) in
            guard let safeData = data else { return }
            DispatchQueue.main.async {
              cell.favoriteImage.image = UIImage(data: safeData)
            }
          }
        } else {
          URLSession.shared.dataTask(with: urlString) { (data, _, _) in
            guard let safeData = data else { return }
            DispatchQueue.main.async {
              cell.favoriteImage.image = UIImage(data: safeData)
            }
          }.resume()
        }
      }
      
      // UITableview (View cell) Setup
      if let title = games.title,
         let date = games.dateReleased,
         let rating = games.rating {
        cell.favoriteTitle.text = title
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        cell.favoriteDate.text = dateFormatter.string(from: date)
        cell.favoriteRating.text = String(rating) + "/5"
      }
      return cell
    }
    return UITableViewCell()
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // Memanggil View Controller dengan berkas NIB/XIB di dalamnya
    tableView.deselectRow(at: indexPath, animated: true)
    let detail = DetailViewController(nibName: "DetailViewController", bundle: nil)
    guard let gameDetailId = gamesModelFav[indexPath.row].id else { return }
    // Push/mendorong view controller lain
    detail.detailID = gameDetailId
    self.navigationController?.pushViewController(detail, animated: true)
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete, let gameId = gamesModelFav[indexPath.row].id, let gameTitle = gamesModelFav[indexPath.row].title {
      
      let alert = UIAlertController(title: "Alert", message: "You want to delete \(gameTitle) from favorite?", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
        self.gamesModelFav.remove(at: indexPath.row)
        self.favoriteTable.deleteRows(at: [indexPath], with: .automatic)
        self.gamesProvider.deleteGamesById(gameId) {
          DispatchQueue.main.async {
            self.loadGames()
            let alert = UIAlertController(title: "Successful", message: "Your favorite has been deleted", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
              self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true)
          }
        }
      }))
      alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
        self.navigationController?.popViewController(animated: true)
      }))
      
      self.present(alert, animated: true)
    }
  }
}
