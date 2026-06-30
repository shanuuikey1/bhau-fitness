import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final _api = ApiService();
  bool _loading = true;

  Map<String, dynamic>? _overview;
  List<Map<String, dynamic>> _revenueTrend = [];
  List<Map<String, dynamic>> _popularClasses = [];
  List<Map<String, dynamic>> _planDist = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _api.getAnalyticsOverview(),
        _api.getRevenueTrend(),
        _api.getPopularClasses(),
        _api.getMembershipDistribution(),
      ]);

      setState(() {
        _overview = results[0] as Map<String, dynamic>;
        _revenueTrend = results[1] as List<Map<String, dynamic>>;
        _popularClasses = results[2] as List<Map<String, dynamic>>;
        _planDist = results[3] as List<Map<String, dynamic>>;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load analytics: $e')),
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
          'ADMIN ANALYTICS',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _loading
            ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(BhauColors.cyan)))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildStatCards(),
                  const SizedBox(height: 20),
                  _buildRevenueChartCard(),
                  const SizedBox(height: 20),
                  _buildPlanDistributionCard(),
                  const SizedBox(height: 20),
                  _buildPopularClassesCard(),
                ],
              ),
      ),
    );
  }

  Widget _buildStatCards() {
    if (_overview == null) return const SizedBox();
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('TOTAL MEMBERS', '${_overview!['totalMembers']}', Icons.people, BhauColors.cyan),
        _buildStatCard('ACTIVE MEMBERS', '${_overview!['activeMemberships']}', Icons.card_membership, BhauColors.lime),
        _buildStatCard('MONTHLY REVENUE', '₹${(_overview!['monthlyRevenue'] as double).toStringAsFixed(0)}', Icons.monetization_on, BhauColors.warn),
        _buildStatCard('CHURN RATE', '${_overview!['churnRate']}%', Icons.trending_down, Colors.redAccent),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      color: BhauColors.bg2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white60)),
                Icon(icon, color: color, size: 18),
              ],
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChartCard() {
    return Card(
      color: BhauColors.bg2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revenue Trend (Last 12 Months)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: _revenueTrend.isEmpty
                  ? const Center(child: Text('No revenue data available.', style: TextStyle(color: Colors.white38)))
                  : LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                int val = value.toInt();
                                if (val >= 0 && val < _revenueTrend.length) {
                                  if (val % 2 == 0) {
                                    String month = _revenueTrend[val]['month'] as String;
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(month.split(' ')[0], style: const TextStyle(color: Colors.white54, fontSize: 10)),
                                    );
                                  }
                                }
                                return const Text('');
                              },
                              reservedSize: 24,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(_revenueTrend.length, (i) {
                              double rev = (_revenueTrend[i]['revenue'] as num).toDouble();
                              return FlSpot(i.toDouble(), rev);
                            }),
                            isCurved: true,
                            color: BhauColors.cyan,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: BhauColors.cyan.withOpacity(0.15),
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

  Widget _buildPlanDistributionCard() {
    return Card(
      color: BhauColors.bg2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Membership Plan Distribution',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: _planDist.isEmpty
                  ? const Center(child: Text('No active memberships.', style: TextStyle(color: Colors.white38)))
                  : Row(
                      children: [
                        Expanded(
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 4,
                              centerSpaceRadius: 40,
                              sections: List.generate(_planDist.length, (i) {
                                final item = _planDist[i];
                                final colors = [BhauColors.cyan, BhauColors.lime, BhauColors.warn, Colors.redAccent];
                                return PieChartSectionData(
                                  color: colors[i % colors.length],
                                  value: (item['percentage'] as num).toDouble(),
                                  title: '${item['percentage']}%',
                                  radius: 40,
                                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                                );
                              }),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(_planDist.length, (i) {
                              final item = _planDist[i];
                              final colors = [BhauColors.cyan, BhauColors.lime, BhauColors.warn, Colors.redAccent];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Container(width: 12, height: 12, color: colors[i % colors.length]),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${item['planName']} (${item['activeCount']})',
                                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularClassesCard() {
    return Card(
      color: BhauColors.bg2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Popular Classes (Bookings Count)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            _popularClasses.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No class bookings recorded yet.', style: TextStyle(color: Colors.white38)),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _popularClasses.length,
                    itemBuilder: (context, index) {
                      final item = _popularClasses[index];
                      final name = item['className'] as String;
                      final count = item['totalBookings'] as int;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(name, style: const TextStyle(fontSize: 13, color: Colors.white)),
                                Text('$count Bookings', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: BhauColors.cyan)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: count / (_popularClasses.first['totalBookings'] as int),
                              backgroundColor: Colors.white10,
                              valueColor: AlwaysStoppedAnimation(BhauColors.cyan),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
