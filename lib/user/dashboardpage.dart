import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_service.dart';
import '../signin.dart';
import 'schedule_provider.dart';
import 'create_schedule.dart';
import 'view_schedule.dart';
import 'notifications.dart';
import 'calendar.dart';
import '../models/User.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex =
      0; // State untuk melacak item yang dipilih di BottomNavigationBar

  // Daftar halaman yang akan ditampilkan berdasarkan BottomNavigationBar
  static final List<Widget> _pages = <Widget>[
    const _HomePageContent(), // Konten utama Dashboard
    const CalendarPage(),
    const CreateSchedulePage(), // Akan dinavigasi secara terpisah atau bisa juga di sini
    const ViewSchedulePage(), // Menggunakan ViewSchedulePage sebagai "History" sementara
    const NotificationPage(),
  ];

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    // Handle navigasi berdasarkan indeks
    switch (index) {
      case 0:
        // Sudah di halaman Dashboard/Home, tidak perlu navigasi
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CalendarPage()),
        );
        break;
      case 2:
        // Navigasi ke halaman Create Schedule dan tunggu hasilnya
        final newSchedule = await Navigator.push<Map<String, dynamic>>(
          context,
          MaterialPageRoute(builder: (context) => const CreateSchedulePage()),
        );
        if (newSchedule != null) {
          // Perbaikan: Tambahkan mounted check sebelum menggunakan context
          if (!mounted) return;
          Provider.of<ScheduleProvider>(
            context,
            listen: false,
          ).addSchedule(newSchedule, context);
        }
        // Setelah kembali dari CreateSchedulePage, pastikan kembali ke Home
        setState(() {
          _selectedIndex = 0;
        });
        break;
      case 3:
        // Menggunakan ViewSchedulePage sebagai "History" sementara
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ViewSchedulePage()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotificationPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // final scheduleProvider = Provider.of<ScheduleProvider>(context); // Tidak perlu di sini jika _pages sudah didefinisikan

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0A4D8C),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex, // Gunakan state _selectedIndex
        onTap: _onItemTapped, // Panggil fungsi _onItemTapped
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFB3E0FB),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.add, color: Color(0xFF0A4D8C)),
            ),
            label: 'Add Schedule',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: 'Notification',
          ),
        ],
      ),
      body: _pages[_selectedIndex], // Tampilkan halaman yang dipilih
    );
  }
}

// Widget terpisah untuk konten halaman utama Dashboard
// lib/user/dashboardpage.dart

class _HomePageContent extends StatefulWidget {
  // Convert to StatefulWidget
  const _HomePageContent({super.key});

  @override
  State<_HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<_HomePageContent> {
  // Create State
  @override
  void initState() {
    super.initState();
    // Load schedules when the widget is initialized
    // Ensure it's called safely after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Selalu cek `mounted` sebelum menggunakan context dalam async callback
        Provider.of<ScheduleProvider>(context, listen: false).loadSchedules(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final user = AuthService.currentUser;

    if (scheduleProvider.isLoading && scheduleProvider.schedules.isEmpty) {
      // Lebih spesifik: loading dan belum ada data
      return const Center(child: CircularProgressIndicator());
    } else if (scheduleProvider.error != null) {
      return Center(child: Text('Error: ${scheduleProvider.error}'));
    } else {
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header (user name part is likely fine)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    user?.name ?? 'User',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A2472),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Logout'),
                                  content: const Text(
                                    'Are you sure you want to logout?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () =>
                                              Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(true),
                                      child: const Text('Logout'),
                                    ),
                                  ],
                                ),
                          );
                          if (confirm == true) {
                            await AuthService.signOut();
                            if (!context.mounted) return;
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignInPage(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                      ),
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Color(0xFFB3E0FB),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundImage: AssetImage('images/avatar.png'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Daily Quote Card (remains the same) [cite: 304]
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFB3E0FB),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(2, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily Quote',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color(0xFF0A2472),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '“I am not a product of my circumstances. I am a product of my decisions.” -',
                      style: TextStyle(fontSize: 16, color: Color(0xFF0A2472)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: List.generate(
                        5,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color:
                                index == 0
                                    ? const Color(0xFF0A2472)
                                    : Colors.white.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Status Cards
              if (scheduleProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (scheduleProvider.error != null)
                Center(child: Text('Error: ${scheduleProvider.error}'))
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatusCard(
                      icon: Icons.assignment_outlined,
                      color: Colors.blue,
                      borderColor: Colors.blue,
                      label: 'Todo',
                      count: scheduleProvider.todoCount, // Pass count
                    ),
                    _StatusCard(
                      icon:
                          Icons
                              .donut_large_outlined, // Changed icon for clarity
                      color: Colors.orange,
                      borderColor: Colors.orange,
                      label: 'Progress',
                      count: scheduleProvider.progressCount, // Pass count
                    ),
                    _StatusCard(
                      icon: Icons.check_box_outlined,
                      color: Colors.green,
                      borderColor: Colors.green,
                      label: 'Done',
                      count: scheduleProvider.completedCount, // Pass count
                    ),
                    _StatusCard(
                      icon: Icons.warning_amber_rounded,
                      color: Colors.red,
                      borderColor: Colors.red,
                      label: 'Late',
                      count: scheduleProvider.overdueCount, // Pass count
                    ),
                  ],
                ),
              const SizedBox(height: 24),

              // Create Schedule Card [cite: 322]
              _BigCard(
                text:
                    "Hi!\nI know it can be tough to stay organized. Let's make a schedule together!",
                buttonText: "Create Schedule",
                imageAsset: 'images/notelist.png',
                onPressed: () async {
                  final newSchedule =
                      await Navigator.push<Map<String, dynamic>>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateSchedulePage(),
                        ),
                      );
                  if (newSchedule != null) {
                    if (!context.mounted) return;
                    // The provider will be updated by CreateSchedulePage itself if successful
                    // scheduleProvider.addSchedule(newSchedule); // This might be redundant
                    // Instead, just reload or trust the provider's state
                    Provider.of<ScheduleProvider>(
                      context,
                      listen: false,
                    ).loadSchedules(context);
                  }
                },
              ),
              const SizedBox(height: 20),
              // View Schedule Card
              _BigCard(
                text: "Check your progress and stay on top of your tasks!",
                buttonText: "View Schedule",
                imageAsset: 'images/presentation.png',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ViewSchedulePage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color borderColor;
  final String label;
  final int count;

  const _StatusCard({
    required this.icon,
    required this.color,
    required this.borderColor,
    required this.label,
    required this.count,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80, // Adjusted width for count
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center content
        children: [
          Text(
            count.toString(), // Display count
            style: TextStyle(
              color: color,
              fontSize: 20, // Count font size
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4), // Reduced space
          Icon(icon, color: color, size: 24), // Adjusted icon size
          const SizedBox(height: 4), // Reduced space
          Text(
            label,
            textAlign: TextAlign.center, // Center label
            style: const TextStyle(
              color: Color(0xFF0A2472),
              fontWeight: FontWeight.w600,
              fontSize: 12, // Adjusted label size
            ),
          ),
        ],
      ),
    );
  }
}

class _BigCard extends StatelessWidget {
  final String text;
  final String buttonText;
  final String imageAsset;
  final VoidCallback onPressed;

  const _BigCard({
    required this.text,
    required this.buttonText,
    required this.imageAsset,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFB3E0FB),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(2, 4)),
        ],
      ),
      child: Row(
        children: [
          // Text and button
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF0A2472),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4DB6F7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: onPressed,
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Illustration
          Expanded(
            flex: 1,
            child: Image.asset(imageAsset, height: 80, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}
