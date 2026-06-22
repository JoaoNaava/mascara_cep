import 'dart:io';
import 'dart:convert';

import 'package:flutter_aplication/Address.dart';

class Searchcep {
  static Future<Address> fetchCep(String cep) async {
    final cepLimpo = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (cepLimpo.length != 8) {
      throw Exception('CEP inválido! Informe 8 números.');
    }

    final client = HttpClient();
    try {
      final req = await client.getUrl(Uri.parse('https://viacep.com.br/ws/$cepLimpo/json/'));
      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();

      if (res.statusCode != HttpStatus.ok) {
        throw Exception('Falha ao consultar o serviço de CEP.');
      }

      final data = jsonDecode(body) as Map<String, dynamic>;
      if (data['erro'] == true) {
        throw Exception('CEP não encontrado!');
      }

      return Address.fromJson(data);
    } on SocketException {
      throw Exception('Sem conexão com a internet.');
    } on FormatException {
      throw Exception('Resposta inválida do serviço de CEP.');
    } finally {
      client.close();
    }
  }
}