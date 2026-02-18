import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum AttendanceDayStatus { hadir, off, extraOff, cuti, sakit, alfa }

enum HistoryFilterType { bulanIni, bulanLalu, customTanggal }

class AttendanceHistoryItem {
  final DateTime date;
  final TimeOfDay? checkIn;
  final TimeOfDay? checkOut;
  final AttendanceDayStatus status;

  const AttendanceHistoryItem({
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.status,
  });
}

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  HistoryFilterType _selectedFilter = HistoryFilterType.bulanIni;
  DateTimeRange? _customRange;
  late final List<AttendanceHistoryItem> _allHistory;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _allHistory = <AttendanceHistoryItem>[
      AttendanceHistoryItem(
        date: DateTime(now.year, now.month, 17),
        checkIn: const TimeOfDay(hour: 8, minute: 1),
        checkOut: const TimeOfDay(hour: 17, minute: 6),
        status: AttendanceDayStatus.hadir,
      ),
      AttendanceHistoryItem(
        date: DateTime(now.year, now.month, 16),
        checkIn: const TimeOfDay(hour: 8, minute: 3),
        checkOut: const TimeOfDay(hour: 17, minute: 10),
        status: AttendanceDayStatus.hadir,
      ),
      AttendanceHistoryItem(
        date: DateTime(now.year, now.month, 15),
        checkIn: null,
        checkOut: null,
        status: AttendanceDayStatus.off,
      ),
      AttendanceHistoryItem(
        date: DateTime(now.year, now.month, 14),
        checkIn: null,
        checkOut: null,
        status: AttendanceDayStatus.extraOff,
      ),
      AttendanceHistoryItem(
        date: DateTime(now.year, now.month, 13),
        checkIn: null,
        checkOut: null,
        status: AttendanceDayStatus.cuti,
      ),
      AttendanceHistoryItem(
        date: DateTime(now.year, now.month, 12),
        checkIn: null,
        checkOut: null,
        status: AttendanceDayStatus.sakit,
      ),
      AttendanceHistoryItem(
        date: DateTime(now.year, now.month, 11),
        checkIn: null,
        checkOut: null,
        status: AttendanceDayStatus.alfa,
      ),
      AttendanceHistoryItem(
        date: DateTime(now.year, now.month - 1, 28),
        checkIn: const TimeOfDay(hour: 8, minute: 5),
        checkOut: const TimeOfDay(hour: 17, minute: 3),
        status: AttendanceDayStatus.hadir,
      ),
      AttendanceHistoryItem(
        date: DateTime(now.year, now.month - 1, 27),
        checkIn: null,
        checkOut: null,
        status: AttendanceDayStatus.cuti,
      ),
      AttendanceHistoryItem(
        date: DateTime(now.year, now.month - 1, 26),
        checkIn: null,
        checkOut: null,
        status: AttendanceDayStatus.extraOff,
      ),
      AttendanceHistoryItem(
        date: DateTime(now.year, now.month - 1, 25),
        checkIn: null,
        checkOut: null,
        status: AttendanceDayStatus.sakit,
      ),
      AttendanceHistoryItem(
        date: DateTime(now.year, now.month - 1, 24),
        checkIn: null,
        checkOut: null,
        status: AttendanceDayStatus.alfa,
      ),
    ]..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2, 1, 1),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: _customRange,
      locale: const Locale('id', 'ID'),
    );

    if (picked == null || !mounted) return;
    setState(() => _customRange = picked);
  }

  List<AttendanceHistoryItem> get _filteredHistory {
    final now = DateTime.now();
    DateTime start;
    DateTime end;

    switch (_selectedFilter) {
      case HistoryFilterType.bulanIni:
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      case HistoryFilterType.bulanLalu:
        start = DateTime(now.year, now.month - 1, 1);
        end = DateTime(now.year, now.month, 0, 23, 59, 59);
      case HistoryFilterType.customTanggal:
        if (_customRange == null) return <AttendanceHistoryItem>[];
        start = DateTime(
          _customRange!.start.year,
          _customRange!.start.month,
          _customRange!.start.day,
        );
        end = DateTime(
          _customRange!.end.year,
          _customRange!.end.month,
          _customRange!.end.day,
          23,
          59,
          59,
        );
    }

    return _allHistory
        .where((item) => !item.date.isBefore(start) && !item.date.isAfter(end))
        .toList();
  }

  Map<AttendanceDayStatus, int> get _summary {
    final map = <AttendanceDayStatus, int>{
      AttendanceDayStatus.hadir: 0,
      AttendanceDayStatus.off: 0,
      AttendanceDayStatus.extraOff: 0,
      AttendanceDayStatus.cuti: 0,
      AttendanceDayStatus.sakit: 0,
      AttendanceDayStatus.alfa: 0,
    };

    for (final item in _filteredHistory) {
      map[item.status] = (map[item.status] ?? 0) + 1;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final filtered = _filteredHistory;

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Absensi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 1.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ringkasan',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _SummaryChip(
                        label: 'Hadir',
                        total: _summary[AttendanceDayStatus.hadir] ?? 0,
                      ),
                      _SummaryChip(
                        label: 'Off',
                        total: _summary[AttendanceDayStatus.off] ?? 0,
                      ),
                      _SummaryChip(
                        label: 'Extra Off',
                        total: _summary[AttendanceDayStatus.extraOff] ?? 0,
                      ),
                      _SummaryChip(
                        label: 'Cuti',
                        total: _summary[AttendanceDayStatus.cuti] ?? 0,
                      ),
                      _SummaryChip(
                        label: 'Sakit',
                        total: _summary[AttendanceDayStatus.sakit] ?? 0,
                      ),
                      _SummaryChip(
                        label: 'Alfa',
                        total: _summary[AttendanceDayStatus.alfa] ?? 0,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 1.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter',
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<HistoryFilterType>(
                    value: _selectedFilter,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: HistoryFilterType.bulanIni,
                        child: Text('Bulan Ini'),
                      ),
                      DropdownMenuItem(
                        value: HistoryFilterType.bulanLalu,
                        child: Text('Bulan Lalu'),
                      ),
                      DropdownMenuItem(
                        value: HistoryFilterType.customTanggal,
                        child: Text('Custom Tanggal'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _selectedFilter = value);
                    },
                  ),
                  if (_selectedFilter == HistoryFilterType.customTanggal) ...[
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _pickCustomRange,
                      icon: const Icon(Icons.date_range_rounded),
                      label: Text(
                        _customRange == null
                            ? 'Pilih Rentang Tanggal'
                            : '${DateFormat('dd MMM yyyy', 'id_ID').format(_customRange!.start)} - ${DateFormat('dd MMM yyyy', 'id_ID').format(_customRange!.end)}',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (filtered.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Tidak ada data pada periode ini.'),
              ),
            )
          else
            ...filtered.map((item) => _HistoryCard(item: item)),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final int total;

  const _SummaryChip({required this.label, required this.total});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $total',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final AttendanceHistoryItem item;

  const _HistoryCard({required this.item});

  String _timeLabel(TimeOfDay? value) {
    if (value == null) return '-';
    return '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(item.date);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1.2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(date, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Jam Masuk: ${_timeLabel(item.checkIn)}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Jam Pulang: ${_timeLabel(item.checkOut)}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _StatusBadge(status: item.status),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final AttendanceDayStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      AttendanceDayStatus.hadir => (
        'Hadir',
        const Color(0xFF2E7D32),
        Colors.white,
      ),
      AttendanceDayStatus.off => (
        'Off',
        const Color(0xFFF9A825),
        const Color(0xFF3A2A00),
      ),
      AttendanceDayStatus.extraOff => (
        'Extra Off',
        const Color(0xFF1565C0),
        Colors.white,
      ),
      AttendanceDayStatus.cuti => (
        'Cuti',
        const Color(0xFFF9A825),
        const Color(0xFF3A2A00),
      ),
      AttendanceDayStatus.sakit => (
        'Sakit',
        const Color(0xFFE67E22),
        Colors.white,
      ),
      AttendanceDayStatus.alfa => (
        'Alfa',
        const Color(0xFFC62828),
        Colors.white,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}
