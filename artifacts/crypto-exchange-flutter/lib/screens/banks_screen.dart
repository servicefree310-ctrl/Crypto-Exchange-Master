import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/api.dart';

class BanksScreen extends StatefulWidget {
  const BanksScreen({super.key});
  @override
  State<BanksScreen> createState() => _BanksScreenState();
}

class _BanksScreenState extends State<BanksScreen> {
  List<dynamic> _banks = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try { _banks = await Api.banks(); } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _add() async {
    final accountHolder = TextEditingController();
    final accountNumber = TextEditingController();
    final ifsc = TextEditingController();
    final bankName = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.card,
      title: const Text('Add Bank Account', style: TextStyle(color: AppColors.fg)),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: accountHolder, style: const TextStyle(color: AppColors.fg), decoration: const InputDecoration(labelText: 'Account holder name')),
          TextField(controller: accountNumber, style: const TextStyle(color: AppColors.fg), decoration: const InputDecoration(labelText: 'Account number')),
          TextField(controller: ifsc, style: const TextStyle(color: AppColors.fg), decoration: const InputDecoration(labelText: 'IFSC')),
          TextField(controller: bankName, style: const TextStyle(color: AppColors.fg), decoration: const InputDecoration(labelText: 'Bank name')),
        ])),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Add'))],
    ));
    if (ok != true) return;
    try {
      await Api.addBank({'accountHolder': accountHolder.text, 'accountNumber': accountNumber.text, 'ifsc': ifsc.text, 'bankName': bankName.text});
      _load();
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
  }

  Future<void> _delete(dynamic id) async {
    try { await Api.deleteBank(id); _load(); }
    catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bank Accounts', style: TextStyle(fontWeight: FontWeight.w800))),
      floatingActionButton: FloatingActionButton(backgroundColor: AppColors.primary, onPressed: _add, child: const Icon(Icons.add)),
      body: _loading ? const Center(child: CircularProgressIndicator(color: AppColors.primary)) :
        _banks.isEmpty ? const Center(child: Text('No banks added yet', style: TextStyle(color: AppColors.muted))) :
        ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: _banks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (_, i) {
            final b = _banks[i];
            final acc = (b['accountNumber'] ?? '').toString();
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
              child: Row(children: [
                const Icon(Icons.account_balance, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text((b['bankName'] ?? '').toString(), style: const TextStyle(color: AppColors.fg, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('•••${acc.substring((acc.length - 4).clamp(0, acc.length))} · ${b['ifsc'] ?? ''}', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                ])),
                IconButton(icon: const Icon(Icons.delete, color: AppColors.danger), onPressed: () => _delete(b['id'])),
              ]),
            );
          },
        ),
    );
  }
}
