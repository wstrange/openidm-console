part of oi_form;

@NgComponent(
    selector: 'oi-textfield',
    templateUrl: 'packages/frangular/form/oi_textfield.html',
    publishAs: 'f',
    cssUrl: 'packages/frangular/frangular.css',
    map : const { "label" : "@label" , "key" : "@key" },
    applyAuthorStyles: true
)
class OITextField  extends OIField {
 var value;
 //@NgOneWayOneTime("label")
 String label;
 NgModel ngModel;

 OITextField(NgModel this.ngModel, OIForm form):super(form) {
   log.finest("Model = $ngModel");
   //ngModel.render = _render;
 }

  void _render(v) {
   log.finest("_render $v");
 }
}