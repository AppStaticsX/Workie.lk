import 'package:flutter/material.dart';
import 'package:workie/widgets/simple_textfeild.dart';

class WorkExperienceBottomsheet extends StatefulWidget {
  final VoidCallback closeBottomSheet;

  const WorkExperienceBottomsheet({
    super.key,
    required this.closeBottomSheet
  });

  @override
  State<WorkExperienceBottomsheet> createState() => _WorkExperienceBottomsheetState();
}

class _WorkExperienceBottomsheetState extends State<WorkExperienceBottomsheet> {
  bool _isChecked = false;
  final TextEditingController titleController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  void _toggleCheck() {
    setState(() {
      _isChecked = !_isChecked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(12),
              topLeft: Radius.circular(12)
          )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    'Add Work Experience',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold
                    )
                ),
                IconButton(
                    onPressed: widget.closeBottomSheet,
                    icon: const Icon(
                      Icons.close,
                      size: 28,
                    )
                )
              ],
            ),

          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                  'Title *',
                style: TextStyle(
                  fontSize: 16
                ),
              ),
              const SizedBox(height: 4),
              SimpleTextfield(
                  controller: titleController,
                  hintText: 'Ex: Carpenter specialize in Cupboard Making',
                  obscureText: false,
                  paddingHorizontal: 0,
                  maxLines: 1,
                  focusBorderColor: Theme.of(context).colorScheme.inverseSurface
              ),
              const SizedBox(height: 30),
              const Text(
                'Company *',
                style: TextStyle(
                    fontSize: 16
                ),
              ),
              const SizedBox(height: 4),
              SimpleTextfield(
                  controller: titleController,
                  hintText: 'Ex: WooddieCraft Pvt. LTD',
                  obscureText: false,
                  paddingHorizontal: 0,
                  maxLines: 1,
                  focusBorderColor: Theme.of(context).colorScheme.inverseSurface
              ),
              const SizedBox(height: 30),
              const Text(
                'Location',
                style: TextStyle(
                    fontSize: 16
                ),
              ),
              const SizedBox(height: 4),
              SimpleTextfield(
                  controller: titleController,
                  hintText: 'Ex: Ambalangoda',
                  obscureText: false,
                  paddingHorizontal: 0,
                  maxLines: 1,
                  focusBorderColor: Theme.of(context).colorScheme.inverseSurface
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  InkWell(
                    onTap: (){
                      _toggleCheck();
                    },
                    child: Container(
                      height: 24,
                      width: 24,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          width: _isChecked? 1.5 : 2,
                          color: _isChecked? Colors.grey : Colors.white
                        )
                      ),
                      child: !_isChecked
                          ? Icon(Icons.check, size: 16, color: Colors.white,)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'I am currently working on this role',
                    style: Theme.of(context).textTheme.bodyLarge,
                  )
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Start Date *',
                style: TextStyle(
                    fontSize: 16
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            width: _isChecked? 1.5 : 2,
                            color: _isChecked? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2) : Colors.white
                        )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              'Month',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.normal
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Flexible(
                    flex: 1,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              width: _isChecked? 1.5 : 2,
                              color: _isChecked? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2) : Colors.white
                          )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Year',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.normal
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Start Date *',
                style: TextStyle(
                    fontSize: 16
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              width: _isChecked? 1.5 : 2,
                              color: _isChecked? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2) : Colors.white
                          )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Month',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.normal
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Flexible(
                    flex: 1,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              width: _isChecked? 1.5 : 2,
                              color: _isChecked? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2) : Colors.white
                          )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Year',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.normal
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}