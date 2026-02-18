import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum AdminRole { admin, staff }

enum ApprovalType { izin, cuti, lembur }

enum ApprovalStatus { pending, approved, rejected }

class _MonthlyRecap {
  final String employeeName;
  final int month;
  final int year;
  final int totalHadir;
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
  final String reason;
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

class _EmployeeData {
  final String id;
  String name;
  String nik;
  AdminRole role;
  bool isActive = true;

  _EmployeeData({
    required this.id,
    required this.name,
    required this.nik,
    required this.role,
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
    ];

    _employees = <_EmployeeData>[
      _EmployeeData(
        id: 'EMP-001',
        name: 'Ari Saputra',
        nik: '327600000001',
        role: AdminRole.staff,
      ),
      _EmployeeData(
        id: 'EMP-002',
        name: 'Dinda Maharani',
        nik: '327600000002',
        role: AdminRole.admin,
      ),
      _EmployeeData(
        id: 'EMP-003',
        name: 'Reno Pratama',
        nik: '327600000003',
        role: AdminRole.staff,
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

  Future<void> _showAddEmployeeDialog() async {
    final nameController = TextEditingController();
    final nikController = TextEditingController();
    AdminRole role = AdminRole.staff;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Karyawan'),
          content: StatefulBuilder(
            builder: (context, setInnerState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nama'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nikController,
                    decoration: const InputDecoration(labelText: 'NIK'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<AdminRole>(
                    value: role,
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
                    decoration: const InputDecoration(labelText: 'Role'),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty ||
                    nikController.text.trim().isEmpty) {
                  return;
                }
                setState(() {
                  _employees.insert(
                    0,
                    _EmployeeData(
                      id: 'EMP-${DateTime.now().millisecondsSinceEpoch}',
                      name: nameController.text.trim(),
                      nik: nikController.text.trim(),
                      role: role,
                    ),
                  );
                });
                _addLog('Tambah karyawan', nameController.text.trim());
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditEmployeeDialog(_EmployeeData employee) async {
    final nameController = TextEditingController(text: employee.name);
    final nikController = TextEditingController(text: employee.nik);
    AdminRole role = employee.role;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Karyawan'),
          content: StatefulBuilder(
            builder: (context, setInnerState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nama'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nikController,
                    decoration: const InputDecoration(labelText: 'NIK'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<AdminRole>(
                    value: role,
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
                    decoration: const InputDecoration(labelText: 'Role'),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty ||
                    nikController.text.trim().isEmpty) {
                  return;
                }
                setState(() {
                  employee.name = nameController.text.trim();
                  employee.nik = nikController.text.trim();
                  employee.role = role;
                });
                _addLog('Edit data karyawan', employee.name);
                Navigator.pop(context);
              },
              child: const Text('Update'),
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
        _EmployeeManagementCard(
          employees: _employees,
          onAdd: _showAddEmployeeDialog,
          onEdit: _showEditEmployeeDialog,
          onChangeRole: (employee, role) {
            setState(() => employee.role = role);
            _addLog('Ubah role', '${employee.name} -> ${_labelRole(role)}');
          },
          onToggleActive: (employee, value) {
            setState(() => employee.isActive = value);
            _addLog(
              value ? 'Aktifkan karyawan' : 'Nonaktifkan karyawan',
              employee.name,
            );
          },
          onResetPassword: (employee) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Password ${employee.name} direset (mock).'),
              ),
            );
            _addLog('Reset password', employee.name);
          },
          onDelete: (employee) {
            setState(() => _employees.remove(employee));
            _addLog('Hapus data karyawan', employee.name);
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
                  label: 'Pending Izin/Sakit/Lembur',
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
                    'Hadir ${item.totalHadir} | Tidak Hadir ${item.totalTidakHadir} | Cuti ${item.totalCuti} | Extra Off ${item.totalExtraOff} | Sakit ${item.totalSakit} | Alfa ${item.totalAlfa} | Lembur ${item.totalLembur} jam',
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
              'Approval Izin/Cuti/Lembur',
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
                      Text('Alasan: ${item.reason}'),
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
                        children: [
                          Expanded(
                            child: Text(
                              '${employee.name} (${employee.nik})',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
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
