import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .yellow
        
        // TODO: To be removed
        /*
        let parameters = LoginParameters(username: "shengwu", password: "12345678")
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
        }
        */
        Current.webService.getRecords().run { result in
            DispatchQueue.main.async {
                print(result)
            }
        }
        
        /*
        let parameters = CreateRecordParamters(title: "Happy hour", note: "This is so good.", date: Date(), mood: .good, amount: 0, currency: .unknown, companions: [Companion(id: 2, username: "shengwu", firstName: "sheng", lastName: "wu", email: "shengwu@libra.co"), Companion(id: 4, username: "shengwu", firstName: "sheng", lastName: "wu", email: "shengwu@libra.co")])
        Current.webService.createRecord(parameters).run { result in
            DispatchQueue.main.async {
                print(result)
            }
        }*/
    }
}
