import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  final List<String> moedas = [
    'USD',
    'BRL',
    'EUR',
    'GBP',
    // Adicione mais moedas aqui, se necessário
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text("Conversor de Moedas"),
        ),
        backgroundColor:
            Color.fromARGB(78, 14, 19, 30), // Cor de fundo da app bar
      ),
      body: Container(
        color: Color.fromARGB(248, 220, 211, 211), // Cor de fundo do body
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: moedaDe,
              onChanged: (String? newValue) {
                setState(() {
                  moedaDe = newValue;
                });
              },
              items: moedas.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                        color: Colors.black), // Cor do texto do dropdown
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: moedaPara,
              onChanged: (String? newValue) {
                setState(() {
                  moedaPara = newValue;
                });
              },
              items: moedas.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                        color: Colors.black), // Cor do texto do dropdown
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextField(
              onChanged: (value) {
                setState(() {
                  valor = double.tryParse(value) ?? 0;
                });
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Digite o valor a ser convertido',
                labelStyle:
                    TextStyle(color: Colors.black), // Cor do texto da label
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  if (moedaDe == null || moedaPara == null || moedaPara == "") {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Erro'),
                          content: const Text(
                              'Por favor, selecione as moedas de origem e destino.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    double resultado =
                        await converterMoeda(valor, moedaDe!, moedaPara!);
                    setState(() {
                      valorConvertido = resultado;
                    });
                  }
                } catch (e) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Erro'),
                        content: Text('Falha ao converter moeda: $e'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                primary:
                    Color.fromRGBO(12, 165, 176, 1.0), // Define a cor do botão
              ),
              child: const Text('Converter'),
            ),
            const SizedBox(height: 20),
            Text(
              'Valor convertido: ${valorConvertido.toStringAsFixed(2)} ${moedaPara != null ? moedaPara : ''}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
