import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

enum AdminRole { admin, staff }

enum ApprovalType { izin, cuti, off, lembur }

enum ApprovalStatus { pending, approved, rejected }

class _MonthlyRecap {
  final String employeeName;
  final int month;
  final int year;
  final int totalHadir;
  final int totalOff;
  final int totalTidakHadir;
  final int totalCuti;
  final int totalExtraOff;
  final int totalSakit;
  final int totalAlfa;
  final int totalLembur;

  const _MonthlyRecap({
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
  int tunjanganHadir;
  int upahLembur;
  int insentifOff;
  int insentifExtraOff;
  int potonganAlfa;
  int potonganTidakHadir;
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
    required this.tunjanganHadir,
    required this.upahLembur,
    required this.insentifOff,
    required this.insentifExtraOff,
    required this.potonganAlfa,
    required this.potonganTidakHadir,
    required this.notes,
    required this.generatedAt,
  });

  int get totalGaji =>
      gajiPokok +
      tunjanganHadir +
      upahLembur +
      insentifOff +
      insentifExtraOff -
      potonganAlfa -
      potonganTidakHadir;
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
    this.profilePhotoPath,
  });
}

class _ActivityLog {
  final DateTime time;
  final String actor;
  final String action;
  final String target;

  const _ActivityLog({
    required this.time,
    required this.actor,
    required this.action,
    required this.target,
  });
}

class AdminDashboardSection extends StatefulWidget {
  final String currentUserName;

  const AdminDashboardSection({super.key, required this.currentUserName});

  @override
  State<AdminDashboardSection> createState() => _AdminDashboardSectionState();
}

class _AdminDashboardSectionState extends State<AdminDashboardSection> {
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
        type: ApprovalType.lembur,
        reason: 'Persiapan event ballroom',
        date: now.subtract(const Duration(days: 2)),
        attachment: 'foto_kegiatan.jpg',
      ),
      _ApprovalRequest(
        id: 'REQ-004',
        employeeName: 'Ari Saputra',
        type: ApprovalType.off,
        reason: null,
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
      ),
    ];
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

  int _sum(int Function(_MonthlyRecap item) selector) {
    return _currentRecapData.fold<int>(0, (p, e) => p + selector(e));
  }

  double get _attendanceRate {
    final hadir = _sum((e) => e.totalHadir);
    final totalHari =
        hadir +
        _sum((e) => e.totalOff) +
        _sum((e) => e.totalTidakHadir) +
        _sum((e) => e.totalCuti) +
        _sum((e) => e.totalExtraOff) +
        _sum((e) => e.totalSakit) +
        _sum((e) => e.totalAlfa);
    if (totalHari == 0) return 0;
    return (hadir / totalHari) * 100;
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

  int get _jumlahTidakHadirHariIni {
    return (_employees.length - _jumlahHadirHariIni).clamp(
      0,
      _employees.length,
    );
  }

  void _addLog(String action, String target) {
    setState(() {
      _activityLogs.insert(
        0,
        _ActivityLog(
          time: DateTime.now(),
          actor: widget.currentUserName,
          action: action,
          target: target,
        ),
      );
    });
  }

  void _exportData(String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Export $format berhasil dibuat (mock).')),
    );
    _addLog('Export $format', 'Rekap absensi $_selectedMonth/$_selectedYear');
  }

  void _updateApproval(_ApprovalRequest request, ApprovalStatus status) {
    setState(() => request.status = status);
    final action = status == ApprovalStatus.approved ? 'Approve' : 'Reject';
    _addLog(
      '$action pengajuan',
      '${request.employeeName} - ${_labelApprovalType(request.type)}',
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

  _SalarySlip _createSalarySlip(_EmployeeData employee, _MonthlyRecap? recap) {
    final gajiPokok = employee.role == AdminRole.admin ? 6500000 : 4200000;
    final totalHadir = recap?.totalHadir ?? 0;
    final totalLembur = recap?.totalLembur ?? 0;
    final totalOff = recap?.totalOff ?? 0;
    final totalExtraOff = recap?.totalExtraOff ?? 0;
    final totalAlfa = recap?.totalAlfa ?? 0;
    final totalTidakHadir = recap?.totalTidakHadir ?? 0;

    return _SalarySlip(
      id: 'SLIP-${DateTime.now().millisecondsSinceEpoch}-${employee.id}',
      employeeId: employee.id,
      employeeName: employee.fullName,
      month: _selectedMonth,
      year: _selectedYear,
      gajiPokok: gajiPokok,
      tunjanganHadir: totalHadir * 35000,
      upahLembur: totalLembur * 25000,
      insentifOff: totalOff * 15000,
      insentifExtraOff: totalExtraOff * 25000,
      potonganAlfa: totalAlfa * 100000,
      potonganTidakHadir: totalTidakHadir * 50000,
      notes: 'Dihitung otomatis dari rekap absensi periode berjalan.',
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
    final tunjanganHadirController = TextEditingController(
      text: '${slip.tunjanganHadir}',
    );
    final upahLemburController = TextEditingController(
      text: '${slip.upahLembur}',
    );
    final insentifOffController = TextEditingController(
      text: '${slip.insentifOff}',
    );
    final insentifExtraOffController = TextEditingController(
      text: '${slip.insentifExtraOff}',
    );
    final potonganAlfaController = TextEditingController(
      text: '${slip.potonganAlfa}',
    );
    final potonganTidakHadirController = TextEditingController(
      text: '${slip.potonganTidakHadir}',
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
                    controller: tunjanganHadirController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Tunjangan Hadir',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: upahLemburController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Upah Lembur'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: insentifOffController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Insentif Off',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: insentifExtraOffController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Insentif Extra Off',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: potonganAlfaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Potongan Alfa',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: potonganTidakHadirController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Potongan Tidak Hadir',
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
                setState(() {
                  slip.gajiPokok = _safeParseInt(
                    gajiPokokController.text,
                    slip.gajiPokok,
                  );
                  slip.tunjanganHadir = _safeParseInt(
                    tunjanganHadirController.text,
                    slip.tunjanganHadir,
                  );
                  slip.upahLembur = _safeParseInt(
                    upahLemburController.text,
                    slip.upahLembur,
                  );
                  slip.insentifOff = _safeParseInt(
                    insentifOffController.text,
                    slip.insentifOff,
                  );
                  slip.insentifExtraOff = _safeParseInt(
                    insentifExtraOffController.text,
                    slip.insentifExtraOff,
                  );
                  slip.potonganAlfa = _safeParseInt(
                    potonganAlfaController.text,
                    slip.potonganAlfa,
                  );
                  slip.potonganTidakHadir = _safeParseInt(
                    potonganTidakHadirController.text,
                    slip.potonganTidakHadir,
                  );
                  slip.notes = notesController.text.trim();
                });
                _addLog(
                  'Edit slip gaji',
                  '${slip.employeeName} (${slip.month}/${slip.year})',
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
    setState(() => slip.sentAt = DateTime.now());
    _addLog(
      'Kirim slip gaji',
      '${slip.employeeName} (${slip.month}/${slip.year})',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Slip gaji ${slip.employeeName} berhasil dikirim.'),
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
                        decoration: const InputDecoration(labelText: 'NIK'),
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
                final fullName = fullNameController.text.trim();
                final nik = nikController.text.trim();
                final placeOfBirth = placeOfBirthController.text.trim();
                final address = addressController.text.trim();
                final phone = phoneController.text.trim();
                final email = emailController.text.trim();
                final jobTitle = jobTitleController.text.trim();
                final department = departmentController.text.trim();
                final bankAccount = bankAccountController.text.trim();

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
                        profilePhotoPath: profilePhotoPath,
                      ),
                    );
                  }
                });
                _addLog(
                  isEdit ? 'Edit data karyawan' : 'Tambah karyawan',
                  fullName,
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
    final days = List.generate(
      5,
      (index) => 'Hari ${index + 1}: ${index == 2 ? 'Lembur 2 jam' : 'Hadir'}',
    );

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detail Harian - ${recap.employeeName}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              ...days.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(e),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
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
      case ApprovalType.off:
        return 'Off';
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
          tidakHadirHariIni: _jumlahTidakHadirHariIni,
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
          totalHadir: _sum((e) => e.totalHadir),
          totalOff: _sum((e) => e.totalOff),
          totalTidakHadir: _sum((e) => e.totalTidakHadir),
          totalCuti: _sum((e) => e.totalCuti),
          totalExtraOff: _sum((e) => e.totalExtraOff),
          totalSakit: _sum((e) => e.totalSakit),
          totalAlfa: _sum((e) => e.totalAlfa),
          totalLembur: _sum((e) => e.totalLembur),
          attendanceRate: _attendanceRate,
          onExportExcel: () => _exportData('Excel'),
          onExportPdf: () => _exportData('PDF'),
          onShowDetail: _showDailyDetail,
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
            setState(() => employee.role = role);
            _addLog('Ubah role', '${employee.fullName} -> ${_labelRole(role)}');
          },
          onToggleActive: (employee, value) {
            setState(() => employee.isActive = value);
            _addLog(
              value ? 'Aktifkan karyawan' : 'Nonaktifkan karyawan',
              employee.fullName,
            );
          },
          onResetPassword: (employee) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Password ${employee.fullName} direset (mock).'),
              ),
            );
            _addLog('Reset password', employee.fullName);
          },
          onDelete: (employee) {
            setState(() => _employees.remove(employee));
            _addLog('Hapus data karyawan', employee.fullName);
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
  final int tidakHadirHariIni;

  const _OverviewCard({
    required this.totalKaryawan,
    required this.hadirHariIni,
    required this.totalPending,
    required this.tidakHadirHariIni,
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
                  label: 'Pending Izin/Cuti/Off/Lembur',
                  value: '$totalPending',
                ),
                _MetricChip(
                  label: 'Tidak Hadir Hari Ini',
                  value: '$tidakHadirHariIni',
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
  final int totalHadir;
  final int totalOff;
  final int totalTidakHadir;
  final int totalCuti;
  final int totalExtraOff;
  final int totalSakit;
  final int totalAlfa;
  final int totalLembur;
  final double attendanceRate;
  final VoidCallback onExportExcel;
  final VoidCallback onExportPdf;
  final ValueChanged<_MonthlyRecap> onShowDetail;
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
    required this.totalHadir,
    required this.totalOff,
    required this.totalTidakHadir,
    required this.totalCuti,
    required this.totalExtraOff,
    required this.totalSakit,
    required this.totalAlfa,
    required this.totalLembur,
    required this.attendanceRate,
    required this.onExportExcel,
    required this.onExportPdf,
    required this.onShowDetail,
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
              runSpacing: 8,
              children: [
                _MetricChip(label: 'Total Hadir', value: '$totalHadir'),
                _MetricChip(label: 'Total Off', value: '$totalOff'),
                _MetricChip(
                  label: 'Total Tidak Hadir',
                  value: '$totalTidakHadir',
                ),
                _MetricChip(label: 'Total Cuti', value: '$totalCuti'),
                _MetricChip(label: 'Total Extra Off', value: '$totalExtraOff'),
                _MetricChip(label: 'Total Sakit', value: '$totalSakit'),
                _MetricChip(label: 'Total Alfa', value: '$totalAlfa'),
                _MetricChip(label: 'Total Lembur', value: '$totalLembur jam'),
                _MetricChip(
                  label: 'Persentase Kehadiran',
                  value: '${attendanceRate.toStringAsFixed(1)}%',
                ),
              ],
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
                child: ListTile(
                  title: Text(
                    item.employeeName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Hadir ${item.totalHadir} | Off ${item.totalOff} | Tidak Hadir ${item.totalTidakHadir} | Cuti ${item.totalCuti} | Extra Off ${item.totalExtraOff} | Sakit ${item.totalSakit} | Alfa ${item.totalAlfa} | Lembur ${item.totalLembur} jam',
                  ),
                  trailing: TextButton(
                    onPressed: () => onShowDetail(item),
                    child: const Text('Detail Harian'),
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
  final Color emptyTextColor;

  const _ApprovalCard({
    required this.requests,
    required this.onUpdateApproval,
    required this.labelApprovalType,
    required this.labelApprovalStatus,
    required this.statusColor,
    required this.approvalHistory,
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
              'Approval Izin/Cuti/Off/Lembur',
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
              'Periode $selectedMonth/$selectedYear - generate dari total hadir, lembur, off, extra off, dan potongan.',
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
                          'Tunjangan Hadir: ${currency.format(slip.tunjanganHadir)}',
                        ),
                        Text(
                          'Upah Lembur: ${currency.format(slip.upahLembur)}',
                        ),
                        Text(
                          'Insentif Off: ${currency.format(slip.insentifOff)}',
                        ),
                        Text(
                          'Insentif Extra Off: ${currency.format(slip.insentifExtraOff)}',
                        ),
                        Text(
                          'Potongan Alfa: ${currency.format(slip.potonganAlfa)}',
                        ),
                        Text(
                          'Potongan Tidak Hadir: ${currency.format(slip.potonganTidakHadir)}',
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
                                  slip.sentAt == null ? 'Kirim' : 'Kirim Ulang',
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
                                  'NIK: ${employee.nik}',
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
                    (log) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '${DateFormat('dd/MM/yyyy HH:mm').format(log.time)} - ${log.actor} ${log.action} (${log.target})',
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
