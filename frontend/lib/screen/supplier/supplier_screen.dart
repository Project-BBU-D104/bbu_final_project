import 'package:flutter/material.dart';

enum SupplierStatus { verified, onHold, active, pending }

class Supplier {
  final String name;
  final String contact;
  final double deliveryRate;
  final int leadTimeDays;
  final SupplierStatus status;

  const Supplier({
    required this.name,
    required this.contact,
    required this.deliveryRate,
    required this.leadTimeDays,
    required this.status,
  });
}

const List<Supplier> _suppliers = [
  Supplier(
    name: 'Global Tech Parts',
    contact: 'Alexander K. Sterling',
    deliveryRate: 98.4,
    leadTimeDays: 4,
    status: SupplierStatus.verified,
  ),
  Supplier(
    name: 'Ironclad Logistics',
    contact: 'Marcus Thorne',
    deliveryRate: 72.1,
    leadTimeDays: 14,
    status: SupplierStatus.onHold,
  ),
  Supplier(
    name: 'Synthetix Labs',
    contact: 'Dr. Elena Rose',
    deliveryRate: 94.8,
    leadTimeDays: 7,
    status: SupplierStatus.active,
  ),
  Supplier(
    name: 'Vanguard Distribution',
    contact: 'Leo Henderson',
    deliveryRate: 99.1,
    leadTimeDays: 2,
    status: SupplierStatus.verified,
  ),
];

// ── Colors ───────────────────────────────────────────────────────────────────

const _bgDark = Colors.white; // Changed from Color(0xFF0D1117) to white
const _cardBg = Color(0xFFF8F9FA);
const _cardBorder = Color(0xFFE1E4E8);
const _textPrimary = Color(0xFF1C2526);
const _textSecondary = Color(0xFF6E7A8A);
const _accentCyan = Color(0xFF00A886);
const _accentBlue = Color(0xFF1F6FEB);
const _filterBg = Color(0xFFF0F2F5);
const _filterActiveBg = Color(0xFF00A886);

// ── Status helpers ────────────────────────────────────────────────────────────

extension SupplierStatusExt on SupplierStatus {
  String get label {
    switch (this) {
      case SupplierStatus.verified:
        return 'Verified';
      case SupplierStatus.onHold:
        return 'On Hold';
      case SupplierStatus.active:
        return 'Active';
      case SupplierStatus.pending:
        return 'Pending';
    }
  }

  Color get badgeColor {
    switch (this) {
      case SupplierStatus.verified:
        return const Color(0xFFD1F5EB);
      case SupplierStatus.onHold:
        return const Color(0xFFFFE0E0);
      case SupplierStatus.active:
        return const Color(0xFFDDEAFF);
      case SupplierStatus.pending:
        return const Color(0xFFFFF3D4);
    }
  }

  Color get badgeTextColor {
    switch (this) {
      case SupplierStatus.verified:
        return const Color(0xFF0F7A55);
      case SupplierStatus.onHold:
        return const Color(0xFFCC2222);
      case SupplierStatus.active:
        return const Color(0xFF1A5DBF);
      case SupplierStatus.pending:
        return const Color(0xFF996600);
    }
  }

  Color get deliveryRateColor {
    switch (this) {
      case SupplierStatus.onHold:
        return const Color(0xFFCC2222);
      default:
        return _accentCyan;
    }
  }

  IconData get avatarIcon {
    switch (this) {
      case SupplierStatus.verified:
        return Icons.precision_manufacturing_outlined;
      case SupplierStatus.onHold:
        return Icons.local_shipping_outlined;
      case SupplierStatus.active:
        return Icons.science_outlined;
      case SupplierStatus.pending:
        return Icons.warehouse_outlined;
    }
  }
}

// ── Filter pill ───────────────────────────────────────────────────────────────

class _FilterPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: active ? _filterActiveBg : _filterBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? _filterActiveBg : _cardBorder,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : _textSecondary,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

// ── Supplier Card ─────────────────────────────────────────────────────────────

class _SupplierCard extends StatelessWidget {
  final Supplier supplier;

  const _SupplierCard({required this.supplier});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _filterBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _cardBorder),
                  ),
                  child: Icon(
                    supplier.status.avatarIcon,
                    color: _accentCyan,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Name & contact
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        supplier.name,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        supplier.contact,
                        style: const TextStyle(
                          color: _textSecondary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: supplier.status.badgeColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    supplier.status.label,
                    style: TextStyle(
                      color: supplier.status.badgeTextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Divider ──
          Container(height: 1, color: _cardBorder),

          // ── Stats row ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _StatItem(
                  label: 'DELIVERY RATE',
                  value: '${supplier.deliveryRate.toStringAsFixed(1)}%',
                  valueColor: supplier.status.deliveryRateColor,
                ),
                const SizedBox(width: 32),
                _StatItem(
                  label: 'LEAD TIME',
                  value: '${supplier.leadTimeDays} Days',
                  valueColor: _textPrimary,
                ),
              ],
            ),
          ),

          // ── Divider ──
          Container(height: 1, color: _cardBorder),

          // ── Footer row ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                // Phone icon
                _IconButton(
                  icon: Icons.phone_outlined,
                  onTap: () {},
                ),
                const SizedBox(width: 10),
                // Email icon
                _IconButton(
                  icon: Icons.mail_outline_rounded,
                  onTap: () {},
                ),
                const Spacer(),
                // View History
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: const [
                      Text(
                        'VIEW HISTORY',
                        style: TextStyle(
                          color: _accentCyan,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: _accentCyan,
                        size: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _StatItem({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _textSecondary,
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: _filterBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _cardBorder),
        ),
        child: Icon(icon, color: _textSecondary, size: 16),
      ),
    );
  }
}

// ── Main Screen ───────────────────────────────────────────────────────────────

class SupplierScreen extends StatefulWidget {
  const SupplierScreen({super.key});

  @override
  State<SupplierScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends State<SupplierScreen> {
  String _activeFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = ['All', 'Verified', 'Critical', 'Pending'];

  List<Supplier> get _filteredSuppliers {
    if (_activeFilter == 'All') return _suppliers;
    return _suppliers.where((s) {
      switch (_activeFilter) {
        case 'Verified':
          return s.status == SupplierStatus.verified;
        case 'Critical':
          return s.status == SupplierStatus.onHold;
        case 'Pending':
          return s.status == SupplierStatus.pending;
        default:
          return true;
      }
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark, // Now white (Colors.white)
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Search bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: _filterBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _cardBorder),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 13,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Search suppliers...',
                          hintStyle: TextStyle(
                            color: _textSecondary,
                            fontSize: 13,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: _textSecondary,
                            size: 18,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Filter icon button
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _filterBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _cardBorder),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: _textSecondary,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),

            // ── Filter pills ──
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: _filters.map((f) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _FilterPill(
                        label: f,
                        active: _activeFilter == f,
                        onTap: () => setState(() => _activeFilter = f),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // ── Supplier list ──
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filteredSuppliers.length,
                itemBuilder: (context, index) {
                  return _SupplierCard(supplier: _filteredSuppliers[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}