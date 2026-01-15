import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool _obscureBalance = false;
  String _fromAccount = 'My Wallet';
  String _toAccount = 'Senzo Pocket Money';
  final TextEditingController _amountController = TextEditingController();

  // Mock balances
  final Map<String, double> _balances = {
    'My Wallet': 12450.00,
    'Senzo Pocket Money': 5300.25,
    'Sibusiso Pocket Money': 24500.90,
  };

  // Mock recent transactions
  final List<_TxnItem> _recent = const [
    _TxnItem(title: 'Deposit', amount: 1500.00, incoming: true, date: 'Today'),
    _TxnItem(
      title: 'Internal Transfer',
      amount: 250.00,
      incoming: false,
      date: 'Yesterday',
    ),
    _TxnItem(title: 'Refund', amount: 120.00, incoming: true, date: 'Jan 02'),
    _TxnItem(
      title: 'Withdrawal',
      amount: 600.00,
      incoming: false,
      date: 'Jan 01',
    ),
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _parsedAmount {
    final raw = _amountController.text.replaceAll(',', '').trim();
    return double.tryParse(raw) ?? 0.0;
  }

  bool get _canConfirm {
    return _parsedAmount > 0 && _fromAccount != _toAccount;
  }

  void _showAccountSelectorBottomSheet({
    required String title,
    required String selectedAccount,
    required String? excludeAccount,
    required Function(String) onAccountSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _AccountSelectorBottomSheet(
        title: title,
        accounts: _balances,
        selectedAccount: selectedAccount,
        excludeAccount: excludeAccount,
        onAccountSelected: onAccountSelected,
      ),
    );
  }

  void _onConfirm() {
    // In production, trigger transfer flow here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Transferring R ${_parsedAmount.toStringAsFixed(2)} from $_fromAccount to $_toAccount',
        ),
      ),
    );
    setState(() {
      _amountController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: const Text('Wallet'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeroCard(context),
            const SizedBox(height: 16),
            _buildInternalTransferCard(surface, onSurface, theme),
            const SizedBox(height: 24),
            Text(
              'Recent Transactions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            _buildRecentTransactions(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color.fromARGB(255, 33, 150, 243), Color.fromARGB(255,33,151,247)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Total Available Balance',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _obscureBalance
                        ? 'R ••••••'
                        : 'R ${_balances['My Wallet']!.toStringAsFixed(2)}',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () =>
                    setState(() => _obscureBalance = !_obscureBalance),
                icon: Icon(
                  _obscureBalance
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: Colors.white,
                ),
                tooltip: _obscureBalance ? 'Show balance' : 'Hide balance',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    // Deposit action
                  },
                  icon: const Icon(Icons.add_rounded, color: Colors.white),
                  label: const Text(
                    'Deposit',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.65),
                      width: 1.2,
                    ),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    // Withdraw action
                  },
                  icon: const Icon(
                    Icons.arrow_upward_rounded,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Withdraw',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
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

  Widget _buildInternalTransferCard(
    Color surface,
    Color onSurface,
    ThemeData theme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.swap_horiz_rounded, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Internal Transfer',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Transfer From
          _Labeled(
            label: 'Transfer From',
            child: _AccountSelector(
              selectedAccount: _fromAccount,
              onTap: () => _showAccountSelectorBottomSheet(
                title: 'Select source account',
                selectedAccount: _fromAccount,
                excludeAccount: _toAccount,
                onAccountSelected: (account) {
                  setState(() => _fromAccount = account);
                },
              ),
              theme: theme,
            ),
          ),

          const SizedBox(height: 8),

          // Directional arrow
          Center(
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_downward_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Transfer To
          _Labeled(
            label: 'Transfer To',
            child: _AccountSelector(
              selectedAccount: _toAccount,
              onTap: () => _showAccountSelectorBottomSheet(
                title: 'Select destination account',
                selectedAccount: _toAccount,
                excludeAccount: _fromAccount,
                onAccountSelected: (account) {
                  setState(() => _toAccount = account);
                },
              ),
              theme: theme,
            ),
          ),

          const SizedBox(height: 12),

          // Amount input
          _Labeled(
            label: 'Amount',
            child: TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^[0-9]*[\.]?[0-9]{0,2}'),
                ),
              ],
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                prefixText: 'R ',
                hintText: '0.00',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Confirm button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _canConfirm ? _onConfirm : null,
              child: const Text('Confirm Transfer'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(ThemeData theme) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = _recent[index];
        final color = item.incoming ? Colors.green : theme.colorScheme.error;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(
              item.incoming
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: color,
            ),
          ),
          title: Text(
            item.title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(item.date),
          trailing: Text(
            '${item.incoming ? '+ ' : '- '}R ${item.amount.toStringAsFixed(2)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: _recent.length,
    );
  }
}

class _AccountSelector extends StatelessWidget {
  final String selectedAccount;
  final VoidCallback onTap;
  final ThemeData theme;

  const _AccountSelector({
    required this.selectedAccount,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: theme.colorScheme.surface,
          isDense: true,
          suffixIcon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedAccount,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountSelectorBottomSheet extends StatelessWidget {
  final String title;
  final Map<String, double> accounts;
  final String selectedAccount;
  final String? excludeAccount;
  final Function(String) onAccountSelected;

  const _AccountSelectorBottomSheet({
    required this.title,
    required this.accounts,
    required this.selectedAccount,
    this.excludeAccount,
    required this.onAccountSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availableAccounts = accounts.keys
        .where((account) => account != excludeAccount)
        .toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Account list
          Flexible(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shrinkWrap: true,
              itemCount: availableAccounts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final account = availableAccounts[index];
                final isSelected = account == selectedAccount;
                final balance = accounts[account]!;

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      onAccountSelected(account);
                      Navigator.of(context).pop();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline.withValues(alpha: 0.2),
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected
                            ? theme.colorScheme.primary.withValues(alpha: 0.08)
                            : theme.colorScheme.surface,
                      ),
                      child: Row(
                        children: [
                          // Wallet icon
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary.withValues(alpha: 0.12)
                                  : theme.colorScheme.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.account_balance_wallet_outlined,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Account info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  account,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'R ${balance.toStringAsFixed(2)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Checkmark for selected account
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _Labeled extends StatelessWidget {
  final String label;
  final Widget child;
  const _Labeled({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _TxnItem {
  final String title;
  final double amount;
  final bool incoming;
  final String date;
  const _TxnItem({
    required this.title,
    required this.amount,
    required this.incoming,
    required this.date,
  });
}
