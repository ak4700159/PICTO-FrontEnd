class SigninResponse{
  SigninResponse({required this.accessToken, required this.refreshToken});
  String accessToken;
  String refreshToken;

  factory SigninResponse.fromJson(Map<String, dynamic> json) {
    return SigninResponse(accessToken: json["accessToken"], refreshToken: json["refreshToken"]);
  }

  }