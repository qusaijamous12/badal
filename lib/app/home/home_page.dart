import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../auth/auth_controller.dart';
import '../swap/closet_page.dart';
import '../swap/discover_page.dart';
import '../swap/offers_page.dart';
import '../swap/swap_controller.dart';
import '../theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final SwapController swap;

  @override
  void initState() {
    super.initState();
    swap = Get.put(
      SwapController(uid: Get.find<AuthController>().user.value!.uid),
    );
  }

  @override
  void dispose() {
    Get.delete<SwapController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Obx(
    () => Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (swap.feedError.value != null)
              MaterialBanner(
                content: Text(swap.feedError.value!),
                actions: [
                  TextButton(
                    onPressed: () => swap.feedError.value = null,
                    child: const Text('إغلاق'),
                  ),
                ],
              ),
            Expanded(
              child: IndexedStack(
                index: swap.selectedTab.value,
                children: const [
                  DiscoverPage(),
                  ClosetPage(),
                  OffersPage(),
                  _ProfilePage(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: swap.selectedTab.value,
        onDestinationSelected: (index) => swap.selectedTab.value = index,
        backgroundColor: Colors.white,
        indicatorColor: BadalColors.mint,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'اكتشف',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'خزانتي',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz_outlined),
            selectedIcon: Icon(Icons.swap_horiz),
            label: 'العروض',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'حسابي',
          ),
        ],
      ),
    ),
  );
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final user = auth.user.value;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'حسابي',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: BadalColors.ink,
          ),
        ),
        const SizedBox(height: 28),
        CircleAvatar(
          radius: 37,
          backgroundColor: BadalColors.mint,
          child: Text(
            (user?.displayName?.isNotEmpty ?? false)
                ? user!.displayName![0]
                : 'ب',
            style: const TextStyle(fontSize: 30, color: BadalColors.forest),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            user?.displayName ?? 'عضو بدل',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Center(
          child: Text(
            user?.email ?? '',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 36),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: BadalColors.mint,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              Icon(Icons.eco_outlined, color: BadalColors.forest),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'كل غرض تتبادله يمنحه حياة جديدة ويقلّل الهدر.',
                  style: TextStyle(color: BadalColors.forest),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        OutlinedButton.icon(
          onPressed: () async {
            final error = await auth.signOut();
            if (error != null && context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(error)));
            }
          },
          icon: const Icon(Icons.logout_rounded),
          label: const Text('تسجيل الخروج'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(55),
            foregroundColor: BadalColors.forest,
          ),
        ),
      ],
    );
  }
}
