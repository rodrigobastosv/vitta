import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vitta/app/core/localization/localization_extensions.dart';
import 'package:vitta/app/design_system/components/buttons/vt_primary_button.dart';
import 'package:vitta/app/design_system/components/general/vt_gap.dart';
import 'package:vitta/app/design_system/tokens/vt_radius.dart';
import 'package:vitta/app/design_system/tokens/vt_spacing.dart';
import 'package:vitta/app/design_system/tokens/vt_text_styles.dart';
import 'package:vitta/app/domain/diet/entities/food.dart';
import 'package:vitta/app/domain/diet/entities/food_source.dart';
import 'package:vitta/app/presentation/pages/food_search/food_search_cubit.dart';

Future<Food?> showCustomFoodSheet({required BuildContext context}) => showModalBottomSheet<Food>(
  context: context,
  isScrollControlled: true,
  builder: (sheetContext) => BlocProvider.value(value: context.read<FoodSearchCubit>(), child: const _CustomFoodSheet()),
);

class _CustomFoodSheet extends StatefulWidget {
  const _CustomFoodSheet();

  @override
  State<_CustomFoodSheet> createState() => _CustomFoodSheetState();
}

class _CustomFoodSheetState extends State<_CustomFoodSheet> {
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _fiberController = TextEditingController();
  Uint8List? _pickedImageBytes;
  String _pickedImageExtension = 'jpg';
  String? _errorMessage;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    super.dispose();
  }

  double? _parse(String text) => double.tryParse(text.replaceAll(',', '.'));

  Future<void> _pickImage() async {
    final l10n = context.l10n;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: .min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.dietTakePhotoAction),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.dietChooseFromGalleryAction),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) {
      return;
    }
    final pickedFile = await ImagePicker().pickImage(source: source, maxWidth: 1024);
    if (pickedFile == null) {
      return;
    }
    final bytes = await pickedFile.readAsBytes();
    if (!mounted) {
      return;
    }
    setState(() {
      _pickedImageBytes = bytes;
      _pickedImageExtension = pickedFile.name.contains('.') ? pickedFile.name.split('.').last : 'jpg';
    });
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final name = _nameController.text.trim();
    final calories = _parse(_caloriesController.text);
    final protein = _parse(_proteinController.text);
    final carbs = _parse(_carbsController.text);
    final fat = _parse(_fatController.text);
    final fiber = _parse(_fiberController.text);

    if (name.isEmpty || calories == null || protein == null || carbs == null || fat == null || fiber == null) {
      setState(() => _errorMessage = l10n.dietInvalidCustomFood);
      return;
    }

    final imageBytes = _pickedImageBytes;
    if (imageBytes == null) {
      _finish(
        Food(
          name: name,
          source: FoodSource.custom,
          caloriesPer100g: calories,
          proteinPer100g: protein,
          carbsPer100g: carbs,
          fatPer100g: fat,
          fiberPer100g: fiber,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final uploadResult = await context.read<FoodSearchCubit>().uploadFoodImage(bytes: imageBytes, fileExtension: _pickedImageExtension);
    final uploadError = uploadResult.when((error) => error, (_) => null);
    if (uploadError != null) {
      setState(() {
        _isSaving = false;
        _errorMessage = uploadError.message;
      });
      return;
    }

    final imageUrl = uploadResult.when((_) => null, (url) => url);
    _finish(
      Food(
        name: name,
        source: FoodSource.custom,
        caloriesPer100g: calories,
        proteinPer100g: protein,
        carbsPer100g: carbs,
        fatPer100g: fat,
        fiberPer100g: fiber,
        imageUrl: imageUrl,
      ),
    );
  }

  void _finish(Food food) {
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(food);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final imageBytes = _pickedImageBytes;
    return Padding(
      padding: EdgeInsets.only(
        left: VTSpacing.m,
        right: VTSpacing.m,
        top: VTSpacing.m,
        bottom: VTSpacing.m + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          children: [
            Text(l10n.dietCustomFoodTitle, style: VTTextStyles.title(context)),
            const VTGap.m(),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: ClipRRect(
                  borderRadius: VTRadius.borderRadiusS,
                  child: SizedBox(
                    width: 96,
                    height: 96,
                    child: imageBytes == null
                        ? ColoredBox(
                            color: colorScheme.surfaceContainerHighest,
                            child: Icon(Icons.add_a_photo_outlined, color: colorScheme.onSurfaceVariant),
                          )
                        : Image.memory(imageBytes, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
            const VTGap.m(),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: l10n.dietFoodNameLabel),
            ),
            const VTGap.s(),
            TextField(
              controller: _caloriesController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l10n.dietCaloriesPer100gLabel),
            ),
            const VTGap.s(),
            TextField(
              controller: _proteinController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l10n.dietProteinPer100gLabel),
            ),
            const VTGap.s(),
            TextField(
              controller: _carbsController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l10n.dietCarbsPer100gLabel),
            ),
            const VTGap.s(),
            TextField(
              controller: _fatController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l10n.dietFatPer100gLabel),
            ),
            const VTGap.s(),
            TextField(
              controller: _fiberController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l10n.dietFiberPer100gLabel),
            ),
            if (_errorMessage != null) ...[const VTGap.s(), Text(_errorMessage!, style: TextStyle(color: colorScheme.error))],
            const VTGap.l(),
            VTPrimaryButton(label: l10n.dietContinueAction, isLoading: _isSaving, onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
