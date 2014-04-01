part of idmui;

@NgComponent(
    selector: 'oi-users',
       templateUrl: 'packages/frangular/idmui/oi_users.html',
       publishAs: 'ctrl',
       cssUrl: 'packages/frangular/frangular.css',
       applyAuthorStyles: true)
class OIUsers {
  OIService _svc;

  //@NgOneWay("users")
  //var users;

  Map<String,Map> userMap = {};

  Map selectedUser = {};

  List<Map> idList = [];

  OIUsers(OIService this._svc) {
    getUsers();
  }

  getUsers() {
    log.fine("fetching user list");
    idList = [];
    _svc.getUsersWithDetail().then( (l) {
      //userMap.clear();
      l.forEach(  (Map i)  {
        var id = i['_id'];
        i['selected'] = false; // add seleted attribute
        idList.add(i);
      });

    });
  }

  selectUser(Map u) {
    selectedUser = u;
  }

  unselect() {
    selectedUser = {};
  }

  selectToggle() =>
    idList.forEach( (m) => m['selected'] = ! m['selected'] );

  selectSet(bool v) => idList.forEach( (m) => m['selected'] = v);

  _toDelete() => idList.where( (item) => item['selected'] == true);

  deleteSelected() {
    var d = _toDelete();
    Future.wait( d.map( (x) => _deleteItem(x))).then( (r) {
      log.finest("deleted all items");
      idList = new List.from( idList.where( (i) => i['_delete'] == null ), growable: true);

    });
  }

  _deleteItem(Map item) {
    return _svc.deleteUser(item).then( (r) {
      log.finest("deleted status= ${r.status}");
      if( r.status == 204)
        item['_delete'] = true; // mark for deletion
    } )
    ;
  }
}