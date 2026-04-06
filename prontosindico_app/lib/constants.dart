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

// Skyline Blueprint Colors
const Color primaryColor = Color(0xFF005EB8); 
const Color secondaryColor = Color(0xFF00A3AD); 

const MaterialColor primaryMaterialColor = MaterialColor(
  0xFF005EB8,
  <int, Color>{
    50: Color(0xFFE6F0F8),
    100: Color(0xFFB3D1EB),
    200: Color(0xFF80B3DE),
    300: Color(0xFF4D94D1),
    400: Color(0xFF267FC7),
    500: Color(0xFF005EB8),
    600: Color(0xFF0056A8),
    700: Color(0xFF004C99),
    800: Color(0xFF00438A),
    900: Color(0xFF00326B),
  },
);

const Color blackColor = Color(0xFF0B1019);
const Color blackColor80 = Color(0xFF2C313B);
const Color blackColor60 = Color(0xFF475057); 
const Color blackColor40 = Color(0xFF7D828D);
const Color blackColor20 = Color(0xFFBDBFC5);
const Color blackColor10 = Color(0xFFE1E2E5);
const Color blackColor5 = Color(0xFFF1F2F4);

const Color whiteColor = Colors.white;

const Color successColor = Color(0xFF00CC99);
const Color warningColor = Color(0xFFFFB300);
const Color errorColor = Color(0xFFFF4D4D);
const Color backgroundLightColor = Color(0xFFF5F7F9);
const Color backgroundDarkColor = Color(0xFF0B1019);

const double defaultPadding = 16.0;
const double defaultBorderRadious = 16.0;
const Duration defaultDuration = Duration(milliseconds: 300);

final passwordValidator = MultiValidator([
  RequiredValidator(errorText: 'Senha e obrigatoria'),
  MinLengthValidator(8, errorText: 'A senha deve ter pelo menos 8 caracteres'),
  PatternValidator(r'(?=.*?[#?!@$%^&*-])',
      errorText: 'A senha deve conter pelo menos um caractere especial')
]);

final emaildValidator = MultiValidator([
  RequiredValidator(errorText: 'Email e obrigatorio'),
  EmailValidator(errorText: "Insira um endereco de email valido"),
]);

const pasNotMatchErrorText = "as senhas nao coincidem";
