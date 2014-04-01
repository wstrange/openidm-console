part of oi_form;

//import 'package:angular/angular.dart';


@NgComponent(
    selector: 'oi-select',
    templateUrl: 'packages/frangular/form/oi_select.html',
    publishAs: 'f',
    cssUrl: 'packages/frangular/frangular.css',
    applyAuthorStyles: true,
    //visibility: NgDirective.DIRECT_CHILDREN_VISIBILITY,
    map: const { "key" : "@key" }

)
class OISelect extends OIField with NgAttachAware {

  OIService _svc;

  @NgAttr("label")
  String label;

  @NgTwoWay("value")
  String value;

  @NgOneWay("options")
  List<String> options = [];

  // A named query to execute
  @NgAttr("namedQuery")
  String namedQuery;

  OISelect(OIForm f,this._svc):super(f) {

  }

  attach() {
    log.finest("OISelect attach()");
    _svc.namedQuery(namedQuery).then(  (opts) => options = opts);
  }

}