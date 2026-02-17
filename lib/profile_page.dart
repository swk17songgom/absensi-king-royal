import 'package:flutter/material.dart';

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

class EmployeeProfilePage extends StatelessWidget {
  final String fullName;
  final String nik;
  final String jobTitle;
  final String department;
  final String phoneNumber;
  final String email;
  final String joinedDate;
  final int totalHadir;
  final int totalCuti;
  final int totalExtraOff;
  final int totalSakit;
  final int totalLembur;
  final List<LeaveHistoryItem> leaveHistory;
  final VoidCallback onLogout;

  const EmployeeProfilePage({
    super.key,
    required this.fullName,
    required this.nik,
    required this.jobTitle,
    required this.department,
    required this.phoneNumber,
    required this.email,
    required this.joinedDate,
    required this.totalHadir,
    required this.totalCuti,
    required this.totalExtraOff,
    required this.totalSakit,
    required this.totalLembur,
    required this.leaveHistory,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
                      const CircleAvatar(
                        radius: 44,
                        backgroundImage: AssetImage(
                          'assets/icons/app_icon.jpg',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      _InfoText(label: 'NIK', value: nik),
                      _InfoText(label: 'Jabatan', value: jobTitle),
                      _InfoText(label: 'Departemen', value: department),
                      _InfoText(label: 'Nomor HP', value: phoneNumber),
                      _InfoText(label: 'Email', value: email),
                      _InfoText(label: 'Tanggal Bergabung', value: joinedDate),
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
                            value: '$totalHadir hari',
                          ),
                          _StatChip(
                            label: 'Total Cuti',
                            value: '$totalCuti hari',
                          ),
                          _StatChip(
                            label: 'Total Extra Off',
                            value: '$totalExtraOff hari',
                          ),
                          _StatChip(
                            label: 'Total Sakit',
                            value: '$totalSakit hari',
                          ),
                          _StatChip(
                            label: 'Total Lembur',
                            value: '$totalLembur jam',
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
                      ...leaveHistory.map(
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Fitur lihat slip gaji akan segera tersedia.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.receipt_long_rounded),
                label: const Text('Lihat Slip Gaji'),
              ),
              const SizedBox(height: 10),
              FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: cs.error,
                ),
                onPressed: onLogout,
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
              maxLines: 3,
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
