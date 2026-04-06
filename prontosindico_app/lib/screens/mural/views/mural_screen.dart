import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prontosindico/constants.dart';
import 'package:prontosindico/screens/home/menu_lateral.dart';
import 'package:prontosindico/domain/entities/mural_aviso.dart';
import 'package:prontosindico/domain/enums/user_role.dart';
import 'package:prontosindico/providers/auth_provider.dart';
import 'package:prontosindico/providers/communication_providers.dart';
import 'package:prontosindico/route/route_constants.dart';
import 'package:prontosindico/screens/mural/views/create_aviso_screen.dart';

class MuralScreen extends ConsumerStatefulWidget {
  const MuralScreen({super.key});

  @override
  ConsumerState<MuralScreen> createState() => _MuralScreenState();
}

class _MuralScreenState extends ConsumerState<MuralScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addNewNotice(BuildContext context, WidgetRef ref) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateAvisoScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avisosAsync = ref.watch(muralAvisosProvider);
    final userProfile = ref.watch(userProfileProvider).valueOrNull;

    // Controle de Permissões: Apenas Admin, Síndico e Tesoureiro podem criar avisos
    final bool canAddNotice = userProfile != null &&
        (userProfile.role == UserRole.administrador ||
            userProfile.role == UserRole.sindico ||
            userProfile.role == UserRole.tesoureiro);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          Column(
            children: [
              // Custom Header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Builder(
                      builder: (ctx) => IconButton(
                        icon: const Icon(Icons.menu, color: primaryColor),
                        onPressed: () => Scaffold.of(ctx).openDrawer(),
                      ),
                    ),
                    Text(
                      "ProntoSíndico",
                      style: TextStyle(
                        fontFamily: grandisExtendedFont,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    InkWell(
                      onTap: () =>
                          Navigator.pushNamed(context, userInfoScreenRoute),
                      borderRadius: BorderRadius.circular(20),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFFFFDAB9),
                        child: Text(
                          userProfile?.name.substring(0, 1).toUpperCase() ??
                              "U",
                          style: const TextStyle(
                              color: Colors.brown, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable Content
              Expanded(
                child: avisosAsync.when(
                  data: (avisos) {
                    // Lógica de Pesquisa no Mural
                    final query = _normalizeString(_searchController.text);
                    final filteredAvisos = avisos.where((aviso) {
                      if (query.isEmpty) return true;
                      return _normalizeString(aviso.title).contains(query) ||
                          _normalizeString(aviso.description).contains(query);
                    }).toList();

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          const Text(
                            "Mural de\nAvisos",
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Mantenha-se informado sobre as últimas\natualizações do seu condomínio.",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Search Bar (Ativada e com Design Premium)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) => setState(() {}),
                              style: const TextStyle(
                                  fontSize: 15, color: Color(0xFF1E293B)),
                              decoration: const InputDecoration(
                                hintText: 'Filtrar avisos...',
                                hintStyle: TextStyle(
                                    fontSize: 15, color: Color(0xFF94A3B8)),
                                prefixIcon: Icon(Icons.search,
                                    color: Color(0xFF64748B), size: 20),
                                prefixIconConstraints:
                                    BoxConstraints(minWidth: 32),
                                border: InputBorder.none,
                                filled: true,
                                fillColor: Colors.transparent,
                                isDense: true,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Render Dynamic Notices from Firebase (Filtered)
                          if (filteredAvisos.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 40),
                                child: Column(
                                  children: [
                                    const Icon(Icons.campaign_outlined,
                                        size: 64, color: Color(0xFF94A3B8)),
                                    const SizedBox(height: 16),
                                    const Text(
                                      "Sem comunicados para exibir.",
                                      style: TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ...filteredAvisos.map((aviso) {
                              if (aviso.tag == MuralTag.social) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: _buildSocialCard(
                                    tag: aviso.tag.label,
                                    title: aviso.title,
                                    description: aviso.description,
                                    buttonText: "Confirmar Presença",
                                  ),
                                );
                              } else if (aviso.tag == MuralTag.importante) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: _buildImportantCard(
                                    tag: aviso.tag.label,
                                    tagColor: aviso.tag.color,
                                    time: aviso.time ?? "Agora",
                                    title: aviso.title,
                                    description: aviso.description,
                                    attachment: aviso.attachment ?? "Sem anexo",
                                  ),
                                );
                              } else {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: _buildCompactCard(
                                    tag: aviso.tag.label,
                                    tagColor: aviso.tag.color,
                                    time: aviso.time ?? "Recentemente",
                                    title: aviso.title,
                                    description: aviso.description,
                                    footerLabel: "Ver Detalhes",
                                    footerIcon: Icons.info_outline,
                                  ),
                                );
                              }
                            }),

                          _buildSuggestionBanner(),
                          const SizedBox(height: 100),
                        ],
                      ).animate().fadeIn(duration: 400.ms),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text("Erro: $err")),
                ),
              ),
            ],
          ),

          // FAB - Only show for Admin/Sindico/Tesoureiro
          if (canAddNotice)
            Positioned(
              bottom: 24,
              right: 24,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF004C99),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF004C99).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: () => _addNewNotice(context, ref),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.add, color: Colors.white, size: 24),
                          SizedBox(width: 8),
                          Text(
                            "Novo Aviso",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImportantCard({
    required String tag,
    required Color tagColor,
    required String time,
    required String title,
    required String description,
    required String attachment,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: tagColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                time,
                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.remove_red_eye_outlined,
                  size: 18, color: Color(0xFF005EB8)),
              const SizedBox(width: 6),
              const Text(
                "Ler Mais",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF005EB8),
                ),
              ),
              const SizedBox(width: 20),
              const Icon(Icons.link, size: 18, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  attachment,
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Profile stack
              SizedBox(
                width: 60,
                height: 26,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      child: _buildMiniAvatar(Colors.teal),
                    ),
                    Positioned(
                      left: 15,
                      child: _buildMiniAvatar(Colors.blueGrey),
                    ),
                    Positioned(
                      left: 30,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Text(
                          "+14",
                          style: TextStyle(
                              fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniAvatar(Color color) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 14),
    );
  }

  Widget _buildSocialCard({
    required String tag,
    required String title,
    required String description,
    required String buttonText,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF96F2FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              tag,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF1E293B),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonText,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCard({
    required String tag,
    required Color tagColor,
    required String time,
    required String title,
    required String description,
    required String footerLabel,
    required IconData footerIcon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tagColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: tagColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                time,
                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(footerIcon, size: 16, color: const Color(0xFF005EB8)),
              const SizedBox(width: 8),
              Text(
                footerLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF005EB8),
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right,
                  size: 20, color: Color(0xFF94A3B8)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF004C99),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    const Icon(Icons.campaign, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Sugestões de\nMelhoria?",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Sua voz é importante para o ProntoSíndico",
                      style: TextStyle(fontSize: 13, color: Color(0xFFB3D1EB)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _normalizeString(String text) {
    const withDia =
        'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
    const withoutDia =
        'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz';
    String normalized = text;
    for (int i = 0; i < withDia.length; i++) {
      normalized = normalized.replaceAll(withDia[i], withoutDia[i]);
    }
    return normalized.toLowerCase();
  }
}
