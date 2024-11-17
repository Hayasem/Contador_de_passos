import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';

void main() => runApp(const ContadorPassos());

class ContadorPassos extends StatelessWidget {
  const ContadorPassos({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contador de Passos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const _TelaContadoraPassos(),
    );
  }
}

class _TelaContadoraPassos extends StatefulWidget {
  const _TelaContadoraPassos({super.key});


  @override
  _TelaContadoraPassosState createState() => _TelaContadoraPassosState();
}

class _TelaContadoraPassosState extends State<_TelaContadoraPassos> {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _statusPedestreStream;

  int _passosAtuais = 0;
  final int _metaPassos = 10000; //Meta inicial
  Duration _tempoCaminhada = Duration.zero;
  bool _estaMovendo = false;
  DateTime? _horarioInicio;

  @override
  void initState() {
    super.initState();
    iniciarPedometer();
  }

  void iniciarPedometer() {
    _stepCountStream = Pedometer.stepCountStream;
    _statusPedestreStream = Pedometer.pedestrianStatusStream;

    _stepCountStream.listen(contarPassos,
    onError: tratarErroPedometer,
    );
  }

  void contarPassos(StepCount event) {
    setState(() {
      _passosAtuais = event.steps;
    });
  }
  void tratarErroPedometer(dynamic error) {
    debugPrint("Erro no Pedometer: $error");
  }

  void calcularTempoCaminhada(){
    setState(() {
      if(_estaMovendo) {
        _estaMovendo = false;
        _tempoCaminhada += DateTime.now().difference(_horarioInicio!);
      }else {
        _estaMovendo = true;
        _horarioInicio = DateTime.now();
      }
    });
  }

  double get distanciaEmKm => _passosAtuais * 0.0008;
  double get caloriasQueimadas => _passosAtuais * 0.04;

  @override
  Widget build(BuildContext context) {
    double progresso = (_passosAtuais / _metaPassos).clamp(0, 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contador de Passos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Meta: $_metaPassos passos",
              style: const TextStyle(fontSize: 20),
        ),
              Text(
                "${(progresso * 100).toStringAsFixed(1)}% concluídos",
                style: const TextStyle(fontSize: 16),
              ),
              Expanded(
                  child: Center(
                    child: Text(
                      "$_passosAtuais",
                      style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
                    ),
                  ),
              ),
              const Text("passos", style: TextStyle(fontSize: 24)),
              ElevatedButton(
                  onPressed: calcularTempoCaminhada,
                  child: Text(_estaMovendo ? "Pausar" : "Iniciar"),
              ),
              const SizedBox(height: 20),
              Text(
                "Passos totais: $_passosAtuais",
                style: const TextStyle(fontSize: 16),
              ),
            Text(
              "Distância percorrida: ${distanciaEmKm.toStringAsFixed(2)} km",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Calorias queimadas: ${caloriasQueimadas.toStringAsFixed(1)} kcal",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
