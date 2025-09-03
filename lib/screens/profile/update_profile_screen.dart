import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:random_avatar/random_avatar.dart';

import '../../data/avatar_seeds.dart';
import '../../data/models/user_profile.dart';
import '../../domain/services/profile_api_service.dart';

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
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFF6BD00);

    return Scaffold(
      backgroundColor: const Color(0xFF121312),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Pick Avatar', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Current avatar preview
            CircleAvatar(
              radius: 48.r,
              backgroundColor: Colors.black,
              child: ClipOval(
                child: RandomAvatar(
                  avatarSeedFor(_avatarId),
                  width: 96.w,
                  height: 96.w,
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Name
            TextField(
              controller: _name,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Name',
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.person, color: Colors.white70),
              ),
            ),
            SizedBox(height: 12.h),

            // Phone
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Phone',
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.phone, color: Colors.white70),
              ),
            ),
            SizedBox(height: 12.h),

            // Avatar picker – 3x3 grid (1..9) – change as you like
            SizedBox(
              height: 220.h,
              child: GridView.builder(
                itemCount: 12,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
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
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? yellow : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: RandomAvatar(avatarSeedFor(id), width: 54, height: 54),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 12.h),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 48.h,
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
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.black,
                  ),
                )
                    : const Text('Update Data'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
