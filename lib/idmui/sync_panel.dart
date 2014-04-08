part of idmui;

@NgComponent(selector: 'sync-panel', templateUrl: 'packages/frangular/idmui/sync_panel.html', publishAs: 'ctrl', cssUrl: 'packages/frangular/frangular.css', applyAuthorStyles: true)
class SyncPanel {

  OIService _svc;

  String status = "";

  // Map of recon info keyed by recon id.
  Map<String, Map> reconInfoMap = {};
  // List of recon Info.  (copy of the above map.values)
  // We need this because angular does not yet allow iteration over map.values
  List<Map> reconInfo = [];


  // IDM will return a list. Each item in the list is a map
  // sample:
  // {name: managedUser_systemCustomerdb, source: managed/user, target: system/customerdb/account, ...}
  // the items we care about now are the name, source and target
  List<Map> syncList = [];

  SyncPanel(this._svc) {
    getSyncConfig();
    updateSyncStatus();
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
        var mapping = item['name'];
        _svc.syncStart(mapping).then((r) {
          status = r.toString();
          var json = r.responseText;
          var id = json["_id"];
        });
      }
    });
    updateSyncStatus();
  }

  // Query OpenIDM to get sync status
  updateSyncStatus() {
    _svc.getSyncInfo().then((json) {
      var x = json['reconciliations'] as List;
      var m = {};
      x.forEach((item) {
        m[item['_id']] = item;
      });
      reconInfo = m.values.toList();
      reconInfoMap = m;
    });
  }

  // get tooltip hover text
  String getTooltip(String id) => "$id \n" + (reconInfoMap[id])['progress'].toString();

  void cancelSync(String id) {
    log.finest("Cancel sync operation for $id");
    _svc.cancelRecon(id).then( (r) {
      log.finest("Cancel results $r");
      //if (r['status'] != 'SUCCESS')  // what to do??
      // todo: We could do a partial update here... but for now lets just refresh all the recon info
      updateSyncStatus();
    });
  }

  // Calculate the % completed for a recon operation
  // [m] is the progress map passed back from OpenIDM

  int syncCompletedPercent(Map m) {
    var ts = int.parse(m['source']['existing']['total']);
    // for some reason this passed as an int
    var ps = m['source']['existing']['processed'];

    return ((ps / ts) * 100).round();

  }
}
