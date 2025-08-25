import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'audioscreen.dart';
import 'data/audio_decoder.dart'; // <-- make sure this import path is correct

class AppBarDemo extends StatefulWidget {
  const AppBarDemo({super.key});

  @override
  State<AppBarDemo> createState() => _AppBarDemoState();
}

class _AppBarDemoState extends State<AppBarDemo>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
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
                controller: _tabController,
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
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AudioScreen(audioPath: "assets/hidden_message.wav"),   // <-- Tab 1
          MessageScreen() // <-- Tab 2
        ],
      ),
    );
  }
}

//
// ------------------- MainScreen -------------------
//
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "This is the Home Screen",
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }
}

//
// ------------------- MessageScreen -------------------
//
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700], // grey background
                  foregroundColor: Colors.white,     // text (and icon) color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // 20 radius corners
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(isDecoding ? "Decoding..." : "Decode Audio"),
              ),


            const SizedBox(height: 12),

            // Logs panel
            AnimatedContainer(
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
