import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final _api = ApiService();
  bool _loading = true;
  List<Map<String, dynamic>> _payments = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _loading = true);
    try {
      final res = await _api.getPaymentHistory();
      setState(() => _payments = res);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load payment history: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BhauColors.bg1,
      appBar: AppBar(
        backgroundColor: BhauColors.bg2,
        title: const Text(
          'PAYMENT HISTORY',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        child: _loading
            ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(BhauColors.cyan)))
            : _payments.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _payments.length,
                    itemBuilder: (context, index) {
                      return _buildPaymentCard(_payments[index]);
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        const Center(
          child: Column(
            children: [
              Icon(Icons.payment, size: 48, color: Colors.white24),
              SizedBox(height: 16),
              Text(
                'No transactions found.',
                style: TextStyle(color: Colors.white60, fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> p) {
    final name = p['planName'] as String;
    final amount = p['amount'] as double;
    final status = p['status'] as String;
    final date = DateTime.parse(p['paymentDate']);
    final df = DateFormat('d MMM yyyy, h:mm a');

    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'paid':
        statusColor = Colors.greenAccent;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'failed':
        statusColor = Colors.redAccent;
        statusIcon = Icons.error_outline;
        break;
      default:
        statusColor = Colors.amberAccent;
        statusIcon = Icons.hourglass_empty;
        break;
    }

    return Card(
      color: BhauColors.bg2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, color: statusColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(df.format(date.toLocal()), style: const TextStyle(fontSize: 11, color: Colors.white54)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${amount.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: statusColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
