import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../auth/auth_controller.dart';
import '../theme.dart';
import '../success_dialog.dart';
import 'item_widgets.dart';
import 'swap_controller.dart';
import 'swap_models.dart';

class ItemFormPage extends StatefulWidget {
  const ItemFormPage({super.key, this.item});
  final SwapItem? item;

  @override
  State<ItemFormPage> createState() => _ItemFormPageState();
}

class _ItemFormPageState extends State<ItemFormPage> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _wanted;
  late String _category;
  late String _condition;
  XFile? _photo;
  bool _classifying = false;
  String? _suggestion;
  final _swap = Get.find<SwapController>();

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.item?.title ?? '');
    _description = TextEditingController(text: widget.item?.description ?? '');
    _wanted = TextEditingController(text: widget.item?.wanted ?? '');
    _category = widget.item?.category ?? 'أخرى';
    _condition = widget.item?.condition ?? 'جيدة';
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _wanted.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 78,
        maxWidth: 1400,
        requestFullMetadata: false,
      );
      if (image == null || !mounted) return;
      setState(() {
        _photo = image;
        _classifying = true;
        _suggestion = null;
      });
      try {
        final category = await _swap.repository.suggestCategory(image.path);
        if (!mounted) return;
        if (category != null) {
          setState(() {
            _category = category;
            _suggestion = category;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(
            () =>
                _suggestion = 'لم نتمكن من التصنيف تلقائيًا. اختر الفئة بنفسك.',
          );
        }
      } finally {
        if (mounted) setState(() => _classifying = false);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر اختيار الصورة. حاول مرة أخرى.')),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_photo == null && widget.item?.imageBytes == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('أضف صورة واضحة للغرض.')));
      return;
    }
    final user = Get.find<AuthController>().user.value!;
    final error = await _swap.run(
      () => _swap.repository.saveItem(
        uid: user.uid,
        ownerName: user.displayName?.trim().isNotEmpty == true
            ? user.displayName!.trim()
            : 'عضو بدل',
        title: _title.text,
        description: _description.text,
        category: _category,
        condition: _condition,
        wanted: _wanted.text,
        imagePath: _photo?.path,
        existing: widget.item,
      ),
    );
    if (!mounted) return;
    if (error == null) {
      await showBadalSuccessDialog(
        title: widget.item == null
            ? 'تم نشر الغرض بنجاح!'
            : 'تم حفظ التعديلات بنجاح!',
        message: widget.item == null
            ? 'أصبح غرضك في خزانتك وجاهزًا للمقايضة.'
            : 'تحديثات الغرض محفوظة في خزانتك.',
        buttonLabel: 'العودة إلى خزانتي',
      );
      if (mounted) Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.item == null ? 'أضف غرضًا' : 'تعديل الغرض'),
      backgroundColor: BadalColors.cream,
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: _pickPhoto,
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      height: 215,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: BadalColors.mint,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: BadalColors.line),
                      ),
                      child: _photo != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Image.file(
                                File(_photo!.path),
                                fit: BoxFit.cover,
                              ),
                            )
                          : widget.item?.imageBytes != null
                          ? ItemImage(widget.item!.imageBytes, height: 215)
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 46,
                                  color: BadalColors.pine,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'أضف صورة للغرض',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: BadalColors.forest,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  if (_classifying)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'نحلل الصورة لاقتراح الفئة...',
                        style: TextStyle(color: BadalColors.pine),
                      ),
                    ),
                  if (_suggestion != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _suggestion == _category
                            ? 'اقتراح التصنيف الذكي: $_suggestion · يمكنك تغييره'
                            : _suggestion!,
                        style: const TextStyle(color: BadalColors.pine),
                      ),
                    ),
                  const SizedBox(height: 23),
                  const _Label('اسم الغرض'),
                  TextFormField(
                    controller: _title,
                    maxLength: 80,
                    decoration: const InputDecoration(
                      hintText: 'مثلًا: سماعات بحالة ممتازة',
                    ),
                    validator: (v) => v == null || v.trim().length < 3
                        ? 'اكتب اسمًا واضحًا للغرض'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  const _Label('الوصف'),
                  TextFormField(
                    controller: _description,
                    maxLines: 3,
                    maxLength: 600,
                    decoration: const InputDecoration(
                      hintText: 'اذكر التفاصيل وأي عيوب أو ملحقات',
                    ),
                    validator: (v) => v == null || v.trim().length < 10
                        ? 'أضف وصفًا من 10 أحرف على الأقل'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  const _Label('الفئة'),
                  DropdownButtonFormField<String>(
                    key: ValueKey(_category),
                    initialValue: _category,
                    decoration: const InputDecoration(),
                    items: itemCategories
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _category = value ?? _category),
                  ),
                  const SizedBox(height: 19),
                  const _Label('الحالة'),
                  DropdownButtonFormField<String>(
                    initialValue: _condition,
                    decoration: const InputDecoration(),
                    items: itemConditions
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _condition = value ?? _condition),
                  ),
                  const SizedBox(height: 19),
                  const _Label('ما الذي تود الحصول عليه؟'),
                  TextFormField(
                    controller: _wanted,
                    maxLength: 120,
                    decoration: const InputDecoration(
                      hintText: 'مثلًا: كتب أو أدوات منزلية',
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'اذكر ما يناسبك في المقابل'
                        : null,
                  ),
                  const SizedBox(height: 18),
                  Obx(
                    () => ElevatedButton(
                      onPressed: _swap.busy.value || _classifying
                          ? null
                          : _save,
                      child: _swap.busy.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              widget.item == null
                                  ? 'نشر الغرض'
                                  : 'حفظ التعديلات',
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        color: BadalColors.ink,
      ),
    ),
  );
}
