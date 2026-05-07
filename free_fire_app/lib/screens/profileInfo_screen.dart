import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileInfoScreen extends StatefulWidget {
  const ProfileInfoScreen({Key? key}) : super(key: key);

  @override
  State<ProfileInfoScreen> createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final _nameController = TextEditingController();
  final _ffIdController = TextEditingController();

  Map<String, dynamic>? userData;
  bool _loading = true;
  bool _updating = false;
  String? _error;
  String _lang = 'en';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      setState(() {
        userData = doc.data();
        _nameController.text = userData?['name'] ?? '';
        _ffIdController.text = userData?['ff_id'] ?? '';
        _lang = userData?['settings']?['language'] ?? 'en';
        _loading = false;
      });
      print(_lang + ' ============');
    } catch (e) {
      setState(() {
        _error = _tr('failedToLoad');
        _loading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.trim().isEmpty ||
        _ffIdController.text.trim().isEmpty) {
      setState(() => _error = _tr('nameAndFfIdEmpty'));
      return;
    }

    final newFfId = _ffIdController.text.trim();
    final currentFfId = userData?['ff_id'];

    setState(() {
      _updating = true;
      _error = null;
    });

    try {
      // Check if FF ID is used by another user
      if (newFfId != currentFfId) {
        final existing = await FirebaseFirestore.instance
            .collection('users')
            .where('ff_id', isEqualTo: newFfId)
            .get();

        if (existing.docs.isNotEmpty) {
          setState(() {
            _error = _tr('ffIdInUse');
            _updating = false;
          });
          return;
        }
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({'name': _nameController.text.trim(), 'ff_id': newFfId});

      setState(() {
        _error = _tr('updatedSuccessfully');
        _updating = false;
      });
    } catch (e) {
      setState(() {
        _error = _tr('updateFailed') + ': $e';
        _updating = false;
      });
    }
  }

  Widget _buildField(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[300],
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white10,
          ),
          child: Text(value, style: TextStyle(color: Colors.white)),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(color: Colors.white, fontSize: 16);
    return Directionality(
      textDirection: _lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Color(0xFF1C1C1C),
        appBar: AppBar(
          title: Text(_tr('profileInfo')),
          backgroundColor: Color(0xFF1C1C1C),
          foregroundColor: Colors.white,
          elevation: 0,
          leading: BackButton(),
        ),
        body: _loading
            ? Center(child: CircularProgressIndicator(color: Colors.orange))
            : SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Editable Name
                    Text(_tr('name'), style: textStyle),
                    SizedBox(height: 4),
                    TextField(
                      controller: _nameController,
                      style: textStyle,
                      decoration: _inputDecoration(),
                    ),
                    SizedBox(height: 16),

                    // Editable FF ID
                    Text(_tr('freeFireId'), style: textStyle),
                    SizedBox(height: 4),
                    TextField(
                      controller: _ffIdController,
                      style: textStyle,
                      decoration: _inputDecoration(),
                    ),
                    SizedBox(height: 16),

                    // Read-only Fields
                    _buildField(_tr('email'), userData?['email'] ?? ''),
                    if (userData?['invited'] != null &&
                        userData!['invited'].isNotEmpty)
                      _buildField(_tr('invitedBy'), userData!['invited'][0]),
                    _buildField(
                      _tr('tokenCount'),
                      userData?['tokenCount'].toString() ?? '0',
                    ),
                    _buildField(
                      _tr('totalTokens'),
                      userData?['totalTokenCount'].toString() ?? '0',
                    ),
                    _buildField(
                      _tr('teamId'),
                      userData?['teamId'] ?? _tr('notInTeam'),
                    ),
                    _buildField(
                      _tr('language'),
                      userData?['settings']?['language'] ?? 'en',
                    ),
                    _buildField(
                      _tr('mode'),
                      userData?['settings']?['mode'] ?? 'light',
                    ),

                    if (_error != null) ...[
                      SizedBox(height: 16),
                      Text(_error!, style: TextStyle(color: Colors.redAccent)),
                    ],

                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _updating ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _updating
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(_tr('update'), style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white10,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  String _tr(String key) {
    final isAr = _lang == 'ar';
    switch (key) {
      case 'profileInfo':
        return isAr ? 'معلومات الملف' : 'Profile Info';
      case 'name':
        return isAr ? 'الاسم' : 'Name';
      case 'freeFireId':
        return isAr ? 'معرّف فري فاير' : 'Free Fire ID';
      case 'email':
        return isAr ? 'البريد الإلكتروني' : 'Email';
      case 'invitedBy':
        return isAr ? 'مدعو من' : 'Invited by';
      case 'tokenCount':
        return isAr ? 'عدد الرموز' : 'Token Count';
      case 'totalTokens':
        return isAr ? 'إجمالي الرموز' : 'Total Tokens';
      case 'teamId':
        return isAr ? 'معرّف الفريق' : 'Team ID';
      case 'notInTeam':
        return isAr ? 'ليس ضمن فريق' : 'Not in a team';
      case 'language':
        return isAr ? 'اللغة' : 'Language';
      case 'mode':
        return isAr ? 'الوضع' : 'Mode';
      case 'update':
        return isAr ? 'تحديث' : 'Update';
      case 'failedToLoad':
        return isAr ? 'فشل تحميل بيانات المستخدم' : 'Failed to load user data';
      case 'nameAndFfIdEmpty':
        return isAr
            ? 'لا يمكن أن يكون الاسم ومعرّف فري فاير فارغين.'
            : 'Name and Free Fire ID cannot be empty.';
      case 'ffIdInUse':
        return isAr ? 'معرّف فري فاير مستخدم مسبقاً.' : 'FF ID already in use.';
      case 'updatedSuccessfully':
        return isAr ? 'تم التحديث بنجاح!' : 'Updated successfully!';
      case 'updateFailed':
        return isAr ? 'فشل التحديث' : 'Update failed';
      default:
        return key;
    }
  }
}
