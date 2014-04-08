part of oi_service;


// Holds Service credentials and endpoint for communicating to openidm
class OIServiceConfig {
  String  username = "openidm-admin";
  String  password = "openidm-admin";
  //String  url = "http://localhost:8080/openidm";
  String  url = "http://openam.example.com/openidm";


  OIServiceConfig.withConfig([this.url = "http://openam.example.com/openidm",this.username ="tst",this.password = "test"]);

  // Need a new no-arg constructor for DI.
  OIServiceConfig();

  loadConfigFromDB() {
    var _db = new Store('openidm','authconfig');
   // _db.getByKey("url").then( (v) => print(v));
   log.finest("Loading config from storage");
   _db.open()
    .then((_) => _db.exists("config"))
    .then( (x)  {
      if(x) {
        _db.getByKey("config").then( (v) => _setConfig(v));
      }
      else
        log.finest("No saved config found");
   });
  }

  _configMap() => { "username" : username, "password": password, "url": url };

  _setConfig(String json) {
    var m = JSON.decode(json) as Map;
    username = m['username'];
    password = m['password'];
    url = m['url'];
  }

  saveConfigToDB() {
    var _db = new Store('openidm','authconfig');
    var j = JSON.encode(_configMap());
    log.finest("saving openidm config = $j");
    _db.open()
      .then( (_) => _db.save(j,"config"));
  }
}
