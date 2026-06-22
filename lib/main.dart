import 'package:flutter_aplication/Address.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'SearchCep.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Consulta CEP',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: const Home(title: 'Consultando CEPs'),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key, required this.title});

  final String title;

  @override
  State<Home> createState() => _HomePageState();
}

class _HomePageState extends State<Home> {
  String cep = "";
  Address? address;
  String? erro;
  bool carregando = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary, title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: ListView(children: [tffCep(), const SizedBox(height: 16), btnConsultarCep(cep), const SizedBox(height: 24), resultadoWidget()]),
      ),
    );
  }

  TextFormField tffCep() {
    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Campo obrigatorio!';
        }
        return null;
      },
      onChanged: (value) => setState(() {
        cep = value;
      }),
      onFieldSubmitted: (_) => _consultarCep(),
      textInputAction: TextInputAction.search,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly, cepFormatter],
      decoration: const InputDecoration(border: UnderlineInputBorder(), label: Text("CEP:"), hintText: '00000-000'),
    );
  }

  ElevatedButton btnConsultarCep(String cep) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
      onPressed: _consultarCep,
      child: const Text(
        "Consultar",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  Future<void> _consultarCep() async {
    setState(() {
      carregando = true;
      address = null;
      erro = null;
    });

    try {
      final data = await Searchcep.fetchCep(cep);
      setState(() {
        address = data;
        carregando = false;
      });
    } catch (e) {
      setState(() {
        erro = e.toString().replaceFirst('Exception: ', '');
        carregando = false;
      });
    }
  }

  Widget resultadoWidget() {
    if (carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (erro != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          border: Border.all(color: Colors.red.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Text(erro!, style: TextStyle(color: Colors.red.shade700)),
            ),
          ],
        ),
      );
    }

    if (address != null) {
      final e = address!;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.purple.shade50,
          border: Border.all(color: Colors.purple.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.purple.shade700),
                const SizedBox(width: 8),
                Text(
                  'Endereço encontrado',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.purple.shade700),
                ),
              ],
            ),
            const Divider(),
            _linhaInfo('CEP', e.cep),
            _linhaInfo('Logradouro', e.logradouro),
            _linhaInfo('Bairro', e.bairro),
            _linhaInfo('Cidade', e.localidade),
            _linhaInfo('Estado', e.uf),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _linhaInfo(String label, String? valor) {
    if (valor == null || valor.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }

  final cepFormatter = MaskTextInputFormatter(mask: '#####-###', filter: {"#": RegExp(r'[0-9]')});
}