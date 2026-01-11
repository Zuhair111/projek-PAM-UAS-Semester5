import 'package:flutter/material.dart';
import '../widgets/role_card.dart';
import '../utils/user_role.dart';
import 'undangan_anak.dart';
import 'verifikasi_kode.dart';
import 'login_page.dart';

class SelectRoleScreen extends StatefulWidget {
  final String name;

  const SelectRoleScreen({Key? key, required this.name}) : super(key: key);

  @override
  State<SelectRoleScreen> createState() => _SelectRoleScreenState();
}

class _SelectRoleScreenState extends State<SelectRoleScreen> {
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8F0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pilih Rolemu',
          style: TextStyle(color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: 200,
                height: 150,
                child: Image.asset('assets/pilih_role.png', width: 150, height: 150)
              ),
              const SizedBox(height: 40),
              RoleCard(
                title: 'Orang tua',
                description:
                    'Halo, ${widget.name}! Kami senang kamu di sini. Di sini kamu dan keluarga dapat bergabung dan berbagi cerita',
                isSelected: selectedRole == 'parent',
                onTap: () {
                  setState(() {
                    selectedRole = 'parent';
                  });
                },
              ),
              const SizedBox(height: 16),
              RoleCard(
                title: 'Anak',
                description:
                    'Halo, ${widget.name}! Ayo kita berpetualang di dunia yang seru dan berbagi kenangan dengan keluarga!',
                isSelected: selectedRole == 'child',
                onTap: () {
                  setState(() {
                    selectedRole = 'child';
                  });
                },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: selectedRole != null
                      ? () {
                          // Simpan role dan nama
                          UserRole.setRole(selectedRole!);
                          UserRole.setName(widget.name);
                          
                          print('DEBUG: Role saved: $selectedRole');
                          print('DEBUG: Name saved: ${widget.name}');
                          
                          if (selectedRole == 'parent') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UndanganAnakScreen(
                                  parentName: widget.name,
                                ),
                              ),
                            );
                          } else if (selectedRole == 'child') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VerifikasiKodeScreen(
                                  childName: widget.name,
                                ),
                              ),
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE07B4F),
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Lanjut',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Sudah punya akun? ',
                    style: TextStyle(color: Colors.black54),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Masuk',
                      style: TextStyle(
                        color: Color(0xFFE07B4F),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}