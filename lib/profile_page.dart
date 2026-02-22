import 'dart:io';

import 'package:absensi_king_royal/payroll_models.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

enum LeaveHistoryStatus { approved, pending, rejected }

extension LeaveHistoryStatusX on LeaveHistoryStatus {
  String get label {
    switch (this) {
      case LeaveHistoryStatus.approved:
        return 'Approve';
      case LeaveHistoryStatus.pending:
        return 'Pending';
      case LeaveHistoryStatus.rejected:
        return 'Tolak';
    }
  }
}

class LeaveHistoryItem {
  final String title;
  final String date;
  final LeaveHistoryStatus status;

  const LeaveHistoryItem({
    required this.title,
    required this.date,
    required this.status,
  });
}

class EmployeeProfilePage extends StatefulWidget {
  final String fullName;
  final String nik;
  final String placeOfBirth;
  final DateTime birthDate;
  final String gender;
  final String address;
  final String phoneNumber;
  final String email;
  final String jobTitle;
  final String role;
  final String department;
  final String employeeStatus;
  final DateTime joinDate;
  final String bankAccountNumber;
  final String? profilePhotoPath;
  final ValueChanged<String?> onProfilePhotoChanged;
  final int totalHadir;
  final int totalOff;
  final int totalCuti;
  final int totalExtraOff;
  final int totalSakit;
  final int totalLembur;
  final int annualLeaveQuota;
  final int remainingLeave;
  final List<LeaveHistoryItem> leaveHistory;
  final List<SentPayrollSlip> salarySlips;
  final VoidCallback onResetPassword;
  final VoidCallback onLogout;

  const EmployeeProfilePage({
    super.key,
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
    required this.profilePhotoPath,
    required this.onProfilePhotoChanged,
    required this.totalHadir,
    required this.totalOff,
    required this.totalCuti,
    required this.totalExtraOff,
    required this.totalSakit,
    required this.totalLembur,
    required this.annualLeaveQuota,
    required this.remainingLeave,
    required this.leaveHistory,
    required this.salarySlips,
    required this.onResetPassword,
    required this.onLogout,
  });

  @override
  State<EmployeeProfilePage> createState() => _EmployeeProfilePageState();
}

class _EmployeeProfilePageState extends State<EmployeeProfilePage> {
  String? _profilePhotoPath;
  bool _isPickingPhoto = false;

  @override
  void initState() {
    super.initState();
    _profilePhotoPath = widget.profilePhotoPath;
  }

  Future<void> _pickProfilePhoto() async {
    setState(() => _isPickingPhoto = true);
    final picker = ImagePicker();
    final result = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (!mounted) return;
    setState(() => _isPickingPhoto = false);
    if (result == null) return;
    setState(() => _profilePhotoPath = result.path);
    widget.onProfilePhotoChanged(result.path);
  }

  void _removeProfilePhoto() {
    setState(() => _profilePhotoPath = null);
    widget.onProfilePhotoChanged(null);
  }

  void _openSlipHistoryPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _SlipHistoryPage(
          employeeName: widget.fullName,
          slips: widget.salarySlips,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasCustomPhoto =
        _profilePhotoPath != null && File(_profilePhotoPath!).existsSync();
    final ImageProvider<Object> profileImage = hasCustomPhoto
        ? FileImage(File(_profilePhotoPath!))
        : const AssetImage('assets/icons/app_icon.jpg');

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Karyawan')),
      body: Stack(
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
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircleAvatar(radius: 44, backgroundImage: profileImage),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: [
                          FilledButton.icon(
                            onPressed: _isPickingPhoto
                                ? null
                                : _pickProfilePhoto,
                            icon: const Icon(Icons.image_rounded),
                            label: Text(
                              _isPickingPhoto
                                  ? 'Memproses...'
                                  : 'Ganti Foto Profil',
                            ),
                          ),
                          if (hasCustomPhoto)
                            OutlinedButton.icon(
                              onPressed: _removeProfilePhoto,
                              icon: const Icon(Icons.delete_outline_rounded),
                              label: const Text('Hapus Foto'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      _InfoText(label: 'Nama Lengkap', value: widget.fullName),
                      _InfoText(label: 'kode karyawan', value: widget.nik),
                      _InfoText(
                        label: 'Tempat, Tanggal Lahir',
                        value:
                            '${widget.placeOfBirth}, ${DateFormat('dd MMMM yyyy', 'id_ID').format(widget.birthDate)}',
                      ),
                      _InfoText(label: 'Jenis Kelamin', value: widget.gender),
                      _InfoText(label: 'Alamat', value: widget.address),
                      _InfoText(label: 'Nomor HP', value: widget.phoneNumber),
                      _InfoText(label: 'Email', value: widget.email),
                      _InfoText(label: 'Jabatan', value: widget.jobTitle),
                      _InfoText(label: 'Role', value: widget.role),
                      _InfoText(label: 'Departemen', value: widget.department),
                      _InfoText(
                        label: 'Status Karyawan',
                        value: widget.employeeStatus,
                      ),
                      _InfoText(
                        label: 'Tanggal Masuk',
                        value: DateFormat(
                          'dd MMMM yyyy',
                          'id_ID',
                        ).format(widget.joinDate),
                      ),
                      _InfoText(
                        label: 'No Rekening',
                        value: widget.bankAccountNumber,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Statistik Kehadiran',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _StatChip(
                            label: 'Total Hadir',
                            value: '${widget.totalHadir} hari',
                          ),
                          _StatChip(
                            label: 'Total Off',
                            value: '${widget.totalOff} hari',
                          ),
                          _StatChip(
                            label: 'Total Cuti',
                            value: '${widget.totalCuti} hari',
                          ),
                          _StatChip(
                            label: 'Total Extra Off',
                            value: '${widget.totalExtraOff} hari',
                          ),
                          _StatChip(
                            label: 'Total Sakit',
                            value: '${widget.totalSakit} hari',
                          ),
                          _StatChip(
                            label: 'Total Lembur',
                            value: '${widget.totalLembur} jam',
                          ),
                          _StatChip(
                            label: 'Sisa Cuti',
                            value:
                                '${widget.remainingLeave} dari ${widget.annualLeaveQuota} hari',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Riwayat Pengajuan Izin',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      ...widget.leaveHistory.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text('${item.title} (${item.date})'),
                              ),
                              _StatusBadge(status: item.status),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: widget.onResetPassword,
                icon: const Icon(Icons.lock_reset_rounded),
                label: const Text('Reset Password'),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: _openSlipHistoryPage,
                icon: const Icon(Icons.receipt_long_rounded),
                label: const Text('Lihat Slip Gaji'),
              ),
              const SizedBox(height: 10),
              FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: cs.error,
                ),
                onPressed: widget.onLogout,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Log Out'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SlipHistoryPage extends StatelessWidget {
  final String employeeName;
  final List<SentPayrollSlip> slips;

  const _SlipHistoryPage({required this.employeeName, required this.slips});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Slip Gaji Terkirim')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            employeeName,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 10),
          ...slips.map(
            (slip) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(
                  DateFormat(
                    'MMMM yyyy',
                    'id_ID',
                  ).format(DateTime(slip.year, slip.month)),
                ),
                subtitle: Text(
                  'Terkirim ${DateFormat('dd/MM/yyyy HH:mm', 'id_ID').format(slip.sentAt)} | Total ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(slip.totalGaji)}',
                ),
                trailing: FilledButton.tonalIcon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Membuka file PDF slip (mock).'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                  label: const Text('Lihat PDF'),
                ),
              ),
            ),
          ),
          if (slips.isEmpty)
            Text(
              'Belum ada slip gaji yang dikirim.',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}

class _InfoText extends StatelessWidget {
  final String label;
  final String value;

  const _InfoText({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLongValue = value.length > 24;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: TextStyle(color: cs.onSurfaceVariant)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              softWrap: true,
              overflow: TextOverflow.visible,
              maxLines: 4,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isLongValue ? 13 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 52) / 2;
    return Container(
      width: width.clamp(140, 260),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0FF),
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

class _StatusBadge extends StatelessWidget {
  final LeaveHistoryStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor) = switch (status) {
      LeaveHistoryStatus.approved => (const Color(0xFF2E7D32), Colors.white),
      LeaveHistoryStatus.pending => (
        const Color(0xFFFBC02D),
        const Color(0xFF3A2A00),
      ),
      LeaveHistoryStatus.rejected => (const Color(0xFFC62828), Colors.white),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
