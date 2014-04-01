part of oi_form;

@NgComponent(selector: 'oi-text', templateUrl:
    'packages/frangular/form/oi_text.html', publishAs: 'f', cssUrl:
    'packages/frangular/frangular.css', applyAuthorStyles: true)
class OIText {
  var value;

  @NgAttr("label")
  String label;

  @NgAttr("key")
  String key;


  NgModel ngModel;
  OIForm form;

  String foo;

  html.Element element;

  OIText(this.ngModel, this.element) {

    log.finest("Model = $ngModel form=$form element=$element");
    ngModel.render = renderModel;
  }

  void renderModel(v) {
    log.finest("_render $v");
    element.innerHtml = "xxxx";
  }
}
