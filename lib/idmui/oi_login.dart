part of idmui;


@NgComponent(selector: 'oi-login', publishAs: 'ctrl', templateUrl: 'packages/frangular/idmui/oi_login.html', cssUrl: 'packages/frangular/frangular.css', applyAuthorStyles: true)
class OILogin {

  String url = "http://openam.example.com/openidm";
  String username = "openidm-admin";
  String password = "openidm-admin";

  String message; // feedback message for testing the connection
  OIService _svc;
  Http _http;

  @NgTwoWay("isAuthenticated")
  bool  isAuthenticated;

  OIServiceConfig _svcConfig;

  OILogin(this._svc, this._http) {
    log.finest("OILogin init");
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

  authenticate() {
    log.finest("Authenticate");
    var c = new OIServiceConfig.withConfig(url, username, password);
    _svc.setServiceConfig(c);
    // todo: we actually dont check the connection right now.... We should check first...
    isAuthenticated = true;
  }

  // User has updated the connection. Test connection
  // todo: Ping is not a good test -
  void testConnection() {
    var c = new OIServiceConfig.withConfig(url, username, password);
    var svc = new OIService(_http, c);
    svc.ping().then((HttpResponse r) {
      //svc.credentialCheck().then( (HttpResponse r) {
      if (r.status == 200) message = "OpenIDM Service is OK"; else message = "OpenIDM Service Error:  ${r.status}";
    });
  }

}
