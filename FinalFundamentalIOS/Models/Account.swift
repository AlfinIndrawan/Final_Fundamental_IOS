import Foundation
import UIKit

struct AccountModel {
  static let stateLoginKey = "state"
  static let nameKey = "name"
  static let emailKey = "email"
  static let linkedinKey = "linkedin"
  static let stateUIKey = "UI"
  var image: Data?
  
  static var stateUI: Bool {
    get {
      return UserDefaults.standard.bool(forKey: stateUIKey)
    }
    set {
      UserDefaults.standard.set(newValue, forKey: stateUIKey)
    }
  }
  
  static var stateLogin: Bool {
    get {
      return UserDefaults.standard.bool(forKey: stateLoginKey)
    }
    set {
      UserDefaults.standard.set(newValue, forKey: stateLoginKey)
    }
  }
  
  static var name: String {
    get {
      return UserDefaults.standard.string(forKey: nameKey) ?? ""
    }
    set {
      UserDefaults.standard.set(newValue, forKey: nameKey)
    }
  }
  
  static var email: String {
    get {
      return UserDefaults.standard.string(forKey: emailKey) ?? ""
    }
    set {
      UserDefaults.standard.set(newValue, forKey: emailKey)
    }
  }
  
  static var linkedin: String {
    get {
      return UserDefaults.standard.string(forKey: linkedinKey) ?? ""
    }
    set {
      UserDefaults.standard.set(newValue, forKey: linkedinKey)
    }
  }
  
  static func synchronize() {
    UserDefaults.standard.synchronize()
  }
}
