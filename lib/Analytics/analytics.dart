import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../provider/ThemeProvider.dart';
import '../provider/transactionProvider.dart';
import 'package:intl/intl.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

final currencyFormat = NumberFormat.currency(
  locale: 'vi_VN',
  symbol: '₫',
  decimalDigits: 0,
);

class _AnalyticsPageState extends State<AnalyticsPage> {
  String _selectedFilter = 'All';
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  Map<String, double> _computeCategorySpending(
    List<Map<String, dynamic>> transactions,
  ) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = now;

    switch (_selectedFilter) {
      case 'Week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'Month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Year':
        startDate = DateTime(now.year, 1, 1);
        break;
      case 'Custom':
        startDate = _customStartDate ?? now.subtract(const Duration(days: 365));
        endDate = _customEndDate ?? now;
        break;
      case 'Income':
      case 'Expense':
        startDate = DateTime(2000);
        endDate = now;
        break;
      default:
        startDate = DateTime(2000);
        endDate = now;
    }

    final filteredTransactions =
        transactions.where((t) {
          final date = DateTime.parse(t['date']);
          final inRange =
              date.isAfter(startDate) &&
              date.isBefore(endDate.add(const Duration(days: 1)));
          return _selectedFilter == 'All' ||
                  _selectedFilter == 'Week' ||
                  _selectedFilter == 'Month' ||
                  _selectedFilter == 'Year' ||
                  _selectedFilter == 'Custom'
              ? inRange
              : inRange && t['type'] == _selectedFilter;
        }).toList();

    final Map<String, double> spending = {};
    for (var t in filteredTransactions) {
      final category = t['category'] ?? 'Uncategorized';
      final amount = (t['amount'] as double).abs();
      spending[category] = (spending[category] ?? 0) + amount;
    }
    return spending;
  }

  List<Map<String, dynamic>> _filterTransactions(
    List<Map<String, dynamic>> transactions,
  ) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = now;

    switch (_selectedFilter) {
      case 'Week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'Month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Year':
        startDate = DateTime(now.year, 1, 1);
        break;
      case 'Custom':
        startDate = _customStartDate ?? now.subtract(const Duration(days: 365));
        endDate = _customEndDate ?? now;
        break;
      case 'Income':
      case 'Expense':
        startDate = DateTime(2000);
        endDate = now;
        break;
      default:
        startDate = DateTime(2000);
        endDate = now;
    }

    return transactions.where((t) {
      final date = DateTime.parse(t['date']);
      final inRange =
          date.isAfter(startDate) &&
          date.isBefore(endDate.add(const Duration(days: 1)));
      return _selectedFilter == 'All' ||
              _selectedFilter == 'Week' ||
              _selectedFilter == 'Month' ||
              _selectedFilter == 'Year' ||
              _selectedFilter == 'Custom'
          ? inRange
          : inRange && t['type'] == _selectedFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: provider.transactionsStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading transactions'));
            }
            final transactions = snapshot.data!;
            final categorySpending = _computeCategorySpending(transactions);
            final filteredTransactions = _filterTransactions(transactions);
            final maxSpending =
                categorySpending.values.isNotEmpty
                    ? categorySpending.values.reduce((a, b) => a > b ? a : b)
                    : 0.0;
            final maxY = maxSpending * 1.2;

            return Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                final isDarkMode = themeProvider.isDarkMode;
                return Scaffold(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  appBar: AppBar(
                    backgroundColor:
                        isDarkMode ? Colors.black : Colors.blueAccent,
                    elevation: 0,
                    title: Text(
                      'Expense',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.white,
                      ),
                    ),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildFilterButton('Week', isDarkMode),
                            _buildFilterButton('Month', isDarkMode),
                            _buildFilterButton('Year', isDarkMode),
                            IconButton(
                              icon: const Icon(
                                Icons.calendar_today,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                final range = await showDateRangePicker(
                                  context: context,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                  initialDateRange:
                                      _customStartDate != null &&
                                              _customEndDate != null
                                          ? DateTimeRange(
                                            start: _customStartDate!,
                                            end: _customEndDate!,
                                          )
                                          : null,
                                );
                                if (range != null) {
                                  setState(() {
                                    _customStartDate = range.start;
                                    _customEndDate = range.end;
                                    _selectedFilter = 'Custom';
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 200,
                          child:
                              categorySpending.isEmpty
                                  ? const Center(
                                    child: Text(
                                      'No data to display',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  )
                                  : BarChart(
                                    BarChartData(
                                      maxY: maxY,
                                      alignment: BarChartAlignment.spaceAround,
                                      barGroups:
                                          categorySpending.entries.map((e) {
                                            final index = categorySpending.keys
                                                .toList()
                                                .indexOf(e.key);
                                            return BarChartGroupData(
                                              x: index,
                                              barRods: [
                                                BarChartRodData(
                                                  toY: e.value,
                                                  color: _getColorForType(
                                                    'Income',
                                                  ),
                                                  width: 20,
                                                  borderRadius:
                                                      const BorderRadius.vertical(
                                                        top: Radius.circular(4),
                                                      ),
                                                ),
                                              ],
                                              showingTooltipIndicators: [0],
                                            );
                                          }).toList(),
                                      titlesData: FlTitlesData(
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 30,
                                            getTitlesWidget: (value, meta) {
                                              final category = categorySpending
                                                  .keys
                                                  .elementAt(value.toInt());
                                              return SideTitleWidget(
                                                space: 8.0,
                                                meta: meta, // Thêm meta vào đây
                                                child: Text(
                                                  category,
                                                  style: TextStyle(
                                                    color:
                                                        isDarkMode
                                                            ? Colors.white
                                                            : Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                            reservedSize: 40,
                                            getTitlesWidget: (value, meta) {
                                              return Text(
                                                currencyFormat.format(value),
                                                style: TextStyle(
                                                  color:
                                                      isDarkMode
                                                          ? Colors.white
                                                          : Colors.black,
                                                  fontSize: 12,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        topTitles: const AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),
                                        rightTitles: const AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      gridData: const FlGridData(show: false),
                                      barTouchData: BarTouchData(
                                        enabled: true,
                                        touchTooltipData: BarTouchTooltipData(
                                          getTooltipItem: (
                                            group,
                                            groupIndex,
                                            rod,
                                            rodIndex,
                                          ) {
                                            final category = categorySpending
                                                .keys
                                                .elementAt(group.x.toInt());
                                            return BarTooltipItem(
                                              currencyFormat.format(rod.toY),
                                              const TextStyle(
                                                color: Colors.white,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Detail Transactions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _buildFilterButton('All', isDarkMode),
                            const SizedBox(width: 12),
                            _buildFilterButton('Income', isDarkMode),
                            const SizedBox(width: 12),
                            _buildFilterButton('Expense', isDarkMode),
                            const SizedBox(width: 12),
                            _buildFilterButton('PDF', isDarkMode),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            itemCount: filteredTransactions.length,
                            itemBuilder: (context, index) {
                              final t = filteredTransactions[index];
                              return _buildTransactionCard(
                                icon: _getIconForCategory(t['category']),
                                iconColor:
                                    t['type'] == 'Income'
                                        ? Colors.green
                                        : Colors.red,
                                title: t['title'],
                                description:
                                    t['description'] ??
                                    '${t['type']} - ${t['category'] ?? 'Uncategorized'}',
                                amount: t['amount'],
                                date: t['date'],
                                onEdit:
                                    () => provider.showTransactionDialog(
                                      context,
                                      id: t['id'],
                                    ),
                                onDelete:
                                    () => provider.deleteTransaction(t['id']),
                                isDarkMode: isDarkMode,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Color _getColorForType(String type) {
    if (type == 'Income') {
      return Colors.green;
    } else {
      return const Color.fromARGB(255, 255, 0, 0);
    }
  }

  Widget _buildFilterButton(String filter, bool isDarkMode) {
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = filter),
      child: Text(
        filter,
        style: TextStyle(
          fontSize: 16,
          color:
              _selectedFilter == filter
                  ? (isDarkMode ? Colors.white : Colors.black)
                  : (isDarkMode ? Colors.white70 : Colors.grey),
          fontWeight:
              _selectedFilter == filter ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  IconData _getIconForCategory(String? category) {
    switch (category ?? 'Uncategorized') {
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Food':
        return Icons.local_dining;
      case 'Transport':
        return Icons.directions_car;
      default:
        return Icons.category;
    }
  }

  Color _getColorForTypes(String? type) {
    switch (type ?? 'Uncategorized') {
      case 'Income':
        return Colors.green;
      case 'Expense':
        return Colors.red;
      default:
        return const Color.fromARGB(255, 241, 97, 97);
    }
  }

  Widget _buildTransactionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required double amount,
    required String date,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required bool isDarkMode,
  }) {
    final Color amountColor = _getColorForType(
      amount >= 0 ? 'Income' : 'Expense',
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.2),
          child: Icon(icon, color: iconColor),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : Colors.blue[900],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              NumberFormat.currency(
                locale: 'vi_VN',
                symbol: '₫',
              ).format(amount),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: amountColor,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white70 : Colors.grey,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              date,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.white70 : Colors.grey,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(
                      Icons.edit,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    title: Text(
                      'Edit',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(
                      Icons.delete,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    title: Text(
                      'Delete',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
          icon: Icon(
            Icons.more_vert,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
