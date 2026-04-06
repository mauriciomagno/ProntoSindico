import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "LGPD & Privacidade",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "CONFORMIDADE LEGAL",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E40AF),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Sua privacidade é nossa prioridade.",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
                height: 1.1,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "O ProntoSíndico valoriza a transparência. Entenda como protegemos seus dados e como você mantém o controle total sobre suas informações no ambiente condominial.",
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Card 1: LGPD
            _buildInfoCard(
              icon: Icons.gavel_outlined,
              iconColor: const Color(0xFF1E40AF),
              title: "Lei Geral de Proteção de Dados (Lei 13.709/2018)",
              description: "A LGPD estabelece regras claras sobre como os dados pessoais devem ser coletados e tratados. No ProntoSíndico, aplicamos o princípio da \"Privacy by Design\", garantindo que a segurança da sua informação esteja no centro de cada funcionalidade que desenvolvemos.",
            ),

            const SizedBox(height: 16),
            // Card 2: Como coletamos
            _buildBulletsCard(
              icon: Icons.storage_outlined,
              title: "Como coletamos seus dados",
              bullets: [
                "Cadastro inicial de morador (nome, unidade, CPF)",
                "Registros de uso do app e interações",
                "Logs de acesso para segurança e auditoria",
              ],
            ),

            const SizedBox(height: 16),
            // Card 3: Segurança Máxima (Blue)
            _buildHighlightCard(),

            const SizedBox(height: 32),
            // Section: Direitos
            Row(
              children: [
                const Icon(Icons.person_outline, color: Color(0xFF1E3A8A), size: 24),
                const SizedBox(width: 12),
                const Text(
                  "Seus Direitos como Titular",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildRightsGrid(),

            const SizedBox(height: 32),
            // Card 4: Contato DPO
            _buildDpoCard(),

            const SizedBox(height: 48),
            // Footer
            Center(
              child: Column(
                children: [
                   const Text(
                    "Última atualização: 31 de Maio de 2024",
                    style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFooterLink("Termos de Uso"),
                      const _Dot(),
                      _buildFooterLink("Cookies"),
                      const _Dot(),
                      _buildFooterLink("Ouvidoria"),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ).animate().fadeIn(duration: 400.ms),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletsCard({
    required IconData icon,
    required String title,
    required List<String> bullets,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF1E40AF), size: 24),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          ...bullets.map((b) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Icon(Icons.circle, size: 6, color: Color(0xFF1E40AF)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    b,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildHighlightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A),
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: const NetworkImage('https://www.transparenttextures.com/patterns/cubes.png'),
          opacity: 0.1,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, color: Colors.white, size: 24),
          const SizedBox(height: 20),
          const Text(
            "Segurança Máxima",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Seus dados são criptografados em repouso e em trânsito, armazenados em servidores de alta disponibilidade com redundância global.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightsGrid() {
    final rights = [
      {'title': 'Acesso e Correção', 'desc': 'Solicite a visualização total ou alteração de dados incorretos.'},
      {'title': 'Portabilidade', 'desc': 'Receba seus dados em formato estruturado para migração.'},
      {'title': 'Exclusão', 'desc': 'Solicite o esquecimento de dados não obrigatórios por lei.'},
      {'title': 'Revogação', 'desc': 'Retire seu consentimento para usos específicos a qualquer momento.'},
    ];

    return Column(
      children: rights.map((r) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9).withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(r['title']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
            const SizedBox(height: 4),
            Text(r['desc']!, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildDpoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Contato DPO",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0C4A6E)),
          ),
          const SizedBox(height: 8),
          const Text(
            "Tem dúvidas sobre privacidade? Fale com nosso Encarregado de Dados.",
            style: TextStyle(fontSize: 14, color: Color(0xFF0369A1)),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: const [
                Icon(Icons.alternate_email, color: Color(0xFF0369A1), size: 18),
                SizedBox(width: 12),
                Text("dpo@prontosindico.com", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.open_in_new, size: 18, color: Colors.white),
              label: const Text("Abrir Solicitação", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      width: 4,
      height: 4,
      decoration: const BoxDecoration(color: Color(0xFF94A3B8), shape: BoxShape.circle),
    );
  }
}
