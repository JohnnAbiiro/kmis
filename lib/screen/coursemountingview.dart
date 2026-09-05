import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/dbmodels/coursemountmodel.dart';
import '../controller/myprovider.dart';
import 'coursemounting.dart';

class ViewCourseMountingPage extends StatefulWidget {
  final bool embedded;
  const ViewCourseMountingPage({super.key, this.embedded = false});

  @override
  State<ViewCourseMountingPage> createState() => _ViewCourseMountingPageState();
}

class _ViewCourseMountingPageState extends State<ViewCourseMountingPage> {
  bool _loading = true;
  String _search = '';
  List<CourseMountModel> _mounts = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final provider = context.read<Myprovider>();
    if (provider.schoolid.trim().isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final snapshot = await provider.db
        .collection('courseMounting')
        .where('schoolId', isEqualTo: provider.schoolid)
        .get();
    if (!mounted) return;
    setState(() {
      _mounts = snapshot.docs.map((d) => CourseMountModel.fromMap({...d.data(), 'id': d.id})).toList();
      _loading = false;
    });
  }

  Future<void> _openMount({CourseMountModel? initial}) async {
    final result = await Navigator.of(context).push<CourseMountModel>(
      MaterialPageRoute(builder: (_) => CourseMountingPage(initial: initial)),
    );
    if (result != null) _load();
  }

  Future<void> _delete(CourseMountModel model) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete mount?'),
        content: Text('Remove the mounted courses for ${model.classOrLevel}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;
    await context.read<Myprovider>().db.collection('courseMounting').doc(model.id).delete();
    _load();
  }

  Future<void> _viewDetails(CourseMountModel model) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${model.classOrLevel} mounted courses'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Core: ${model.coreCourseCodes.join(', ')}'),
              const SizedBox(height: 8),
              Text('Elective: ${model.electiveCourseCodes.join(', ')}'),
              const SizedBox(height: 8),
              Text('Total credits: ${model.totalCredits.toStringAsFixed(2)}'),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final filtered = _mounts.where((m) {
      final text = '${m.classOrLevel} ${m.departmentId} ${m.allCourseCodes.join(' ')}'.toLowerCase();
      return text.contains(_search.toLowerCase());
    }).toList();
    final provider =context.read<Myprovider>();
    if (provider.schoolid.trim().isEmpty) {
      return const Center(child: Text('No school selected yet.'));
    }
    final body = _loading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Course mounting', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              FilledButton.icon(onPressed: () => _openMount(), icon: const Icon(Icons.add), label: const Text('Add mount')),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: const InputDecoration(labelText: 'Search mounted records', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: filtered.isEmpty
                ? Center(child: Text('No mounted records yet.', style: TextStyle(color: scheme.onSurfaceVariant)))
                : ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final m = filtered[i];
                return Card(
                  child: ListTile(
                    title: Text('${m.classOrLevel}  |  ${m.allCourseCodes.join(', ')}'),
                    subtitle: Text('Department: ${m.departmentId} • Credits: ${m.totalCredits.toStringAsFixed(2)}'),
                    trailing: Wrap(
                      children: [
                        IconButton(icon: const Icon(Icons.visibility_outlined), tooltip: 'View', onPressed: () => _viewDetails(m)),
                        IconButton(icon: const Icon(Icons.edit_outlined), tooltip: 'Edit', onPressed: () => _openMount(initial: m)),
                        IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), tooltip: 'Delete', onPressed: () => _delete(m)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );

    if (widget.embedded) return body;
    return Scaffold(appBar: AppBar(title: const Text('Course mounting')), body: body);
  }
}