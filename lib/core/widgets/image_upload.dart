import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../network/marketplace_api.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import 'service_image.dart';

class UploadImage {
  const UploadImage(this.bytes, this.name);
  final Uint8List bytes;
  final String name;
  MultipartFile multipart() => MultipartFile.fromBytes(
    bytes,
    filename: name,
    contentType: MultipartFile.lookupMediaType(name),
  );
}

Future<UploadImage?> chooseImage(
  BuildContext context, {
  required int maxMegabytes,
}) async {
  final picker = ImagePicker();
  XFile? chosen;
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    final lost = await picker.retrieveLostData();
    if (lost.exception != null) {
      throw const ApiFailure(
        'Unable to recover the selected image. Please choose it again.',
      );
    }
    if (lost.files?.isNotEmpty == true) chosen = lost.files!.first;
  }
  chosen ??= await picker.pickImage(
    source: ImageSource.gallery,
    requestFullMetadata: false,
  );
  if (chosen == null) return null;
  if (await chosen.length() > maxMegabytes * 1024 * 1024) {
    throw ApiFailure('Choose an image smaller than $maxMegabytes MB.');
  }
  final image = UploadImage(await chosen.readAsBytes(), chosen.name);
  if (!context.mounted) return null;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Use this image?'),
      content: Image.memory(
        image.bytes,
        height: 220,
        width: 220,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const Text('Image preview unavailable'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Use image'),
        ),
      ],
    ),
  );
  return confirmed == true ? image : null;
}

class AvatarEditor extends StatefulWidget {
  const AvatarEditor({
    super.key,
    required this.path,
    required this.onChanged,
    this.onTap,
  });
  final String path;
  final ValueChanged<String> onChanged;
  final VoidCallback? onTap;
  @override
  State<AvatarEditor> createState() => _AvatarEditorState();
}

class _AvatarEditorState extends State<AvatarEditor> {
  bool _busy = false;
  String? _uploaded;
  Future<void> _change() async {
    if (_busy) return;
    if (widget.onTap != null) {
      widget.onTap!();
      return;
    }
    setState(() => _busy = true);
    try {
      final image = await chooseImage(context, maxMegabytes: 4);
      if (image == null) return;
      final api = MarketplaceApi();
      await api.request(
        'me/avatar',
        method: 'POST',
        data: FormData.fromMap({'avatar': image.multipart()}),
      );
      final me = apiMap(await api.request('me'));
      if (!mounted) return;
      final avatar = apiText(me['avatar']);
      setState(() => _uploaded = avatar);
      widget.onChanged(avatar);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = responsiveWidth(context, 140);
    return Center(
      child: Semantics(
        button: true,
        label: 'Change profile photo',
        child: GestureDetector(
          onTap: _busy ? null : _change,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(responsiveWidth(context, 44)),
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ServiceImage(_uploaded ?? widget.path, isAvatar: true),
                  ColoredBox(color: AppColors.dark.withAlpha(145)),
                  Center(
                    child: _busy
                        ? const CircularProgressIndicator(
                            color: AppColors.surface,
                          )
                        : Icon(
                            Icons.camera_alt_outlined,
                            color: AppColors.surface,
                            size: responsiveWidth(context, 32),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
