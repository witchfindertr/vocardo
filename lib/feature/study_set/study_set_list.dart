import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocardo/core/service/card/practice_card_list_provider.dart';
import 'package:vocardo/core/service/study_set/current_study_set_provider.dart';
import 'package:vocardo/core/service/study_set/study_set_list_provider.dart';
import 'package:vocardo/core/util/text_util.dart';
import 'package:vocardo/core/widget/dialog_widget.dart';
import 'package:vocardo/feature/card_list/card_list.dart';
import 'package:vocardo/feature/edit/edit.dart';
import 'package:vocardo/feature/practice/practice.dart';
import 'package:vocardo/feature/study_set/add_study_set_dialog.dart';

class StudySetListPage extends ConsumerWidget {
  const StudySetListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(studySetListProvider);

    return data.when(data: (sets) {
      if (sets.isEmpty) {
        return Center(
          child: ElevatedButton.icon(
            onPressed: () {
              showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (context) {
                    return const AddStudySetDialog();
                  });
            },
            label: const Text("CREATE A NEW SET"),
            icon: const Icon(Icons.add),
          ),
        );
      }

      return ListView.builder(
        itemBuilder: (context, index) {
          final set = sets[index];
          final completedCount = set.items.where((e) => e.quality == 5).length;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: () {
                ref.read(currentStudySetProvider.notifier).setStudySetId(set);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const CardListPage(),
                ));
              },
              child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(set.name,
                            style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 16),
                        Text(
                            "$completedCount / ${set.items.length} ${cardOrCards(set.items.length)}"),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                ref
                                    .read(currentStudySetProvider.notifier)
                                    .setStudySetId(set);
                                ref
                                    .read(practiceCardListProvider.notifier)
                                    .init();
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        const PracticePage()));
                              },
                              label: const Text(
                                "PRACTICE",
                              ),
                              icon: const Icon(Icons.play_arrow,
                                  color: Color.fromRGBO(255, 255, 255, 1)),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => EditPage(
                                    studySet: set,
                                  ),
                                ));
                              },
                              label: const Text(
                                "ADD",
                              ),
                              icon: const Icon(Icons.add,
                                  color: Color.fromRGBO(255, 255, 255, 1)),
                            ),
                            IconButton(
                                onPressed: () async {
                                  final yes = await showOkCancelDialog(context,
                                      content: "Are you sure?",
                                      title: "Delete");
                                  if (!yes) return;
                                  final studySetProvider =
                                      ref.read(studySetListProvider.notifier);
                                  studySetProvider.deleteStudySet(set.id);
                                },
                                icon: const Icon(Icons.delete)),
                          ],
                        )
                      ],
                    ),
                  )),
            ),
          );
        },
        itemCount: sets.length,
      );
    }, error: (error, stackTrace) {
      return Center(
        child: Text("failed to load data: $error"),
      );
    }, loading: () {
      return const Center(
        child: CircularProgressIndicator(),
      );
    });
  }
}
