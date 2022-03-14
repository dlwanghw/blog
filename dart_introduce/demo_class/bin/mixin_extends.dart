
import 'base_another.dart';
import 'derivedb_class.dart';
import 'derivedc_class.dart';
import 'driveda_class.dart';
import 'multi_implement.dart';

class MixinMultiClass extends Object with MultiImplementDClass, DerivedBClass {

}

mixin OtherMultiClass on MultiImplementDClass,DerivedBClass {

}
