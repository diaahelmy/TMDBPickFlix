class UserModel {
  final String? sessionId;
  final String? requestToken;

  UserModel({this.sessionId, this.requestToken});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      sessionId: json['session_id'],
      requestToken: json['request_token'],
    );
  }
}
