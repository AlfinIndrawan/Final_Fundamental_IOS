// review sebelumnya import ini tidak digunakan sarannya tapi ketika saya hapus malah error
import Foundation

struct GameDetailResponse: Codable {
  let ID: Int
  let title: String?
  let description: String?
  let released: Date?
  let rating: Double?
  let website: String?
  let backgroundImage: String?
  enum CodingKeys: String, CodingKey {
    case description, rating, released
    case ID = "id"
    case title = "name"
    case backgroundImage = "background_image"
    case website
  }
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    rating = try container.decode(Double.self, forKey: .rating)
    description = try container.decode(String.self, forKey: .description)
    website = try container.decode(String.self, forKey: .website)
    let dateString = try container.decode(String.self, forKey: .released)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    released = dateFormatter.date(from: dateString)!
    ID = try container.decode(Int.self, forKey: .ID)
    title = try container.decode(String.self, forKey: .title)
    backgroundImage = try container.decode(String.self, forKey: .backgroundImage)
  }
}
