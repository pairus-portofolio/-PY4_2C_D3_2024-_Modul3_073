import 'package:flutter/material.dart';
import 'package:logbook_app_073/features/onboarding/onboarding_view.dart';
import 'package:logbook_app_073/features/logbook/log_controller.dart';
import 'package:logbook_app_073/features/logbook/models/log_model.dart';

const List<String> kCategories = ['Pekerjaan', 'Pribadi', 'Urgent'];

const Map<String, Color> kCategoryColors = {
  'Pekerjaan': Color(0xFF4A90D9),
  'Pribadi': Color(0xFF27AE60),
  'Urgent': Color(0xFFE74C3C),
};

const Map<String, Color> kCategoryBgColors = {
  'Pekerjaan': Color(0xFFEBF4FF),
  'Pribadi': Color(0xFFEAFAF1),
  'Urgent': Color(0xFFFDEDEC),
};

const Map<String, IconData> kCategoryIcons = {
  'Pekerjaan': Icons.work_outline,
  'Pribadi': Icons.person_outline,
  'Urgent': Icons.priority_high_rounded,
};

// ────────────────────────────────────────────────────────────
// LogView
// ────────────────────────────────────────────────────────────
class LogView extends StatefulWidget {
  final String username;

  const LogView({super.key, required this.username});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final LogController _controller = LogController();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedCategory = 'Pribadi'; // untuk dialog add/edit

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeDialog();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Dialog Selamat Datang ──────────────────────────────────
  void _showWelcomeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selamat Datang'),
          content: Text(
            'Halo ${widget.username}, selamat menggunakan Logbook!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Mulai'),
            ),
          ],
        );
      },
    );
  }

  // ── Dialog Tambah Catatan ─────────────────────────────────
  void _showAddLogDialog() {
    _titleController.clear();
    _descController.clear();
    _selectedCategory = 'Pribadi';

    showDialog(
      context: context,
      builder: (context) => _CategoryDialog(
        titleLabel: 'Tambah Catatan',
        titleController: _titleController,
        descController: _descController,
        initialCategory: _selectedCategory,
        onCancel: () => Navigator.pop(context),
        onSubmit: (category) {
          if (_titleController.text.isNotEmpty &&
              _descController.text.isNotEmpty) {
            _controller.addLog(
              _titleController.text,
              _descController.text,
              category: category,
            );
            _titleController.clear();
            _descController.clear();
            Navigator.pop(context);
          }
        },
        submitLabel: 'Simpan',
      ),
    );
  }

  // ── Dialog Edit Catatan ────────────────────────────────────
  void _showEditLogDialog(int index, LogModel log) {
    _titleController.text = log.title;
    _descController.text = log.description;
    _selectedCategory = log.category;

    showDialog(
      context: context,
      builder: (context) => _CategoryDialog(
        titleLabel: 'Edit Catatan',
        titleController: _titleController,
        descController: _descController,
        initialCategory: _selectedCategory,
        onCancel: () {
          _titleController.clear();
          _descController.clear();
          Navigator.pop(context);
        },
        onSubmit: (category) {
          if (_titleController.text.isNotEmpty &&
              _descController.text.isNotEmpty) {
            _controller.updateLog(
              index,
              _titleController.text,
              _descController.text,
              category: category,
            );
            _titleController.clear();
            _descController.clear();
            Navigator.pop(context);
          }
        },
        submitLabel: 'Update',
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LogBook: ${widget.username}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const OnboardingView()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Search TextField ──────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari catatan berdasarkan judul...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchController,
                  builder: (ctx, val, child) => val.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : const SizedBox.shrink(),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),

          // ─── Daftar Catatan ────────────────────────────────
          Expanded(
            child: ValueListenableBuilder<List<LogModel>>(
              valueListenable: _controller.logsNotifier,
              builder: (context, logs, child) {
                final filteredLogs = logs.where((log) {
                  return log.title.toLowerCase().contains(_searchQuery);
                }).toList();

                // ─ Empty State ─────────────────────────────
                if (filteredLogs.isEmpty) {
                  return _EmptyState(isSearching: _searchQuery.isNotEmpty);
                }

                // ─ List Catatan ────────────────────────────
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: filteredLogs.length,
                  itemBuilder: (context, index) {
                    final log = filteredLogs[index];
                    final color =
                        kCategoryColors[log.category] ??
                        const Color(0xFF27AE60);
                    final bgColor =
                        kCategoryBgColors[log.category] ??
                        const Color(0xFFEAFAF1);
                    final icon =
                        kCategoryIcons[log.category] ?? Icons.note_outlined;

                    return Dismissible(
                      key: ValueKey(log.title + log.date),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.delete_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Hapus',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: const Text('Hapus Catatan?'),
                                content: Text(
                                  'Catatan "${log.title}" akan dihapus secara permanen.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Batal'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            ) ??
                            false;
                      },
                      onDismissed: (direction) {
                        final originalIndex = logs.indexOf(log);
                        _controller.removeLog(originalIndex);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Catatan "${log.title}" dihapus.'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            action: SnackBarAction(
                              label: 'OK',
                              onPressed: () {},
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(
                            color: color.withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                        ),
                        elevation: 2,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            final originalIndex = logs.indexOf(log);
                            _showEditLogDialog(originalIndex, log);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Row(
                              children: [
                                // ikon kategori
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(icon, color: color, size: 26),
                                ),
                                const SizedBox(width: 14),
                                // konten
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // badge kategori
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          log.category,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: color,
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        log.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1A1A2E),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        log.description,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        log.date,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddLogDialog,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
// Widget: Empty State
// ────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isSearching;

  const _EmptyState({required this.isSearching});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ilustrasi animasi sederhana via Stack
            _IllustrationWidget(isSearching: isSearching),
            const SizedBox(height: 28),
            Text(
              isSearching ? 'Catatan Tidak Ditemukan' : 'Belum Ada Catatan',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              isSearching
                  ? 'Coba gunakan kata kunci yang berbeda.'
                  : 'Tekan tombol "Tambah" di bawah untuk membuat catatan pertamamu!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _IllustrationWidget extends StatelessWidget {
  final bool isSearching;

  const _IllustrationWidget({required this.isSearching});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Lingkaran latar belakang dekoratif
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primary.withValues(alpha: 0.07),
          ),
        ),
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primary.withValues(alpha: 0.12),
          ),
        ),
        // Ikon utama
        Icon(
          isSearching ? Icons.search_off_rounded : Icons.edit_note_rounded,
          size: 80,
          color: primary.withValues(alpha: 0.55),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────
// Widget: Dialog dengan Dropdown Kategori (StatefulWidget)
// ────────────────────────────────────────────────────────────
class _CategoryDialog extends StatefulWidget {
  final String titleLabel;
  final TextEditingController titleController;
  final TextEditingController descController;
  final String initialCategory;
  final VoidCallback onCancel;
  final void Function(String category) onSubmit;
  final String submitLabel;

  const _CategoryDialog({
    required this.titleLabel,
    required this.titleController,
    required this.descController,
    required this.initialCategory,
    required this.onCancel,
    required this.onSubmit,
    required this.submitLabel,
  });

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    final color = kCategoryColors[_selectedCategory] ?? Colors.green;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(widget.titleLabel),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─ Input Judul ────────────────────────────────────
          TextField(
            controller: widget.titleController,
            decoration: InputDecoration(
              labelText: 'Judul',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.title),
            ),
          ),
          const SizedBox(height: 14),

          // ─ Input Deskripsi ────────────────────────────────
          TextField(
            controller: widget.descController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Deskripsi',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.notes),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),

          // ─ Dropdown Kategori ──────────────────────────────
          const Text(
            'Kategori',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              prefixIcon: Icon(kCategoryIcons[_selectedCategory], color: color),
            ),
            items: kCategories.map((cat) {
              final catColor = kCategoryColors[cat]!;
              return DropdownMenuItem(
                value: cat,
                child: Row(
                  children: [
                    Icon(kCategoryIcons[cat], color: catColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      cat,
                      style: TextStyle(
                        color: catColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedCategory = value);
            },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: widget.onCancel, child: const Text('Batal')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => widget.onSubmit(_selectedCategory),
          child: Text(widget.submitLabel),
        ),
      ],
    );
  }
}
