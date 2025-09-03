import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:random_avatar/random_avatar.dart';

import '../../../data/avatar_seeds.dart';
import '../../../data/models/list_entry.dart';
import '../../../data/models/user_profile.dart';
import '../../../domain/services/auth_api_service.dart';
import '../../../domain/services/profile_api_service.dart';
import '../../movie_details/movie_details_screen.dart';
import '../../profile/update_profile_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> with TickerProviderStateMixin {
  final _api = ProfileApiService();
  late final TabController _tabs;

  UserProfile? _me;
  List<ListEntry> _wish = const [];
  List<ListEntry> _history = const [];

  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final me = await _api.me();
      final wish = await _api.wishList();
      final hist = await _api.history();
      if (!mounted) return;
      setState(() {
        _me = me;
        _wish = wish;
        _history = hist;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
    const yellow = Color(0xFFF6BD00);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          'Failed to load profile:\n$_error',
          style: const TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      );
    }
    final me = _me!;
    final wishCount = me.wishCount != 0 ? me.wishCount : _wish.length;
    final histCount = me.historyCount != 0 ? me.historyCount : _history.length;

    return ColoredBox(
      color: bg,
      child: RefreshIndicator(
        onRefresh: _loadAll,
        color: yellow,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ===== Header =====
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 8.h),
              child: Container(
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.all(14.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 32.r,
                      backgroundColor: Colors.black,
                      child: ClipOval(
                        child: RandomAvatar(
                          avatarSeedFor(me.avaterId),
                          width: 60.w,
                          height: 60.w,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
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
                              fontSize: 16.sp,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            me.email,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.sp,
                              fontFamily: 'Inter',
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              _stat('$wishCount', 'Wish List'),
                              SizedBox(width: 18.w),
                              _stat('$histCount', 'History'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ===== Actions =====
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44.h,
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
                          if (changed == true) _loadAll();
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit Profile'),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  SizedBox(
                    height: 44.h,
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
                        Navigator.of(context).popUntil((r) => r.isFirst);
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        'Exit',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),

            // ===== Tabs =====
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

            // ===== Tab content =====
            SizedBox(
              height: 600.h, // allow TabBarView inside ListView
              child: TabBarView(
                controller: _tabs,
                children: [
                  _grid(_wish),
                  _grid(_history),
                ],
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _grid(List<ListEntry> items) {
    if (items.isEmpty) {
      return const _EmptyState();
    }
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
          onTap: () {
            Navigator.pushNamed(
              context,
              MovieDetailsScreen.routeName,
              arguments: m.movieId,
            );
          },
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
                          style:
                          const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.star,
                            color: Color(0xFFF6BD00), size: 14),
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
      child:
      Icon(Icons.local_movies_outlined, color: Colors.white24, size: 64),
    );
  }
}
