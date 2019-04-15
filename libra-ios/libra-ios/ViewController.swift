import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .yellow
        
        /* To be removed
        let parameters = SignUpParameters(username: "shenghuawu5", password: "12345678", firstName: "Sheng Hua", lastName: "Wu", email: "shenghuawu5@libra.co")
        Current.webService.signUp(parameters).run { result in
            switch result {
            case .success(let user):
                print(user)
            case .failure(let error):
                print(error)
            }
        }*/
    }
}
