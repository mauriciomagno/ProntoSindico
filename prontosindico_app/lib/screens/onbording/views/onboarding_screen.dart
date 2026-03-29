import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:prontosindico/components/dot_indicators.dart';
import 'package:prontosindico/constants.dart';
import 'package:prontosindico/ui/features/auth/views/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/onbording_content.dart';

class OnBordingScreen extends StatefulWidget {
  const OnBordingScreen({super.key});

  @override
  State<OnBordingScreen> createState() => _OnBordingScreenState();
}

class _OnBordingScreenState extends State<OnBordingScreen> {
  late PageController _pageController;
  int _pageIndex = 0;
  final List<Onbord> _onbordData = [
    Onbord(
      image: "assets/images/onboarding/building.png",
      imageDarkTheme: "assets/images/onboarding/building.png",
      title: "Bem-vindo ao\nProntoSíndico",
      description:
          "Sua plataforma completa para gestão e convivência inteligente no seu condomínio. Tudo na palma da sua mão.",
    ),
    Onbord(
      image: "assets/images/onboarding/communication.png",
      imageDarkTheme: "assets/images/onboarding/communication.png",
      title: "Comunicação\nEficiente",
      description:
          "Receba comunicados importantes, participe de enquetes e converse diretamente com a administração sem burocracia.",
    ),
    Onbord(
      image: "assets/images/onboarding/booking.png",
      imageDarkTheme: "assets/images/onboarding/booking.png",
      title: "Reservas de\nÁreas Comuns",
      description:
          "Agende o salão de festas, churrasqueira e outras áreas de lazer de forma rápida e totalmente digital.",
    ),
    Onbord(
      image: "assets/images/onboarding/incidents.png",
      imageDarkTheme: "assets/images/onboarding/incidents.png",
      title: "Relato de\nOcorrências",
      description:
          "Viu algo errado? Abra chamados de manutenção e acompanhe a resolução em tempo real pelo aplicativo.",
    ),
  ];

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    super.initState();
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: Text(
                    "Pular",
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge!.color),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _onbordData.length,
                  onPageChanged: (value) {
                    setState(() {
                      _pageIndex = value;
                    });
                  },
                  itemBuilder: (context, index) => OnbordingContent(
                    title: _onbordData[index].title,
                    description: _onbordData[index].description,
                    image: (Theme.of(context).brightness == Brightness.dark &&
                            _onbordData[index].imageDarkTheme != null)
                        ? _onbordData[index].imageDarkTheme!
                        : _onbordData[index].image,
                    isTextOnTop: index.isOdd,
                  ),
                ),
              ),
              Row(
                children: [
                  ...List.generate(
                    _onbordData.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(right: defaultPadding / 4),
                      child: DotIndicator(isActive: index == _pageIndex),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_pageIndex < _onbordData.length - 1) {
                          _pageController.nextPage(
                              curve: Curves.ease, duration: defaultDuration);
                        } else {
                          _finishOnboarding();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        minimumSize: const Size(60, 60),
                        fixedSize: const Size(60, 60),
                        padding: EdgeInsets.zero,
                      ),
                      child: SvgPicture.asset(
                        "assets/icons/Arrow - Right.svg",
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: defaultPadding),
            ],
          ),
        ),
      ),
    );
  }
}

class Onbord {
  final String image, title, description;
  final String? imageDarkTheme;

  Onbord({
    required this.image,
    required this.title,
    this.description = "",
    this.imageDarkTheme,
  });
}
