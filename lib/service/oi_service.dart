library oi_service;

import 'package:angular/angular.dart';
import 'dart:async';
import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:lawndart/lawndart.dart';

part 'wf_context.dart';


class OIServiceModule extends Module {
  OIServiceModule() {
    type(OIService);
    type(OIServiceConfig);
    type(WFContext);
  }
}

var log = new Logger("OIService");


// Holds Service credentials and endpoint for communicating to openidm
class OIServiceConfig {
  String  username = "openidm-admin";
  String  password = "openidm-admin";
  //String  url = "http://localhost:8080/openidm";
  String  url = "http://openam.example.com/openidm";
  var _db = new Store('openidm','authconfig');

  OIServiceConfig.withConfig(this.url,this.username,this.password) {
    saveConfig();
  }

  OIServiceConfig() {
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

   _db.open()
    .then( (_) => _db.all().listen( (v) => log.finest("val = $v")));
  }

  _configMap() => { "username" : username, "password": password, "url": url };
  _setConfig(String json) {
    var m = JSON.decode(json) as Map;
    username = m['username'];
    password = m['password'];
    url = m['url'];

  }

  saveConfig() {
    var j = JSON.encode(_configMap());
    log.finest("saving openidm config = $j");
    _db.open()
      .then( (_) => _db.save(j,"config"));
  }
}

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


  OIService(this._http,this._serviceConfig) {
    _setHeaders();
  }

  // shorthand for GET calls
  // todo: Can we do more error handling here?
  Future<HttpResponse> _get(resource) {
    //log.finest("_get $adminHeaders" );
    return _http.get('$_url$resource',headers: adminHeaders);
  }

  // Ping the OpenIDM service to see if it is alive. Return Future<true> if it is OK
  // Note that username/password are ignored. Anyone can ping openidm
  // This just tests if OpenIDM is up and responding
  Future<HttpResponse> ping() {
    return _get("/info/ping").then( (resp) {
      return resp;
    });
  }

  // Check the status of the openidm server as well our credentials
  // Note: We dont use ping here because it does not test the credentials.
  // We test by doing a GET on the sync config
  // todo: We should find a less expensive call
  Future<HttpResponse> credentialCheck() {
      return _get("/config/sync").then( (resp) {
        return resp;
      }, onError: (e) {
        log.severe("Health Check Failed. Cause ${e.status}");
        return e;
      } );
    }


  Future<List> getUsers() {
    //var t2 = "$_url/managed/user/?_queryId=query-all-ids";

    return _get("/managed/user/?_queryId=query-all-ids").then((val) {
      //print("response = $val");
      //var json = JSON.decode(val.responseText);
      var json = val.responseText; // get converts it for us...
      var r = json['result'];
      var ids = [];
      r.forEach((item) => ids.add(item['_id']));
      //print("ids = $ids");
      return ids;
    });
  }

  Future<Map> getUserDetail(String id) {
    return _get("/managed/user/$id").then((v) {
      return v.responseText;
    });
  }

  Future<List> getUsersWithDetail() {
    return getUsers().then((List ids) {
      return Future.wait(ids.map((id) => getUserDetail(id))).then((result) => result);
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


  Future queryAvailableWorkflows() => _http.get("$_url/workflow/processdefinition?_queryId=query-all-ids", headers: adminHeaders).then((r) => _queryResult(r));

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

  Future queryAllRunningProcessInstances() {
    return _get("/workflow/processinstance?_queryId=query-all-ids").then((r) => _queryResult(r));
  }


  // Returns a Future Map with the process status. The attributes in the map are
  // A sample map entry:
  // {_rev: 0, startTime: 2014-02-19T15:18:54.561Z, startUserId: openidm-admin,
  //  _id: 101, businessKey: null, durationInMillis: null, endTime: null,
  // superProcessInstanceId: null, processDefinitionId: contractorOnboarding:1:3, deleteReason: null}
  Future<Map> getProcessInstanceStatus(String id) {
    return _get("/workflow/processinstance/$id").then((r) => r.responseText);
  }

  Future stopProcessInstance(String id) => _http.delete("$_url/workflow/processinstance/$id", headers: adminHeaders).then((r) => r.responseText);

  // extract the query results
  // get appears to coerce responseText to a map if media type is JSON
  dynamic _queryResult(HttpResponse response) {
    if (response.responseText is Map) {
      return response.responseText["result"];
    } else {
      var m = JSON.decode(response.responseText) as Map;
      return m["result"];
    }
  }

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

  Future<List> getSyncConfig() {
    return _get("/config/sync").then( (r) {
      log.finest("sync config = $r");
      var  json = r.responseText;
      return json['mappings'];
    });
  }


  // Invoke recon on the given mapping
  Future syncStart(String mapping) {
    return _http.post("$_url/recon?_action=recon&mapping=$mapping", "", headers: adminHeaders ).then( (r) {
      log.finest("Recon result $r");
      return r;
    });
  }
}


