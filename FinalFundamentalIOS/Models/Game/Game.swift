import UIKit

class Game: Codable {
  let count: Int?
  public var games: [GameResponse]?
  
  enum CodingKeys: String, CodingKey {
    case count
    case games = "results"
  }
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    count = try container.decode(Int.self, forKey: .count)
    games = try container.decode([GameResponse].self, forKey: .games)
  }
}

struct GameResponse: Codable {
  let ID: Int?
  let title: String?
  let released: Date?
  let backgroundImage: String?
  let rating: Double?
  enum CodingKeys: String, CodingKey {
    case ID = "id"
    case title = "name"
    case released
    case backgroundImage = "background_image"
    case rating
  }
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    // Menentukan alamat gambar
    backgroundImage = try container.decodeIfPresent(String.self, forKey: .backgroundImage) ?? ""
    // Menentukan tanggal rilis
    let dateString = try container.decode(String.self, forKey: .released)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    released = dateFormatter.date(from: dateString)!
    ID = try container.decode(Int.self, forKey: .ID)
    title = try container.decode(String.self, forKey: .title)
    //     genres = try container.decode([Int].self, forKey: .genres)
    rating = try container.decode(Double.self, forKey: .rating)
  }
}
