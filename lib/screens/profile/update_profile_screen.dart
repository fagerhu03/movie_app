import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:random_avatar/random_avatar.dart';

import '../../data/avatar_seeds.dart';
import '../../data/models/user_profile.dart';
import '../../domain/services/profile_api_service.dart';
import '../../domain/services/auth_api_service.dart';     // <-- add
import '../auth_screen/login_screen.dart';                // <-- add

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key, required this.me});

  final UserProfile me;
  static const routeName = 'UpdateProfileScreen';

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _api = ProfileApiService();

  late final TextEditingController _name;
  late final TextEditingController _phone;
  late int _avatarId;
  bool _saving = false;
  bool _deleting = false; // <-- NEW

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.me.name);
    _phone = TextEditingController(text: widget.me.phone ?? '');
    _avatarId = widget.me.avaterId;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await _api.update(
        name: _name.text.trim(),
        phone: _phone.text.trim(),
        avaterId: _avatarId,
      );
      if (!mounted) return;
      Navigator.pop(context, true); // tell caller we changed something
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Update failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmDelete() async {
    if (_deleting) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete account?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will permanently delete your profile on the server. '
              'Your local watch list/history will also be cleared.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
            const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFE53935))),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _deleteAccount();
    }
  }

  Future<void> _deleteAccount() async {
    setState(() => _deleting = true);
    try {
      // 1) delete on server (also clears Hive caches in the service)
      await _api.deleteAccount();
      // 2) clear auth token locally
      await AuthApiService().logout();
      if (!mounted) return;
      // 3) go to login screen fresh
      Navigator.of(context).pushNamedAndRemoveUntil(
        LoginScreen.routeName,
            (r) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFF6BD00);

    return Scaffold(
      backgroundColor: const Color(0xFF121312),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Pick Avatar', style: TextStyle(color: yellow)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: yellow),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Current avatar
            CircleAvatar(
              radius: 60.r,
              backgroundColor: Colors.black,
              child: ClipOval(
                child: RandomAvatar(
                  avatarSeedFor(_avatarId),
                  width: 150.w,
                  height: 150.w,
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Name
            TextField(
              controller: _name,
              style: const TextStyle(color: Colors.white, fontSize: 20),
              decoration: InputDecoration(
                hintText: 'Name',
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.person, color: Colors.white),
              ),
            ),
            SizedBox(height: 16.h),

            // Phone
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white, fontSize: 20),
              decoration: InputDecoration(
                hintText: 'Phone',
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.phone, color: Colors.white),
              ),
            ),
            SizedBox(height: 12.h),

            // Avatar picker
            SizedBox(
              height: 220.h,
              child: GridView.builder(
                itemCount: 12,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (_, i) {
                  final id = i + 1; // 1-based
                  final selected = id == _avatarId;
                  return GestureDetector(
                    onTap: () => setState(() => _avatarId = id),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF212121),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? yellow : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: RandomAvatar(avatarSeedFor(id),
                          width: 80.w, height: 80.h),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16.h),

            Row(
              children: [
                // Save
                Expanded(
                  child: SizedBox(
                    height: 60.h,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: yellow,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                          : const Text('Update Data',style: TextStyle(fontSize: 20),),

                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 60.h,
                    child: OutlinedButton.icon(
                      onPressed: _deleting ? null : _confirmDelete,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color(0xFFE53935), width: 1.5),
                        foregroundColor:  Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      backgroundColor: Color(0xFFE53935)),
                      icon: _deleting
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFE53935),
                        ),
                      )
                          : const Icon(Icons.delete_outline,size: 30,),
                      label: const Text('Delete Account',style: TextStyle(fontSize: 20),),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
