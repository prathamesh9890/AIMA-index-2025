class StallUserExportModel {
  bool success;
  int statusCode;
  String message;
  List<UserExportData> data;

  StallUserExportModel({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory StallUserExportModel.fromJson(Map<String, dynamic> json) {
    return StallUserExportModel(
      success: json["success"],
      statusCode: json["status_code"],
      message: json["message"],
      data: List<UserExportData>.from(
          json["data"].map((x) => UserExportData.fromJson(x))),
    );
  }
}

class UserExportData {
  int id;
  int stallId;
  int userId;
  String scannedAt;
  UserInfo user;

  UserExportData({
    required this.id,
    required this.stallId,
    required this.userId,
    required this.scannedAt,
    required this.user,
  });

  factory UserExportData.fromJson(Map<String, dynamic> json) {
    return UserExportData(
      id: json["id"],
      stallId: json["stall_id"],
      userId: json["user_id"],
      scannedAt: json["scanned_at"],
      user: UserInfo.fromJson(json["user"]),
    );
  }
}

class UserInfo {
  int id;
  String name;
  String compName;
  String email;
  String phone;
  String city;
  String occupation;

  UserInfo({
    required this.id,
    required this.name,
    required this.compName,
    required this.email,
    required this.phone,
    required this.city,
    required this.occupation,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json["id"],
      name: json["name"] ?? "",
      compName: json["comp_name"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      city: json["city"] ?? "-",
      occupation: json["occupation"] ?? "-",
    );
  }
}
