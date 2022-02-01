class SignUpWithPhoneNumberResponse {
  SignUpWithPhoneNumberResponse({
    required this.status,
    required this.data,
    required this.meta,
  });

  String status;
  Data data;
  Meta meta;

  factory SignUpWithPhoneNumberResponse.fromJson(Map<String, dynamic> json) => SignUpWithPhoneNumberResponse(
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
  String challengeName, session, GetStreamToken;
  Map<String, String> challengeParametes;

  Data(this.challengeName, this.session,this.challengeParametes, this.GetStreamToken);

  factory Data.fromJson(Map<String, dynamic> json) => Data(json['ChallengeName'], json['Session'], {
    'USERNAME': json['ChallengeParameters']['USERNAME'] ?? "",
    'secretLoginCode': json['ChallengeParameters']['secretLoginCode'] ?? "",
    'userUid': json['ChallengeParameters']['userUid'] ?? " ",
  }, json['streamToken'] ?? " ");

  Map<String, dynamic> toJson() => {};

  String? get userName => challengeParametes['USERNAME'];
  String? get secretLoginCode => challengeParametes['secretLoginCode'];
  String? get userUid => challengeParametes['userUid'];
}

class Meta {
  Meta();

  factory Meta.fromJson(Map<String, dynamic> json) => Meta();

  Map<String, dynamic> toJson() => {};
}