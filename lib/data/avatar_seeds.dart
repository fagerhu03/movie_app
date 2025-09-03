/// The same seeds you used in Register (expand as you like).
const List<String> kAvatarSeeds = [
  'movie_user_1',
  'movie_user_2',
  'movie_user_3',
  'cinephile_4',
  'cinephile_5',
  'critic_6',
  'popcorn_7',
  'ticket_8',
  'camera_9',
  'clapper_10',
  'reel_11',
  'projector_12',
];

/// The API stores `avaterId` as 1-based. Clamp and convert safely.
int clampAvatarId(int? id) {
  final n = kAvatarSeeds.length;
  if (n == 0) return 1;
  final i = (id ?? 1) - 1;
  if (i < 0) return 1;
  if (i >= n) return n;
  return i + 1;
}

/// Get seed string for a (1-based) id.
String avatarSeedFor(int? avaterId1Based) {
  final id = clampAvatarId(avaterId1Based);
  return kAvatarSeeds[id - 1];
}
