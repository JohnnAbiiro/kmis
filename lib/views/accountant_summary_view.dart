import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../controller/myprovider.dart';

class AccountantSummaryView extends StatefulWidget {
  const AccountantSummaryView({super.key});

  @override
  State<AccountantSummaryView> createState() => _AccountantSummaryViewState();
}

class _AccountantSummaryViewState extends State<AccountantSummaryView> {
  DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime endDate = DateTime.now();
  final DateFormat _df = DateFormat("dd MMM yyyy");
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    final provider = context.read<Myprovider>();
    await provider.fetchAccountantSummary(startDate: startDate, endDate: endDate);
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450, maxHeight: 550),
            child: child,
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
      _refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ProgressHUD(
      child: Consumer<Myprovider>(
        builder: (context, val, child) {
          final filteredSummaries = val.accountantSummaryList.where((summary) {
            final query = searchQuery.toLowerCase();
            final staffName = (summary['staffName'] ?? "").toString().toLowerCase();
            final date = (summary['date'] ?? "").toString().toLowerCase();
            return staffName.contains(query) || date.contains(query);
          }).toList();

          double grandTotal = filteredSummaries.fold(0.0, (sum, item) => sum + (double.tryParse(item['totalCollected']?.toString() ?? "0") ?? 0));

          return Scaffold(
            backgroundColor: colors.surfaceContainerLowest,
            appBar: AppBar(
              title: _isSearching
                  ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: "Search staff or date...",
                        border: InputBorder.none,
                      ),
                      onChanged: (v) => setState(() => searchQuery = v),
                    )
                  : const Text("Accountant Daily Summary", style: TextStyle(fontWeight: FontWeight.bold)),
              actions: [
                if (!_isSearching) ...[
                  ActionChip(
                    avatar: Icon(Icons.calendar_today, size: 16, color: colors.primary),
                    label: Text("${_df.format(startDate)} - ${_df.format(endDate)}",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.primary)),
                    onPressed: () => _selectDateRange(context),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _isSearching = true),
                    icon: const Icon(Icons.search),
                  ),
                  IconButton(
                    onPressed: _refreshData,
                    icon: const Icon(Icons.refresh),
                  ),
                ] else
                  IconButton(
                    onPressed: () => setState(() {
                      _isSearching = false;
                      searchQuery = "";
                      _searchController.clear();
                    }),
                    icon: const Icon(Icons.close),
                  ),
                const SizedBox(width: 8),
              ],
            ),
            body: filteredSummaries.isEmpty
                ? _buildEmptyState(colors)
                : _buildSummaryTable(context, filteredSummaries, val, colors, grandTotal),
          );
        },
      ),
    );
  }

  Widget _buildSummaryTable(BuildContext context, List<Map<String, dynamic>> summaries, Myprovider val, ColorScheme colors, double grandTotal) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outlineVariant.withOpacity(0.5)),
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(colors.surfaceContainerHigh),
              columns: [
                const DataColumn(label: Text("DATE")),
                const DataColumn(label: Text("STAFF")),
                const DataColumn(label: Text("PAYMENT METHODS")),
                 DataColumn(label: Text("TOTAL COLLECTED (GHS)")),
              ],
              rows: [
                ...summaries.map((summary) {
                  final total = double.tryParse(summary['totalCollected']?.toString() ?? "0") ?? 0;
                  final methods = summary['paymentMethods'] as Map<String, dynamic>? ?? {};
                  
                  return DataRow(cells: [
                    DataCell(Text(summary['date'] ?? "")),
                    DataCell(Text(summary['staffName'] ?? "")),
                    DataCell(
                      Wrap(
                        spacing: 4,
                        children: methods.entries.map((e) {
                          return Chip(
                            label: Text("${e.key}: ${val.numberFormat.format(e.value)}", style: const TextStyle(fontSize: 10)),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          );
                        }).toList(),
                      ),
                    ),
                    DataCell(Text(val.numberFormat.format(total), style: const TextStyle(fontWeight: FontWeight.bold))),
                  ]);
                }),
                DataRow(
                  color: WidgetStateProperty.all(colors.primaryContainer.withOpacity(0.1)),
                  cells: [
                    const DataCell(Text("")),
                    const DataCell(Text("")),
                    const DataCell(Align(alignment: Alignment.centerRight, child: Text("GRAND TOTAL:", style: TextStyle(fontWeight: FontWeight.bold)))),
                    DataCell(Text(val.numberFormat.format(grandTotal), style: TextStyle(fontWeight: FontWeight.w900, color: colors.primary))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.summarize_outlined, size: 64, color: colors.outlineVariant),
          const SizedBox(height: 16),
          const Text("No summaries found for this range"),
          TextButton(onPressed: _refreshData, child: const Text("Refresh")),
        ],
      ),
    );
  }
}
