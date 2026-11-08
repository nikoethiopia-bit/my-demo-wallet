import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SetupScreen(),
  ));
}

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  File? _picOne;
  File? _picTwo;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(int imageNumber) async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (imageNumber == 1) {
          _picOne = File(picked.path);
        } else {
          _picTwo = File(picked.path);
        }
      });
    }
  }

  void _startFullscreen() {
    if (_picOne == null || _picTwo == null) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => FullscreenViewer(picOne: _picOne!, picTwo: _picTwo!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool ready = _picOne != null && _picTwo != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Select Images')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImage(1),
              icon: Icon(_picOne == null ? Icons.image : Icons.check_circle),
              label: Text(_picOne == null ? 'Select Pic 1' : 'Pic 1 Selected'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _pickImage(2),
              icon: Icon(_picTwo == null ? Icons.image : Icons.check_circle),
              label: Text(_picTwo == null ? 'Select Pic 2' : 'Pic 2 Selected'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
            const SizedBox(height: 40),
            FilledButton(
              onPressed: ready ? _startFullscreen : null,
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(18)),
              child: const Text('START', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

class FullscreenViewer extends StatefulWidget {
  final File picOne;
  final File picTwo;

  const FullscreenViewer({
    super.key,
    required this.picOne,
    required this.picTwo,
  });

  @override
  State<FullscreenViewer> createState() => _FullscreenViewerState();
}

class _FullscreenViewerState extends State<FullscreenViewer> {
  bool _isLockedToPicTwo = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _onScreenTap() {
    if (!_isLockedToPicTwo) {
      setState(() {
        _isLockedToPicTwo = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onScreenTap,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SizedBox.expand(
            child: Image.file(
              _isLockedToPicTwo ? widget.picTwo : widget.picOne,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
