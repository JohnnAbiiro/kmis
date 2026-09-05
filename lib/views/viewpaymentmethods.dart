import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Change this import to your actual provider
import 'package:ksoftsms/controller/Myprovider.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  // ---------------------------------------------------------------------------
  // COLORS
  // ---------------------------------------------------------------------------

  static const Color _background = Color(0xFF0D1421);
  static const Color _card = Color(0xFF182232);
  static const Color _cardLight = Color(0xFF202D40);
  static const Color _primary = Color(0xFF3B82F6);
  static const Color _success = Color(0xFF22C55E);
  static const Color _danger = Color(0xFFEF4444);
  static const Color _warning = Color(0xFFF59E0B);

  // ---------------------------------------------------------------------------
  // STATE
  // ---------------------------------------------------------------------------

  final TextEditingController _searchController =
  TextEditingController();

  String _searchTerm = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // FIRESTORE QUERY
  // ---------------------------------------------------------------------------

  Stream<QuerySnapshot<Map<String, dynamic>>> _paymentMethodsStream(
      String schoolId,
      ) {
    return FirebaseFirestore.instance
        .collection('payment_methods')
        .where('schoolId', isEqualTo: schoolId)
        .snapshots();
  }

  // ---------------------------------------------------------------------------
  // FILTER
  // ---------------------------------------------------------------------------

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filterMethods(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> methods,
      ) {
    if (_searchTerm.isEmpty) {
      return methods;
    }

    return methods.where((doc) {
      final data = doc.data();

      final name =
      (data['name'] ?? '').toString().toLowerCase();

      final accountType =
      (data['accountType'] ?? '').toString().toLowerCase();

      final subType =
      (data['subType'] ?? '').toString().toLowerCase();

      final staff =
      (data['staff'] ?? '').toString().toLowerCase();

      final linkedAccounts =
          (data['linkedAccounts'] as List?)
              ?.map((e) => e.toString().toLowerCase())
              .join(' ') ??
              '';

      return name.contains(_searchTerm) ||
          accountType.contains(_searchTerm) ||
          subType.contains(_searchTerm) ||
          staff.contains(_searchTerm) ||
          linkedAccounts.contains(_searchTerm);
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // DELETE
  // ---------------------------------------------------------------------------

  Future<void> _deletePaymentMethod(
      QueryDocumentSnapshot<Map<String, dynamic>> document,
      ) async {
    final data = document.data();

    final name = data['name']?.toString() ?? 'Payment Method';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _card,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: _warning,
              ),
              SizedBox(width: 10),
              Text(
                'Delete Payment Method',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "$name"?\n\n'
                'This action cannot be undone.',
            style: const TextStyle(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white60,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              icon: const Icon(
                Icons.delete_outline,
                size: 18,
              ),
              label: const Text('Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _danger,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await document.reference.delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: _success,
          content: Text(
            '$name deleted successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: _danger,
          content: Text(
            'Failed to delete payment method: $e',
          ),
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // EDIT
  // ---------------------------------------------------------------------------

  Future<void> _editPaymentMethod(
      QueryDocumentSnapshot<Map<String, dynamic>> document,
      ) async {
    final data = document.data();

    final nameController = TextEditingController(
      text: data['name']?.toString() ?? '',
    );

    final accountTypeController = TextEditingController(
      text: data['accountType']?.toString() ?? '',
    );

    final subTypeController = TextEditingController(
      text: data['subType']?.toString() ?? '',
    );

    final linkedAccounts = List<String>.from(
      data['linkedAccounts'] ?? [],
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return _EditPaymentMethodDialog(
          nameController: nameController,
          accountTypeController: accountTypeController,
          subTypeController: subTypeController,
          linkedAccounts: linkedAccounts,
        );
      },
    );

    nameController.dispose();
    accountTypeController.dispose();
    subTypeController.dispose();

    if (result != true) return;

    try {
      await document.reference.update({
        'name': nameController.text.trim(),
        'accountType': accountTypeController.text.trim(),
        'subType': subTypeController.text.trim(),
        'linkedAccounts': linkedAccounts,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: _success,
          content: Text(
            'Payment method updated successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: _danger,
          content: Text(
            'Failed to update payment method: $e',
          ),
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<Myprovider>(
      context,
      listen: false,
    );

    final schoolId = provider.schoolid;

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _paymentMethodsStream(schoolId),
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: _primary,
                ),
              );
            }

            if (snapshot.hasError) {
              return _buildError(snapshot.error.toString());
            }

            final allMethods = snapshot.data?.docs ?? [];

            final methods = _filterMethods(allMethods);

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(
                    total: allMethods.length,
                  ),
                ),

                SliverToBoxAdapter(
                  child: _buildSearchBar(),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      20,
                      20,
                      10,
                    ),
                    child: _buildSummary(
                      total: allMethods.length,
                      visible: methods.length,
                    ),
                  ),
                ),

                if (methods.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      10,
                      20,
                      30,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _buildResponsiveContent(
                        methods,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------

  Widget _buildHeader({
    required int total,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        12,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 20,
            runSpacing: 14,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 200,
                  maxWidth: 600,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _primary.withOpacity(.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: _primary,
                        size: 25,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Flexible(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Payment Methods',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$total payment methods configured',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              ElevatedButton.icon(
                onPressed: () {
                  // Connect this to your existing add page/dialog.
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Payment Method'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SEARCH
  // ---------------------------------------------------------------------------

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        5,
        20,
        5,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 0,
          maxWidth: 800,
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText:
            'Search payment method, account, type...',
            hintStyle: const TextStyle(
              color: Colors.white38,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: Colors.white54,
            ),
            suffixIcon: _searchTerm.isNotEmpty
                ? IconButton(
              onPressed: _searchController.clear,
              icon: const Icon(
                Icons.clear,
                color: Colors.white54,
              ),
            )
                : null,
            filled: true,
            fillColor: _card,
            contentPadding:
            const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.white10,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: _primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SUMMARY
  // ---------------------------------------------------------------------------

  Widget _buildSummary({
    required int total,
    required int visible,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _smallStat(
          icon: Icons.account_balance_wallet_outlined,
          label: 'Total Methods',
          value: total.toString(),
        ),
        if (_searchTerm.isNotEmpty)
          _smallStat(
            icon: Icons.filter_list,
            label: 'Showing',
            value: visible.toString(),
          ),
      ],
    );
  }

  Widget _smallStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.white54,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // RESPONSIVE CONTENT
  // ---------------------------------------------------------------------------

  Widget _buildResponsiveContent(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> methods,
      ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop
        if (constraints.maxWidth >= 1000) {
          return _buildDesktopTable(methods);
        }

        // Tablet / Mobile
        return _buildCards(methods);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // DESKTOP TABLE
  // ---------------------------------------------------------------------------

  Widget _buildDesktopTable(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> methods,
      ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowHeight: 55,
            dataRowMinHeight: 70,
            dataRowMaxHeight: 110,
            columnSpacing: 28,
            headingRowColor:
            WidgetStateProperty.all(_cardLight),
            columns: const [
              DataColumn(
                label: Text(
                  'PAYMENT METHOD',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'ACCOUNT TYPE',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'LINKED ACCOUNTS',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'STAFF',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'DATE CREATED',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'ACTIONS',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            rows: methods.map((doc) {
              final data = doc.data();

              return DataRow(
                cells: [
                  DataCell(
                    _paymentName(data),
                  ),
                  DataCell(
                    _accountType(data),
                  ),
                  DataCell(
                    _linkedAccounts(data),
                  ),
                  DataCell(
                    Text(
                      data['staff']?.toString() ?? '-',
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      _formatDate(data['dateCreated']),
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  DataCell(
                    _actionButtons(doc),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MOBILE / TABLET CARDS
  // ---------------------------------------------------------------------------

  Widget _buildCards(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> methods,
      ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        const minCardWidth = 320.0;

        final columns =
        (constraints.maxWidth /
            (minCardWidth + spacing))
            .floor()
            .clamp(1, 3);

        final cardWidth =
            (constraints.maxWidth -
                ((columns - 1) * spacing)) /
                columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: methods.map((doc) {
            return SizedBox(
              width: cardWidth,
              child: _paymentCard(doc),
            );
          }).toList(),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // PAYMENT CARD
  // ---------------------------------------------------------------------------

  Widget _paymentCard(
      QueryDocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data();

    final name =
        data['name']?.toString() ?? 'Unnamed Payment';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _primary.withOpacity(.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.payments_outlined,
                  color: _primary,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow:
                      TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    _typeBadge(data),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              PopupMenuButton<String>(
                color: _cardLight,
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.white54,
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    _editPaymentMethod(doc);
                  }

                  if (value == 'delete') {
                    _deletePaymentMethod(doc);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          color: Colors.white70,
                          size: 19,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Edit',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: _danger,
                          size: 19,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Delete',
                          style: TextStyle(
                            color: _danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Divider(
            color: Colors.white10,
            height: 1,
          ),

          const SizedBox(height: 14),

          _detailRow(
            Icons.account_balance_outlined,
            'Account Type',
            data['accountType']?.toString() ?? '-',
          ),

          if ((data['subType'] ?? '')
              .toString()
              .isNotEmpty)
            _detailRow(
              Icons.category_outlined,
              'Sub Type',
              data['subType'].toString(),
            ),

          const SizedBox(height: 10),

          _buildLinkedAccounts(data),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _detailRow(
                  Icons.person_outline,
                  'Staff',
                  data['staff']?.toString() ?? '-',
                  compact: true,
                ),
              ),
              Expanded(
                child: _detailRow(
                  Icons.calendar_today_outlined,
                  'Created',
                  _formatDate(data['dateCreated']),
                  compact: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _editPaymentMethod(doc),
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 17,
                  ),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white70,
                    ),
                    padding:
                    const EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _deletePaymentMethod(doc),
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 17,
                  ),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _danger,
                    side: const BorderSide(
                      color: _danger,
                    ),
                    padding:
                    const EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PAYMENT NAME
  // ---------------------------------------------------------------------------

  Widget _paymentName(
      Map<String, dynamic> data,
      ) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _primary.withOpacity(.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.payments_outlined,
            color: _primary,
            size: 19,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          data['name']?.toString() ?? '-',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // ACCOUNT TYPE
  // ---------------------------------------------------------------------------

  Widget _accountType(
      Map<String, dynamic> data,
      ) {
    final accountType =
        data['accountType']?.toString() ?? '';

    final subType =
        data['subType']?.toString() ?? '';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          accountType.isEmpty
              ? '-'
              : accountType,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        if (subType.isNotEmpty)
          Text(
            subType,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 11,
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TYPE BADGE
  // ---------------------------------------------------------------------------

  Widget _typeBadge(
      Map<String, dynamic> data,
      ) {
    final type =
        data['accountType']?.toString() ?? '';

    if (type.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _primary.withOpacity(.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type,
        style: const TextStyle(
          color: _primary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LINKED ACCOUNTS
  // ---------------------------------------------------------------------------

  Widget _linkedAccounts(
      Map<String, dynamic> data,
      ) {
    final accounts = List<String>.from(
      data['linkedAccounts'] ?? [],
    );

    if (accounts.isEmpty) {
      return const Text(
        '-',
        style: TextStyle(
          color: Colors.white38,
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 350,
      ),
      child: Wrap(
        spacing: 5,
        runSpacing: 5,
        children: accounts.map((account) {
          return Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.06),
              borderRadius:
              BorderRadius.circular(6),
            ),
            child: Text(
              account,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLinkedAccounts(
      Map<String, dynamic> data,
      ) {
    final accounts = List<String>.from(
      data['linkedAccounts'] ?? [],
    );

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.link,
              color: Colors.white38,
              size: 16,
            ),
            SizedBox(width: 6),
            Text(
              'Linked Accounts',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (accounts.isEmpty)
          const Text(
            'No linked accounts',
            style: TextStyle(
              color: Colors.white30,
              fontSize: 12,
            ),
          )
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: accounts.map((account) {
              return Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.06),
                  borderRadius:
                  BorderRadius.circular(7),
                  border: Border.all(
                    color: Colors.white10,
                  ),
                ),
                child: Text(
                  account,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // DETAIL ROW
  // ---------------------------------------------------------------------------

  Widget _detailRow(
      IconData icon,
      String label,
      String value, {
        bool compact = false,
      }) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: compact ? 0 : 7,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 15,
            color: Colors.white38,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 2,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ACTION BUTTONS
  // ---------------------------------------------------------------------------

  Widget _actionButtons(
      QueryDocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Edit',
          onPressed: () =>
              _editPaymentMethod(doc),
          icon: const Icon(
            Icons.edit_outlined,
            size: 19,
            color: Colors.white60,
          ),
        ),
        IconButton(
          tooltip: 'Delete',
          onPressed: () =>
              _deletePaymentMethod(doc),
          icon: const Icon(
            Icons.delete_outline,
            size: 19,
            color: _danger,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // EMPTY
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 420,
        ),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.payments_outlined,
                  size: 35,
                  color: Colors.white24,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _searchTerm.isEmpty
                    ? 'No Payment Methods'
                    : 'No Matching Payment Methods',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                _searchTerm.isEmpty
                    ? 'There are no payment methods configured yet.'
                    : 'Try a different search term.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ERROR
  // ---------------------------------------------------------------------------

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 500,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: _danger,
                size: 45,
              ),
              const SizedBox(height: 15),
              const Text(
                'Unable to load payment methods',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DATE FORMAT
  // ---------------------------------------------------------------------------

  String _formatDate(dynamic value) {
    if (value == null) return '-';

    DateTime? date;

    if (value is Timestamp) {
      date = value.toDate();
    } else if (value is DateTime) {
      date = value;
    } else {
      date = DateTime.tryParse(
        value.toString(),
      );
    }

    if (date == null) return '-';

    return DateFormat(
      'dd MMM yyyy',
    ).format(date);
  }
}

// =============================================================================
// EDIT PAYMENT METHOD DIALOG
// =============================================================================

class _EditPaymentMethodDialog extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController accountTypeController;
  final TextEditingController subTypeController;
  final List<String> linkedAccounts;

  const _EditPaymentMethodDialog({
    required this.nameController,
    required this.accountTypeController,
    required this.subTypeController,
    required this.linkedAccounts,
  });

  @override
  State<_EditPaymentMethodDialog> createState() =>
      _EditPaymentMethodDialogState();
}

class _EditPaymentMethodDialogState
    extends State<_EditPaymentMethodDialog> {
  late List<String> accounts;

  final TextEditingController _accountController =
  TextEditingController();

  @override
  void initState() {
    super.initState();

    accounts = List<String>.from(
      widget.linkedAccounts,
    );
  }

  @override
  void dispose() {
    _accountController.dispose();
    super.dispose();
  }

  void _addAccount() {
    final value =
    _accountController.text.trim();

    if (value.isEmpty) return;

    if (!accounts.contains(value)) {
      setState(() {
        accounts.add(value);
      });
    }

    _accountController.clear();
  }

  void _removeAccount(String account) {
    setState(() {
      accounts.remove(account);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor:
      const Color(0xFF182232),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      title: const Text(
        'Edit Payment Method',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(
                controller:
                widget.nameController,
                label: 'Payment Method Name',
                icon: Icons.payments_outlined,
              ),

              const SizedBox(height: 12),

              _field(
                controller:
                widget.accountTypeController,
                label: 'Account Type',
                icon:
                Icons.account_balance_outlined,
              ),

              const SizedBox(height: 12),

              _field(
                controller:
                widget.subTypeController,
                label: 'Sub Type',
                icon: Icons.category_outlined,
              ),

              const SizedBox(height: 18),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Linked Accounts',
                  style: TextStyle(
                    color: Colors.white.withOpacity(.65),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: accounts.map((account) {
                  return Chip(
                    label: Text(
                      account,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                    backgroundColor:
                    Colors.white.withOpacity(.06),
                    deleteIcon: const Icon(
                      Icons.close,
                      color: Colors.white54,
                      size: 16,
                    ),
                    onDeleted: () =>
                        _removeAccount(account),
                  );
                }).toList(),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller:
                      _accountController,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      onSubmitted: (_) =>
                          _addAccount(),
                      decoration: InputDecoration(
                        hintText:
                        'Add linked account',
                        hintStyle:
                        const TextStyle(
                          color: Colors.white30,
                        ),
                        filled: true,
                        fillColor:
                        Colors.white.withOpacity(.05),
                        border:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(9),
                          borderSide:
                          BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addAccount,
                    style: IconButton.styleFrom(
                      backgroundColor:
                      const Color(0xFF3B82F6),
                    ),
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context, false),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Colors.white54,
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () =>
              Navigator.pop(context, true),
          icon: const Icon(
            Icons.save_outlined,
            size: 18,
          ),
          label: const Text('Save Changes'),
          style: ElevatedButton.styleFrom(
            backgroundColor:
            const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.white54,
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.white38,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(
            color: Colors.white10,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(
            color: Color(0xFF3B82F6),
          ),
        ),
      ),
    );
  }
}