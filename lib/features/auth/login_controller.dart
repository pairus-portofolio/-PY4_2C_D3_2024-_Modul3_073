class LoginController {

  final Map<String, String> users = {
  'admin': '123',
  'budi': '456',
  'siti': 'abc',
};

  bool login(String username, String password) {
    if (users.containsKey(username) &&
        users[username] == password) {
      return true;
    }
    return false;
  }
}
