import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:screenshot/screenshot.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../services/export_service.dart';
import '../services/font_support_checker.dart';

class TextEditorScreen extends StatefulWidget {
  const TextEditorScreen({super.key});

  @override
  State<TextEditorScreen> createState() => _TextEditorScreenState();
}

class _TextEditorScreenState extends State<TextEditorScreen> {
  final quill.QuillController _controller = quill.QuillController.basic();
  final ScreenshotController _screenshotController = ScreenshotController();
  final FocusNode _focusNode = FocusNode();

  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderline = false;
  Color _currentColor = Colors.black;
  String _currentFont = 'NotoSansDevanagari';
  double _fontSize = 16.0;

  bool _containsHindi = false;
  bool _containsGondi = false;
  bool _gondiSupported = false;

  @override
  void initState() {
    super.initState();
    _checkFontSupport();
    _controller.addListener(_onTextChanged);
  }

  Future<void> _checkFontSupport() async {
    final supported = await FontSupportChecker.supportsMasaramGondi();
    setState(() {
      _gondiSupported = supported;
    });
  }

  void _onTextChanged() {
    final text = _controller.document.toPlainText();
    setState(() {
      _containsHindi = FontSupportChecker.containsHindiCharacters(text);
      _containsGondi = FontSupportChecker.containsGondiCharacters(text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleBold() {
    setState(() => _isBold = !_isBold);
    _controller.formatSelection(quill.Attribute.bold);
  }

  void _toggleItalic() {
    setState(() => _isItalic = !_isItalic);
    _controller.formatSelection(quill.Attribute.italic);
  }

  void _toggleUnderline() {
    setState(() => _isUnderline = !_isUnderline);
    _controller.formatSelection(quill.Attribute.underline);
  }

  void _changeColor(Color color) {
    setState(() => _currentColor = color);
    _controller.formatSelection(
      quill.ColorAttribute(
        '#${color.toARGB32().toRadixString(16).substring(2)}',
      ),
    );
  }

  void _changeFontFamily(String font) {
    setState(() => _currentFont = font);
    _controller.formatSelection(quill.FontAttribute(font));
  }

  void _changeFontSize(double size) {
    setState(() => _fontSize = size);
    _controller.formatSelection(quill.SizeAttribute(size.toString()));
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _currentColor,
            onColorChanged: (color) {
              setState(() => _currentColor = color);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _changeColor(_currentColor);
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showFontPicker() {
    final fonts = [
      'Roboto',
      'NotoSansDevanagari',
      'NotoSansMasaramGondi',
      'Arial',
      'Times New Roman',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Font'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: fonts.map((font) {
            return ListTile(
              title: Text(font, style: TextStyle(fontFamily: font)),
              selected: _currentFont == font,
              onTap: () {
                _changeFontFamily(font);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showSaveOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('Save as TXT'),
              onTap: () {
                Navigator.pop(context);
                _saveAsTxt();
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Save as PDF'),
              onTap: () {
                Navigator.pop(context);
                _saveAsPdf();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Save as PNG'),
              onTap: () {
                Navigator.pop(context);
                _saveAsPng();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAsTxt() async {
    final text = _controller.document.toPlainText();
    final fileName = 'document_${DateTime.now().millisecondsSinceEpoch}';

    final file = await ExportService.saveAsTxt(text, fileName);

    if (file != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved as ${file.path}'),
          action: SnackBarAction(
            label: 'Share',
            onPressed: () => ExportService.shareFile(file),
          ),
        ),
      );
    }
  }

  Future<void> _saveAsPdf() async {
    final text = _controller.document.toPlainText();
    final fileName = 'document_${DateTime.now().millisecondsSinceEpoch}';

    final file = await ExportService.saveAsPdf(
      text,
      fileName,
      containsHindi: _containsHindi,
      containsGondi: _containsGondi,
    );

    if (file != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved as ${file.path}'),
          action: SnackBarAction(
            label: 'Share',
            onPressed: () => ExportService.shareFile(file),
          ),
        ),
      );
    }
  }

  Future<void> _saveAsPng() async {
    final imageBytes = await _screenshotController.capture();

    if (imageBytes != null) {
      final fileName = 'document_${DateTime.now().millisecondsSinceEpoch}';
      final file = await ExportService.saveAsPng(imageBytes, fileName);

      if (file != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Saved to gallery'),
            action: SnackBarAction(
              label: 'Share',
              onPressed: () => ExportService.shareFile(file),
            ),
          ),
        );
      }
    }
  }

  Future<void> _smartShare() async {
    final text = _controller.document.toPlainText();
    await ExportService.smartShare(text, _screenshotController);
  }

  void _copyText() {
    final text = _controller.document.toPlainText();
    if (text.isNotEmpty) {
      // Copy to clipboard
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Text copied to clipboard')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Editor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyText,
            tooltip: 'Copy',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _smartShare,
            tooltip: 'Share',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _showSaveOptions,
            tooltip: 'Save',
          ),
        ],
      ),
      body: Column(
        children: [
          // Font support indicator
          if (_containsGondi)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: _gondiSupported ? Colors.green : Colors.orange,
              child: Row(
                children: [
                  Icon(
                    _gondiSupported ? Icons.check_circle : Icons.warning,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _gondiSupported
                          ? 'Gondi font supported - will share as text'
                          : 'Gondi font not supported - will share as image',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

          // Formatting toolbar
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  // Font selector
                  _buildToolbarButton(
                    icon: Icons.font_download,
                    label: _currentFont,
                    onPressed: _showFontPicker,
                  ),
                  const SizedBox(width: 8),

                  // Font size
                  _buildToolbarButton(
                    icon: Icons.format_size,
                    label: _fontSize.round().toString(),
                    onPressed: () => _showFontSizePicker(),
                  ),
                  const SizedBox(width: 8),

                  const VerticalDivider(),
                  const SizedBox(width: 8),

                  // Bold
                  _buildToolbarIconButton(
                    icon: Icons.format_bold,
                    isActive: _isBold,
                    onPressed: _toggleBold,
                  ),

                  // Italic
                  _buildToolbarIconButton(
                    icon: Icons.format_italic,
                    isActive: _isItalic,
                    onPressed: _toggleItalic,
                  ),

                  // Underline
                  _buildToolbarIconButton(
                    icon: Icons.format_underlined,
                    isActive: _isUnderline,
                    onPressed: _toggleUnderline,
                  ),

                  const SizedBox(width: 8),
                  const VerticalDivider(),
                  const SizedBox(width: 8),

                  // Color picker
                  _buildColorButton(),

                  const SizedBox(width: 8),

                  // Alignment
                  _buildToolbarIconButton(
                    icon: Icons.format_align_left,
                    onPressed: () => _controller.formatSelection(
                      quill.Attribute.leftAlignment,
                    ),
                  ),
                  _buildToolbarIconButton(
                    icon: Icons.format_align_center,
                    onPressed: () => _controller.formatSelection(
                      quill.Attribute.centerAlignment,
                    ),
                  ),
                  _buildToolbarIconButton(
                    icon: Icons.format_align_right,
                    onPressed: () => _controller.formatSelection(
                      quill.Attribute.rightAlignment,
                    ),
                  ),

                  const SizedBox(width: 8),
                  const VerticalDivider(),
                  const SizedBox(width: 8),

                  // Lists
                  _buildToolbarIconButton(
                    icon: Icons.format_list_bulleted,
                    onPressed: () =>
                        _controller.formatSelection(quill.Attribute.ul),
                  ),
                  _buildToolbarIconButton(
                    icon: Icons.format_list_numbered,
                    onPressed: () =>
                        _controller.formatSelection(quill.Attribute.ol),
                  ),

                  const SizedBox(width: 8),
                  const VerticalDivider(),
                  const SizedBox(width: 8),

                  // Clear formatting
                  _buildToolbarIconButton(
                    icon: Icons.format_clear,
                    onPressed: () {
                      _controller.formatSelection(
                        quill.Attribute.clone(quill.Attribute.bold, null),
                      );
                      setState(() {
                        _isBold = false;
                        _isItalic = false;
                        _isUnderline = false;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // Editor area
          Expanded(
            child: Screenshot(
              controller: _screenshotController,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    textTheme: Theme.of(context).textTheme.apply(
                      fontFamily: 'NotoSansDevanagari',
                      fontFamilyFallback: ['NotoSansMasaramGondi', 'Roboto'],
                    ),
                  ),
                  child: quill.QuillEditor.basic(
                    controller: _controller,
                    focusNode: _focusNode,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
      ),
    );
  }

  Widget _buildToolbarIconButton({
    required IconData icon,
    bool isActive = false,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      color: isActive
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.onSurfaceVariant,
      style: IconButton.styleFrom(
        backgroundColor: isActive
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
      ),
    );
  }

  Widget _buildColorButton() {
    return InkWell(
      onTap: _showColorPicker,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _currentColor,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(Icons.palette, color: Colors.white, size: 20),
      ),
    );
  }

  void _showFontSizePicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Font Size'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  value: _fontSize,
                  min: 10,
                  max: 48,
                  divisions: 38,
                  label: _fontSize.round().toString(),
                  onChanged: (value) {
                    setState(() => _fontSize = value);
                  },
                ),
                Text(
                  'Size: ${_fontSize.round()}',
                  style: TextStyle(fontSize: _fontSize),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _changeFontSize(_fontSize);
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
