import 'dart:io';

import 'package:absensi_king_royal/payroll_models.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

enum AdminRole { admin, staff }

enum ApprovalType { izin, cuti, extraOff, sakit, lembur }

enum ApprovalStatus { pending, approved, rejected }

enum _DailyAttendanceStatus {
  hadir,
  off,
  extraOff,
  cuti,
  sakit,
  alfa,
  tidakHadir,
}

class _DailyAttendanceDetail {
  DateTime date;
  _DailyAttendanceStatus status;
  TimeOfDay? checkIn;
  TimeOfDay? checkOut;
  int lemburHours;
  String note;
  String? checkInPhotoPath;
  String? checkOutPhotoPath;
  bool isManuallyEdited = false;

  _DailyAttendanceDetail({
    required this.date,
    required this.status,
    required this.checkIn,
    required this.checkOut,
    required this.lemburHours,
    required this.note,
    required this.checkInPhotoPath,
    required this.checkOutPhotoPath,
  });
}

class _MonthlyRecap {
  final String employeeName;
  final int month;
  final int year;
  int totalHadir;
  int totalOff;
  int totalTidakHadir;
  int totalCuti;
  int totalExtraOff;
  int totalSakit;
  int totalAlfa;
  int totalLembur;
  final List<_DailyAttendanceDetail> dailyDetails;

  _MonthlyRecap({
    required this.employeeName,
    required this.month,
    required this.year,
    required this.totalHadir,
    required this.totalOff,
    required this.totalTidakHadir,
    required this.totalCuti,
    required this.totalExtraOff,
    required this.totalSakit,
    required this.totalAlfa,
    required this.totalLembur,
    required this.dailyDetails,
  });
}

class _ApprovalRequest {
  final String id;
  final String employeeName;
  final ApprovalType type;
  final String? reason;
  final DateTime date;
  final String? attachment;
  ApprovalStatus status = ApprovalStatus.pending;

  _ApprovalRequest({
    required this.id,
    required this.employeeName,
    required this.type,
    required this.reason,
    required this.date,
    required this.attachment,
  });
}

class _SalarySlip {
  final String id;
  final String employeeId;
  final String employeeName;
  final int month;
  final int year;
  int gajiPokok;
  int tunjanganJabatan;
  int lembur;
  int tunjanganLain;
  int potonganPinjaman;
  int potonganAbsen;
  int potonganBpjsKesehatan;
  int potonganBpjsTkJht;
  int potonganBpjsTkJp;
  int potonganPph21;
  String notes;
  final DateTime generatedAt;
  DateTime? sentAt;

  _SalarySlip({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.month,
    required this.year,
    required this.gajiPokok,
    required this.tunjanganJabatan,
    required this.lembur,
    required this.tunjanganLain,
    required this.potonganPinjaman,
    required this.potonganAbsen,
    required this.potonganBpjsKesehatan,
    required this.potonganBpjsTkJht,
    required this.potonganBpjsTkJp,
    required this.potonganPph21,
    required this.notes,
    required this.generatedAt,
  });

  int get totalGaji =>
      gajiPokok +
      tunjanganJabatan +
      lembur +
      tunjanganLain -
      potonganPinjaman -
      potonganAbsen -
      potonganBpjsKesehatan -
      potonganBpjsTkJht -
      potonganBpjsTkJp -
      potonganPph21;
}

class _EmployeeData {
  final String id;
  String fullName;
  String nik;
  String placeOfBirth;
  DateTime birthDate;
  String gender;
  String address;
  String phoneNumber;
  String email;
  String jobTitle;
  AdminRole role;
  String department;
  String employeeStatus;
  DateTime joinDate;
  String bankAccountNumber;
  int gajiPokok;
  String? profilePhotoPath;
  bool isActive = true;

  _EmployeeData({
    required this.id,
    required this.fullName,
    required this.nik,
    required this.placeOfBirth,
    required this.birthDate,
    required this.gender,
    required this.address,
    required this.phoneNumber,
    required this.email,
    required this.jobTitle,
    required this.role,
    required this.department,
    required this.employeeStatus,
    required this.joinDate,
    required this.bankAccountNumber,
    required this.gajiPokok,
    this.profilePhotoPath,
  });
}

class _ActivityLog {
  final DateTime time;
  final String actor;
  final String module;
  final String action;
  final String target;
  final String? detail;
  final String? before;
  final String? after;

  const _ActivityLog({
    required this.time,
    required this.actor,
    required this.module,
    required this.action,
    required this.target,
    this.detail,
    this.before,
    this.after,
  });
}

class AdminDashboardSection extends StatefulWidget {
  final String currentUserName;
  final ValueChanged<SentPayrollSlip>? onSlipSent;

  const AdminDashboardSection({
    super.key,
    required this.currentUserName,
    this.onSlipSent,
  });

  @override
  State<AdminDashboardSection> createState() => _AdminDashboardSectionState();
}

class _AdminDashboardSectionState extends State<AdminDashboardSection> {
  static const int _annualLeaveQuota = 12;
  late int _selectedMonth;
  late int _selectedYear;
  String _nameFilter = '';

  late final List<_MonthlyRecap> _recapData;
  late final List<_ApprovalRequest> _approvalRequests;
  late final List<_EmployeeData> _employees;
  final List<_SalarySlip> _salarySlips = [];
  final List<_ActivityLog> _activityLogs = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;

    _recapData = <_MonthlyRecap>[
      _MonthlyRecap(
        employeeName: 'Ari Saputra',
        month: now.month,
        year: now.year,
        totalHadir: 20,
        totalOff: 1,
        totalTidakHadir: 1,
        totalCuti: 1,
        totalExtraOff: 1,
        totalSakit: 0,
        totalAlfa: 0,
        totalLembur: 6,
        dailyDetails: <_DailyAttendanceDetail>[],
      ),
      _MonthlyRecap(
        employeeName: 'Dinda Maharani',
        month: now.month,
        year: now.year,
        totalHadir: 19,
        totalOff: 1,
        totalTidakHadir: 2,
        totalCuti: 1,
        totalExtraOff: 0,
        totalSakit: 1,
        totalAlfa: 0,
        totalLembur: 3,
        dailyDetails: <_DailyAttendanceDetail>[],
      ),
      _MonthlyRecap(
        employeeName: 'Reno Pratama',
        month: now.month,
        year: now.year,
        totalHadir: 18,
        totalOff: 0,
        totalTidakHadir: 3,
        totalCuti: 0,
        totalExtraOff: 1,
        totalSakit: 1,
        totalAlfa: 1,
        totalLembur: 4,
        dailyDetails: <_DailyAttendanceDetail>[],
      ),
      _MonthlyRecap(
        employeeName: 'Ari Saputra',
        month: now.month == 1 ? 12 : now.month - 1,
        year: now.month == 1 ? now.year - 1 : now.year,
        totalHadir: 21,
        totalOff: 1,
        totalTidakHadir: 0,
        totalCuti: 0,
        totalExtraOff: 1,
        totalSakit: 0,
        totalAlfa: 0,
        totalLembur: 8,
        dailyDetails: <_DailyAttendanceDetail>[],
      ),
      _MonthlyRecap(
        employeeName: 'Dinda Maharani',
        month: now.month == 1 ? 12 : now.month - 1,
        year: now.month == 1 ? now.year - 1 : now.year,
        totalHadir: 20,
        totalOff: 0,
        totalTidakHadir: 1,
        totalCuti: 1,
        totalExtraOff: 0,
        totalSakit: 0,
        totalAlfa: 0,
        totalLembur: 2,
        dailyDetails: <_DailyAttendanceDetail>[],
      ),
    ];

    _approvalRequests = <_ApprovalRequest>[
      _ApprovalRequest(
        id: 'REQ-001',
        employeeName: 'Dinda Maharani',
        type: ApprovalType.cuti,
        reason: 'Acara keluarga',
        date: now.subtract(const Duration(days: 1)),
        attachment: null,
      ),
      _ApprovalRequest(
        id: 'REQ-002',
        employeeName: 'Ari Saputra',
        type: ApprovalType.izin,
        reason: 'Kontrol kesehatan',
        date: now,
        attachment: 'surat_dokter.pdf',
      ),
      _ApprovalRequest(
        id: 'REQ-003',
        employeeName: 'Reno Pratama',
        type: ApprovalType.extraOff,
        reason: 'Kebutuhan keluarga',
        date: now.subtract(const Duration(days: 2)),
        attachment: 'surat_pengantar.jpg',
      ),
      _ApprovalRequest(
        id: 'REQ-004',
        employeeName: 'Ari Saputra',
        type: ApprovalType.sakit,
        reason: 'Demam tinggi',
        date: now,
        attachment: 'surat_dokter.pdf',
      ),
      _ApprovalRequest(
        id: 'REQ-005',
        employeeName: 'Dinda Maharani',
        type: ApprovalType.lembur,
        reason: 'Closing laporan bulanan',
        date: now,
        attachment: null,
      ),
    ];

    _employees = <_EmployeeData>[
      _EmployeeData(
        id: 'EMP-001',
        fullName: 'Ari Saputra',
        nik: '327600000001',
        placeOfBirth: 'Bandung',
        birthDate: DateTime(1996, 2, 11),
        gender: 'Laki-laki',
        address: 'Jl. Ciumbuleuit No. 10, Bandung',
        phoneNumber: '0812-1111-2222',
        email: 'ari@kingroyal.com',
        jobTitle: 'Staff Housekeeping',
        role: AdminRole.staff,
        department: 'Housekeeping',
        employeeStatus: 'Tetap',
        joinDate: DateTime(2023, 10, 15),
        bankAccountNumber: '201001223344',
        gajiPokok: 4200000,
      ),
      _EmployeeData(
        id: 'EMP-002',
        fullName: 'Dinda Maharani',
        nik: '327600000002',
        placeOfBirth: 'Bandung',
        birthDate: DateTime(1994, 6, 12),
        gender: 'Perempuan',
        address: 'Jl. Setiabudi No. 18, Bandung',
        phoneNumber: '0812-3456-7890',
        email: 'dinda@kingroyal.com',
        jobTitle: 'Supervisor HR',
        role: AdminRole.admin,
        department: 'Human Capital',
        employeeStatus: 'Tetap',
        joinDate: DateTime(2024, 1, 12),
        bankAccountNumber: '201001334455',
        gajiPokok: 6500000,
      ),
      _EmployeeData(
        id: 'EMP-003',
        fullName: 'Reno Pratama',
        nik: '327600000003',
        placeOfBirth: 'Jakarta',
        birthDate: DateTime(1998, 9, 3),
        gender: 'Laki-laki',
        address: 'Jl. Cempaka Putih No. 22, Jakarta',
        phoneNumber: '0812-0000-1111',
        email: 'reno@kingroyal.com',
        jobTitle: 'Staff Operasional',
        role: AdminRole.staff,
        department: 'Front Office',
        employeeStatus: 'Kontrak',
        joinDate: DateTime(2025, 3, 1),
        bankAccountNumber: '201001556677',
        gajiPokok: 4300000,
      ),
    ];

    for (final recap in _recapData) {
      if (recap.dailyDetails.isEmpty) {
        recap.dailyDetails.addAll(_buildDailyDetailsFromRecap(recap));
      }
      _syncRecapTotalsFromDailyDetails(recap);
    }
  }

  List<_MonthlyRecap> get _currentRecapData {
    final byPeriod = _recapData
        .where((e) => e.month == _selectedMonth && e.year == _selectedYear)
        .toList();
    if (_nameFilter.trim().isEmpty) return byPeriod;
    final q = _nameFilter.toLowerCase();
    return byPeriod
        .where((e) => e.employeeName.toLowerCase().contains(q))
        .toList();
  }

  int get _totalPending {
    return _approvalRequests
        .where((e) => e.status == ApprovalStatus.pending)
        .length;
  }

  int get _totalKaryawan => _employees.length;

  int get _jumlahHadirHariIni {
    return (_employees.length * 0.82).round();
  }

  int get _jumlahOffHariIni {
    return (_employees.length * 0.16).round();
  }

  int _remainingLeaveForEmployee(String employeeName, {int? year}) {
    final activeYear = year ?? _selectedYear;
    final used = _recapData
        .where(
          (item) =>
              item.employeeName == employeeName && item.year == activeYear,
        )
        .fold<int>(0, (sum, item) => sum + item.totalCuti);
    return (_annualLeaveQuota - used).clamp(0, _annualLeaveQuota);
  }

  void _addLog(
    String action,
    String target, {
    String module = 'Umum',
    String? detail,
    String? before,
    String? after,
  }) {
    setState(() {
      _activityLogs.insert(
        0,
        _ActivityLog(
          time: DateTime.now(),
          actor: widget.currentUserName,
          module: module,
          action: action,
          target: target,
          detail: detail,
          before: before,
          after: after,
        ),
      );
    });
  }

  void _exportData(String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Export $format berhasil dibuat (mock).')),
    );
    _addLog(
      'Export $format',
      'Rekap absensi $_selectedMonth/$_selectedYear',
      module: 'Rekap Absensi',
      detail:
          'Admin mengekspor data rekap periode $_selectedMonth/$_selectedYear',
    );
  }

  void _updateApproval(_ApprovalRequest request, ApprovalStatus status) {
    final previousStatus = request.status;
    setState(() => request.status = status);
    final action = status == ApprovalStatus.approved ? 'Approve' : 'Reject';
    _addLog(
      '$action pengajuan',
      '${request.employeeName} - ${_labelApprovalType(request.type)}',
      module: 'Approval',
      before: _labelApprovalStatus(previousStatus),
      after: _labelApprovalStatus(status),
      detail:
          'Tanggal ${DateFormat('dd/MM/yyyy').format(request.date)} | Alasan ${request.reason ?? "-"}',
    );
  }

  _MonthlyRecap? _findRecapByEmployee(String employeeName) {
    for (final recap in _currentRecapData) {
      if (recap.employeeName == employeeName) return recap;
    }
    return null;
  }

  int _safeParseInt(String value, int fallback) {
    final parsed = int.tryParse(value.trim());
    return parsed ?? fallback;
  }

  List<_DailyAttendanceDetail> _buildDailyDetailsFromRecap(
    _MonthlyRecap recap,
  ) {
    final totalRecordedDays =
        recap.totalHadir +
        recap.totalOff +
        recap.totalTidakHadir +
        recap.totalCuti +
        recap.totalExtraOff +
        recap.totalSakit +
        recap.totalAlfa;
    final workingDays = totalRecordedDays <= 0 ? 1 : totalRecordedDays;
    final counts = <_DailyAttendanceStatus, int>{
      _DailyAttendanceStatus.hadir: recap.totalHadir,
      _DailyAttendanceStatus.off: recap.totalOff,
      _DailyAttendanceStatus.cuti: recap.totalCuti,
      _DailyAttendanceStatus.extraOff: recap.totalExtraOff,
      _DailyAttendanceStatus.sakit: recap.totalSakit,
      _DailyAttendanceStatus.alfa: recap.totalAlfa,
      _DailyAttendanceStatus.tidakHadir: recap.totalTidakHadir,
    };
    var remainingLembur = recap.totalLembur;
    final lastDateOfMonth = DateTime(recap.year, recap.month + 1, 0);
    final details = <_DailyAttendanceDetail>[];

    _DailyAttendanceStatus takeStatus() {
      for (final entry in counts.entries) {
        if (entry.value > 0) {
          counts[entry.key] = entry.value - 1;
          return entry.key;
        }
      }
      return _DailyAttendanceStatus.off;
    }

    for (var i = 0; i < workingDays; i++) {
      final status = takeStatus();
      final date = lastDateOfMonth.subtract(Duration(days: i));
      final isHadir = status == _DailyAttendanceStatus.hadir;
      final lemburHours = isHadir && remainingLembur > 0 ? 1 : 0;
      if (lemburHours > 0) {
        remainingLembur -= 1;
      }
      final checkIn = isHadir ? TimeOfDay(hour: 8, minute: (i * 3) % 60) : null;
      final checkOut = isHadir
          ? TimeOfDay(hour: 17 + lemburHours, minute: (i * 7) % 60)
          : null;

      details.add(
        _DailyAttendanceDetail(
          date: date,
          status: status,
          checkIn: checkIn,
          checkOut: checkOut,
          lemburHours: lemburHours,
          note: _dailyStatusLabel(status),
          checkInPhotoPath: isHadir ? 'assets/icons/app_icon.jpg' : null,
          checkOutPhotoPath: isHadir ? 'assets/icons/app_icon.jpg' : null,
        ),
      );
    }
    return details;
  }

  void _syncRecapTotalsFromDailyDetails(_MonthlyRecap recap) {
    var hadir = 0;
    var off = 0;
    var tidakHadir = 0;
    var cuti = 0;
    var extraOff = 0;
    var sakit = 0;
    var alfa = 0;
    var lembur = 0;

    for (final day in recap.dailyDetails) {
      switch (day.status) {
        case _DailyAttendanceStatus.hadir:
          hadir += 1;
          lembur += day.lemburHours;
        case _DailyAttendanceStatus.off:
          off += 1;
        case _DailyAttendanceStatus.extraOff:
          extraOff += 1;
        case _DailyAttendanceStatus.cuti:
          cuti += 1;
        case _DailyAttendanceStatus.sakit:
          sakit += 1;
        case _DailyAttendanceStatus.alfa:
          alfa += 1;
        case _DailyAttendanceStatus.tidakHadir:
          tidakHadir += 1;
      }
    }

    recap.totalHadir = hadir;
    recap.totalOff = off;
    recap.totalTidakHadir = tidakHadir;
    recap.totalCuti = cuti;
    recap.totalExtraOff = extraOff;
    recap.totalSakit = sakit;
    recap.totalAlfa = alfa;
    recap.totalLembur = lembur;
  }

  String _dailyStatusLabel(_DailyAttendanceStatus status) {
    switch (status) {
      case _DailyAttendanceStatus.hadir:
        return 'Hadir';
      case _DailyAttendanceStatus.off:
        return 'Off';
      case _DailyAttendanceStatus.extraOff:
        return 'Extra Off';
      case _DailyAttendanceStatus.cuti:
        return 'Cuti';
      case _DailyAttendanceStatus.sakit:
        return 'Sakit';
      case _DailyAttendanceStatus.alfa:
        return 'Alfa';
      case _DailyAttendanceStatus.tidakHadir:
        return 'Tidak Hadir';
    }
  }

  Color _dailyStatusColor(_DailyAttendanceStatus status) {
    switch (status) {
      case _DailyAttendanceStatus.hadir:
        return const Color(0xFF1B5E20);
      case _DailyAttendanceStatus.off:
        return const Color(0xFF455A64);
      case _DailyAttendanceStatus.extraOff:
        return const Color(0xFF1565C0);
      case _DailyAttendanceStatus.cuti:
        return const Color(0xFF6A1B9A);
      case _DailyAttendanceStatus.sakit:
        return const Color(0xFFE65100);
      case _DailyAttendanceStatus.alfa:
        return const Color(0xFFC62828);
      case _DailyAttendanceStatus.tidakHadir:
        return const Color(0xFFB71C1C);
    }
  }

  String _timeText(TimeOfDay? value) {
    if (value == null) return '-';
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute WIB';
  }

  TimeOfDay? _parseTimeOfDay(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final parts = trimmed.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Widget _attendancePhotoPreview(String title, String? path) {
    Widget content;
    if (path == null || path.trim().isEmpty) {
      content = const Center(
        child: Text('Tidak ada foto', style: TextStyle(fontSize: 12)),
      );
    } else if (path.startsWith('assets/')) {
      content = Image.asset(path, fit: BoxFit.cover);
    } else if (File(path).existsSync()) {
      content = Image.file(File(path), fit: BoxFit.cover);
    } else {
      content = const Center(
        child: Text(
          'Foto tidak ditemukan',
          style: TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 120,
              width: double.infinity,
              color: const Color(0xFFECEFF5),
              child: content,
            ),
          ),
        ],
      ),
    );
  }

  String _formatRecap(_MonthlyRecap recap) {
    return 'Hadir ${recap.totalHadir}, Off ${recap.totalOff}, Tidak Hadir ${recap.totalTidakHadir}, Cuti ${recap.totalCuti}, Extra Off ${recap.totalExtraOff}, Sakit ${recap.totalSakit}, Alfa ${recap.totalAlfa}, Lembur ${recap.totalLembur} jam';
  }

  String _formatDailyDetail(_DailyAttendanceDetail detail) {
    return 'Status ${_dailyStatusLabel(detail.status)}, Masuk ${_timeText(detail.checkIn)}, Pulang ${_timeText(detail.checkOut)}, Lembur ${detail.lemburHours} jam, Catatan ${detail.note.trim().isEmpty ? "-" : detail.note}';
  }

  String _formatSlip(_SalarySlip slip) {
    return 'Gaji Pokok ${slip.gajiPokok}, Tunjangan Jabatan ${slip.tunjanganJabatan}, Lembur ${slip.lembur}, Tunjangan Lain ${slip.tunjanganLain}, Potongan Absen ${slip.potonganAbsen}, Total ${slip.totalGaji}';
  }

  String _formatEmployee(_EmployeeData employee) {
    return 'kode karyawan ${employee.nik}, Jabatan ${employee.jobTitle}, Role ${_labelRole(employee.role)}, Departemen ${employee.department}, Status ${employee.employeeStatus}, Aktif ${employee.isActive ? "Ya" : "Tidak"}';
  }

  _SalarySlip _createSalarySlip(_EmployeeData employee, _MonthlyRecap? recap) {
    final gajiPokok = employee.gajiPokok;
    final totalLembur = recap?.totalLembur ?? 0;
    final totalAbsenBermasalah =
        (recap?.totalAlfa ?? 0) + (recap?.totalTidakHadir ?? 0);
    final tunjanganJabatan = employee.role == AdminRole.admin
        ? 1200000
        : 500000;

    return _SalarySlip(
      id: 'SLIP-${DateTime.now().millisecondsSinceEpoch}-${employee.id}',
      employeeId: employee.id,
      employeeName: employee.fullName,
      month: _selectedMonth,
      year: _selectedYear,
      gajiPokok: gajiPokok,
      tunjanganJabatan: tunjanganJabatan,
      lembur: totalLembur * 25000,
      tunjanganLain: 300000,
      potonganPinjaman: 0,
      potonganAbsen: totalAbsenBermasalah * 75000,
      potonganBpjsKesehatan: 120000,
      potonganBpjsTkJht: 95000,
      potonganBpjsTkJp: 65000,
      potonganPph21: 125000,
      notes: 'Slip gaji dihitung dan dikirim dalam format PDF.',
      generatedAt: DateTime.now(),
    );
  }

  void _generateSlipForEmployee(_EmployeeData employee) {
    final recap = _findRecapByEmployee(employee.fullName);
    final newSlip = _createSalarySlip(employee, recap);

    setState(() {
      _salarySlips.removeWhere(
        (item) =>
            item.employeeId == employee.id &&
            item.month == _selectedMonth &&
            item.year == _selectedYear,
      );
      _salarySlips.insert(0, newSlip);
    });

    _addLog(
      'Generate slip gaji',
      '${employee.fullName} ($_selectedMonth/$_selectedYear)',
      module: 'Payroll',
      detail: _formatSlip(newSlip),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Slip gaji ${employee.fullName} berhasil digenerate.'),
      ),
    );
  }

  void _generateAllSlips() {
    final activeEmployees = _employees
        .where((employee) => employee.isActive)
        .toList();
    if (activeEmployees.isEmpty) return;

    setState(() {
      for (final employee in activeEmployees) {
        final recap = _findRecapByEmployee(employee.fullName);
        final newSlip = _createSalarySlip(employee, recap);
        _salarySlips.removeWhere(
          (item) =>
              item.employeeId == employee.id &&
              item.month == _selectedMonth &&
              item.year == _selectedYear,
        );
        _salarySlips.add(newSlip);
      }
      _salarySlips.sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
    });

    _addLog(
      'Generate massal slip gaji',
      'Periode $_selectedMonth/$_selectedYear',
      module: 'Payroll',
      detail: 'Jumlah slip dibuat: ${activeEmployees.length}',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Berhasil generate ${activeEmployees.length} slip gaji.'),
      ),
    );
  }

  Future<void> _editSlip(_SalarySlip slip) async {
    final gajiPokokController = TextEditingController(
      text: '${slip.gajiPokok}',
    );
    final tunjanganJabatanController = TextEditingController(
      text: '${slip.tunjanganJabatan}',
    );
    final lemburController = TextEditingController(text: '${slip.lembur}');
    final tunjanganLainController = TextEditingController(
      text: '${slip.tunjanganLain}',
    );
    final potonganPinjamanController = TextEditingController(
      text: '${slip.potonganPinjaman}',
    );
    final potonganAbsenController = TextEditingController(
      text: '${slip.potonganAbsen}',
    );
    final bpjsKesehatanController = TextEditingController(
      text: '${slip.potonganBpjsKesehatan}',
    );
    final bpjsTkJhtController = TextEditingController(
      text: '${slip.potonganBpjsTkJht}',
    );
    final bpjsTkJpController = TextEditingController(
      text: '${slip.potonganBpjsTkJp}',
    );
    final pph21Controller = TextEditingController(
      text: '${slip.potonganPph21}',
    );
    final notesController = TextEditingController(text: slip.notes);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Edit Slip ${slip.employeeName}'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: gajiPokokController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Gaji Pokok'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: tunjanganJabatanController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Tunjangan Jabatan',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: lemburController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Lembur'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: tunjanganLainController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Tunjangan Lain',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: potonganPinjamanController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Potongan Pinjaman',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: potonganAbsenController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Potongan Absen',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: bpjsKesehatanController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Potongan BPJS Kesehatan',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: bpjsTkJhtController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Potongan BPJS TK JHT',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: bpjsTkJpController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Potongan BPJS TK JP',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: pph21Controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Potongan Pajak PPh21',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesController,
                    minLines: 2,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Catatan'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                final beforeSummary = _formatSlip(slip);
                setState(() {
                  slip.gajiPokok = _safeParseInt(
                    gajiPokokController.text,
                    slip.gajiPokok,
                  );
                  slip.tunjanganJabatan = _safeParseInt(
                    tunjanganJabatanController.text,
                    slip.tunjanganJabatan,
                  );
                  slip.lembur = _safeParseInt(
                    lemburController.text,
                    slip.lembur,
                  );
                  slip.tunjanganLain = _safeParseInt(
                    tunjanganLainController.text,
                    slip.tunjanganLain,
                  );
                  slip.potonganPinjaman = _safeParseInt(
                    potonganPinjamanController.text,
                    slip.potonganPinjaman,
                  );
                  slip.potonganAbsen = _safeParseInt(
                    potonganAbsenController.text,
                    slip.potonganAbsen,
                  );
                  slip.potonganBpjsKesehatan = _safeParseInt(
                    bpjsKesehatanController.text,
                    slip.potonganBpjsKesehatan,
                  );
                  slip.potonganBpjsTkJht = _safeParseInt(
                    bpjsTkJhtController.text,
                    slip.potonganBpjsTkJht,
                  );
                  slip.potonganBpjsTkJp = _safeParseInt(
                    bpjsTkJpController.text,
                    slip.potonganBpjsTkJp,
                  );
                  slip.potonganPph21 = _safeParseInt(
                    pph21Controller.text,
                    slip.potonganPph21,
                  );
                  slip.notes = notesController.text.trim();
                });
                final afterSummary = _formatSlip(slip);
                _addLog(
                  'Edit slip gaji',
                  '${slip.employeeName} (${slip.month}/${slip.year})',
                  module: 'Payroll',
                  before: beforeSummary,
                  after: afterSummary,
                  detail: 'Catatan: ${slip.notes.isEmpty ? "-" : slip.notes}',
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _sendSlip(_SalarySlip slip) {
    final sentAt = DateTime.now();
    setState(() => slip.sentAt = sentAt);
    widget.onSlipSent?.call(
      SentPayrollSlip(
        employeeId: slip.employeeId,
        employeeName: slip.employeeName,
        month: slip.month,
        year: slip.year,
        sentAt: sentAt,
        totalGaji: slip.totalGaji,
      ),
    );
    _addLog(
      'Kirim slip gaji PDF',
      '${slip.employeeName} (${slip.month}/${slip.year})',
      module: 'Payroll',
      detail:
          'Total gaji ${slip.totalGaji} | Waktu kirim ${DateFormat('dd/MM/yyyy HH:mm').format(sentAt)}',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Slip gaji PDF ${slip.employeeName} berhasil dikirim.'),
      ),
    );
  }

  Future<void> _showAddEmployeeDialog() async {
    await _showEmployeeDialog();
  }

  Future<void> _showEditEmployeeDialog(_EmployeeData employee) async {
    await _showEmployeeDialog(employee: employee);
  }

  Future<void> _showEmployeeDialog({_EmployeeData? employee}) async {
    final isEdit = employee != null;
    final fullNameController = TextEditingController(
      text: employee?.fullName ?? '',
    );
    final nikController = TextEditingController(text: employee?.nik ?? '');
    final placeOfBirthController = TextEditingController(
      text: employee?.placeOfBirth ?? '',
    );
    final addressController = TextEditingController(
      text: employee?.address ?? '',
    );
    final phoneController = TextEditingController(
      text: employee?.phoneNumber ?? '',
    );
    final emailController = TextEditingController(text: employee?.email ?? '');
    final jobTitleController = TextEditingController(
      text: employee?.jobTitle ?? '',
    );
    final departmentController = TextEditingController(
      text: employee?.department ?? '',
    );
    final bankAccountController = TextEditingController(
      text: employee?.bankAccountNumber ?? '',
    );
    final gajiPokokController = TextEditingController(
      text: '${employee?.gajiPokok ?? 0}',
    );
    var role = employee?.role ?? AdminRole.staff;
    var gender = employee?.gender ?? 'Laki-laki';
    var employeeStatus = employee?.employeeStatus ?? 'Tetap';
    var birthDate = employee?.birthDate ?? DateTime(2000, 1, 1);
    var joinDate = employee?.joinDate ?? DateTime.now();
    String? profilePhotoPath = employee?.profilePhotoPath;
    final picker = ImagePicker();

    Future<void> pickDate({
      required DateTime initialDate,
      required ValueChanged<DateTime> onPicked,
    }) async {
      final picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(1970),
        lastDate: DateTime.now().add(const Duration(days: 3650)),
      );
      if (picked == null) return;
      onPicked(picked);
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit Karyawan' : 'Tambah Karyawan'),
          content: StatefulBuilder(
            builder: (context, setInnerState) {
              final hasPhoto =
                  profilePhotoPath != null &&
                  File(profilePhotoPath!).existsSync();
              return SizedBox(
                width: 560,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundImage: hasPhoto
                            ? FileImage(File(profilePhotoPath!))
                            : const AssetImage('assets/icons/app_icon.jpg')
                                  as ImageProvider<Object>,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await picker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 80,
                                maxWidth: 1200,
                              );
                              if (picked == null) return;
                              setInnerState(
                                () => profilePhotoPath = picked.path,
                              );
                            },
                            icon: const Icon(Icons.image_rounded),
                            label: const Text('Pilih Foto'),
                          ),
                          if (hasPhoto)
                            OutlinedButton.icon(
                              onPressed: () {
                                setInnerState(() => profilePhotoPath = null);
                              },
                              icon: const Icon(Icons.delete_outline_rounded),
                              label: const Text('Hapus'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: fullNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Lengkap',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nikController,
                        decoration: const InputDecoration(
                          labelText: 'kode karyawan',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: placeOfBirthController,
                              decoration: const InputDecoration(
                                labelText: 'Tempat Lahir',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                await pickDate(
                                  initialDate: birthDate,
                                  onPicked: (value) {
                                    setInnerState(() => birthDate = value);
                                  },
                                );
                              },
                              child: Text(
                                'Tgl Lahir: ${DateFormat('dd/MM/yyyy').format(birthDate)}',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: gender,
                        decoration: const InputDecoration(
                          labelText: 'Jenis Kelamin',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Laki-laki',
                            child: Text('Laki-laki'),
                          ),
                          DropdownMenuItem(
                            value: 'Perempuan',
                            child: Text('Perempuan'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setInnerState(() => gender = value);
                        },
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: addressController,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'Alamat'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: phoneController,
                        decoration: const InputDecoration(labelText: 'No HP'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: jobTitleController,
                        decoration: const InputDecoration(labelText: 'Jabatan'),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<AdminRole>(
                        value: role,
                        decoration: const InputDecoration(labelText: 'Role'),
                        items: const [
                          DropdownMenuItem(
                            value: AdminRole.admin,
                            child: Text('Admin'),
                          ),
                          DropdownMenuItem(
                            value: AdminRole.staff,
                            child: Text('Staff'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setInnerState(() => role = value);
                        },
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: departmentController,
                        decoration: const InputDecoration(
                          labelText: 'Departemen',
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: employeeStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status Karyawan',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Tetap',
                            child: Text('Tetap'),
                          ),
                          DropdownMenuItem(
                            value: 'Kontrak',
                            child: Text('Kontrak'),
                          ),
                          DropdownMenuItem(
                            value: 'Magang',
                            child: Text('Magang'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setInnerState(() => employeeStatus = value);
                        },
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () async {
                          await pickDate(
                            initialDate: joinDate,
                            onPicked: (value) {
                              setInnerState(() => joinDate = value);
                            },
                          );
                        },
                        child: Text(
                          'Tanggal Masuk: ${DateFormat('dd/MM/yyyy').format(joinDate)}',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: bankAccountController,
                        decoration: const InputDecoration(
                          labelText: 'No Rekening',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: gajiPokokController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Gaji Pokok',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                final previousEmployeeSnapshot = employee == null
                    ? null
                    : _formatEmployee(employee);
                final fullName = fullNameController.text.trim();
                final nik = nikController.text.trim();
                final placeOfBirth = placeOfBirthController.text.trim();
                final address = addressController.text.trim();
                final phone = phoneController.text.trim();
                final email = emailController.text.trim();
                final jobTitle = jobTitleController.text.trim();
                final department = departmentController.text.trim();
                final bankAccount = bankAccountController.text.trim();
                final gajiPokok = _safeParseInt(gajiPokokController.text, 0);

                if (fullName.isEmpty ||
                    nik.isEmpty ||
                    placeOfBirth.isEmpty ||
                    address.isEmpty ||
                    phone.isEmpty ||
                    email.isEmpty ||
                    jobTitle.isEmpty ||
                    department.isEmpty ||
                    bankAccount.isEmpty) {
                  return;
                }

                setState(() {
                  if (isEdit) {
                    employee.fullName = fullName;
                    employee.nik = nik;
                    employee.placeOfBirth = placeOfBirth;
                    employee.birthDate = birthDate;
                    employee.gender = gender;
                    employee.address = address;
                    employee.phoneNumber = phone;
                    employee.email = email;
                    employee.jobTitle = jobTitle;
                    employee.role = role;
                    employee.department = department;
                    employee.employeeStatus = employeeStatus;
                    employee.joinDate = joinDate;
                    employee.bankAccountNumber = bankAccount;
                    employee.gajiPokok = gajiPokok;
                    employee.profilePhotoPath = profilePhotoPath;
                  } else {
                    _employees.insert(
                      0,
                      _EmployeeData(
                        id: 'EMP-${DateTime.now().millisecondsSinceEpoch}',
                        fullName: fullName,
                        nik: nik,
                        placeOfBirth: placeOfBirth,
                        birthDate: birthDate,
                        gender: gender,
                        address: address,
                        phoneNumber: phone,
                        email: email,
                        jobTitle: jobTitle,
                        role: role,
                        department: department,
                        employeeStatus: employeeStatus,
                        joinDate: joinDate,
                        bankAccountNumber: bankAccount,
                        gajiPokok: gajiPokok,
                        profilePhotoPath: profilePhotoPath,
                      ),
                    );
                  }
                });
                _addLog(
                  isEdit ? 'Edit data karyawan' : 'Tambah karyawan',
                  fullName,
                  module: 'Manajemen Karyawan',
                  before: previousEmployeeSnapshot,
                  after: isEdit
                      ? _formatEmployee(employee)
                      : 'kode karyawan $nik, Jabatan $jobTitle, Role ${_labelRole(role)}, Departemen $department, Status $employeeStatus, Aktif Ya',
                  detail:
                      'Kontak $phone | Email $email | Gaji Pokok $gajiPokok',
                );
                Navigator.pop(dialogContext);
              },
              child: Text(isEdit ? 'Update' : 'Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showDailyDetail(_MonthlyRecap recap) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final items = recap.dailyDetails
          ..sort((a, b) => b.date.compareTo(a.date));
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.85,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detail Rekap Absensi - ${recap.employeeName}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Menampilkan foto, jam, status, dan catatan. Edit bisa dilakukan per hari.',
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        DateFormat(
                                          'EEEE, dd MMMM yyyy',
                                          'id_ID',
                                        ).format(item.date),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _dailyStatusColor(item.status),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        _dailyStatusLabel(item.status),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('Jam Masuk: ${_timeText(item.checkIn)}'),
                                Text('Jam Pulang: ${_timeText(item.checkOut)}'),
                                Text('Lembur: ${item.lemburHours} jam'),
                                Text(
                                  'Catatan: ${item.note.trim().isEmpty ? '-' : item.note}',
                                ),
                                if (item.isManuallyEdited)
                                  const Text(
                                    'Data ini sudah diedit manual oleh admin.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    _attendancePhotoPreview(
                                      'Foto Masuk',
                                      item.checkInPhotoPath,
                                    ),
                                    const SizedBox(width: 10),
                                    _attendancePhotoPreview(
                                      'Foto Pulang',
                                      item.checkOutPhotoPath,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        _editDailyAttendance(recap, item),
                                    icon: const Icon(Icons.edit_rounded),
                                    label: const Text('Edit Data Harian'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _editDailyAttendance(
    _MonthlyRecap recap,
    _DailyAttendanceDetail detail,
  ) async {
    var selectedStatus = detail.status;
    final checkInController = TextEditingController(
      text: detail.checkIn == null
          ? ''
          : '${detail.checkIn!.hour.toString().padLeft(2, '0')}:${detail.checkIn!.minute.toString().padLeft(2, '0')}',
    );
    final checkOutController = TextEditingController(
      text: detail.checkOut == null
          ? ''
          : '${detail.checkOut!.hour.toString().padLeft(2, '0')}:${detail.checkOut!.minute.toString().padLeft(2, '0')}',
    );
    final lemburController = TextEditingController(
      text: '${detail.lemburHours}',
    );
    final noteController = TextEditingController(text: detail.note);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: Text(
                'Edit Detail ${DateFormat('dd MMM yyyy', 'id_ID').format(detail.date)}',
              ),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<_DailyAttendanceStatus>(
                        value: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status Kehadiran',
                        ),
                        items: _DailyAttendanceStatus.values
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(_dailyStatusLabel(status)),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setLocalState(() => selectedStatus = value);
                        },
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: checkInController,
                        decoration: const InputDecoration(
                          labelText: 'Jam Masuk (HH:mm)',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: checkOutController,
                        decoration: const InputDecoration(
                          labelText: 'Jam Pulang (HH:mm)',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: lemburController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Lembur (jam)',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: noteController,
                        minLines: 2,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Catatan'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: () {
                    final beforeSummary = _formatDailyDetail(detail);
                    setState(() {
                      detail.status = selectedStatus;
                      detail.checkIn = _parseTimeOfDay(checkInController.text);
                      detail.checkOut = _parseTimeOfDay(
                        checkOutController.text,
                      );
                      detail.lemburHours = _safeParseInt(
                        lemburController.text,
                        detail.lemburHours,
                      ).clamp(0, 24);
                      detail.note = noteController.text.trim();
                      detail.isManuallyEdited = true;

                      if (selectedStatus == _DailyAttendanceStatus.hadir) {
                        detail.checkIn ??= const TimeOfDay(hour: 8, minute: 0);
                        detail.checkOut ??= const TimeOfDay(
                          hour: 17,
                          minute: 0,
                        );
                        detail.checkInPhotoPath ??= 'assets/icons/app_icon.jpg';
                        detail.checkOutPhotoPath ??=
                            'assets/icons/app_icon.jpg';
                      } else {
                        detail.checkIn = null;
                        detail.checkOut = null;
                        detail.lemburHours = 0;
                        detail.checkInPhotoPath = null;
                        detail.checkOutPhotoPath = null;
                      }

                      _syncRecapTotalsFromDailyDetails(recap);
                    });
                    _addLog(
                      'Edit detail rekap absensi',
                      '${recap.employeeName} - ${DateFormat('dd/MM/yyyy').format(detail.date)}',
                      module: 'Rekap Absensi',
                      before: beforeSummary,
                      after: _formatDailyDetail(detail),
                      detail: 'Data diedit manual oleh admin',
                    );
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _editRecap(_MonthlyRecap recap) async {
    final hadirController = TextEditingController(text: '${recap.totalHadir}');
    final offController = TextEditingController(text: '${recap.totalOff}');
    final cutiController = TextEditingController(text: '${recap.totalCuti}');
    final extraOffController = TextEditingController(
      text: '${recap.totalExtraOff}',
    );
    final sakitController = TextEditingController(text: '${recap.totalSakit}');
    final lemburController = TextEditingController(
      text: '${recap.totalLembur}',
    );
    final tidakHadirController = TextEditingController(
      text: '${recap.totalTidakHadir}',
    );
    final alfaController = TextEditingController(text: '${recap.totalAlfa}');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Edit Rekap - ${recap.employeeName}'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _numberField(hadirController, 'Total Hadir'),
                  _numberField(offController, 'Total Off'),
                  _numberField(cutiController, 'Total Cuti'),
                  _numberField(extraOffController, 'Total Extra Off'),
                  _numberField(sakitController, 'Total Sakit'),
                  _numberField(lemburController, 'Total Lembur (jam)'),
                  _numberField(tidakHadirController, 'Total Tidak Hadir'),
                  _numberField(alfaController, 'Total Alfa'),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                final beforeSummary = _formatRecap(recap);
                setState(() {
                  recap.totalHadir = _safeParseInt(
                    hadirController.text,
                    recap.totalHadir,
                  );
                  recap.totalOff = _safeParseInt(
                    offController.text,
                    recap.totalOff,
                  );
                  recap.totalCuti = _safeParseInt(
                    cutiController.text,
                    recap.totalCuti,
                  );
                  recap.totalExtraOff = _safeParseInt(
                    extraOffController.text,
                    recap.totalExtraOff,
                  );
                  recap.totalSakit = _safeParseInt(
                    sakitController.text,
                    recap.totalSakit,
                  );
                  recap.totalLembur = _safeParseInt(
                    lemburController.text,
                    recap.totalLembur,
                  );
                  recap.totalTidakHadir = _safeParseInt(
                    tidakHadirController.text,
                    recap.totalTidakHadir,
                  );
                  recap.totalAlfa = _safeParseInt(
                    alfaController.text,
                    recap.totalAlfa,
                  );
                });
                _addLog(
                  'Edit rekap absensi',
                  '${recap.employeeName} (${recap.month}/${recap.year})',
                  module: 'Rekap Absensi',
                  before: beforeSummary,
                  after: _formatRecap(recap),
                  detail: 'Edit ringkasan bulanan oleh admin',
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Widget _numberField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  String _labelRole(AdminRole role) =>
      role == AdminRole.admin ? 'Admin' : 'Staff';

  String _labelApprovalType(ApprovalType type) {
    switch (type) {
      case ApprovalType.izin:
        return 'Izin';
      case ApprovalType.cuti:
        return 'Cuti';
      case ApprovalType.extraOff:
        return 'Extra Off';
      case ApprovalType.sakit:
        return 'Sakit';
      case ApprovalType.lembur:
        return 'Lembur';
    }
  }

  String _labelApprovalStatus(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.pending:
        return 'Pending';
      case ApprovalStatus.approved:
        return 'Approve';
      case ApprovalStatus.rejected:
        return 'Reject';
    }
  }

  Color _statusColor(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.pending:
        return const Color(0xFFF9A825);
      case ApprovalStatus.approved:
        return const Color(0xFF2E7D32);
      case ApprovalStatus.rejected:
        return const Color(0xFFC62828);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final monthOptions = List<int>.generate(12, (i) => i + 1);
    final yearOptions = List<int>.generate(
      5,
      (i) => DateTime.now().year - 2 + i,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        _OverviewCard(
          totalKaryawan: _totalKaryawan,
          hadirHariIni: _jumlahHadirHariIni,
          totalPending: _totalPending,
          totalOffHariIni: _jumlahOffHariIni,
        ),
        const SizedBox(height: 12),
        _RecapCard(
          selectedMonth: _selectedMonth,
          selectedYear: _selectedYear,
          monthOptions: monthOptions,
          yearOptions: yearOptions,
          onMonthChanged: (value) => setState(() => _selectedMonth = value),
          onYearChanged: (value) => setState(() => _selectedYear = value),
          onNameFilterChanged: (value) => setState(() => _nameFilter = value),
          currentRecapData: _currentRecapData,
          onExportExcel: () => _exportData('Excel'),
          onExportPdf: () => _exportData('PDF'),
          onShowDetail: _showDailyDetail,
          onEditRecap: _editRecap,
          annualLeaveQuota: _annualLeaveQuota,
          remainingLeaveByEmployee: {
            for (final employee in _employees)
              employee.fullName: _remainingLeaveForEmployee(employee.fullName),
          },
          emptyTextColor: cs.onSurfaceVariant,
        ),
        const SizedBox(height: 12),
        _ApprovalCard(
          requests: _approvalRequests,
          onUpdateApproval: _updateApproval,
          labelApprovalType: _labelApprovalType,
          labelApprovalStatus: _labelApprovalStatus,
          statusColor: _statusColor,
          approvalHistory: _activityLogs
              .where(
                (log) =>
                    log.action.contains('Approve') ||
                    log.action.contains('Reject'),
              )
              .take(8)
              .toList(),
          annualLeaveQuota: _annualLeaveQuota,
          remainingLeaveLookup: _remainingLeaveForEmployee,
          emptyTextColor: cs.onSurfaceVariant,
        ),
        const SizedBox(height: 12),
        _PayrollCard(
          employees: _employees.where((employee) => employee.isActive).toList(),
          salarySlips: _salarySlips
              .where(
                (slip) =>
                    slip.month == _selectedMonth && slip.year == _selectedYear,
              )
              .toList(),
          selectedMonth: _selectedMonth,
          selectedYear: _selectedYear,
          onGenerateAll: _generateAllSlips,
          onGenerateEmployee: _generateSlipForEmployee,
          onEditSlip: _editSlip,
          onSendSlip: _sendSlip,
        ),
        const SizedBox(height: 12),
        _EmployeeManagementCard(
          employees: _employees,
          onAdd: _showAddEmployeeDialog,
          onEdit: _showEditEmployeeDialog,
          onChangeRole: (employee, role) {
            final beforeRole = _labelRole(employee.role);
            setState(() => employee.role = role);
            _addLog(
              'Ubah role',
              employee.fullName,
              module: 'Manajemen Karyawan',
              before: beforeRole,
              after: _labelRole(role),
              detail: 'Perubahan hak akses pengguna',
            );
          },
          onToggleActive: (employee, value) {
            final beforeStatus = employee.isActive ? 'Aktif' : 'Nonaktif';
            setState(() => employee.isActive = value);
            _addLog(
              value ? 'Aktifkan karyawan' : 'Nonaktifkan karyawan',
              employee.fullName,
              module: 'Manajemen Karyawan',
              before: beforeStatus,
              after: value ? 'Aktif' : 'Nonaktif',
              detail: 'Perubahan status akun pengguna',
            );
          },
          onResetPassword: (employee) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Password ${employee.fullName} direset (mock).'),
              ),
            );
            _addLog(
              'Reset password',
              employee.fullName,
              module: 'Keamanan Akun',
              detail: 'Admin mereset password akun karyawan',
            );
          },
          onDelete: (employee) {
            final beforeEmployee = _formatEmployee(employee);
            setState(() => _employees.remove(employee));
            _addLog(
              'Hapus data karyawan',
              employee.fullName,
              module: 'Manajemen Karyawan',
              before: beforeEmployee,
              detail: 'Data karyawan dihapus dari daftar',
            );
          },
        ),
        const SizedBox(height: 12),
        _LogCard(logs: _activityLogs, emptyTextColor: cs.onSurfaceVariant),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final int totalKaryawan;
  final int hadirHariIni;
  final int totalPending;
  final int totalOffHariIni;

  const _OverviewCard({
    required this.totalKaryawan,
    required this.hadirHariIni,
    required this.totalPending,
    required this.totalOffHariIni,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard Ringkas',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MetricChip(label: 'Total Karyawan', value: '$totalKaryawan'),
                _MetricChip(label: 'Hadir Hari Ini', value: '$hadirHariIni'),
                _MetricChip(
                  label: 'Pending Izin/Cuti/Extra Off/Sakit/Lembur',
                  value: '$totalPending',
                ),
                _MetricChip(
                  label: 'Total Off Hari Ini',
                  value: '$totalOffHariIni',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecapCard extends StatelessWidget {
  final int selectedMonth;
  final int selectedYear;
  final List<int> monthOptions;
  final List<int> yearOptions;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<int> onYearChanged;
  final ValueChanged<String> onNameFilterChanged;
  final List<_MonthlyRecap> currentRecapData;
  final VoidCallback onExportExcel;
  final VoidCallback onExportPdf;
  final ValueChanged<_MonthlyRecap> onShowDetail;
  final ValueChanged<_MonthlyRecap> onEditRecap;
  final int annualLeaveQuota;
  final Map<String, int> remainingLeaveByEmployee;
  final Color emptyTextColor;

  const _RecapCard({
    required this.selectedMonth,
    required this.selectedYear,
    required this.monthOptions,
    required this.yearOptions,
    required this.onMonthChanged,
    required this.onYearChanged,
    required this.onNameFilterChanged,
    required this.currentRecapData,
    required this.onExportExcel,
    required this.onExportPdf,
    required this.onShowDetail,
    required this.onEditRecap,
    required this.annualLeaveQuota,
    required this.remainingLeaveByEmployee,
    required this.emptyTextColor,
  });

  String _statusLabel(_DailyAttendanceStatus status) {
    switch (status) {
      case _DailyAttendanceStatus.hadir:
        return 'Hadir';
      case _DailyAttendanceStatus.off:
        return 'Off';
      case _DailyAttendanceStatus.extraOff:
        return 'Extra Off';
      case _DailyAttendanceStatus.cuti:
        return 'Cuti';
      case _DailyAttendanceStatus.sakit:
        return 'Sakit';
      case _DailyAttendanceStatus.alfa:
        return 'Alfa';
      case _DailyAttendanceStatus.tidakHadir:
        return 'Tidak Hadir';
    }
  }

  String _timeLabel(TimeOfDay? value) {
    if (value == null) return '-';
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _miniPhoto(String? path) {
    Widget content;
    if (path == null || path.trim().isEmpty) {
      content = const Center(
        child: Text('Tanpa foto', style: TextStyle(fontSize: 11)),
      );
    } else if (path.startsWith('assets/')) {
      content = Image.asset(path, fit: BoxFit.cover);
    } else if (File(path).existsSync()) {
      content = Image.file(File(path), fit: BoxFit.cover);
    } else {
      content = const Center(
        child: Text('Foto hilang', style: TextStyle(fontSize: 11)),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 56,
        width: 76,
        color: const Color(0xFFECEFF5),
        child: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rekap Absensi (All Karyawan)',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: selectedMonth,
                    decoration: const InputDecoration(
                      labelText: 'Bulan',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: monthOptions
                        .map(
                          (month) => DropdownMenuItem(
                            value: month,
                            child: Text(
                              DateFormat(
                                'MMMM',
                                'id_ID',
                              ).format(DateTime(2026, month)),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      onMonthChanged(value);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: selectedYear,
                    decoration: const InputDecoration(
                      labelText: 'Tahun',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: yearOptions
                        .map(
                          (year) => DropdownMenuItem(
                            value: year,
                            child: Text('$year'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      onYearChanged(value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              onChanged: onNameFilterChanged,
              decoration: const InputDecoration(
                labelText: 'Filter Nama Karyawan',
                prefixIcon: Icon(Icons.search_rounded),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: onExportExcel,
                  icon: const Icon(Icons.table_view_rounded),
                  label: const Text('Export Excel'),
                ),
                OutlinedButton.icon(
                  onPressed: onExportPdf,
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                  label: const Text('Export PDF'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Rekap Per Karyawan',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...currentRecapData.map(
              (item) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.employeeName,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Hadir ${item.totalHadir} | Off ${item.totalOff} | Tidak Hadir ${item.totalTidakHadir} | Cuti ${item.totalCuti} | Extra Off ${item.totalExtraOff} | Sakit ${item.totalSakit} | Alfa ${item.totalAlfa} | Lembur ${item.totalLembur} jam',
                      ),
                      Text(
                        'Sisa Cuti ${remainingLeaveByEmployee[item.employeeName] ?? annualLeaveQuota}/$annualLeaveQuota | Detail harian ${item.dailyDetails.length} hari',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (item.dailyDetails.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Builder(
                          builder: (_) {
                            final latest = item.dailyDetails
                              ..sort((a, b) => b.date.compareTo(a.date));
                            final day = latest.first;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Absensi terbaru: ${DateFormat('dd MMM yyyy', 'id_ID').format(day.date)} | ${_statusLabel(day.status)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Jam masuk ${_timeLabel(day.checkIn)} | Jam pulang ${_timeLabel(day.checkOut)}',
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    _miniPhoto(day.checkInPhotoPath),
                                    const SizedBox(width: 8),
                                    _miniPhoto(day.checkOutPhotoPath),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => onShowDetail(item),
                            icon: const Icon(Icons.visibility_rounded),
                            label: const Text('Detail Lengkap'),
                          ),
                          FilledButton.tonalIcon(
                            onPressed: () => onEditRecap(item),
                            icon: const Icon(Icons.edit_rounded),
                            label: const Text('Edit Rekap'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (currentRecapData.isEmpty)
              Text(
                'Data tidak ditemukan.',
                style: TextStyle(color: emptyTextColor),
              ),
          ],
        ),
      ),
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  final List<_ApprovalRequest> requests;
  final void Function(_ApprovalRequest, ApprovalStatus) onUpdateApproval;
  final String Function(ApprovalType) labelApprovalType;
  final String Function(ApprovalStatus) labelApprovalStatus;
  final Color Function(ApprovalStatus) statusColor;
  final List<_ActivityLog> approvalHistory;
  final int annualLeaveQuota;
  final int Function(String employeeName) remainingLeaveLookup;
  final Color emptyTextColor;

  const _ApprovalCard({
    required this.requests,
    required this.onUpdateApproval,
    required this.labelApprovalType,
    required this.labelApprovalStatus,
    required this.statusColor,
    required this.approvalHistory,
    required this.annualLeaveQuota,
    required this.remainingLeaveLookup,
    required this.emptyTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Approval Izin/Cuti/Extra Off/Sakit/Lembur',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            ...requests.map(
              (item) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item.employeeName} - ${labelApprovalType(item.type)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor(item.status),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              labelApprovalStatus(item.status),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tanggal: ${DateFormat('dd MMM yyyy', 'id_ID').format(item.date)}',
                      ),
                      Text(
                        'Alasan: ${(item.reason == null || item.reason!.trim().isEmpty) ? '-' : item.reason}',
                      ),
                      Text('Lampiran: ${item.attachment ?? '-'}'),
                      if (item.type == ApprovalType.cuti)
                        Text(
                          'Sisa Cuti: ${remainingLeaveLookup(item.employeeName)}/$annualLeaveQuota',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      if (item.status == ApprovalStatus.pending) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.tonal(
                                onPressed: () => onUpdateApproval(
                                  item,
                                  ApprovalStatus.approved,
                                ),
                                child: const Text('Approve'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton.tonal(
                                onPressed: () => onUpdateApproval(
                                  item,
                                  ApprovalStatus.rejected,
                                ),
                                child: const Text('Reject'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Riwayat Approval',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            if (approvalHistory.isEmpty)
              Text(
                'Belum ada riwayat approval.',
                style: TextStyle(color: emptyTextColor),
              )
            else
              ...approvalHistory.map(
                (log) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${DateFormat('dd/MM HH:mm').format(log.time)} - ${log.actor} ${log.action} (${log.target})',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PayrollCard extends StatelessWidget {
  final List<_EmployeeData> employees;
  final List<_SalarySlip> salarySlips;
  final int selectedMonth;
  final int selectedYear;
  final VoidCallback onGenerateAll;
  final ValueChanged<_EmployeeData> onGenerateEmployee;
  final ValueChanged<_SalarySlip> onEditSlip;
  final ValueChanged<_SalarySlip> onSendSlip;

  const _PayrollCard({
    required this.employees,
    required this.salarySlips,
    required this.selectedMonth,
    required this.selectedYear,
    required this.onGenerateAll,
    required this.onGenerateEmployee,
    required this.onEditSlip,
    required this.onSendSlip,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Card(
      elevation: 1.2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payroll & Slip Gaji',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Periode $selectedMonth/$selectedYear - komponen gaji dan potongan, kirim dalam format PDF.',
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: onGenerateAll,
              icon: const Icon(Icons.calculate_rounded),
              label: const Text('Generate Semua Slip'),
            ),
            const SizedBox(height: 10),
            const Text(
              'Generate Per Staff',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...employees.map(
              (employee) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(child: Text(employee.fullName)),
                    OutlinedButton.icon(
                      onPressed: () => onGenerateEmployee(employee),
                      icon: const Icon(Icons.receipt_long_rounded),
                      label: const Text('Generate'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Slip Terbentuk',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (salarySlips.isEmpty)
              const Text('Belum ada slip untuk periode ini.')
            else
              ...salarySlips.map(
                (slip) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                slip.employeeName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text('Total: ${currency.format(slip.totalGaji)}'),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('Gaji Pokok: ${currency.format(slip.gajiPokok)}'),
                        Text(
                          'Tunjangan Jabatan: ${currency.format(slip.tunjanganJabatan)}',
                        ),
                        Text('Lembur: ${currency.format(slip.lembur)}'),
                        Text(
                          'Tunjangan Lain: ${currency.format(slip.tunjanganLain)}',
                        ),
                        Text(
                          'Potongan Pinjaman: ${currency.format(slip.potonganPinjaman)}',
                        ),
                        Text(
                          'Potongan Absen: ${currency.format(slip.potonganAbsen)}',
                        ),
                        Text(
                          'Potongan BPJS Kesehatan: ${currency.format(slip.potonganBpjsKesehatan)}',
                        ),
                        Text(
                          'Potongan BPJS TK JHT: ${currency.format(slip.potonganBpjsTkJht)}',
                        ),
                        Text(
                          'Potongan BPJS TK JP: ${currency.format(slip.potonganBpjsTkJp)}',
                        ),
                        Text(
                          'Potongan Pajak PPh21: ${currency.format(slip.potonganPph21)}',
                        ),
                        Text(
                          'Catatan: ${slip.notes.isEmpty ? '-' : slip.notes}',
                        ),
                        Text(
                          slip.sentAt == null
                              ? 'Status: Belum dikirim'
                              : 'Status: Terkirim ${DateFormat('dd/MM/yyyy HH:mm').format(slip.sentAt!)}',
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.tonal(
                                onPressed: () => onEditSlip(slip),
                                child: const Text('Edit'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton(
                                onPressed: () => onSendSlip(slip),
                                child: Text(
                                  slip.sentAt == null
                                      ? 'Kirim PDF'
                                      : 'Kirim Ulang PDF',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmployeeManagementCard extends StatelessWidget {
  final List<_EmployeeData> employees;
  final VoidCallback onAdd;
  final ValueChanged<_EmployeeData> onEdit;
  final void Function(_EmployeeData, AdminRole) onChangeRole;
  final void Function(_EmployeeData, bool) onToggleActive;
  final ValueChanged<_EmployeeData> onResetPassword;
  final ValueChanged<_EmployeeData> onDelete;

  const _EmployeeManagementCard({
    required this.employees,
    required this.onAdd,
    required this.onEdit,
    required this.onChangeRole,
    required this.onToggleActive,
    required this.onResetPassword,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Manajemen Data Karyawan',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: const Text('Tambah'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...employees.map(
              (employee) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundImage:
                                employee.profilePhotoPath != null &&
                                    File(
                                      employee.profilePhotoPath!,
                                    ).existsSync()
                                ? FileImage(File(employee.profilePhotoPath!))
                                : const AssetImage('assets/icons/app_icon.jpg')
                                      as ImageProvider<Object>,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  employee.fullName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'kode karyawan: ${employee.nik}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  '${employee.jobTitle} | ${employee.department}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  'Status: ${employee.employeeStatus}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  'Gaji Pokok: Rp ${NumberFormat.decimalPattern('id_ID').format(employee.gajiPokok)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                onEdit(employee);
                              } else if (value == 'reset') {
                                onResetPassword(employee);
                              } else if (value == 'hapus') {
                                onDelete(employee);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit Karyawan'),
                              ),
                              PopupMenuItem(
                                value: 'reset',
                                child: Text('Reset Password'),
                              ),
                              PopupMenuItem(
                                value: 'hapus',
                                child: Text('Hapus Data'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<AdminRole>(
                              value: employee.role,
                              decoration: const InputDecoration(
                                labelText: 'Role',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: AdminRole.admin,
                                  child: Text('Admin'),
                                ),
                                DropdownMenuItem(
                                  value: AdminRole.staff,
                                  child: Text('Staff'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == null) return;
                                onChangeRole(employee, value);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SwitchListTile(
                              value: employee.isActive,
                              onChanged: (value) =>
                                  onToggleActive(employee, value),
                              title: const Text('Aktif'),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogCard extends StatelessWidget {
  final List<_ActivityLog> logs;
  final Color emptyTextColor;

  const _LogCard({required this.logs, required this.emptyTextColor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 1.2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Log Aktivitas Sistem',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (logs.isEmpty)
              Text(
                'Belum ada aktivitas.',
                style: TextStyle(color: emptyTextColor),
              )
            else
              ...logs
                  .take(20)
                  .map(
                    (log) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: const Color(0xFFF8FAFF),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat(
                                'dd/MM/yyyy HH:mm:ss',
                              ).format(log.time),
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${log.actor} | ${log.module}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${log.action} (${log.target})',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (log.detail != null &&
                                log.detail!.trim().isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text('Detail: ${log.detail!}'),
                            ],
                            if (log.before != null &&
                                log.before!.trim().isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Before: ${log.before!}',
                                style: TextStyle(color: cs.onSurfaceVariant),
                              ),
                            ],
                            if (log.after != null &&
                                log.after!.trim().isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                'After: ${log.after!}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;

  const _MetricChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 130),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F0FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
