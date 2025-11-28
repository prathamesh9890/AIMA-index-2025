// class UserListModel {
//   final dynamic id;
//   final dynamic stallId;
//   final dynamic userId;
//   final dynamic scannedAt;
//   final dynamic createdAt;
//   final dynamic updatedAt;
//   final UserData user;
//
//   UserListModel({
//     required this.id,
//     required this.stallId,
//     required this.userId,
//     required this.scannedAt,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.user,
//   });
//
//   factory UserListModel.fromJson(Map<dynamic, dynamic> json) {
//     return UserListModel(
//       id:json["id"],
//       stallId:json["stall_id"],
//       userId:json["user_id"],
//       scannedAt: json["scanned_at"],
//       createdAt: json["created_at"],
//       updatedAt: json["updated_at"],
//       user: UserData.fromJson(json["user"]),
//     );
//   }
// }
// class UserData {
//   final dynamic id;
//   final dynamic name;
//   final dynamic compName;
//   final dynamic email;
//   final dynamic phone;
//   final dynamic city;
//   final dynamic occupation;
//   final dynamic qrCode;
//   final dynamic qrImage;
//
//   UserData({
//     required this.id,
//     required this.name,
//     required this.compName,
//     required this.email,
//     required this.phone,
//     required this.city,
//     required this.occupation,
//     required this.qrCode,
//     required this.qrImage,
//   });
//
//   factory UserData.fromJson(Map<dynamic, dynamic> json) {
//     return UserData(
//       id: json["id"],
//       name: json["name"] ?? "",
//       compName: json["comp_name"] ?? "",
//       email: json["email"] ?? "",
//       phone: json["phone"] ?? "",
//       city: json["city"] ?? "",
//       occupation: json["occupation"] ?? "",
//       qrCode: json["qr_code"],      // dynamic
//       qrImage: json["qr_image"] ?? "",
//     );
//   }
// }


class StallUserResponse {
  final bool success;
  final int statusCode;
  final String message;
  final PaginationData paginationData;

  StallUserResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.paginationData,
  });

  factory StallUserResponse.fromJson(Map<String, dynamic> json) {
    return StallUserResponse(
      success: json["success"],
      statusCode: json["status_code"],
      message: json["message"],
      paginationData: PaginationData.fromJson(json["data"]),
    );
  }
}

class PaginationData {
  final int currentPage;
  final int total;
  final List<UserListModel> users;

  PaginationData({
    required this.currentPage,
    required this.total,
    required this.users,
  });

  factory PaginationData.fromJson(Map<String, dynamic> json) {
    return PaginationData(
      currentPage: json["current_page"],
      total: json["total"],
      users: (json["data"] as List)
          .map((e) => UserListModel.fromJson(e))
          .toList(),
    );
  }
}

class UserListModel {
  final dynamic id;
  final dynamic stallId;
  final dynamic userId;
  final dynamic scannedAt;
  final dynamic createdAt;
  final dynamic updatedAt;
  final UserData user;

  UserListModel({
    required this.id,
    required this.stallId,
    required this.userId,
    required this.scannedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory UserListModel.fromJson(Map<dynamic, dynamic> json) {
    return UserListModel(
      id: json["id"],
      stallId: json["stall_id"],
      userId: json["user_id"],
      scannedAt: json["scanned_at"],
      createdAt: json["created_at"],
      updatedAt: json["updated_at"],
      user: UserData.fromJson(json["user"]),
    );
  }
}

class UserData {
  final dynamic id;
  final dynamic name;
  final dynamic compName;
  final dynamic email;
  final dynamic phone;
  final dynamic city;
  final dynamic occupation;
  final dynamic qrCode;
  final dynamic qrImage;

  UserData({
    required this.id,
    required this.name,
    required this.compName,
    required this.email,
    required this.phone,
    required this.city,
    required this.occupation,
    required this.qrCode,
    required this.qrImage,
  });

  factory UserData.fromJson(Map<dynamic, dynamic> json) {
    return UserData(
      id: json["id"],
      name: json["name"] ?? "",
      compName: json["comp_name"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      city: json["city"] ?? "",
      occupation: json["occupation"] ?? "",
      qrCode: json["qr_code"],
      qrImage: json["qr_image"] ?? "",
    );
  }
}
