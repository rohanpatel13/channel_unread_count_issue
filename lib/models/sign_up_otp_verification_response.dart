class SignUpOtpVerificationResponse {
  SignUpOtpVerificationResponse({
    required this.status,
    required this.data,
    required this.meta,
  });

  String status;
  Data data;
  Meta meta;

  factory SignUpOtpVerificationResponse.fromJson(Map<String, dynamic> json) => SignUpOtpVerificationResponse(
    status: json["status"],
    data: Data.fromJson(json["data"]),
    meta: Meta.fromJson(json["_meta"] != null ? json["_meta"] : new Meta()),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data.toJson(),
    "_meta": new Meta().toJson(),
  };
}

class Data {
  String? uid, cognitoUserName, accessToken, refreshToken, tokenType, userName, streamToken;
  bool hasAccessToken = false;


  Data(Map<String, dynamic> json) {
    if(json.containsKey('accessToken')) {
      hasAccessToken = true;
      accessToken = json['accessToken'];
      refreshToken = json['refreshToken'];
      tokenType = json['tokenType'];
      userName = json['username'];
      streamToken = json['streamToken'];
    } else {
      uid = json['userUid'];
      cognitoUserName = json['cognitoUsername'];
      hasAccessToken = false;
    }
  }

  factory Data.fromJson(Map<String, dynamic> json) => Data(json);

  Map<String, dynamic> toJson() => {};
}

class Meta {
  Meta();

  factory Meta.fromJson(Map<String, dynamic> json) => Meta();

  Map<String, dynamic> toJson() => {};
}