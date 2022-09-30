import UIKit

class CustomTabBarController: UITabBarController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    AccountModel.synchronize()
    UIMode()
    self.tabBar.layer.cornerRadius = 30
    self.tabBar.layer.masksToBounds = true
    // making sure that corner radius is masked only for the top two corner not the remaning corners
    self.tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    self.additionalSafeAreaInsets.bottom = 20
  }
  
  func UIMode( ) {
    if AccountModel.stateUI {
      self.tabBar.tintColor = UIColor(named: "TabBarDarkTint")!
      overrideUserInterfaceStyle = .dark
      loadView()
    } else {
      self.tabBar.tintColor = UIColor(named: "TabBarTint")!
      overrideUserInterfaceStyle = .light
      loadView()
    }
  }
}
