import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../audioscreen.dart';
import '../data/audio_decoder.dart';

//───────────────────────────────────────────────────────────────────────────
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key, this.initialIndex = 0});
  final int initialIndex; // 0 = Home, 1 = Frequency Graph

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  PreferredSizeWidget buildMainAppBar(TabController controller) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Center(
          child: Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(40),
            ),
            child: TabBar(
              controller: controller,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(30),
              ),
              indicatorColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: "Home"),
                Tab(text: "Frequency Graph"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: buildMainAppBar(_tabController),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/blue.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: const [
            MessageScreen(),
            AudioScreen(audioPath: "assets/hidden_message.wav"),
          ],
        ),
      ),
    );
  }
}

/// ────────────────────────────────────────────────────────────────────────────
/// MESSAGE SCREEN – no AppBar here; it's provided by MainScaffold
/// ────────────────────────────────────────────────────────────────────────────
class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  String message = "";
  List<String> logs = [];
  List<double> spectrum = [];
  bool isDecoding = false;
  bool startedDecoding = false;

  void decode() async {
    setState(() {
      message = "";
      logs.clear();
      spectrum.clear();
      isDecoding = true;
      startedDecoding = true;
    });

    final decoder = AudioDecoder();
    await for (final step in decoder.decodeStream("assets/hidden_message.wav")) {
      setState(() {
        message += step.char;
        logs.add(
          "Window peak freq: ${step.freq.toStringAsFixed(2)} Hz -> "
              "nearest ${step.matchedFreq} Hz -> '${step.char}'",
        );
        spectrum = step.spectrum;
      });
      await Future.delayed(const Duration(milliseconds: 100));
    }

    setState(() {
      isDecoding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!startedDecoding)
              ElevatedButton(
                onPressed: isDecoding ? null : decode,
                child: Text(isDecoding ? "Decoding..." : "Decode"),
              ),
            const SizedBox(height: 12),

            // Logs panel
            AnimatedContainer
              (
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              height: 300,
              width: 400,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 15,
                    bottom: 15,
                    left: 15,
                    right: 15,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: ListView.builder(
                      itemCount: logs.length,
                      itemBuilder: (context, i) => Text(
                        logs[i],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Decoded message
            Text(
              "Decoded: $message",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            // Spectrum chart
            spectrum.isNotEmpty
                ? SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(show: false),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (int i = 0; i < spectrum.length; i++)
                          FlSpot(i.toDouble(), spectrum[i])
                      ],
                      isCurved: false,
                      color: Colors.blue,
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    )
                  ],
                ),
              ),
            )
                : const Text(
              "No spectrum yet",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
