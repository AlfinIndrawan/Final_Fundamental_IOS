import Foundation
import UIKit
// swiftlint:disable class_delegate_protocol
protocol GamesManagerDelegate {
  func didUpdateGames(gamesManager: GamesManager, gamesModel: [GamesModel])
}
var key="9afa42ba395c4070af244409877505dd"
struct GamesManager {
  
  var delegate: GamesManagerDelegate?
  
  func fetchGame() {
    let gameURL = "https://api.rawg.io/api/games?key=\(key)"
    performQuery(gameURL, GameResponse.self)
  }
  
  func searchGame(searchName: String) {
    // order from best rating
    let gameSearchURL = "https://api.rawg.io/api/games?key=\(key)&search=\(searchName)&ordering=-rating"
    performQuery(gameSearchURL, GameResponse.self)
  }
  
  func detailGame(detailId: String) {
    let gameDetailURL = "https://api.rawg.io/api/games/\(detailId)?key=\(key)"
    performQuery(gameDetailURL, GameDetailResponse.self)
  }
  // swiftlint:disable unused_closure_parameter
  func performQuery<T: Codable>(_ urlString: String, _ type: T.Type) {
    if let url = URL(string: urlString) {
      let session = URLSession(configuration: .default)
      let task = session.dataTask(with: url) { (data, response, error) in
        guard let safeData = data, error == nil else {
          print("Failed to get data from URLSession data task")
          return
        }
        print(safeData)
        
        if type == GameResponse.self {
          print(type)
          guard let model = self.parseJSON(safeData) else { return }
          self.delegate?.didUpdateGames(gamesManager: self, gamesModel: model)
        } else if type == GameDetailResponse.self {
          print(type)
          guard let model = self.parseJSONById(safeData) else { return }
          self.delegate?.didUpdateGames(gamesManager: self, gamesModel: model)
        }
        
      }
      task.resume()
    }
    
  }
  
  private func parseJSON(_ data: Data) -> [GamesModel]? {
    var gamesModel = [GamesModel]()
    let decoder = JSONDecoder()
    
    do {
      let decodeData = try decoder.decode(Game.self, from: data)
      decodeData.games?.forEach { (result) in
        let id = result.ID
        let title = result.title
        let bgImage = result.backgroundImage
        let release = result.released
        let rating = result.rating
        let gameData = GamesModel(id: Int32(id ?? 0), title: title, description: "", dateReleased: release, backgroundImage: bgImage, website: "", rating: rating, selected: false)
        
        gamesModel.append(gameData)
      }
      return gamesModel
    } catch {
      print(error)
      return nil
    }
  }
  
  private func parseJSONById(_ data: Data) -> [GamesModel]? {
    var gamesModel = [GamesModel]()
    let decoder = JSONDecoder()
    do {
      let decodeData = try decoder.decode(GameDetailResponse.self, from: data)
      let id = decodeData.ID
      let title = decodeData.title
      let description = decodeData.description
      let website = decodeData.website
      let bgImage = decodeData.backgroundImage
      let realese = decodeData.released
      let rating = decodeData.rating
      
      let gameDataModel = GamesModel(id: Int32(id), title: title, description: description, dateReleased: realese, backgroundImage: bgImage, website: website, rating: rating, selected: false)
      
      gamesModel.append(gameDataModel)
      return gamesModel
    } catch {
      print(error)
      return nil
    }
  }
  
  enum GamesError: Error {
    case gamesErrorCompletion
  }
}
