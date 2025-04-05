import 'package:textfield_tags/textfield_tags.dart';
import 'dart:math';
import 'package:flutter/material.dart';

/*
 * Dynamic Tags
 */
class ButtonData {
  final Color buttonColor;
  final String emoji;
  const ButtonData(this.buttonColor, this.emoji);
}

class TagSelectionScreen extends StatefulWidget {
  const TagSelectionScreen({Key? key}) : super(key: key);

  @override
  State<TagSelectionScreen> createState() => _TagSelectionScreenState();
}

class _TagSelectionScreenState extends State<TagSelectionScreen> {
  late double _distanceToField;
  final random = Random();
  late DynamicTagController<DynamicTagData<ButtonData>> _dynamicTagController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _distanceToField = MediaQuery.of(context).size.width;
  }

  @override
  void dispose() {
    super.dispose();
    _dynamicTagController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _dynamicTagController = DynamicTagController<DynamicTagData<ButtonData>>();
  }

  static final List<DynamicTagData<ButtonData>> _initialTags = [
    DynamicTagData<ButtonData>(
      'cat',
      const ButtonData(
        Color.fromARGB(255, 200, 232, 255),
        "😽",
      ),
    ),
    DynamicTagData(
      'penguin',
      const ButtonData(
        Color.fromARGB(255, 255, 201, 243),
        '🐧',
      ),
    ),
    DynamicTagData(
      'tiger',
      const ButtonData(
        Color.fromARGB(255, 240, 255, 200),
        '🐯',
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 74, 137, 92),
        centerTitle: true,
        title: const Text(
          'Dynamic Tag Demo...',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          TextFieldTags<DynamicTagData<ButtonData>>(
            textfieldTagsController: _dynamicTagController,
            initialTags: _initialTags,
            textSeparators: const [' ', ','],
            letterCase: LetterCase.normal,
            validator: (DynamicTagData<ButtonData> tag) {
              if (tag.tag == 'lion') {
                return 'Not envited per tiger request';
              } else if (_dynamicTagController.getTags!
                  .any((element) => element.tag == tag.tag)) {
                return 'Already in the club';
              }
              return null;
            },
            inputFieldBuilder: (context, inputFieldValues) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  controller: inputFieldValues.textEditingController,
                  focusNode: inputFieldValues.focusNode,
                  decoration: InputDecoration(
                    isDense: true,
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 74, 137, 92),
                        width: 3.0,
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 74, 137, 92),
                        width: 3.0,
                      ),
                    ),
                    helperText: 'Zootopia club...',
                    helperStyle: const TextStyle(
                      color: Color.fromARGB(255, 74, 137, 92),
                    ),
                    hintText: inputFieldValues.tags.isNotEmpty
                        ? ''
                        : "Register name...",
                    errorText: inputFieldValues.error,
                    prefixIconConstraints:
                    BoxConstraints(maxWidth: _distanceToField * 0.75),
                    prefixIcon: inputFieldValues.tags.isNotEmpty
                        ? SingleChildScrollView(
                      controller: inputFieldValues.tagScrollController,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                          children: inputFieldValues.tags
                              .map((DynamicTagData<ButtonData> tag) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(20.0),
                                ),
                                color: tag.data.buttonColor,
                              ),
                              margin:
                              const EdgeInsets.symmetric(horizontal: 5.0),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5.0),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    child: Text(
                                      '${tag.data.emoji} ${tag.tag}',
                                      style: const TextStyle(
                                          color:
                                          Color.fromARGB(255, 0, 0, 0)),
                                    ),
                                    onTap: () {
                                      // print("${tag.tag} selected");
                                    },
                                  ),
                                  const SizedBox(width: 4.0),
                                  InkWell(
                                    child: const Icon(
                                      Icons.cancel,
                                      size: 14.0,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                    onTap: () {
                                      inputFieldValues.onTagRemoved(tag);
                                    },
                                  )
                                ],
                              ),
                            );
                          }).toList()),
                    )
                        : null,
                  ),
                  onChanged: (value) {
                    final getColor = Color.fromARGB(
                        random.nextInt(256),
                        random.nextInt(256),
                        random.nextInt(256),
                        random.nextInt(256));
                    final button = ButtonData(getColor, '✨');
                    final tagData = DynamicTagData(value, button);
                    inputFieldValues.onTagChanged(tagData);
                  },
                  onSubmitted: (value) {
                    final getColor = Color.fromARGB(
                        random.nextInt(256),
                        random.nextInt(256),
                        random.nextInt(256),
                        random.nextInt(256));
                    final button = ButtonData(getColor, '✨');
                    final tagData = DynamicTagData(value, button);
                    inputFieldValues.onTagSubmitted(tagData);
                  },
                ),
              );
            },
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                const Color.fromARGB(255, 74, 137, 92),
              ),
            ),
            onPressed: () {
              _dynamicTagController.clearTags();
            },
            child: const Text(
              'CLEAR TAGS',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}