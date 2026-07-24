import 'package:flutter/material.dart';
import 'package:functional_parenting/core/theme/app_theme.dart';

/// The four behavior functions, shared by the Behavior Decoder worksheet and
/// the Action Plan's "Identify the Function" step. (label, description)
const kBehaviorFunctions = <(String, String)>[
  ('Attention', 'Seeking connection or interaction'),
  ('Escape', 'Trying to avoid something difficult'),
  ('Access', 'Trying to obtain something they want'),
  ('Regulation / Sensory', 'Managing emotions or sensory input'),
];

enum WorksheetInput { text, choice }

/// One question inside a worksheet.
class WorksheetQuestion {
  final String key;
  final String prompt;

  /// Muted example text shown under the prompt to prime the answer.
  final String? examples;
  final WorksheetInput input;

  /// (label, description) options for a single-select question.
  final List<(String, String)> options;

  const WorksheetQuestion({
    required this.key,
    required this.prompt,
    this.examples,
    this.input = WorksheetInput.text,
    this.options = const [],
  });
}

/// A phase worksheet, surfaced as a tool on the Tools screen and rendered by
/// the generic WorksheetScreen. Distilled from the toolkit's fill-in worksheets.
class WorksheetTool {
  final String id;
  final String phaseEyebrow;
  final String title;
  final String subtitle; // tool-tile subtitle
  final IconData icon;
  final Color iconColor;
  final String intro;
  final List<WorksheetQuestion> questions;

  const WorksheetTool({
    required this.id,
    required this.phaseEyebrow,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.intro,
    required this.questions,
  });
}

WorksheetTool? worksheetById(String id) {
  for (final w in kWorksheets) {
    if (w.id == id) return w;
  }
  return null;
}

const kWorksheets = <WorksheetTool>[
  WorksheetTool(
    id: 'parent_trigger_map',
    phaseEyebrow: 'Phase 1 · Reset the Parent',
    title: 'Parent Trigger Map',
    subtitle: 'Spot the moments that push you into reacting',
    icon: Icons.map_outlined,
    iconColor: kBlueDeep,
    intro:
        'Certain behaviors, situations, or times of day can quickly push us '
        'into a reactive state. Naming yours is the first step toward '
        'responding more intentionally.',
    questions: [
      WorksheetQuestion(
        key: 'behaviors',
        prompt: 'What behaviors tend to trigger the strongest reaction in you?',
        examples:
            'e.g. refusing directions, arguing or talking back, whining, '
            'sibling conflict, ignoring requests',
      ),
      WorksheetQuestion(
        key: 'when',
        prompt: 'When do these situations usually happen?',
        examples:
            'e.g. morning routines, homework time, bedtime, transitions '
            'between activities, when you’re already stressed or tired',
      ),
      WorksheetQuestion(
        key: 'reaction',
        prompt: 'How do you usually react in these moments?',
        examples:
            'e.g. raising your voice, repeating yourself, threatening '
            'consequences, giving in out of exhaustion',
      ),
      WorksheetQuestion(
        key: 'practice',
        prompt: 'What response would you like to practice instead?',
        examples:
            'e.g. pausing before responding, lowering your voice, giving one '
            'clear instruction, stepping away briefly first',
      ),
    ],
  ),
  WorksheetTool(
    id: 'parenting_goal_clarifier',
    phaseEyebrow: 'Phase 2 · Define the Goal',
    title: 'Parenting Goal Clarifier',
    subtitle: 'Turn a frustrating behavior into a skill to build',
    icon: Icons.flag_outlined,
    iconColor: kSageDeep,
    intro:
        'Move from focusing on a frustrating behavior to naming the skill you '
        'want your child to develop instead. Pick one behavior and work '
        'through it.',
    questions: [
      WorksheetQuestion(
        key: 'behavior',
        prompt: 'What behavior has been the most challenging recently?',
        examples:
            'e.g. whining, arguing, refusing directions, tantrums, '
            'ignoring requests',
      ),
      WorksheetQuestion(
        key: 'when',
        prompt: 'When does this behavior usually happen?',
        examples:
            'e.g. morning routines, homework time, bedtime, transitions, when '
            'your child is tired or hungry',
      ),
      WorksheetQuestion(
        key: 'skill',
        prompt: 'What skill might your child still be learning?',
        examples:
            'e.g. asking for help appropriately, managing frustration, '
            'accepting limits, transitioning between activities, communicating '
            'needs clearly, waiting patiently',
      ),
      WorksheetQuestion(
        key: 'goal',
        prompt: 'What goal would you like to work toward with your child?',
        examples:
            'Describe the positive skill you want to see — e.g. “My child asks '
            'for help using calm words.”',
      ),
    ],
  ),
  WorksheetTool(
    id: 'behavior_decoder',
    phaseEyebrow: 'Phase 3 · Identify the Function',
    title: 'Behavior Decoder',
    subtitle: 'Work out the most likely reason behind a behavior',
    icon: Icons.search_rounded,
    iconColor: kBlueDeep,
    intro:
        'Choose one challenging behavior and use these questions to identify '
        'its most likely function.',
    questions: [
      WorksheetQuestion(
        key: 'behavior',
        prompt: 'What behavior are you noticing?',
        examples:
            'e.g. whining, arguing, refusing directions, tantrums, '
            'ignoring requests',
      ),
      WorksheetQuestion(
        key: 'when',
        prompt: 'When does this behavior usually happen?',
        examples:
            'Think about the situation around it — e.g. during homework, when '
            'transitioning between activities, when attention is focused '
            'elsewhere, when tired or overwhelmed',
      ),
      WorksheetQuestion(
        key: 'function',
        prompt: 'What might your child be trying to accomplish?',
        input: WorksheetInput.choice,
        options: kBehaviorFunctions,
      ),
      WorksheetQuestion(
        key: 'response',
        prompt: 'What response might better support your child?',
        examples:
            'e.g. offering brief attention first, breaking a task into smaller '
            'steps, setting clear expectations, helping your child calm down '
            'before problem-solving',
      ),
    ],
  ),
  WorksheetTool(
    id: 'structure_builder',
    phaseEyebrow: 'Phase 4 · Build the Structure',
    title: 'Structure Builder',
    subtitle: 'Find where a little structure makes the day easier',
    icon: Icons.dashboard_outlined,
    iconColor: kSageDeep,
    intro:
        'Identify one or two areas where adding structure could reduce stress '
        'and prevent behavior challenges. You don’t need to change everything '
        'at once.',
    questions: [
      WorksheetQuestion(
        key: 'chaotic',
        prompt: 'Which parts of the day feel the most chaotic or stressful?',
        examples:
            'e.g. getting ready in the morning, homework time, mealtime, '
            'transitions between activities, bedtime routines',
      ),
      WorksheetQuestion(
        key: 'unclear',
        prompt: 'What expectations might be unclear during these times?',
        examples:
            'e.g. when homework should start, how long screen time lasts, what '
            'needs to happen before bedtime, what tasks come before play',
      ),
      WorksheetQuestion(
        key: 'structure',
        prompt: 'What simple structure could make this clearer?',
        examples:
            'e.g. creating a simple routine, setting a consistent time, giving '
            'a transition warning, using a checklist or visual reminder',
      ),
      WorksheetQuestion(
        key: 'thisweek',
        prompt: 'What will you try implementing this week?',
        examples:
            'Choose one small, consistent change to start with — small changes '
            'often have the biggest impact over time.',
      ),
    ],
  ),
];
