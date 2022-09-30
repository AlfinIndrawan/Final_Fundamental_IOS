import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  // swiftlint:disable unused_optional_binding
  var window: UIWindow?
  let storyboard = UIStoryboard(name: "Main", bundle: nil)
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let _ = (scene as? UIWindowScene) else { return }
    guard let windowScene = scene as? UIWindowScene else { return }
    
    let initialViewController: UIViewController?
    
    window = UIWindow(windowScene: windowScene)
    if AccountModel.stateLogin {
      initialViewController = storyboard.instantiateViewController(withIdentifier: "CustomTabBar") as? CustomTabBarController
    } else {
      initialViewController = storyboard.instantiateViewController(withIdentifier: "AuthScene") as? AuthViewController
    }
    
    window?.rootViewController = initialViewController
    window?.makeKeyAndVisible()
  }
  
  func sceneDidEnterBackground(_ scene: UIScene) {
    (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
  }
}
