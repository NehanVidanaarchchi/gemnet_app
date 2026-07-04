import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/gem_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/loading_widget.dart';
import 'gem_detail_screen.dart';

/// Public gem certificate lookup by short Gem ID (e.g. GEM-A1B2C3).
/// [embedded] = true when shown as a tab inside BuyerHomeScreen.
class CertificateLookupScreen extends StatefulWidget {
  final bool embedded;
  const CertificateLookupScreen({super.key, this.embedded = false});

  @override
  State<CertificateLookupScreen> createState() => _CertificateLookupScreenState();
}

class _CertificateLookupScreenState extends State<CertificateLookupScreen> {
  final _controller = TextEditingController();
  final _firestore = FirestoreService();
  bool _loading = false;
  String? _error;
  GemModel? _result;

  Future<void> _lookup() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final gem = await _firestore.fetchGemByPublicId(_controller.text.trim());
      if (gem == null) {
        setState(() => _error = 'No gem found for that certificate ID.');
      } else {
        setState(() => _result = gem);
      }
    } catch (e) {
      setState(() => _error = 'Something went wrong. Try again.');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.embedded) const SizedBox(height: 8),
          const Text('Verify a Certificate', style: TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Enter the Gem ID printed on the certificate (e.g. GEM-A1B2C3) to view authentic listing details.',
              style: TextStyle(color: AppColors.midGrey, fontSize: 13)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(color: AppColors.white),
                  decoration: const InputDecoration(hintText: 'GEM-XXXXXX'),
                  onSubmitted: (_) => _lookup(),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _loading ? null : _lookup,
                child: const Icon(Icons.search),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_loading) const InlineLoading(),
          if (_error != null) Text(_error!, style: const TextStyle(color: AppColors.error)),
          if (_result != null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.diamond, color: AppColors.white),
                title: Text(_result!.title.isNotEmpty ? _result!.title : _result!.type,
                    style: const TextStyle(color: AppColors.white)),
                subtitle: Text('${_result!.gemId} • ${_result!.status.name}',
                    style: const TextStyle(color: AppColors.midGrey)),
                trailing: const Icon(Icons.chevron_right, color: AppColors.midGrey),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GemDetailScreen(gem: _result!))),
              ),
            ),
        ],
      ),
    );

    if (widget.embedded) return body;
    return Scaffold(backgroundColor: AppColors.black, appBar: AppBar(title: const Text('Certificate Lookup')), body: body);
  }
}
