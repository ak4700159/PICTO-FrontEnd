class SigninResponse {
  SigninResponse({required this.accessToken, required this.refreshToken, required this.userId});

  String accessToken;
  String refreshToken;
  int userId;

  factory SigninResponse.fromJson(Map<String, dynamic> json) {
    return SigninResponse(
      accessToken: json["data"]["accessToken"],
      refreshToken: json["data"]["refreshToken"],
      userId: json["data"]["userId"],
    );
  }
}
