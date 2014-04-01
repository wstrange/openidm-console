part of idmui;

/**
 * Server settings
 */
//@NgComponent(selector: 'oi-settings', templateUrl: 'packages/frangular/idmui/oi_settings.html', publishAs: 'ctrl', cssUrl: 'packages/frangular/frangular.css', applyAuthorStyles: true)

@NgController(selector: '[modal-settings-ctrl]', publishAs: 'ctrl')
class OISettings {
  String url = "http://openam.example.com/openidm";
  String username = "openidm-admin";
  String password = "openidm-admin";

  String tmp;
  Modal modal;
  ModalInstance modalInstance;
  Scope scope;
  String message; // feedback message for testing the connection
  OIService _svc;
  Http  _http;

  OIServiceConfig _svcConfig;

  OISettings(this.modal, this.scope,this._svc,this._http) {
    _svcConfig = _svc.serviceConfig;
   reset();
  }

  // copy current configuration service config
  reset() {
    message = null;
    url = _svcConfig.url;
    username = _svcConfig.username;
    password = _svcConfig.password;
  }

  void open(String templateUrl) {
    log.finest("Template url $templateUrl");
    reset();
    modalInstance = modal.open(new ModalOptions(templateUrl: templateUrl), scope);

    modalInstance.result.then((value) {
      log.fine('Closed dialog = $url');
      _svc.setServiceConfig( new OIServiceConfig.withConfig(url, username, password));
    }, onError: (e) {
      log.fine('Dismissed with $e');
    });
  }

  // User has updated the connection. Test them out
  void testConnection() {
    var c = new OIServiceConfig.withConfig(url,username,password);
    var svc = new OIService(_http, c);
    svc.ping().then( (HttpResponse r) {
    //svc.credentialCheck().then( (HttpResponse r) {
      if( r.status == 200)
         message = "OpenIDM Service is OK";
      else
        message = "OpenIDM Service Error:  ${r.status}";
    });
  }

  void ok() {
    modalInstance.close("ok");
  }

}
