part of idmui;

@NgComponent(selector: 'sync-panel', templateUrl: 'packages/frangular/idmui/sync_panel.html', publishAs: 'ctrl', cssUrl: 'packages/frangular/frangular.css', applyAuthorStyles: true)

class SyncPanel {

  OIService _svc;

  String status = "";

  // IDM will return a list. Each item in the list is a map
  // sample:
  // {name: managedUser_systemCustomerdb, source: managed/user, target: system/customerdb/account, ...}
  // the items we care about now are the name, source and target
  List<Map> syncList = [];

  SyncPanel(this._svc) {
    getSyncConfig();
  }

  // Call OpenIDM to get an updated list of the sync configuration
  getSyncConfig() {
    _svc.getSyncConfig().then((List m) {
      syncList = m;
      // add a 'selected' attribute to the map
      // we use this in the gui to toggle selection of the entry for sync
      syncList.forEach((item) {
        item['selected'] = false;
      });
    });
  }

  syncSelected() {
    syncList.forEach((item) {
      if (item['selected']) {
        _svc.syncStart(item['name']).then((r) {
          status = r.toString();
        });
      }
    });
  }

}
