import 'package:flutter/material.dart';

import '../theme.dart';
import 'auth_widgets.dart';
import 'login_page.dart';
import 'signup_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BadalColors.forest,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, size) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 460,
                  minHeight: size.maxHeight - 52,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BrandMark(light: true),
                    SizedBox(height: size.maxHeight < 680 ? 28 : 55),
                    const _SwapArtwork(),
                    const SizedBox(height: 42),
                    const Text(
                      'غرضٌ لا تحتاجه،\nفرصةٌ لشخص آخر.',
                      style: TextStyle(
                        fontSize: 34,
                        height: 1.35,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'تبادل أغراضك بسهولة، واكتشف قيمة جديدة لما لديك. مقايضة ذكية، بلا مال، وبأثر ألطف على كوكبنا.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.7,
                        color: Colors.white.withValues(alpha: .78),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SignUpPage()),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BadalColors.orange,
                          foregroundColor: BadalColors.forest,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                'ابدأ رحلتك مع بدل',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(width: 9),
                            Icon(Icons.arrow_back_rounded),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: .4),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'لدي حساب بالفعل',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SwapArtwork extends StatelessWidget {
  const _SwapArtwork();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 245,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 15,
            right: 6,
            child: _artCard(
              Icons.chair_alt_rounded,
              const Color(0xFFE7EEE0),
              BadalColors.pine,
              -.12,
            ),
          ),
          Positioned(
            bottom: 10,
            left: 5,
            child: _artCard(
              Icons.headphones_rounded,
              const Color(0xFFF8D9B0),
              BadalColors.forest,
              .12,
            ),
          ),
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: BadalColors.orange,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.swap_horiz_rounded,
              color: BadalColors.forest,
              size: 38,
            ),
          ),
          Positioned(top: 4, left: 40, child: _sparkle()),
          Positioned(bottom: 12, right: 33, child: _sparkle()),
        ],
      ),
    );
  }

  Widget _artCard(
    IconData icon,
    Color background,
    Color foreground,
    double turn,
  ) => Transform.rotate(
    angle: turn,
    child: Container(
      width: 142,
      height: 162,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .14),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Icon(icon, size: 82, color: foreground),
    ),
  );

  Widget _sparkle() => const Icon(
    Icons.auto_awesome_rounded,
    size: 25,
    color: BadalColors.orange,
  );
}
