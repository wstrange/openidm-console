part of idmui;

@NgComponent(
    selector: 'oi-config-panel',
       templateUrl: 'packages/frangular/idmui/oi_config_panel.html',
       publishAs: 'ctrl',
       cssUrl: 'packages/frangular/frangular.css',
       applyAuthorStyles: true)
class OIConfigPanel {

  OIService _svc;
  OIConfig config;
  String selectedConnector = "";
  String objectId = "";

  //List<String> get connectorList => config.connectorList;

  OIConfigPanel(this._svc) {
    getConfig();
  }

  void getConfig() {
    _svc.getConfig().then( (c) {
      config = c;
      log.finest("Connectors ${c.connectorList}");

    });
  }

  selectConnector() {
  }

  getSystemIds() {
    _svc.getSystemObjects(selectedConnector, "account").then((list) {
      log.finest("Got list $list");
    });
  }

  getSystemObject() {
    _svc.getSystemObject(selectedConnector, "account", objectId).then( (r) {
      log.finest("Result = $r");
    });
  }


}