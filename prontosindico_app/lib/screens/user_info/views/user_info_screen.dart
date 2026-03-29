import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prontosindico/constants.dart';
import 'package:prontosindico/components/app_drawer.dart';
import 'package:prontosindico/providers/user_profile_providers.dart';
import 'package:prontosindico/ui/features/user_profile/states/user_profile_state.dart';

class UserInfoScreen extends ConsumerStatefulWidget {
  const UserInfoScreen({super.key});

  @override
  ConsumerState<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends ConsumerState<UserInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl = TextEditingController();
  late final TextEditingController _phoneCtrl = TextEditingController();
  bool _isEditing = false;
  bool _controllersPopulated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProfileControllerProvider.notifier).loadProfile();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _populateControllers(UserProfileLoaded data) {
    if (!_controllersPopulated) {
      _nameCtrl.text = data.name;
      _phoneCtrl.text = data.phone;
      _controllersPopulated = true;
    }
  }

  void _enterEditMode(UserProfileLoaded data) {
    _nameCtrl.text = data.name;
    _phoneCtrl.text = data.phone;
    setState(() => _isEditing = true);
  }

  void _cancelEdit(UserProfileLoaded data) {
    _nameCtrl.text = data.name;
    _phoneCtrl.text = data.phone;
    setState(() => _isEditing = false);
  }

  Future<void> _pickAndCropPhoto(BuildContext context) async {
    final source = await _showImageSourceDialog(context);
    if (source == null) return;

    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;

    if (!mounted) return;
    ref
        .read(userProfileControllerProvider.notifier)
        .updatePhoto(File(picked.path));
  }

  Future<ImageSource?> _showImageSourceDialog(BuildContext context) async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(defaultBorderRadious * 2),
        ),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: defaultPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: defaultPadding),
                decoration: BoxDecoration(
                  color: blackColor20,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Alterar foto de perfil',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(defaultBorderRadious),
                  ),
                  child: const Icon(Icons.camera_alt, color: primaryColor),
                ),
                title: const Text('Câmera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(defaultBorderRadious),
                  ),
                  child: const Icon(Icons.photo_library, color: primaryColor),
                ),
                title: const Text('Galeria'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userProfileControllerProvider);

    ref.listen<UserProfileState>(userProfileControllerProvider, (_, next) {
      switch (next) {
        case UserProfileLoaded():
          _populateControllers(next);
        case UserProfileSaved():
          _populateControllers(next.data);
          setState(() {
            _isEditing = false;
            _controllersPopulated = false;
          });
          _populateControllers(next.data);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil atualizado com sucesso!'),
              backgroundColor: successColor,
            ),
          );
        case UserProfileError():
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.message),
              backgroundColor: errorColor,
            ),
          );
        default:
          break;
      }
    });

    return Scaffold(
      backgroundColor: backgroundLightColor,
      drawer: const AppDrawer(),
      appBar: _buildAppBar(state),
      body: _buildBody(context, state),
    );
  }

  AppBar _buildAppBar(UserProfileState state) {
    final loaded = _extractLoaded(state);
    final isSaving = state is UserProfileSaving;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: primaryColor),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Image.asset(
        'assets/logo/logo.png',
        height: 32,
        errorBuilder: (_, __, ___) => const Text("ProntoSindico",
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
      ),
      centerTitle: true,
      actions: [
        if (!_isEditing && loaded != null)
          TextButton(
            onPressed: () => _enterEditMode(loaded),
            child: const Text('Editar'),
          ),
        if (_isEditing && loaded != null)
          TextButton(
            onPressed: isSaving ? null : () => _cancelEdit(loaded),
            child: const Text('Cancelar'),
          ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, UserProfileState state) {
    if (state is UserProfileInitial || state is UserProfileLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final loaded = _extractLoaded(state);
    if (loaded == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: errorColor),
            const SizedBox(height: 16),
            Text(
              state is UserProfileError ? state.message : 'Erro desconhecido',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref
                  .read(userProfileControllerProvider.notifier)
                  .loadProfile(),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    final isSaving = state is UserProfileSaving;

    return AbsorbPointer(
      absorbing: isSaving,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: defaultPadding),

              // Avatar com botão de edição
              Center(
                child: _ProfilePhotoWidget(
                  photoUrl: loaded.photoUrl,
                  isEditing: _isEditing,
                  isSaving: isSaving,
                  onTap: () => _pickAndCropPhoto(context),
                ),
              ),

              const SizedBox(height: 32),

              // Nome
              _buildLabel('Nome completo'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameCtrl,
                enabled: _isEditing && !isSaving,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Seu nome completo',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Nome é obrigatório' : null,
              ),

              const SizedBox(height: defaultPadding),

              // Telefone
              _buildLabel('Telefone / WhatsApp'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _phoneCtrl,
                enabled: _isEditing && !isSaving,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d\s\+\(\)\-]')),
                ],
                decoration: const InputDecoration(
                  hintText: '(11) 99999-9999',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),

              const SizedBox(height: defaultPadding),

              // E-mail (somente leitura)
              _buildLabel('E-mail'),
              const SizedBox(height: 6),
              TextFormField(
                initialValue: loaded.email,
                enabled: false,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),

              const SizedBox(height: defaultPadding),

              // Perfil (somente leitura)
              _buildLabel('Perfil de acesso'),
              const SizedBox(height: 6),
              TextFormField(
                initialValue: loaded.role,
                enabled: false,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),

              const SizedBox(height: 32),

              // Botão Salvar
              if (_isEditing)
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            ref
                                .read(userProfileControllerProvider.notifier)
                                .saveProfile(
                                  name: _nameCtrl.text.trim(),
                                  phone: _phoneCtrl.text.trim(),
                                );
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Salvar Alterações'),
                ),

              const SizedBox(height: defaultPadding),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: blackColor60,
      ),
    );
  }

  UserProfileLoaded? _extractLoaded(UserProfileState state) {
    return switch (state) {
      UserProfileLoaded() => state,
      UserProfileSaving() => state.data,
      UserProfileSaved() => state.data,
      UserProfileError() => state.previousData,
      _ => null,
    };
  }
}

/// Widget do avatar com suporte a foto de rede, arquivo local e placeholder.
class _ProfilePhotoWidget extends StatelessWidget {
  const _ProfilePhotoWidget({
    required this.photoUrl,
    required this.isEditing,
    required this.isSaving,
    required this.onTap,
  });

  final String? photoUrl;
  final bool isEditing;
  final bool isSaving;
  final VoidCallback onTap;

  static const double _size = 110.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.3),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(child: _buildImage()),
        ),
        if (isEditing)
          GestureDetector(
            onTap: isSaving ? null : onTap,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isSaving ? blackColor40 : primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
              ),
              child: isSaving
                  ? const Padding(
                      padding: EdgeInsets.all(6),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
            ),
          ),
      ],
    );
  }

  Widget _buildImage() {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: photoUrl!,
        width: _size,
        height: _size,
        fit: BoxFit.cover,
        placeholder: (_, __) => _placeholder(),
        errorWidget: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: blackColor5,
      child: const Icon(Icons.person, size: 52, color: blackColor40),
    );
  }
}
