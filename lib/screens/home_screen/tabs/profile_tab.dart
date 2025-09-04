import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:movie_app/screens/auth_screen/login_screen.dart';
import 'package:random_avatar/random_avatar.dart';
import '../../../data/avatar_seeds.dart';
import '../../../data/local/local_collections.dart';
import '../../../data/models/list_entry.dart';
import '../../../data/models/user_profile.dart' show UserProfile;
import '../../../domain/services/profile_api_service.dart';
import '../../../domain/services/auth_api_service.dart';
import '../../movie_details/movie_details_screen.dart';
import '../../profile/update_profile_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> with TickerProviderStateMixin {
  final _api = ProfileApiService();
  final _local = LocalCollections();

  late final TabController _tabs;

  UserProfile? _me;
  bool _loadingProfile = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _loadProfile();
    _syncLists();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loadingProfile = true;
      _error = null;
    });
    try {
      final me = await _api.me();
      if (!mounted) return;
      setState(() => _me = me);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  Future<void> _syncLists() async {
    try {
      await _api.wishList();
    } catch (_) {}
    try {
      await _api.history();
    } catch (_) {}
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF121312);
    const card = Color(0xFF1E1E1E);
    const yellow = Color(0xFFFFC107);

    if (_loadingProfile) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          'Failed to load profile:\n$_error',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),
      );
    }

    final me = _me!;

    final wishBox = Hive.box<ListEntry>('wishlistBox');
    final histBox = Hive.box<ListEntry>('historyBox');
    final wishCount = wishBox.length;
    final histCount = histBox.length;

    return ColoredBox(
      color: bg,
      child: Column(
        children: [
          // header
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 8.h),
            child: Container(
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 60.r,
                    backgroundColor: Color(0xFF212121),
                    child: ClipOval(
                      child: RandomAvatar(
                        avatarSeedFor(me.avaterId),
                        width: 150.w,
                        height: 150.w,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          me.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 24.sp,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _stat(
                              '$wishCount',
                              'Wish List',
                              fontSize: 20.sp,
                            ),
                            SizedBox(width: 32.w),
                            _stat(
                              '$histCount',
                              'History',
                              fontSize: 20.sp,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          //action
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 60.h,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: yellow,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final changed = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UpdateProfileScreen(me: me),
                          ),
                        );
                        if (changed == true) {
                          _loadProfile();
                        }
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit Profile',style: TextStyle(fontSize: 20),),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                SizedBox(
                  height: 60.h,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      await AuthApiService().logout();
                      if (!mounted) return;
                      Navigator.pushNamedAndRemoveUntil(context,LoginScreen.routeName, (route) => false);
                    },
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text(
                      'Exit',
                      style: TextStyle(color: Colors.white,fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),

          // ===== TABS =====
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: TabBar(
              controller: _tabs,
              indicatorColor: yellow,
              labelColor: yellow,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(icon: Icon(Icons.menu_rounded), text: 'Watch List'),
                Tab(icon: Icon(Icons.folder_rounded), text: 'History'),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _wishGridReactive(),
                _historyGridReactive(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //  widgets and helper

  Widget _stat(String value, String label, {double? fontSize}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: fontSize ?? 18,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: fontSize != null ? fontSize * 0.75 : 12, // Adjust label font size proportionally
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  // Grid reactive Hive
  Widget _wishGridReactive() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<ListEntry>('wishlistBox').listenable(),
      builder: (_, Box<ListEntry> box, __) {
        final items = box.values.toList(growable: false);
        if (items.isEmpty) return const _EmptyState();
        return _grid(items);
      },
    );
  }

  Widget _historyGridReactive() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<ListEntry>('historyBox').listenable(),
      builder: (_, Box<ListEntry> box, __) {
        final items = box.values.toList(growable: false);
        if (items.isEmpty) return const _EmptyState();
        return _grid(items);
      },
    );
  }

  Widget _grid(List<ListEntry> items) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 12.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: .58,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final m = items[i];
        return GestureDetector(
          onTap: () => Navigator.pushNamed(
            context,
            MovieDetailsScreen.routeName,
            arguments: m.movieId,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(m.imageUrl, fit: BoxFit.cover),
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.65),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          m.rating.toStringAsFixed(1),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.star,
                            color: Color(0xFFFFC107), size: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.local_movies_outlined,
          color: Colors.white24, size: 64),
    );
  }
}
