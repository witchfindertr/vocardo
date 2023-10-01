import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocardo/core/service/card/current_card_provider.dart';
import 'package:record/record.dart';
import 'package:vocardo/core/widget/recording_dialog_widget.dart';

import '../../core/service/card/card_service.dart';

class PracticePage extends ConsumerStatefulWidget {
  const PracticePage({Key? key}) : super(key: key);
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PracticePageState();
}

class _PracticePageState extends ConsumerState<PracticePage> {
  bool showAnswer = false;

  @override
  Widget build(BuildContext context) {
    final card = ref.watch(currentCardProvider);

    return Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(
              child: card.when(data: (card) {
                if (card == null) {
                  return const Text("No cards");
                }
                return Card(
                    child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Center(
                      child: Text(showAnswer ? card.answer : card.question,
                          style: Theme.of(context).textTheme.headlineLarge),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            showRecordingDialog(context);
                          },
                          icon: const Icon(Icons.mic),
                        ),

                        // Play button
                        IconButton(
                          onPressed: () async {
                            AudioPlayer audioPlayer = AudioPlayer();
                            final cardService =
                                await ref.read(cardServiceProvider.future);
                            final audioData =
                                await cardService.getSound(card.id);
                            if (audioData == null) {
                              return;
                            }
                            await audioPlayer.play(
                                BytesSource(Uint8List.fromList(audioData)));
                          },
                          icon: const Icon(Icons.volume_up),
                        ),

                        /// Recording button
                        IconButton(
                          onPressed: () async {
                            setState(() {
                              showAnswer = !showAnswer;
                            });
                          },
                          icon: const Icon(Icons.replay),
                        ),
                      ],
                    ),
                  ],
                ));
              }, error: (_, __) {
                return const Text("Error");
              }, loading: () {
                return const Text("Loading");
              }),
            ),
            SizedBox(
              height: 64,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text("HARD"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text("OK"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(currentCardProvider.notifier).next();
                        setState(() {
                          showAnswer = false;
                        });
                      },
                      child: const Text("EASY"),
                    ),
                  )
                ],
              ),
            )
          ]),
        ));
  }
}
