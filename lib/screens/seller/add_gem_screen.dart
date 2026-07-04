import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/app_config.dart';
import '../../services/app_state.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import '../../services/groq_service.dart';
import '../../models/gem_model.dart';
import '../../theme/app_theme.dart';

/// Add a new gem listing, or edit an existing one if [existingGem] is passed.
/// Flow for new listings: capture/pick photo -> Groq AI analyzes it ->
/// form is pre-filled -> seller edits anything -> submit for admin approval.
class AddGemScreen extends StatefulWidget {
  final GemModel? existingGem;
  const AddGemScreen({super.key, this.existingGem});

  @override
  State<AddGemScreen> createState() => _AddGemScreenState();
}

class _AddGemScreenState extends State<AddGemScreen> {
  final _picker = ImagePicker();
  final _storage = StorageService();
  final _firestore = FirestoreService();
  late final GroqService _groq = GroqService(apiKey: AppConfig.groqApiKey);

  final List<File> _newImages = [];
  List<String> _existingImageUrls = [];

  bool _analyzing = false;
  bool _saving = false;
  String? _aiError;
  Map<String, dynamic>? _aiRaw;

  final _titleCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _cutCtrl = TextEditingController();
  final _clarityCtrl = TextEditingController();
  final _transparencyCtrl = TextEditingController();
  final _originCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  String _currency = 'LKR';

  bool get _isEditing => widget.existingGem != null;

  @override
  void initState() {
    super.initState();
    final g = widget.existingGem;
    if (g != null) {
      _titleCtrl.text = g.title;
      _typeCtrl.text = g.type;
      _colorCtrl.text = g.color;
      _weightCtrl.text = g.weightCarat.toString();
      _cutCtrl.text = g.cut;
      _clarityCtrl.text = g.clarityNotes;
      _transparencyCtrl.text = g.transparency;
      _originCtrl.text = g.originGuess;
      _descCtrl.text = g.description;
      _priceCtrl.text = g.price.toString();
      _currency = g.currency;
      _existingImageUrls = List.from(g.imageUrls);
    }
  }

  Future<void> _captureAndAnalyze() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.richBlack,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AppColors.white),
              title: const Text('Take photo', style: TextStyle(color: AppColors.white)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.white),
              title: const Text('Choose from gallery', style: TextStyle(color: AppColors.white)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picked = await _picker.pickImage(source: source, imageQuality: 85, maxWidth: 1600);
    if (picked == null) return;

    final file = File(picked.path);
    setState(() {
      _newImages.add(file);
    });

    // Only auto-run AI analysis for the first photo of a brand-new listing.
    if (!_isEditing && _newImages.length == 1) {
      await _runAiAnalysis(file);
    }
  }

  Future<void> _runAiAnalysis(File file) async {
    setState(() {
      _analyzing = true;
      _aiError = null;
    });
    try {
      final result = await _groq.analyzeGemImage(file);
      _aiRaw = result;
      setState(() {
        _typeCtrl.text = (result['type'] ?? '').toString();
        _colorCtrl.text = (result['color'] ?? '').toString();
        final w = result['estimatedWeightCarat'];
        _weightCtrl.text = w == null ? '' : w.toString();
        _cutCtrl.text = (result['cut'] ?? '').toString();
        _clarityCtrl.text = (result['clarityNotes'] ?? '').toString();
        _transparencyCtrl.text = (result['transparency'] ?? '').toString();
        _originCtrl.text = (result['originGuess'] ?? '').toString();
        _descCtrl.text = (result['description'] ?? '').toString();
        if (_titleCtrl.text.isEmpty) {
          _titleCtrl.text = (result['type'] ?? '').toString();
        }
      });
    } catch (e) {
      setState(() => _aiError = e.toString());
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  Future<void> _save() async {
    final me = context.read<AppState>().currentUserProfile;
    if (me == null) return;

    if (_typeCtrl.text.trim().isEmpty || _priceCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in at least type and price.')));
      return;
    }
    if (_existingImageUrls.isEmpty && _newImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one photo.')));
      return;
    }

    setState(() => _saving = true);
    try {
      final uploadedUrls = _newImages.isEmpty ? <String>[] : await _storage.uploadGemImages(_newImages, me.uid);
      final allImages = [..._existingImageUrls, ...uploadedUrls];

      final gem = GemModel(
        id: '',
        gemId: widget.existingGem?.gemId ?? '',
        sellerId: me.uid,
        sellerName: me.name,
        title: _titleCtrl.text.trim(),
        type: _typeCtrl.text.trim(),
        color: _colorCtrl.text.trim(),
        weightCarat: double.tryParse(_weightCtrl.text.trim()) ?? 0,
        cut: _cutCtrl.text.trim(),
        clarityNotes: _clarityCtrl.text.trim(),
        transparency: _transparencyCtrl.text.trim(),
        originGuess: _originCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        price: double.tryParse(_priceCtrl.text.trim()) ?? 0,
        currency: _currency,
        imageUrls: allImages,
        status: GemStatus.pending, // (re)submissions always go through admin review
        aiRaw: _aiRaw,
        createdAt: DateTime.now(),
      );

      if (_isEditing) {
        await _firestore.updateGem(widget.existingGem!.id, gem.toMap());
      } else {
        await _firestore.addGem(gem);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing submitted for admin approval.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(title: Text(_isEditing ? 'Edit Gem' : 'Add Gem')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _imagesRow(),
          const SizedBox(height: 10),
          if (_analyzing)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white)),
                  SizedBox(width: 12),
                  Text('Groq AI is analyzing your gem photo...', style: TextStyle(color: AppColors.lightGrey)),
                ],
              ),
            ),
          if (_aiError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text('AI analysis failed: $_aiError\nYou can still fill the form manually.',
                  style: const TextStyle(color: AppColors.error, fontSize: 12)),
            ),
          if (_aiRaw != null && _aiRaw!['confidence'] != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text('AI confidence: ${_aiRaw!['confidence']}% — please review and correct all fields below.',
                  style: const TextStyle(color: AppColors.warning, fontSize: 12)),
            ),
          _field('Listing title', _titleCtrl),
          _field('Gem type (e.g. Blue Sapphire)', _typeCtrl),
          _field('Color', _colorCtrl),
          Row(
            children: [
              Expanded(child: _field('Weight (carat)', _weightCtrl, keyboard: TextInputType.number)),
              const SizedBox(width: 10),
              Expanded(child: _field('Cut / shape', _cutCtrl)),
            ],
          ),
          _field('Clarity notes', _clarityCtrl, maxLines: 2),
          _field('Transparency', _transparencyCtrl),
          _field('Origin (estimate)', _originCtrl),
          _field('Description', _descCtrl, maxLines: 4),
          Row(
            children: [
              Expanded(flex: 2, child: _field('Price', _priceCtrl, keyboard: TextInputType.number)),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _currency,
                  dropdownColor: AppColors.richBlack,
                  style: const TextStyle(color: AppColors.white),
                  items: const [
                    DropdownMenuItem(value: 'LKR', child: Text('LKR')),
                    DropdownMenuItem(value: 'USD', child: Text('USD')),
                  ],
                  onChanged: (v) => setState(() => _currency = v ?? 'LKR'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.black))
                : Text(_isEditing ? 'Save changes' : 'Submit for approval'),
          ),
          const SizedBox(height: 12),
          const Text(
            'New and edited listings are reviewed by an admin before appearing to buyers.',
            style: TextStyle(color: AppColors.midGrey, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _imagesRow() {
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ..._existingImageUrls.map((url) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(url, width: 90, height: 90, fit: BoxFit.cover),
                ),
              )),
          ..._newImages.map((f) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(f, width: 90, height: 90, fit: BoxFit.cover),
                ),
              )),
          GestureDetector(
            onTap: _captureAndAnalyze,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.charcoal,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.darkGrey),
              ),
              child: const Icon(Icons.add_a_photo_outlined, color: AppColors.midGrey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {int maxLines = 1, TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboard,
        style: const TextStyle(color: AppColors.white),
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
