import UIKit

class HomeViewController: UIViewController, GamesManagerDelegate {
  private var games: [Game] = []
  @IBOutlet var gameTable: UITableView!
  private var gameItems = [GamesModel]()
  private var gamesManager = GamesManager()
  private var gamesProvider = GamesProvider()
  private let searchBar: UISearchBar = {
    let searchBar = UISearchBar()
    searchBar.searchBarStyle = .prominent
    searchBar.placeholder = "Search 'Games name'"
    searchBar.sizeToFit()
    searchBar.isTranslucent = false
    searchBar.backgroundColor = .clear
    return searchBar
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }
  override func viewWillAppear(_ animated: Bool) {
    UIMode()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    gamesManager.fetchGame()
  }
  
  func UIMode( ) {
    if AccountModel.stateUI {
      overrideUserInterfaceStyle = .dark
    } else {
      overrideUserInterfaceStyle = .light
    }
  }
  
  func setupView() {
    gameTable.dataSource = self
    gameTable.delegate = self
    gameTable.layer.masksToBounds = true
    gamesManager.delegate = self
    searchBar.delegate = self
    navigationItem.titleView = searchBar
    
  }
  func didUpdateGames(gamesManager: GamesManager, gamesModel: [GamesModel]) {
    DispatchQueue.main.async {
      self.gameItems = gamesModel
      
      if self.gameItems.isEmpty {
        self.gameTable.reloadData()
        let alert = UIAlertController(title: " No Result Games", message: "Let's try to search another games", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
          self.searchBar.searchTextField.text = ""
          self.searchBar.becomeFirstResponder()
        }))
        
        self.present(alert, animated: true)
        
      } else {
        self.gameTable.reloadData()
      }
      
    }
  }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return gameItems.count
    
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath) as? HomeTableViewCell {
      cell.gameImage.layer.cornerRadius = 30
      cell.gameImage.layer.masksToBounds = true
      cell.gameImage.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
      cell.visualView.layer.masksToBounds = true
      cell.visualView.layer.cornerRadius = 30
      cell.visualView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
      let game = gameItems[indexPath.row]
      if let bgImage = game.backgroundImage, let urlString = URL(string: bgImage), let defaultImage = bgImage.first?.description {
        cell.imageView?.contentMode = .scaleAspectFit
        cell.imageView?.translatesAutoresizingMaskIntoConstraints = false
        if game.backgroundImage == "", let firstImageUrl = URL(string: defaultImage) {
          URLSession.shared.dataTask(with: firstImageUrl) { (data, _, _) in
            guard let safeData = data else { return }
            DispatchQueue.main.async {
              cell.gameImage.image = UIImage(data: safeData)
            }
          }
        } else {
          URLSession.shared.dataTask(with: urlString) { (data, _, _) in
            guard let safeData = data else { return }
            DispatchQueue.main.async {
              cell.gameImage.image = UIImage(data: safeData)
            }
          }.resume()
        }
      }
      
      // UITableViewCell Setup games view
      if let name = game.title,
         let date = game.dateReleased,
         let rating = game.rating {
        cell.gameTitle.text = name
        cell.gameRating.text = String(rating) + "/5"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        cell.gameDate.text = dateFormatter.string(from: date)
      }
      return cell
    } else {
      return UITableViewCell()
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // Memanggil View Controller dengan berkas NIB/XIB di dalamnya
    tableView.deselectRow(at: indexPath, animated: true)
    let detail = DetailViewController(nibName: "DetailViewController", bundle: nil)
    guard let gameDetailId = gameItems[indexPath.row].id else { return }
    // Push/mendorong view controller lain
    detail.detailID = gameDetailId
    self.navigationController?.pushViewController(detail, animated: true)
  }
  
}

// MARK: - Search Bar Delegate
extension HomeViewController: UISearchBarDelegate {
  
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    searchBar.setShowsCancelButton(true, animated: true)
    searchBar.becomeFirstResponder()
  }
  
  func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
    return true
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let searchText = searchBar.text?.replacingOccurrences(of: " ", with: ""), !searchText.isEmpty else {
      return
    }
    gameItems.removeAll()
    gamesManager.searchGame(searchName: searchText)
    searchBar.resignFirstResponder()
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    searchBar.text = ""
    searchBar.showsCancelButton = false
    gameItems.removeAll()
    gamesManager.fetchGame()
  }
  
}
