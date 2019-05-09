// This type is actually an umbrella of users, records, and friends APIs
struct WebService {
    var users = UsersWebService()
    var records = RecordsWebService()
    var friends = FriendsWebService()
}
