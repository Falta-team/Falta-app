import 'package:falta_app/features/profile/domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.fullName,
    required super.branch,
    required super.countryCode,
    required super.phone,
    super.avatarUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // API: { firstName, lastName, fullName, academicBranch, phoneNumber, profilePhotoUrl }
    final first   = json['firstName']?.toString()?.trim() ?? '';
    final last    = json['lastName']?.toString()?.trim()  ?? '';
    final full    = json['fullName']?.toString()?.trim()  ??
        json['full_name']?.toString()?.trim() ??
        '$first $last'.trim();

    const branchMap = {'scientific': 'الفرع العلمي', 'literary': 'الفرع الأدبي'};
    final rawBranch = (json['academicBranch'] ?? json['branch'] ?? '').toString();
    final branch = branchMap[rawBranch] ?? rawBranch;

    return ProfileModel(
      id:          json['id']?.toString()            ?? '',
      fullName:    full,
      branch:      branch,
      countryCode: '+970',
      phone:       (json['phoneNumber'] ?? json['phone'] ?? '').toString(),
      avatarUrl:   (json['profilePhotoUrl'] ?? json['avatar_url'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id':        id,
    'fullName':  fullName,
    'branch':    branch,
    'phone':     phone,
    'avatarUrl': avatarUrl,
  };
}