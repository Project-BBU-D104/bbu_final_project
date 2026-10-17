import 'package:flutter/material.dart';

class CardSystemConfigurationWidget extends StatelessWidget {
  final Map<String, dynamic> configuration;
  final VoidCallback onTap;

  const CardSystemConfigurationWidget({
    super.key,
    required this.configuration,
    required this.onTap,
  });

  static const Color primaryColor = Color(0xFF00A878);
  static const Color darkColor = Color(0xFF1A2B49);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE8FAF5), Color(0xFFD4F7EF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.business_rounded,
                          color: primaryColor,
                          size: 34,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              configuration['company_name']?.toString() ??
                                  'Company Name',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: darkColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'System Configuration',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.settings_rounded,
                          color: primaryColor,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Company details
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'CONTACT INFORMATION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),

                _buildItem(
                  Icons.location_on_rounded,
                  'Address',
                  configuration['company_address'],
                  const Color(0xFF00A878),
                  const Color(0xFFE6F8F1),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 54),
                  child: Divider(
                    height: 1,
                    color: Colors.grey.withValues(alpha: 0.15),
                  ),
                ),

                _buildItem(
                  Icons.phone_rounded,
                  'Phone',
                  configuration['phone'],
                  const Color(0xFF3989E8),
                  const Color(0xFFEAF3FF),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(
    IconData icon,
    String title,
    dynamic value,
    Color iconColor,
    Color backgroundColor,
  ) {
    final displayValue = value == null || value.toString().trim().isEmpty
        ? 'Not set'
        : value.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 21, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8490A5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 2,
            child: Text(
              displayValue,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: darkColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
