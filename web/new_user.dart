library newuser;

import 'package:angular/angular.dart';
import 'package:frangular/service/oi_service.dart';

@NgComponent(selector: 'new-user', templateUrl: 'new_user.html', publishAs: 'ctrl',
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

  String statusMsg = "";

  reset() {
    //userName = "testx";
    password = "Passw0rd";
    email = "test@test.com";
    userrole = "mobile"; //default
    statusMsg = "";
  }

  submit() {
    print("create user for =$userName");
    var m = {
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

    //_svc.createManagedUser(m)
    _svc.createManagedUserCustomEndpoint(m)
      .then((result) => statusMsg = result.toString());

  }

  createUser() {
    var m = {
      "id": "1",
      "firstname": "Warren",
      "lastname": "Strange",
      "userrole": "testrole",
      "uid": "test1"
    };
    _svc.createUser(m);
  }
}
