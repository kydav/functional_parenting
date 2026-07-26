// Option lists for the ABC behavior-tracker form. Kept in one place so the
// form, the log display, and any future pattern/graphing work all read from
// the same canonical vocabulary.

const kSettingOptions = <String>[
  'Common living area',
  'A bedroom',
  'Bathroom',
  'Mealtime',
  'Car or transportation',
  'School or daycare',
  'Store or public place',
  'Family or friend’s home',
  'Community activity or event',
  'Outdoors or playground',
];

const kAntecedentOptions = <String>[
  'A direction or request was given',
  'They were told “no” or a limit was set',
  'A preferred activity was stopped',
  'A transition was announced or started',
  'They were asked to wait',
  'An item or activity was unavailable',
  'Adult attention moved elsewhere',
  'A difficult or disliked task was presented',
  'A sibling or peer conflict occurred',
  'Plans or routines changed unexpectedly',
  'They were corrected or given feedback',
  'They were left without an activity or unsure what to do',
  'No clear event or trigger',
];

const kBehaviorOptions = <String>[
  'Refused or did not follow the direction',
  'Argued, protested, or negotiated',
  'Whined or cried',
  'Yelled or screamed',
  'Had a tantrum or meltdown',
  'Hit, kicked, bit, or pushed',
  'Threw, knocked over, or damaged items',
  'Dropped or fell to the floor',
  'Ran away or left the area',
  'Grabbed or took an item',
  'Withdrew, hid, or shut down',
  'Engaged in repetitive or sensory behavior',
];

// The four behavior functions this tracker reasons about. Only the consequence
// drives the function, so each consequence maps to exactly one of these.
const kFnEscape = 'Escape/Avoidance';
const kFnAttention = 'Attention/Connection';
const kFnTangible = 'Tangible/Activity';
const kFnRegulation = 'Regulation/Overwhelm';

/// Canonical function order (stable across the graph bars).
const kTrackerFunctions = <String>[
  kFnEscape,
  kFnAttention,
  kFnTangible,
  kFnRegulation,
];

/// Each consequence → the function it points to. Selecting a consequence adds
/// one "point" to that function for the logged behavior. Insertion order is the
/// display order.
const kConsequenceFunctions = <String, String>{
  'The task, direction, or transition was delayed': kFnEscape,
  'They received adult attention, conversation, correction, or negotiation':
      kFnAttention,
  'They received the item, food, screen, or activity they wanted': kFnTangible,
  'They were moved to a quieter or less stimulating environment': kFnRegulation,
  'The task, direction, or transition was removed': kFnEscape,
  'They received comfort, reassurance, or physical closeness': kFnAttention,
  'They were allowed to continue a preferred activity longer': kFnTangible,
  'They received a calming or sensory support': kFnRegulation,
  'They received a break from the task, demand, or transition': kFnEscape,
  'A sibling or peer responded or interacted with them': kFnAttention,
  'The task was shortened, made easier, or partially completed for them':
      kFnEscape,
  'Noise, activity, or stimulation was reduced': kFnRegulation,
  'They received a different preferred item or activity': kFnTangible,
  'They were allowed to leave the task or situation': kFnEscape,
  'They were given time and space to regulate without receiving the requested '
          'item or avoiding a required task':
      kFnRegulation,
};

/// Consequence options in display order (derived from the function map).
final kConsequenceOptions = kConsequenceFunctions.keys.toList();

const kTriggerOptions = <String>[
  'Tired or did not sleep well',
  'Hungry or thirsty',
  'Sick, in pain, or physically uncomfortable',
  'Overstimulated by noise, crowds, or activity',
  'Routine was different than usual',
  'The family was rushed',
  'Recently stopped using a screen',
  'Difficulty communicating what they needed',
  'Conflict or stress happened earlier',
  'Too many demands or transitions occurred close together',
  'Excited or highly energized',
  'No additional trigger noticed',
  'Unsure',
];

const kResponseOptions = <String>[
  'Stayed calm and used brief language',
  'Repeated the direction or reminder',
  'Explained or reasoned with my child',
  'Offered a choice',
  'Used a first-then statement',
  'Used a timer, visual, or routine support',
  'Broke the task into smaller steps',
  'Helped my child complete the task',
  'Offered a short break',
  'Comforted or reassured my child',
  'Redirected to another behavior or activity',
  'Reduced attention to the behavior',
  'Gave a consequence or removed a privilege',
  'Negotiated or changed the original expectation',
  'Raised my voice, threatened, or argued',
  'Gave the item or removed the demand',
  'Asked another adult for help',
  'Other',
];

const kOutcomeOptions = <String>[
  'The behavior stopped quickly',
  'The behavior decreased gradually',
  'My child calmed or regulated',
  'My child used a more appropriate request',
  'My child completed the expectation',
  'My child completed part of the expectation',
  'My child accepted the limit or transition',
  'The behavior continued without much change',
  'The behavior became more intense',
  'The task or transition was delayed',
  'The task or transition was avoided',
  'My child received the item or activity',
  'The situation ended without resolution',
  'Unsure',
];
