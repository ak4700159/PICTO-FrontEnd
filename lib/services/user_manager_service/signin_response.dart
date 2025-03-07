class SigninResponse {
  SigninResponse({required this.accessToken, required this.refreshToken, required this.userId});

  String accessToken;
  String refreshToken;
  int userId;

  factory SigninResponse.fromJson(Map<String, dynamic> json) {
    return SigninResponse(
      accessToken: json["accessToken"],
      refreshToken: json["refreshToken"],
      userId: json["userId"],
    );
  }
}
