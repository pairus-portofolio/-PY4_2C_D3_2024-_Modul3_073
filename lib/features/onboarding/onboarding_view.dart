import 'package:flutter/material.dart';
import 'package:logbook_app_073/features/auth/login_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  int _step = 1;

  // Data konten untuk setiap langkah onboarding
  final List<Map<String, String>> _onboardingData = [
    {
      'image': 'assets/images/Onboarding1.jpg',
      'title': 'Catat Aktivitasmu',
      'description':
          'Dokumentasikan setiap kegiatan harianmu dengan mudah dan terstruktur. '
          'Logbook digitalmu selalu siap menemanimu kapan saja dan di mana saja.',
    },
    {
      'image': 'assets/images/Onboarding2.jpg',
      'title': 'Pantau Perkembanganmu',
      'description':
          'Lihat progres belajarmu secara real-time dan evaluasi pencapaianmu. '
          'Jadikan setiap hari lebih produktif dan bermakna bersama kami.',
    },
    {
      'image': 'assets/images/Onboarding3.jpg',
      'title': 'Raih Prestasi Terbaikmu',
      'description':
          'Wujudkan target akademikmu dengan perencanaan yang matang dan terukur. '
          'Bersama LogBook, perjalanan belajarmu menjadi lebih terarah dan menyenangkan!',
    },
  ];

  void _nextStep() {
    if (_step >= 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginView()),
      );
    } else {
      setState(() {
        _step++;
      });
    }
  }

  void _skip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _onboardingData[_step - 1];
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Tombol Skip di pojok kanan atas
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: TextButton(
                  onPressed: _skip,
                  child: Text(
                    'Lewati',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // Gambar Ilustrasi
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: Image.asset(
                    data['image']!,
                    key: ValueKey(_step),
                    fit: BoxFit.contain,
                    width: size.width,
                  ),
                ),
              ),
            ),

            // Konten Teks
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Indikator Langkah (Dots)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        final isActive = index + 1 == _step;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFF4A90D9)
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 20),

                    // Judul
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Text(
                        data['title']!,
                        key: ValueKey('title_$_step'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Deskripsi
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Text(
                        data['description']!,
                        key: ValueKey('desc_$_step'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.6,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Tombol Lanjut
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A90D9),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          _step == 3 ? 'Mulai Sekarang' : 'Lanjut',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
