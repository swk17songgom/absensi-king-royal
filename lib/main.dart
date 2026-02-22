import 'dart:async';
import 'dart:io';

import 'package:absensi_king_royal/absen_masuk_page.dart';
import 'package:absensi_king_royal/absen_pulang_page.dart';
import 'package:absensi_king_royal/ajukan_izin_page.dart';
import 'package:absensi_king_royal/attendance_capture_page.dart';
import 'package:absensi_king_royal/admin_dashboard_section.dart';
import 'package:absensi_king_royal/auth_service.dart';
import 'package:absensi_king_royal/login_page.dart';
import 'package:absensi_king_royal/payroll_models.dart';
import 'package:absensi_king_royal/riwayat_page.dart';
import 'package:absensi_king_royal/reset_password_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:absensi_king_royal/profile_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  runApp(const AbsensiKingRoyalApp());
}

class AbsensiKingRoyalApp extends StatefulWidget {
  const AbsensiKingRoyalApp({super.key});

  @override
  State<AbsensiKingRoyalApp> createState() => _AbsensiKingRoyalAppState();
}

class _AbsensiKingRoyalAppState extends State<AbsensiKingRoyalApp> {
  final AuthService _authService = AuthService();
  AppUser? _loggedInUser;
  bool _rememberMe = false;

  void _handleLoginSuccess(AppUser user, bool rememberMe) {
    setState(() {
      _loggedInUser = user;
      _rememberMe = rememberMe;
    });
  }

  void _handleLogout() {
    setState(() {
      _loggedInUser = null;
      if (!_rememberMe) {
        _rememberMe = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const royalBlue = Color(0xFF0D2B52);
    const royalGold = Color(0xFFC9A548);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Absensi King Royal',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: royalBlue,
          primary: royalBlue,
          secondary: royalGold,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8FB),
      ),
      home: _loggedInUser == null
          ? LoginPage(
              authService: _authService,
              onLoginSuccess: _handleLoginSuccess,
            )
          : HomeScreen(
              currentUser: _loggedInUser!,
              authService: _authService,
              onLogout: _handleLogout,
            ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final AppUser currentUser;
  final AuthService authService;
  final VoidCallback onLogout;

  const HomeScreen({
    super.key,
    required this.currentUser,
    required this.authService,
    required this.onLogout,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  late final String employeeName;
  late final String employeeNik;
  late final String employeePlaceOfBirth;
  late final DateTime employeeBirthDate;
  late final String employeeGender;
  late final String employeeAddress;
  late final String employeeJobTitle;
  late final String employeeRole;
  late final String employeeDepartment;
  late final String employeeStatus;
  late final DateTime employeeJoinDate;
  late final String employeeBankAccountNumber;
  late final String employeePhone;
  late final String employeeEmail;
  String? employeeProfilePhotoPath;

  int totalHadir = 22;
  int totalOff = 2;
  int totalCuti = 1;
  int totalExtraOff = 2;
  int totalSakit = 0;
  int totalLembur = 7;
  static const int annualLeaveQuota = 12;

  AttendanceSessionState attendanceState = AttendanceSessionState.notCheckedIn;
  DateTime? checkInAt;
  DateTime? checkOutAt;
  final List<LeaveHistoryItem> leaveHistory = [
    const LeaveHistoryItem(
      title: 'Izin Keperluan Keluarga',
      date: '03/02/2026',
      status: LeaveHistoryStatus.approved,
    ),
    const LeaveHistoryItem(
      title: 'Izin Sakit',
      date: '14/01/2026',
      status: LeaveHistoryStatus.rejected,
    ),
  ];
  final List<SentPayrollSlip> _sentPayrollSlips = [];

  @override
  void initState() {
    super.initState();
    employeeName = widget.currentUser.fullName;
    employeeNik = widget.currentUser.nik;
    employeePlaceOfBirth = widget.currentUser.placeOfBirth;
    employeeBirthDate = widget.currentUser.birthDate;
    employeeGender = widget.currentUser.gender;
    employeeAddress = widget.currentUser.address;
    employeeJobTitle = widget.currentUser.jobTitle;
    employeeRole = widget.currentUser.role;
    employeeDepartment = widget.currentUser.department;
    employeeStatus = widget.currentUser.employeeStatus;
    employeeJoinDate = widget.currentUser.joinDate;
    employeeBankAccountNumber = widget.currentUser.bankAccountNumber;
    employeePhone = widget.currentUser.phoneNumber;
    employeeEmail = widget.currentUser.email;
    employeeProfilePhotoPath = widget.currentUser.profilePhotoPath;
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

  Future<void> _openAbsenMasukPage() async {
    if (attendanceState != AttendanceSessionState.notCheckedIn) return;
    final result = await Navigator.of(context).push<AttendanceCaptureResult>(
      MaterialPageRoute(
        builder: (_) => AbsenMasukPage(
          employeeName: employeeName,
          employeeNik: employeeNik,
        ),
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      checkInAt = result.capturedAt;
      checkOutAt = null;
      attendanceState = AttendanceSessionState.checkedIn;
    });
  }

  Future<void> _openAbsenPulangPage() async {
    if (attendanceState != AttendanceSessionState.checkedIn) return;
    final result = await Navigator.of(context).push<AttendanceCaptureResult>(
      MaterialPageRoute(
        builder: (_) => AbsenPulangPage(
          employeeName: employeeName,
          employeeNik: employeeNik,
        ),
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      checkOutAt = result.capturedAt;
      attendanceState = AttendanceSessionState.checkedOut;
    });
  }

  Future<void> _openAjukanIzinPage({
    LeaveRequestType initialType = LeaveRequestType.sakit,
  }) async {
    final result = await Navigator.of(context).push<LeaveSubmissionPayload>(
      MaterialPageRoute(
        builder: (_) => AjukanIzinPage(
          leaveHistory: leaveHistory,
          initialType: initialType,
        ),
      ),
    );

    if (result == null || !mounted) return;
    setState(() {
      final requestedDays = result.requestedDays <= 0
          ? 1
          : result.requestedDays;
      leaveHistory.insert(0, result.historyItem);
      if (result.type == LeaveRequestType.sakit) totalSakit += requestedDays;
      if (result.type == LeaveRequestType.cuti) totalCuti += requestedDays;
      if (result.type == LeaveRequestType.extraOff) {
        totalExtraOff += requestedDays;
      }
      if (result.type == LeaveRequestType.lembur) totalLembur += 1;
    });
  }

  void _openProfilePage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EmployeeProfilePage(
          fullName: employeeName,
          nik: employeeNik,
          placeOfBirth: employeePlaceOfBirth,
          birthDate: employeeBirthDate,
          gender: employeeGender,
          address: employeeAddress,
          phoneNumber: employeePhone,
          email: employeeEmail,
          jobTitle: employeeJobTitle,
          role: employeeRole,
          department: employeeDepartment,
          employeeStatus: employeeStatus,
          joinDate: employeeJoinDate,
          bankAccountNumber: employeeBankAccountNumber,
          profilePhotoPath: employeeProfilePhotoPath,
          onProfilePhotoChanged: (path) {
            setState(() => employeeProfilePhotoPath = path);
          },
          totalHadir: totalHadir,
          totalOff: totalOff,
          totalCuti: totalCuti,
          totalExtraOff: totalExtraOff,
          totalSakit: totalSakit,
          totalLembur: totalLembur,
          annualLeaveQuota: annualLeaveQuota,
          remainingLeave: (annualLeaveQuota - totalCuti).clamp(
            0,
            annualLeaveQuota,
          ),
          leaveHistory: leaveHistory,
          salarySlips: _sentPayrollSlips
              .where((slip) => slip.employeeName == employeeName)
              .toList(),
          onResetPassword: _openResetPasswordPage,
          onLogout: () {
            Navigator.of(context).pop();
            widget.onLogout();
          },
        ),
      ),
    );
  }

  void _openResetPasswordPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResetPasswordPage(
          authService: widget.authService,
          user: widget.currentUser,
        ),
      ),
    );
  }

  void _openRiwayatPage() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RiwayatPage()));
  }

  DateTime? _parseDateLabel(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    try {
      return DateFormat('dd/MM/yyyy', 'id_ID').parseStrict(trimmed);
    } catch (_) {
      return null;
    }
  }

  bool _isLeaveInMonth(LeaveHistoryItem item, int year, int month) {
    final rangeParts = item.date.split(' - ');
    final start = _parseDateLabel(rangeParts.first);
    if (start == null) return false;
    final end = rangeParts.length > 1
        ? (_parseDateLabel(rangeParts.last) ?? start)
        : start;

    final monthStart = DateTime(year, month, 1);
    final monthEnd = DateTime(year, month + 1, 0, 23, 59, 59);
    return !end.isBefore(monthStart) && !start.isAfter(monthEnd);
  }

  List<LeaveHistoryItem> get _leaveHistoryThisMonth {
    return leaveHistory
        .where((item) => _isLeaveInMonth(item, _now.year, _now.month))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final jam = DateFormat('HH:mm:ss', 'id_ID').format(_now);
    final hari = DateFormat('EEEE', 'id_ID').format(_now);
    final tanggal = DateFormat('dd MMMM yyyy', 'id_ID').format(_now);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.06,
                child: Center(
                  child: Image.asset(
                    'assets/icons/app_icon.jpg',
                    width: 320,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          'assets/icons/app_icon.jpg',
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _HeaderCard(
                      employeeName: employeeName,
                      employeeNik: employeeNik,
                      employeeJobTitle: employeeJobTitle,
                      employeeRole: employeeRole,
                      employeeDepartment: employeeDepartment,
                      profilePhotoPath: employeeProfilePhotoPath,
                      onTap: _openProfilePage,
                    ),
                    const SizedBox(height: 12),
                    _InfoBulanIniCard(
                      totalHadir: totalHadir,
                      totalOff: totalOff,
                      totalCuti: totalCuti,
                      totalExtraOff: totalExtraOff,
                      totalSakit: totalSakit,
                      totalLembur: totalLembur,
                      leaveHistory: _leaveHistoryThisMonth,
                      attendanceStatus: switch (attendanceState) {
                        AttendanceSessionState.notCheckedIn => 'Belum Absen',
                        AttendanceSessionState.checkedIn => 'Sudah Absen Masuk',
                        AttendanceSessionState.checkedOut =>
                          'Sudah Absen Pulang',
                      },
                    ),
                    const SizedBox(height: 12),
                    _MainMenuCard(
                      jam: jam,
                      hari: hari,
                      tanggal: tanggal,
                      attendanceState: attendanceState,
                      checkInAt: checkInAt,
                      checkOutAt: checkOutAt,
                      onAbsenMasuk: _openAbsenMasukPage,
                      onAbsenPulang: _openAbsenPulangPage,
                      onAjukanIzin: () {
                        _openAjukanIzinPage();
                      },
                      onRiwayat: _openRiwayatPage,
                    ),
                    if (employeeRole.toLowerCase() == 'admin')
                      AdminDashboardSection(
                        currentUserName: employeeName,
                        onSlipSent: (slip) {
                          setState(() {
                            _sentPayrollSlips.removeWhere(
                              (item) =>
                                  item.employeeId == slip.employeeId &&
                                  item.month == slip.month &&
                                  item.year == slip.year,
                            );
                            _sentPayrollSlips.insert(0, slip);
                          });
                        },
                      ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'Copyright King Royal Hotel - v1.0',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
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

class _HeaderCard extends StatelessWidget {
  final String employeeName;
  final String employeeNik;
  final String employeeJobTitle;
  final String employeeRole;
  final String employeeDepartment;
  final String? profilePhotoPath;
  final VoidCallback onTap;

  const _HeaderCard({
    required this.employeeName,
    required this.employeeNik,
    required this.employeeJobTitle,
    required this.employeeRole,
    required this.employeeDepartment,
    required this.profilePhotoPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasCustomPhoto =
        profilePhotoPath != null && File(profilePhotoPath!).existsSync();
    final ImageProvider<Object> profileImage = hasCustomPhoto
        ? FileImage(File(profilePhotoPath!))
        : const AssetImage('assets/icons/app_icon.jpg');
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundImage: profileImage,
                backgroundColor: cs.primaryContainer,
              ),
              const SizedBox(height: 10),
              Text(
                'Selamat Datang',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                employeeName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'kode karyawan: $employeeNik',
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
              Text(
                employeeJobTitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
              Text(
                'Role: $employeeRole',
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
              Text(
                employeeDepartment,
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 6),
              Text(
                'Ketuk untuk lihat profil',
                style: TextStyle(
                  color: cs.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBulanIniCard extends StatelessWidget {
  final int totalHadir;
  final int totalOff;
  final int totalCuti;
  final int totalExtraOff;
  final int totalSakit;
  final int totalLembur;
  final List<LeaveHistoryItem> leaveHistory;
  final String attendanceStatus;

  const _InfoBulanIniCard({
    required this.totalHadir,
    required this.totalOff,
    required this.totalCuti,
    required this.totalExtraOff,
    required this.totalSakit,
    required this.totalLembur,
    required this.leaveHistory,
    required this.attendanceStatus,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final infoItems = [
      _InfoLine(label: 'Total Hadir', value: '$totalHadir hari'),
      _InfoLine(label: 'Total Off', value: '$totalOff hari'),
      _InfoLine(label: 'Total Cuti', value: '$totalCuti hari'),
      _InfoLine(label: 'Total Extra Off', value: '$totalExtraOff hari'),
      _InfoLine(label: 'Total Sakit', value: '$totalSakit hari'),
      _InfoLine(label: 'Total Lembur', value: '$totalLembur jam'),
      _InfoLine(label: 'Status Absen Hari Ini', value: attendanceStatus),
    ];

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Info Bulan Ini',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            ...infoItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.value,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: item.label.contains('Status')
                            ? cs.primary
                            : cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Status Pengajuan Izin',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (leaveHistory.isEmpty)
              const _LeaveStatusBadge(status: LeaveSubmissionStatus.none)
            else
              ...leaveHistory.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(color: cs.onSurfaceVariant),
                            ),
                          ),
                          _LeaveStatusBadge(
                            status: switch (item.status) {
                              LeaveHistoryStatus.approved =>
                                LeaveSubmissionStatus.approved,
                              LeaveHistoryStatus.pending =>
                                LeaveSubmissionStatus.pending,
                              LeaveHistoryStatus.rejected =>
                                LeaveSubmissionStatus.rejected,
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tanggal: ${item.date}',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
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

enum AttendanceSessionState { notCheckedIn, checkedIn, checkedOut }

enum LeaveSubmissionStatus { approved, pending, rejected, none }

extension LeaveSubmissionStatusX on LeaveSubmissionStatus {
  String get label {
    switch (this) {
      case LeaveSubmissionStatus.approved:
        return 'Approve';
      case LeaveSubmissionStatus.pending:
        return 'Pending';
      case LeaveSubmissionStatus.rejected:
        return 'Tolak';
      case LeaveSubmissionStatus.none:
        return 'Tidak Ada';
    }
  }
}

class _LeaveStatusBadge extends StatelessWidget {
  final LeaveSubmissionStatus status;

  const _LeaveStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor) = switch (status) {
      LeaveSubmissionStatus.approved => (const Color(0xFF2E7D32), Colors.white),
      LeaveSubmissionStatus.pending => (
        const Color(0xFFFBC02D),
        const Color(0xFF3A2A00),
      ),
      LeaveSubmissionStatus.rejected => (const Color(0xFFC62828), Colors.white),
      LeaveSubmissionStatus.none => (const Color(0xFF9E9E9E), Colors.white),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _InfoLine {
  final String label;
  final String value;

  const _InfoLine({required this.label, required this.value});
}

class _MainMenuCard extends StatelessWidget {
  final String jam;
  final String hari;
  final String tanggal;
  final AttendanceSessionState attendanceState;
  final DateTime? checkInAt;
  final DateTime? checkOutAt;
  final VoidCallback onAbsenMasuk;
  final VoidCallback onAbsenPulang;
  final VoidCallback onAjukanIzin;
  final VoidCallback onRiwayat;

  const _MainMenuCard({
    required this.jam,
    required this.hari,
    required this.tanggal,
    required this.attendanceState,
    required this.checkInAt,
    required this.checkOutAt,
    required this.onAbsenMasuk,
    required this.onAbsenPulang,
    required this.onAjukanIzin,
    required this.onRiwayat,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final menus = [
      _MainMenuItem(
        title: 'Absen Masuk',
        icon: Icons.login_rounded,
        color: cs.primary,
        isEnabled: attendanceState == AttendanceSessionState.notCheckedIn,
        onTap: onAbsenMasuk,
      ),
      _MainMenuItem(
        title: 'Absen Pulang',
        icon: Icons.logout_rounded,
        color: cs.secondary,
        isEnabled: attendanceState == AttendanceSessionState.checkedIn,
        onTap: onAbsenPulang,
      ),
      _MainMenuItem(
        title: 'Ajukan Izin',
        icon: Icons.note_add_rounded,
        color: const Color(0xFF2A8F64),
        onTap: onAjukanIzin,
      ),
      _MainMenuItem(
        title: 'Riwayat',
        icon: Icons.history_rounded,
        color: const Color(0xFF8949B3),
        onTap: onRiwayat,
      ),
    ];

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Menu Utama',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              jam,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Text(hari, style: TextStyle(color: cs.onSurfaceVariant)),
            Text(tanggal, style: TextStyle(color: cs.onSurfaceVariant)),
            if (checkInAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Absen masuk pada ${DateFormat('HH:mm:ss', 'id_ID').format(checkInAt!)} WIB',
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (checkOutAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Absen pulang pada ${DateFormat('HH:mm:ss', 'id_ID').format(checkOutAt!)} WIB',
                style: TextStyle(
                  color: cs.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.45,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: menus.map((item) => _MenuTile(item: item)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainMenuItem {
  final String title;
  final IconData icon;
  final Color color;
  final bool isEnabled;
  final VoidCallback onTap;

  const _MainMenuItem({
    required this.title,
    required this.icon,
    required this.color,
    this.isEnabled = true,
    required this.onTap,
  });
}

class _MenuTile extends StatelessWidget {
  final _MainMenuItem item;

  const _MenuTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final tileColor = item.isEnabled
        ? item.color.withValues(alpha: 0.14)
        : const Color(0xFFE0E0E0);
    final iconColor = item.isEnabled ? item.color : const Color(0xFF9E9E9E);
    final textColor = item.isEnabled ? Colors.black87 : const Color(0xFF9E9E9E);

    return Material(
      color: tileColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: item.isEnabled ? item.onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, color: iconColor),
              const SizedBox(height: 10),
              Text(
                item.title,
                style: TextStyle(fontWeight: FontWeight.w700, color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
