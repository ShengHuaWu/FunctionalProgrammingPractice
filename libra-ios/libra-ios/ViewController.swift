import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .yellow
        
        print(try! Current.storage.fetchToken())
        
        // TODO: To be removed
        /*
        let parameters = LoginParameters(username: "shenghuawu5", password: "12345678")
        Current.webService.logIn(parameters).map { result -> Result<Void, Error> in
            do {
                let user = try result.get()
                
                guard let token = user.token else { return .failure(NetworkError.unexpectedResponse) }
                
                try Current.storage.saveToken(token)
                
                return .success(())
            } catch {
                return .failure(error)
            }
        }.run{ result in
            DispatchQueue.main.async {
                print(result)
            }
        }*/
    }
}
