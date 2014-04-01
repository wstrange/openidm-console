part of oi_form;


@NgComponent(
    selector: 'oi-email',
    templateUrl: 'packages/frangular/form/oi_email.html',
    publishAs: 'f',
    cssUrl: 'packages/frangular/frangular.css',
    applyAuthorStyles: true,
    //visibility: NgDirective.DIRECT_CHILDREN_VISIBILITY,
    map: const { "key" : "@key" }

)
class OIEmail extends OIField  {



  @NgAttr("label")
  String label;

  @NgTwoWay("value")
  String value;

   OIEmail(OIForm f):super(f) ;

}