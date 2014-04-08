library newuser;

import 'package:angular/angular.dart';
import 'package:frangular/service/oi_service.dart';
import 'package:quiver/async.dart';
import 'dart:async';

/*
 * Compoenent to create sample managed user.
 * Can also do bulk creation.
 * Fields with %i will be
 */
@NgComponent(selector: 'new-user', templateUrl: 'packages/frangular/idmui/new_user.html', publishAs: 'ctrl',
    cssUrl: 'packages/frangular/frangular.css',
    applyAuthorStyles: true)
class NewUser {

  OIService _svc;

  NewUser(this._svc) {
    reset();
  }

  String userName;
  String password;
  String email;
  String userrole; //default

  // true if we want to create a batch of users
  bool bulkCreate = false;
  int startIndex = 0;
  int count = 100;

  String statusMsg = "";

  reset() {
    //userName = "testx";
    password = "Passw0rd";
    email = "test@test.com";
    userrole = "mobile"; //default
    statusMsg = "";
  }

  Future _createUser(Map m) {
    return _svc.createManagedUser(m).then ((result) {
      statusMsg = result.toString();
    });
  }

  submit() {
    print("create user for =$userName");
    var template = {
      "userName": userName,
      "_id": userName,
      "id": userName,
      "email": email,
      "givenName": "Test",
      "familyName": "Tester",
      "commonName": "Common Tester Name",
      "userrole": userrole,
      "password": password,
      "displayName": "Testy Tester",
      "phoneNumber": "5551212"
    };

    if( ! bulkCreate ) // single user??
      _createUser(template);
    else {  // bulk create a bunch of users?
      // iterator creates a stream of user attr maps
      var iterator =  new Iterable.generate(count, (i) => _templateUser(template,i+startIndex));
      // forEachAsync waits for each one to complete before launching the next
      forEachAsync( iterator, (user) => _createUser(user), maxTasks: 5 );
    }
  }

  // create a new user attribute map based on the template.
  // Replace all strings '%i' with the value i
  Map _templateUser(Map<String,String> template, int i) {
    var m = {};
    template.forEach( (k,v) {
      m[k] = v.replaceAll(r'%i', i.toString());
    });
    return m;
  }


}
