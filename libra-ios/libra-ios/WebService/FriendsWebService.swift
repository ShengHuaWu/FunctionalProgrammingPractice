// This type contains APIs related to friends, and it should NOT be accessed directly

// TODO: Return people or person instead of user
struct FriendsWebService {
    var getAll = getAllFriends(for:)
    var addFriendship = addFriendship(with:)
    var get = getFriend(with:)
    var removeFriendship = removeFriendship(with:)
}

// MARK: - Private
private func getAllFriends(for userID: Int) -> Future<Result<[User], NetworkError>> {
    return Current.urlSession().sendTokenAuthenticatedRequest(to: .friends(userID: userID), method: .get)
}

private func addFriendship(with parameters: FriendshipParameters) -> Future<Result<SuccessResponse, NetworkError>> {
    return Current.urlSession().sendTokenAuthenticatdRequest(to: .friends(userID: parameters.userID), method: .post, parameters: parameters)
}

private func getFriend(with parameters: FriendshipParameters) -> Future<Result<User, NetworkError>> {
    return Current.urlSession().sendTokenAuthenticatedRequest(to: .friend(userID: parameters.userID, friendID: parameters.personID), method: .get)
}

private func removeFriendship(with parameters: FriendshipParameters) -> Future<Result<SuccessResponse, NetworkError>> {
    return Current.urlSession().sendTokenAuthenticatedRequest(to: .friend(userID: parameters.userID, friendID: parameters.personID), method: .delete)
}
