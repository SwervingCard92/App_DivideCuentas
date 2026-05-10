import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

void main() {
  runApp(const DivideCuentaApp());
}

// ─── COLORES Y TEMA ────────────────────────────────────────────────────────────
const Color kPrimary   = Color(0xFF7B5EA7);
const Color kGreen     = Color(0xFF6AB469);
const Color kWhatsApp  = Color(0xFF25D366);
const Color kBgGris    = Color(0xFFF5F5F5);

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: kPrimary),
  fontFamily: 'Poppins',
  scaffoldBackgroundColor: kBgGris,
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kPrimary, width: 2),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kPrimary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 16),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
);

class DivideCuentaApp extends StatelessWidget {
  const DivideCuentaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Divide la Cuenta',
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      home: const PantallaPrincipal(),
    );
  }
}

// ─── PANTALLA 1: ENTRADA ───────────────────────────────────────────────────────
class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});
  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  final _totalCtrl     = TextEditingController();
  final _nombreCtrl    = TextEditingController();
  final List<String>   _participantes = [];
  String               _modo          = 'igual';

  // Para modo manual: monto por persona
  final Map<String, TextEditingController> _montosCtrl = {};
  // Para modo porcentaje: slider por persona
  final Map<String, double> _porcentajes = {};

  void _agregarParticipante() {
    final nombre = _nombreCtrl.text.trim();
    if (nombre.isEmpty || _participantes.contains(nombre)) return;
    setState(() {
      _participantes.add(nombre);
      _montosCtrl[nombre] = TextEditingController();
      _porcentajes[nombre] = 0;
      _nombreCtrl.clear();
    });
  }

  void _eliminarParticipante(String nombre) {
    setState(() {
      _participantes.remove(nombre);
      _montosCtrl[nombre]?.dispose();
      _montosCtrl.remove(nombre);
      _porcentajes.remove(nombre);
    });
  }

  Map<String, double> _calcularMontos() {
    final total = double.tryParse(_totalCtrl.text.replaceAll(',', '')) ?? 0;
    final n = _participantes.length;
    if (n == 0) return {};

    switch (_modo) {
      case 'igual':
        final parte = total / n;
        return {for (var p in _participantes) p: parte};

      case 'porcentaje':
        return {
          for (var p in _participantes) p: total * (_porcentajes[p] ?? 0) / 100
        };

      case 'manual':
        return {
          for (var p in _participantes)
            p: double.tryParse(_montosCtrl[p]?.text ?? '0') ?? 0
        };

      default:
        return {};
    }
  }

  bool _puedeCalcular() {
    final total = double.tryParse(_totalCtrl.text.replaceAll(',', '')) ?? 0;
    if (total <= 0 || _participantes.isEmpty) return false;
    return true;
  }

  void _irAResultados() {
    if (!_puedeCalcular()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agrega el total y al menos un participante'),
          backgroundColor: kPrimary,
        ),
      );
      return;
    }
    final total = double.parse(_totalCtrl.text.replaceAll(',', ''));
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => PantallaResultados(
        total: total,
        montos: _calcularMontos(),
        modo: _modo,
      ),
    ));
  }

  @override
  void dispose() {
    _totalCtrl.dispose();
    _nombreCtrl.dispose();
    for (var c in _montosCtrl.values) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimary,
        title: const Text('Dividir cuenta',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('Ingresa los datos de la cuenta',
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Total ──────────────────────────────────────────
            _Label('Total de la cuenta'),
            const SizedBox(height: 6),
            TextField(
              controller: _totalCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
              decoration: const InputDecoration(
                prefixText: '\$  ',
                prefixStyle: TextStyle(color: kPrimary, fontWeight: FontWeight.bold),
                suffixText: 'MXN',
                suffixStyle: TextStyle(color: Colors.grey),
                hintText: '0.00',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),

            // ── Agregar participantes ──────────────────────────
            _Label('Participantes'),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _nombreCtrl,
                  decoration: const InputDecoration(hintText: 'Nombre del participante'),
                  onSubmitted: (_) => _agregarParticipante(),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _agregarParticipante,
                child: Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: kPrimary, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.person_add, color: Colors.white),
                ),
              ),
            ]),
            const SizedBox(height: 10),

            // Chips de participantes
            if (_participantes.isNotEmpty)
              Wrap(
                spacing: 8, runSpacing: 6,
                children: _participantes.map((p) => Chip(
                  label: Text(p, style: const TextStyle(color: Colors.white, fontSize: 13)),
                  backgroundColor: kPrimary,
                  deleteIconColor: Colors.white70,
                  onDeleted: () => _eliminarParticipante(p),
                )).toList(),
              ),
            const SizedBox(height: 20),

            // ── Tipo de división ──────────────────────────────
            _Label('Tipo de división'),
            const SizedBox(height: 8),
            Row(children: [
              _ToggleBtn('Igual',         'igual',       _modo, (v) => setState(() => _modo = v)),
              const SizedBox(width: 8),
              _ToggleBtn('Por %',         'porcentaje',  _modo, (v) => setState(() => _modo = v)),
              const SizedBox(width: 8),
              _ToggleBtn('Manual',        'manual',      _modo, (v) => setState(() => _modo = v)),
            ]),
            const SizedBox(height: 16),

            // ── Controles según modo ──────────────────────────
            if (_participantes.isNotEmpty) ...[
              if (_modo == 'igual') _VistaIgual(_totalCtrl.text, _participantes.length),
              if (_modo == 'porcentaje') _VistaPorcentaje(
                participantes: _participantes,
                porcentajes: _porcentajes,
                onChange: (p, v) => setState(() => _porcentajes[p] = v),
              ),
              if (_modo == 'manual') _VistaManual(
                participantes: _participantes,
                controladores: _montosCtrl,
              ),
            ],
            const SizedBox(height: 24),

            // ── Botón calcular ────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _irAResultados,
                icon: const Icon(Icons.calculate_outlined),
                label: const Text('Calcular'),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ─── VISTAS DE MODO ────────────────────────────────────────────────────────────

class _VistaIgual extends StatelessWidget {
  final String totalText;
  final int n;
  const _VistaIgual(this.totalText, this.n);
  @override
  Widget build(BuildContext context) {
    final total = double.tryParse(totalText.replaceAll(',', '')) ?? 0;
    final parte = n > 0 ? total / n : 0.0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kPrimary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kPrimary.withOpacity(0.2)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.people_outline, color: kPrimary, size: 18),
        const SizedBox(width: 8),
        Text('División igual entre $n ${n == 1 ? "persona" : "personas"}  ·  ',
            style: const TextStyle(color: kPrimary, fontSize: 13)),
        Text('\$${_fmt(parte)} MXN',
            style: const TextStyle(color: kPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
      ]),
    );
  }
}

class _VistaPorcentaje extends StatelessWidget {
  final List<String> participantes;
  final Map<String, double> porcentajes;
  final void Function(String, double) onChange;
  const _VistaPorcentaje({required this.participantes, required this.porcentajes, required this.onChange});
  @override
  Widget build(BuildContext context) {
    final suma = porcentajes.values.fold(0.0, (a, b) => a + b);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...participantes.map((p) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDDDDDD)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(p, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('${(porcentajes[p] ?? 0).toStringAsFixed(0)}%',
                    style: const TextStyle(color: kPrimary, fontWeight: FontWeight.bold)),
              ]),
              Slider(
                value: porcentajes[p] ?? 0,
                min: 0, max: 100,
                activeColor: kPrimary,
                onChanged: (v) => onChange(p, v),
              ),
            ]),
          ),
        )),
        if (suma.round() != 100)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              const Icon(Icons.warning_amber_outlined, color: Colors.orange, size: 16),
              const SizedBox(width: 6),
              Text('Los porcentajes suman ${suma.toStringAsFixed(0)}% (necesitas 100%)',
                  style: const TextStyle(fontSize: 12, color: Colors.orange)),
            ]),
          ),
      ],
    );
  }
}

class _VistaManual extends StatelessWidget {
  final List<String> participantes;
  final Map<String, TextEditingController> controladores;
  const _VistaManual({required this.participantes, required this.controladores});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: participantes.map((p) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          controller: controladores[p],
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
          decoration: InputDecoration(
            labelText: p,
            prefixText: '\$  ',
            prefixStyle: const TextStyle(color: kPrimary, fontWeight: FontWeight.bold),
            suffixText: 'MXN',
          ),
        ),
      )).toList(),
    );
  }
}

// ─── PANTALLA 2: RESULTADOS ────────────────────────────────────────────────────
class PantallaResultados extends StatelessWidget {
  final double total;
  final Map<String, double> montos;
  final String modo;

  const PantallaResultados({
    super.key,
    required this.total,
    required this.montos,
    required this.modo,
  });

  String get _modoLabel => switch (modo) {
    'porcentaje' => 'Por porcentaje',
    'manual'     => 'Montos manuales',
    _            => 'División igual',
  };


  // Colores para los avatares
  Color _colorAvatar(int index) {
    const colores = [kPrimary, kGreen, Color(0xFFFF9800), Color(0xFFE91E63),
                     Color(0xFF2196F3), Color(0xFF795548)];
    return colores[index % colores.length];
  }

  @override
  Widget build(BuildContext context) {
    final participantes = montos.keys.toList();

    return Scaffold(
      body: Column(children: [

        // ── Encabezado morado ──────────────────────────────────
        Container(
          width: double.infinity,
          color: kPrimary,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 16,
            bottom: 24, left: 20, right: 20,
          ),
          child: Column(children: [
            Row(children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Expanded(
                child: Text('Resultados',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 18,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 48),
            ]),
            const SizedBox(height: 16),
            Text('Total de la cuenta',
                style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13)),
            const SizedBox(height: 4),
            Text('\$${_fmt(total)} MXN',
                style: const TextStyle(color: Colors.white, fontSize: 32,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${participantes.length} personas  ·  $_modoLabel',
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
          ]),
        ),

        // ── Lista de participantes ─────────────────────────────
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text('Lo que paga cada quien',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 12),
              ...participantes.asMap().entries.map((entry) {
                final i      = entry.key;
                final nombre = entry.value;
                final monto  = montos[nombre] ?? 0;
                final pct    = total > 0 ? monto / total : 0;
                final color  = _colorAvatar(i);
                final iniciales = nombre.length >= 2
                    ? nombre.substring(0, 2).toUpperCase()
                    : nombre.toUpperCase();

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: Row(children: [
                    CircleAvatar(
                      backgroundColor: color,
                      child: Text(iniciales,
                          style: const TextStyle(color: Colors.white,
                              fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(nombre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct.toDouble(),
                            backgroundColor: const Color(0xFFEEEEEE),
                            color: color,
                            minHeight: 5,
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('\$${_fmt(monto)}',
                          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('${(pct * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ]),
                  ]),
                );
              }),

              const SizedBox(height: 20),

              // ── Botón copiar ───────────────────────────────
              OutlinedButton.icon(
                onPressed: () {
                  final sb = StringBuffer();
                  sb.writeln('Cuenta dividida — \$${_fmt(total)} MXN');
                  montos.forEach((n, m) => sb.writeln('$n: \$${_fmt(m)} MXN'));
                  Clipboard.setData(ClipboardData(text: sb.toString()));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Resumen copiado al portapapeles ✓'),
                        backgroundColor: kPrimary),
                  );
                },
                icon: const Icon(Icons.copy_outlined, size: 18),
                label: const Text('Copiar resumen'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPrimary,
                  side: const BorderSide(color: kPrimary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ]),
    );
  }
}

// ─── WIDGETS REUTILIZABLES ─────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 2),
    child: Text(text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
            color: Colors.grey, letterSpacing: 0.5)),
  );
}

class _ToggleBtn extends StatelessWidget {
  final String label, valor, actual;
  final void Function(String) onTap;
  const _ToggleBtn(this.label, this.valor, this.actual, this.onTap);
  @override
  Widget build(BuildContext context) {
    final activo = actual == valor;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(valor),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: activo ? kPrimary : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: activo ? kPrimary : const Color(0xFFDDDDDD)),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: activo ? Colors.white : Colors.grey,
                  fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

// ─── UTILIDAD ──────────────────────────────────────────────────────────────────
String _fmt(double n) {
  if (n == n.roundToDouble()) return n.toStringAsFixed(2);
  return n.toStringAsFixed(2);
}
