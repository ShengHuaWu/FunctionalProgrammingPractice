import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .yellow
        
        // TODO: To be removed
        /*
        let parameters = LogInParameters(username: "shengwu1", password: "12345678")
        Current.webService.authentication.logIn(parameters).map { result -> Result<Void, Error> in
            do {
                let user = try result.get()
                
                guard let token = user.token else { return .failure(NetworkError.unexpectedResponse) }
                
                try Current.storage.authentication.saveToken(token)
                try Current.storage.user.save(user)
                
                return .success(())
            } catch {
                return .failure(error)
            }
        }.run { result in
            DispatchQueue.main.async {
                print(result)
                
                let user = try! Current.storage.user.fetch()
                print(user)
            }
        }*/
    }
}
