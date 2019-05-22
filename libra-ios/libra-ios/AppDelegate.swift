import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let vc = ViewController()
        // TODO: Build UI: authenticated (login/signup) and list of records 
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
        
        return true
    }
}

