import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  runApp(const AbsensiKingRoyalApp());
}

class AbsensiKingRoyalApp extends StatelessWidget {
  const AbsensiKingRoyalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Absensi King Royal',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  bool isCheckedIn = false;
  String? lastAction;

  final String employeeName = 'Nama Karyawan';
  final String employeeRole = 'Front Office';
  final String shift = 'Shift Pagi';
  final String locationStatus = 'Lokasi OK (GPS)';

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _checkIn(String timeStr) {
    setState(() {
      isCheckedIn = true;
      lastAction = 'Check In - $timeStr';
    });
  }

  void _checkOut(String timeStr) {
    setState(() {
      isCheckedIn = false;
      lastAction = 'Check Out - $timeStr';
    });
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('HH:mm:ss', 'id_ID').format(_now);
    final dateStr = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_now);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Absensi King Royal',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              'Hotel King Royal',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 860;
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _ProfileCard(
                              employeeName: employeeName,
                              employeeRole: employeeRole,
                              shift: shift,
                              timeStr: timeStr,
                              dateStr: dateStr,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: _StatusCard(
                              isCheckedIn: isCheckedIn,
                              locationStatus: locationStatus,
                              lastAction: lastAction,
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _ProfileCard(
                        employeeName: employeeName,
                        employeeRole: employeeRole,
                        shift: shift,
                        timeStr: timeStr,
                        dateStr: dateStr,
                      ),
                      const SizedBox(height: 14),
                      _StatusCard(
                        isCheckedIn: isCheckedIn,
                        locationStatus: locationStatus,
                        lastAction: lastAction,
                      ),
                    ],
                    const SizedBox(height: 14),
                    _ActionButtons(
                      isCheckedIn: isCheckedIn,
                      onCheckIn: () => _checkIn(timeStr),
                      onCheckOut: () => _checkOut(timeStr),
                      isWide: isWide,
                    ),
                    const SizedBox(height: 14),
                    _QuickMenu(
                      onHistory: () {},
                      onLeave: () {},
                      onProfile: () {},
                      isWide: isWide,
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'Copyright King Royal Hotel - v1.0',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String employeeName;
  final String employeeRole;
  final String shift;
  final String timeStr;
  final String dateStr;

  const _ProfileCard({
    required this.employeeName,
    required this.employeeRole,
    required this.shift,
    required this.timeStr,
    required this.dateStr,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 360;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        employeeName.isNotEmpty
                            ? employeeName[0].toUpperCase()
                            : 'A',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            employeeName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            employeeRole,
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                          Text(shift, style: TextStyle(color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (compact)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timeStr,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(dateStr, style: TextStyle(color: cs.onSurfaceVariant)),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Waktu Saat Ini',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            timeStr,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(dateStr, style: TextStyle(color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final bool isCheckedIn;
  final String locationStatus;
  final String? lastAction;

  const _StatusCard({
    required this.isCheckedIn,
    required this.locationStatus,
    required this.lastAction,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status Hari Ini',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text(isCheckedIn ? 'Sudah Check In' : 'Belum Check In')),
                Chip(label: Text(locationStatus)),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: isCheckedIn ? 1 : 0),
            const SizedBox(height: 10),
            Text(
              lastAction ?? 'Belum ada aktivitas.',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final bool isCheckedIn;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;
  final bool isWide;

  const _ActionButtons({
    required this.isCheckedIn,
    required this.onCheckIn,
    required this.onCheckOut,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    if (isWide) {
      return Row(
        children: [
          SizedBox(
            width: 180,
            child: FilledButton(
              onPressed: isCheckedIn ? null : onCheckIn,
              child: const Text('Check In'),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 180,
            child: FilledButton.tonal(
              onPressed: isCheckedIn ? onCheckOut : null,
              child: const Text('Check Out'),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: isCheckedIn ? null : onCheckIn,
            child: const Text('Check In'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.tonal(
            onPressed: isCheckedIn ? onCheckOut : null,
            child: const Text('Check Out'),
          ),
        ),
      ],
    );
  }
}

class _QuickMenu extends StatelessWidget {
  final VoidCallback onHistory;
  final VoidCallback onLeave;
  final VoidCallback onProfile;
  final bool isWide;

  const _QuickMenu({
    required this.onHistory,
    required this.onLeave,
    required this.onProfile,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    final menus = [
      _MenuItem(label: 'Riwayat', onPressed: onHistory),
      _MenuItem(label: 'Izin', onPressed: onLeave),
      _MenuItem(label: 'Profil', onPressed: onProfile),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Menu Cepat',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            if (isWide)
              Row(
                children: menus
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: OutlinedButton(
                          onPressed: item.onPressed,
                          child: Text(item.label),
                        ),
                      ),
                    )
                    .toList(),
              )
            else
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: menus
                    .map(
                      (item) => OutlinedButton(
                        onPressed: item.onPressed,
                        child: Text(item.label),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final String label;
  final VoidCallback onPressed;

  _MenuItem({required this.label, required this.onPressed});
}
