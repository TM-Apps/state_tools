import 'package:state_tools/state_tools.dart';

class FruitsState extends PersistableStateNotifier<String> with ListingSupport {
  FruitsState() : super('');

  @override
  String get listId => 'fruits';

  @override
  String getListItemId(String state) => state;

  @override
  String get id => state;

  @override
  Map<String, dynamic> toJson(String state) => {'value': state};

  @override
  String fromJson(Map<String, dynamic> json) => json['value'] as String;
}

const List<String> fruits = [
  'Apple',
  'Banana',
  'Orange',
  'Mango',
  'Watermelon',
  'Pineapple',
  'Grapes',
  'Strawberry',
  'Blueberry',
  'Raspberry',
  'Blackberry',
  'Cherry',
  'Lemon',
  'Lime',
  'Orange',
  'Mango',
  'Watermelon',
  'Pineapple',
  'Grapes',
  'Strawberry',
  'Blueberry',
  'Raspberry',
  'Blackberry',
  'Cherry',
  'Lemon',
  'Lime',
];
