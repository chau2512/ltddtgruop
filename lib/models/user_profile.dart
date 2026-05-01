class UserProfile {
  final String userId;
  final String name;
  final int avatarIndex;

  UserProfile({
    required this.userId,
    required this.name,
    this.avatarIndex = 0,
  });

  /// Danh sách emoji avatar cho các bé chọn
  static const List<String> avatarEmojis = [
    '🦁', '🐼', '🐱', '🐶', '🐰', '🦊',
    '🐸', '🐵', '🐧', '🦄', '🐲', '🐻',
    '🐯', '🐮', '🐷', '🐤',
  ];

  /// Danh sách tên avatar tương ứng
  static const List<String> avatarNames = [
    'Sư tử', 'Gấu trúc', 'Mèo con', 'Cún con', 'Thỏ bông', 'Cáo nhỏ',
    'Ếch xanh', 'Khỉ con', 'Chim cánh cụt', 'Kỳ lân', 'Rồng con', 'Gấu nâu',
    'Hổ con', 'Bò sữa', 'Heo hồng', 'Gà con',
  ];

  String get avatarEmoji => avatarEmojis[avatarIndex % avatarEmojis.length];

  UserProfile copyWith({String? name, int? avatarIndex}) {
    return UserProfile(
      userId: userId,
      name: name ?? this.name,
      avatarIndex: avatarIndex ?? this.avatarIndex,
    );
  }
}
