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
                    color: primaryColor.withOpacity(0.1),
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
                    color: primaryColor.withOpacity(0.1),
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

    final loaded = _extractLoaded(state);
    final isSaving = state is UserProfileSaving;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const AppDrawer(),
      body: (state is UserProfileInitial || state is UserProfileLoading)
          ? const Center(child: CircularProgressIndicator())
          : loaded == null
              ? _buildErrorState(state)
              : Column(
                  children: [
                    // Cabeçalho fixo (congelado)
                    Container(
                      color: const Color(0xFFF8FAFC),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Builder(
                                  builder: (ctx) => IconButton(
                                    icon: const Icon(Icons.menu,
                                        color: primaryColor),
                                    onPressed: () =>
                                        Scaffold.of(ctx).openDrawer(),
                                  ),
                                ),
                                const Expanded(
                                  child: Text(
                                    "Meu Perfil",
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                                if (!_isEditing)
                                  TextButton.icon(
                                    onPressed: () => _enterEditMode(loaded),
                                    icon: const Icon(Icons.edit,
                                        size: 18, color: primaryColor),
                                    label: const Text(
                                      'Editar',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                if (_isEditing)
                                  TextButton.icon(
                                    onPressed: isSaving
                                        ? null
                                        : () => _cancelEdit(loaded),
                                    icon: const Icon(Icons.close,
                                        size: 18, color: Color(0xFF64748B)),
                                    label: const Text(
                                      'Cancelar',
                                      style: TextStyle(
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Visualize e edite suas informações pessoais.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Conteúdo rolável
                    Expanded(
                      child: _buildContent(context, loaded, isSaving),
                    ),
                  ],
                ),
    );
  }

  Widget _buildErrorState(UserProfileState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: errorColor),
            const SizedBox(height: 16),
            Text(
              state is UserProfileError ? state.message : 'Erro desconhecido',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref
                  .read(userProfileControllerProvider.notifier)
                  .loadProfile(),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, UserProfileLoaded loaded, bool isSaving) {
    return AbsorbPointer(
      absorbing: isSaving,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                enabled: _isEditing && !isSaving,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w500,
                ),
                decoration: _buildInputDecoration(
                  hintText: 'Seu nome completo',
                  icon: Icons.person_outline,
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Nome é obrigatório' : null,
              ),

              const SizedBox(height: 20),

              // Telefone
              _buildLabel('Telefone / WhatsApp'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneCtrl,
                enabled: _isEditing && !isSaving,
                keyboardType: TextInputType.phone,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w500,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _BrazilianPhoneInputFormatter(),
                ],
                decoration: _buildInputDecoration(
                  hintText: '(11) 99999-9999',
                  icon: Icons.phone_outlined,
                ),
              ),

              const SizedBox(height: 20),

              // E-mail (somente leitura)
              _buildLabel('E-mail'),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: loaded.email,
                enabled: false,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.w500,
                ),
                decoration: _buildInputDecoration(
                  hintText: loaded.email,
                  icon: Icons.email_outlined,
                ),
              ),

              const SizedBox(height: 20),

              // Perfil (somente leitura)
              _buildLabel('Perfil de acesso'),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: loaded.role,
                enabled: false,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.w500,
                ),
                decoration: _buildInputDecoration(
                  hintText: loaded.role,
                  icon: Icons.badge_outlined,
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 3,
                    shadowColor: primaryColor.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Salvar Alterações',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
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
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF64748B),
        letterSpacing: 0.5,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFFBBBBBB),
        fontSize: 15,
      ),
      prefixIcon: Icon(
        icon,
        color: Color(0xFF94A3B8),
        size: 22,
      ),
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: primaryColor,
          width: 1.5,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: errorColor,
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: errorColor,
          width: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
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
              color: primaryColor.withOpacity(0.3),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.15),
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

/// Formatter para telefone brasileiro (11) 99999-9999 ou (11) 9999-9999
class _BrazilianPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    final digitsOnly = text.replaceAll(RegExp(r'\D'), '');

    // Limita a 11 dígitos (DDD + número)
    if (digitsOnly.length > 11) {
      return oldValue;
    }

    final buffer = StringBuffer();
    int cursorPosition = newValue.selection.end;
    int addedChars = 0;

    for (int i = 0; i < digitsOnly.length; i++) {
      // Adiciona '(' antes do DDD
      if (i == 0) {
        buffer.write('(');
        if (cursorPosition > i) addedChars++;
      }

      buffer.write(digitsOnly[i]);

      // Adiciona ') ' após o DDD (2 dígitos)
      if (i == 1) {
        buffer.write(') ');
        if (cursorPosition > i + 1) addedChars += 2;
      }

      // Adiciona '-' antes dos últimos 4 dígitos
      // Para celular (11 dígitos): (11) 99999-9999
      // Para fixo (10 dígitos): (11) 9999-9999
      if (digitsOnly.length == 11 && i == 6) {
        buffer.write('-');
        if (cursorPosition > i + 1) addedChars++;
      } else if (digitsOnly.length == 10 && i == 5) {
        buffer.write('-');
        if (cursorPosition > i + 1) addedChars++;
      }
    }

    final formattedText = buffer.toString();
    final newCursorPosition =
        (cursorPosition + addedChars).clamp(0, formattedText.length);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }
}
