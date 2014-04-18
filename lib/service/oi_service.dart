library oi_service;

import 'package:angular/angular.dart';
import 'dart:async';
import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:lawndart/lawndart.dart';

part 'wf_context.dart';
part 'oi_service_config.dart';
part 'oi_config.dart';

class OIServiceModule extends Module {
  OIServiceModule() {
    type(OIService);
    type(OIServiceConfig);
    type(WFContext);
  }
}

var log = new Logger("OIService");

class OIService {

  Http _http;
  OIServiceConfig _serviceConfig;
  String get _url => _serviceConfig.url;
  OIServiceConfig get serviceConfig => _serviceConfig;

  var adminHeaders = {
    "Content-Type": "application/json"
  };

  // set the credentials to use for REST calls to OpenIDM
  setServiceConfig(OIServiceConfig c) {
    _serviceConfig = c;
    _setHeaders();
  }

  _setHeaders() {
    adminHeaders['X-OpenIDM-Username'] = _serviceConfig.username;
    adminHeaders['X-OpenIDM-Password'] = _serviceConfig.password;
  }


  OIService(this._http, this._serviceConfig) {
    _setHeaders();
  }

  // shorthand for GET calls
  // todo: Can we do more error handling here?
  Future<HttpResponse> _get(resource) {
    //log.finest("_get $adminHeaders" );
    return _http.get('$_url$resource', headers: adminHeaders);
  }

  // perform a GET - resturn the JSON response
  // todo: Is this really usefull? doesnt handle any errors...
  Future _getJSON(resource) => _get(resource).then((r) => r.responseText);

  Future<HttpResponse> _post(resource, [var data = ""]) => _http.post("$_url$resource", data, headers: adminHeaders);

  Future<Map> _postReturnJSON(resource, [var data = ""]) => _post(resource, data).then((r) => r.responseText);



  // Ping the OpenIDM service to see if it is alive. Return Future<true> if it is OK
  // Note that username/password are ignored. Anyone can ping openidm
  // This just tests if OpenIDM is up and responding
  Future<HttpResponse> ping() {
    return _get("/info/ping").then((resp) {
      return resp;
    });
  }

  // Get the openidm configuration
  Future<OIConfig> getConfig() => _getJSON("/config").then((m) => new OIConfig(m));

  // Check the status of the openidm server as well our credentials
  // Note: We dont use ping here because it does not test the credentials.
  // We test by doing a GET on the sync config
  // todo: We should find a less expensive call
  Future<HttpResponse> credentialCheck() {
    return _get("/config").then((resp) {
      return resp;
    }, onError: (e) {
      log.severe("Health Check Failed. Cause ${e.status}");
      return e;
    });
  }

  Future<List> getUsers() => _queryAllIds("/managed/user");

  // Query for all ids. If [justReturnIds] is true we return an array of just
  // the object ids (not any additional data that may be passed back)
  Future<List> _queryAllIds(String queryRoot, {bool justReturnIds: false}) {
    return _get("$queryRoot?_queryId=query-all-ids").then((val) {
      var r = val.responseText['result'];
      if (justReturnIds) {
        var ids = [];
        r.forEach((item) => ids.add(item['_id']));
        return ids;
      }
      return r;
    });
  }

  Future<Map> getUserDetail(String id) {
    return _get("/managed/user/$id").then((v) {
      return v.responseText;
    });
  }

  Future<List> getUsersWithDetail() {
    return getUsers().then((List ids) {
      return Future.wait(ids.map((x) => getUserDetail(x['_id']))).then((result) => result);
    });
  }

  Future deleteUser(Map m) {
    var id = m['_id'];
    var rev = m['_rev'];
    Map h = {
      "If-Match": '"${rev}"'
    };
    h.addAll(adminHeaders);
    log.finer("delete managed/user/$id rev=$rev");
    return _http.delete("$_url/managed/user/$id", headers: h).then((HttpResponse r) {
      log.finer("delete result $r");
      return r; //todo: should we return the status?
    });
  }

  Future<String> getManager() {
    return _http.request('$_url/endpoint/workflow?query=manager', method: "GET", requestHeaders: adminHeaders).then((val) {
      var manager = val.responseText;
      return manager;
    });
  }


  Future queryAvailableWorkflows() => _queryAllIds("workflow/processdefinition?_queryId=query-all-ids");

  /**
    * Launch a workflow instance.
    * [key] is the process id of the workflow (example: <process id="myWorkflow" name="test"/>
    * If there is more than one version of the workflow, the latest deployed one will be launched.
    * You can provide a [variables] map that will be passed to the workflow.
    * [businessKey] is an optional key value that can be used to query the running workflow process
    *
    */
  Future createProcessInstance(String key, Map<String, dynamic> variables, [String businessKey = null]) {
    var data = {
      "_key": key,
      "_businessKey": businessKey
    };
    data.addAll(variables);

    print('launch workflow instance $key with $data');

    return _http.request("$_url/workflow/processinstance?_action=createProcessInstance", method: "POST", requestHeaders: adminHeaders, sendData: JSON.encode(data)).then((r) => r.responseText);
  }

  Future queryProcessInstanceByKey(String businessKey) {
    return _http.request("$_url/workflow/processinstance?_queryId=filtered-query&businessKey=$businessKey", method: "POST", requestHeaders: adminHeaders).then((r) => r.responseText);
  }

  Future queryAllRunningProcessInstances() => _queryAllIds("/workflow/processinstance");

  // Returns a Future Map with the process status. The attributes in the map are
  // A sample map entry:
  // {_rev: 0, startTime: 2014-02-19T15:18:54.561Z, startUserId: openidm-admin,
  //  _id: 101, businessKey: null, durationInMillis: null, endTime: null,
  // superProcessInstanceId: null, processDefinitionId: contractorOnboarding:1:3, deleteReason: null}
  Future<Map> getProcessInstanceStatus(String id) => _getJSON("/workflow/processinstance/$id");


  Future stopProcessInstance(String id) => _http.delete("$_url/workflow/processinstance/$id", headers: adminHeaders).then((r) => r.responseText);


  Future<List> namedQuery(String query) {
    log.fine("named query = $query");
    // for now we just support all users query :-)
    return getUsers();
  }

  // Create a user on a target
  Future createUser(Map u) {
    var id = u["id"];
    u['_id'] = id;
    var p = JSON.encode(u);
    log.fine("create $id $p");
    return _http.post("$_url/system/customerdb/account?_action=create", p, headers: adminHeaders).then((r) {
      log.fine("Result = $r");
      return r;
    });
  }

  Future createManagedUser(Map u) {
    var id = u["id"];
    u['_id'] = id;
    var p = JSON.encode(u);
    log.fine("create $id $p");
    return _http.post("$_url/managed/user?_action=create", p, headers: adminHeaders).then((r) {
      log.fine("Result = $r");
      return r;
    });
  }

  Future createManagedUserCustomEndpoint(Map u) {
    var id = u["id"];
    u['_id'] = id;
    var p = JSON.encode(u);
    log.fine("create $id $p");
    return _http.post("$_url/endpoint/createuser", p, headers: adminHeaders).then((r) {
      log.fine("Result = $r");
      return r;
    });
  }

  Future deleteDBUser(String id) {
    log.fine("delete user $id");
    return _http.delete("$_url/system/customerdb/account/$id", headers: adminHeaders).then((r) {

      log.fine("Result = $r");
      return r;
    });
  }

  // Return a list of sync configuration objects
  // todo: show example
  Future<List> getSyncConfig() {
    return _get("/config/sync").then((r) {
      log.finest("sync config = $r");
      return r.responseText['mappings'];
    });
  }

  // Invoke recon on the given mapping
  Future<HttpResponse> syncStart(String mapping) {
    return _http.post("$_url/recon?_action=recon&mapping=$mapping", "", headers: adminHeaders).then((r) {
      log.finest("Recon result $r");
      return r;
    });
  }

  // Get recon info.
  // See http://openidm.forgerock.org/doc/integrators-guide/index/chap-synchronization.html#recon-over-rest
  // If [id] is provided this will fetch info for just that id. Otherwise -all recons will be fetched.
  // The recon [id] is returned when OpenIDM starts the sync process
  // Sample return values:
  // {reconciliations: [{_id: 76d744b0-f55b-4068-b786-992c1e691b6c, mapping: managedUser_systemLDAP, ....
  /* The progress attribute available for in-process recons:
   *
   *  "progress":{
  "source":{             // Progress on set of existing entries in the mapping source
    "existing":{
      "processed":1001,
        "total":"1001"   // Total number of entries in source set, if known, “?” otherwise
    }
  },
  "target":{             // Progress on set of existing entries in the mapping target
    "existing":{
      "processed":1001,
      "total":"1001"     // Total number of entries in target set, if known, “?” otherwise
    },
    "created":0          // New entries that were created
  },
  "links":{              // Progress on set of existing links between source and target
    "existing":{
      "processed":1001,
      "total":"1001"     // Total number of existing links, if known, “?” otherwise
    },
  "created":0            // Denotes new links that were created
  }

   */
  Future<Map> getSyncInfo([String id = null]) => (id == null ? _getJSON("/recon") : _getJSON("/recon/$id"));

  // Cancel an in progress recon operation
  Future<Map> cancelRecon(String id) => _postReturnJSON("/recon/$id&_action=cancel");

  // /system objects

  // get all ids for system.
  // [system] "ldap" for example
  // [objType] "account" or "group"
  Future<List> getSystemObjects(String system, String objType) => _queryAllIds("/system/$system/$objType");

  // get the specified system object.
  // Example getSystemObject("ldap","account","uid=xxxx....")
  // [id] is an identifier returned by [getSystemObjects]
  Future<Map> getSystemObject(String system, String objType, String id) => _getJSON("/system/$system/$objType/$id");
}

