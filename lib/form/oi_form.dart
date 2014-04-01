
library oi_form;

import 'package:angular/angular.dart';
import 'package:logging/logging.dart';
import 'dart:html' as html;
import 'package:frangular/service/oi_service.dart';


part 'oi_field.dart';

part 'oi_select.dart';
part 'oi_textfield.dart';
part 'oi_text.dart';
part 'oi_email.dart';



final log = new Logger('oi-components');

@NgComponent(
    selector: 'oi-form',
    templateUrl: 'packages/frangular/form/oi_form.html',
    publishAs: 'form',
    cssUrl: 'packages/frangular/frangular.css',
    applyAuthorStyles: true,
    visibility: NgDirective.DIRECT_CHILDREN_VISIBILITY
)
class OIForm {
  List<OIField> fields = [];

  @NgTwoWay("context")
  WFContext context;

  @NgTwoWay("test")
  Map test;

  Scope _scope;
  OIForm(this._scope);

  void submit() {
    print("Context Before =$context");
    context.variables.clear();
    test.clear();
    fields.forEach( (f) {
      print ("${f.key} =${f.value}");
      context.variables[f.key]= f.value;
      test[f.key] = f.value;
    });
    print("Context $context");

}

  void registerField(OIField field) {
    //print("register ${field.key}");
    fields.add(field);
  }


  noSuchMethod(Invocation msg) {
    print('msg = $msg');
  }

}


class OIFormModule extends Module {
  OIFormModule() {
      type(OIForm);
       type(OITextField);
       type(OISelect);
       type(OIService);
       type(OIEmail);
       type(OIText);
  }
}
