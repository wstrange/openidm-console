import 'package:angular/angular.dart';
import 'package:frangular/form/oi_form.dart';
import 'package:frangular/service/oi_service.dart';


@NgComponent(
    selector: 'contractor',
    templateUrl: 'contractor.html',
    publishAs: 'c',
    cssUrl: 'packages/frangular/frangular.css'
)
class Contractor  {

  @NgTwoWay("context")
  WFContext wfcontext;

  Map<String,Object> models = {};
  //String models = "ff";
/*
  Scope _scope;

  @NgTwoWay("test")
  Map test = { "bar": "foo" };


  Contractor(this._scope) {
    _scope.$on("vars-updated", (ScopeEvent e) => myCallback(e) );
  }

  myCallback(ScopeEvent e) {
    e.currentScope.$dirty();
  }
  */
}