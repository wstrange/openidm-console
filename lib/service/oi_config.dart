part of oi_service;


// holds OpenIDM config
class OIConfig {

  Map _endpoints = {};
  // return map of endpoints. Map key is the endpoint name (e.g sendmail).
  // map value is the json config (_id, factory, etc.)
  Map get endpoints => _endpoints;

  List<String> _endpointList;
  List<String> get endpointList => _endpointList;

  // a Map of configured provisioners. Key is the provisioner name (e.g. ldap)
  // value is the config Map (contains pid, etc. - stuff we probably dont need right now)
  Map _connectors = {};
  Map<String, Map> get connectors => _connectors;

  List<String> _connectorList;
  // Angular wants a stable list - so we cant just use map.keys.toList();
  List<String> get connectorList => _connectorList;

  //List<String> provisionerList => _provisionerList ;

  // Create a OpenIDM config. Map m is the JSON config returned by calling openidm /config
  OIConfig(Map m) {
    String s;

    //log.finest("Parsing configurations: $m");
    m['configurations'].forEach((item) {
      String id = item['_id'];
      if (id.startsWith("endpoint/")) {
        _endpoints[id.substring(9)] = item; // strip off the endpoint/
      } else if (id.startsWith("provisioner.openicf/")) {
        // strip off the provisioner.openicf prefix
        var k = id.substring(20);
        _connectors[k] = item;
      }
    });
    this._connectorList = _connectors.keys.toList();
    this._endpointList = _endpoints.keys.toList();
  }

  String toString() => "endpoints: $_endpoints connectors: $connectorList";

}
