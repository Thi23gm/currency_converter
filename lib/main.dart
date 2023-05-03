import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final String apiKey = 'OZ38YS18TalFGcYxSDkS7UtXgDFEl136';
final String apiUrl = 'https://api.apilayer.com/exchangerates_data/convert?';

Future<double> converterMoeda(
    double valor, String moedaDe, String moedaPara) async {
  final uri = Uri.parse('$apiUrl' +
      'to=' +
      moedaPara +
      '&from=' +
      moedaDe +
      '&amount=$valor' +
      '&apikey=' +
      apiKey);
  final response = await http.get(uri);
  if (response.statusCode == 200) {
    // Se a resposta da API for bem-sucedida
    // Analise a resposta JSON e obtenha a taxa de câmbio desejada
    final data = json.decode(response.body);
    double resultado = data['result'];
    return resultado;
  } else {
    // Se a resposta da API não for bem-sucedida
    throw Exception('Falha ao obter taxa de câmbio: ${response.statusCode}');
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MoneyConverter(),
  ));
}

class MoneyConverter extends StatefulWidget {
  const MoneyConverter({Key? key});

  @override
  State<MoneyConverter> createState() => _MoneyConverterState();
}

class _MoneyConverterState extends State<MoneyConverter> {
  String? moedaDe;
  String? moedaPara;
  double valor = 0;
  double valorConvertido = 0;
  bool isDarkMode = false;

  final List<String> moedas = [
    'USD',
    'BRL',
    'EUR',
    'GBP',
    // Adicione mais moedas aqui, se necessário
  ];

  @override
  void initState() {
    super.initState();
    _loadIsDarkMode();
  }

  _loadIsDarkMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  _toggleDarkMode(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = value;
      prefs.setBool('isDarkMode', value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text("Conversor de Moedas"),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Digite um valor',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    valor = double.parse(value);
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DropdownButton<String>(
                    value: moedaDe,
                    hint: const Text('Moeda de origem'),
                    onChanged: (String? newValue) {
                      setState(() {
                        moedaDe = newValue!;
                      });
                    },
                    items: moedas.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const Icon(Icons.arrow_forward),
                  DropdownButton<String>(
                    value: moedaPara,
                    hint: const Text('Moeda de destino'),
                    onChanged: (String? newValue) {
                      setState(() {
                        moedaPara = newValue!;
                      });
                    },
                    items: moedas.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (moedaDe != null && moedaPara != null) {
                  double resultado =
                      await converterMoeda(valor, moedaDe!, moedaPara!);
                  setState(() {
                    valorConvertido = resultado;
                  });
                }
              },
              child: const Text('Converter'),
            ),
            const SizedBox(height: 32.0),
            Text(
              'Resultado: ${valorConvertido.toStringAsFixed(2)} $moedaPara',
              style: const TextStyle(fontSize: 24.0),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Modo escuro'),
                Switch(
                  value: isDarkMode,
                  onChanged: _toggleDarkMode,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
