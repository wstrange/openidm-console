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


}