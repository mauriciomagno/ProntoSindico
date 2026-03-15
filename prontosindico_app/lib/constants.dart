import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

// Just for demo
const productDemoImg1 = "https://i.imgur.com/CGCyp1d.png";
const productDemoImg2 = "https://i.imgur.com/AkzWQuJ.png";
const productDemoImg3 = "https://i.imgur.com/J7mGZ12.png";
const productDemoImg4 = "https://i.imgur.com/q9oF9Yq.png";
const productDemoImg5 = "https://i.imgur.com/MsppAcx.png";
const productDemoImg6 = "https://i.imgur.com/JfyZlnO.png";

// End For demo

const grandisExtendedFont = "Grandis Extended";

// On color 80, 60.... those means opacity

const Color primaryColor = Color(0xFF0055D3); // Premium Professional Blue
const Color secondaryColor = Color(0xFF00CC99); // Fresh Emerald accent

const MaterialColor primaryMaterialColor =
    MaterialColor(0xFF0055D3, <int, Color>{
  50: Color(0xFFE6EFFF),
  100: Color(0xFFB3D1FF),
  200: Color(0xFF80B3FF),
  300: Color(0xFF4D95FF),
  400: Color(0xFF267FFF),
  500: Color(0xFF0055D3),
  600: Color(0xFF004DCC),
  700: Color(0xFF0042C2),
  800: Color(0xFF0038B8),
  900: Color(0xFF0027A8),
});

const Color blackColor = Color(0xFF0B1019); // Richer black/navy
const Color blackColor80 = Color(0xFF2C313B);
const Color blackColor60 = Color(0xFF4D525D);
const Color blackColor40 = Color(0xFF7D828D);
const Color blackColor20 = Color(0xFFBDBFC5);
const Color blackColor10 = Color(0xFFE1E2E5);
const Color blackColor5 = Color(0xFFF1F2F4);

const Color whiteColor = Colors.white;
const Color whileColor80 = Color(0xFFFAFAFA);

const Color successColor = Color(0xFF00CC99);
const Color warningColor = Color(0xFFFFB300);
const Color errorColor = Color(0xFFFF4D4D);
const Color backgroundLightColor = Color(0xFFF9FAFB);
const Color backgroundDarkColor = Color(0xFF0B1019);

const double defaultPadding = 16.0;
const double defaultBorderRadious = 12.0;
const Duration defaultDuration = Duration(milliseconds: 300);

final passwordValidator = MultiValidator([
  RequiredValidator(errorText: 'Senha é obrigatória'),
  MinLengthValidator(8, errorText: 'A senha deve ter pelo menos 8 caracteres'),
  PatternValidator(r'(?=.*?[#?!@$%^&*-])',
      errorText: 'A senha deve conter pelo menos um caractere especial')
]);

final emaildValidator = MultiValidator([
  RequiredValidator(errorText: 'Email é obrigatório'),
  EmailValidator(errorText: "Insira um endereço de email válido"),
]);

const pasNotMatchErrorText = "as senhas não coincidem";
