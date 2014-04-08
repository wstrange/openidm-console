library frangular;

import 'package:angular/angular.dart';
import 'package:angular/angular_dynamic.dart';
import 'package:frangular/server_config.dart';
import 'package:frangular/form/oi_form.dart';
import 'package:frangular/service/oi_service.dart';
import 'package:frangular/idmui/idmui.dart';

import 'package:angular_ui/angular_ui.dart';

import 'contractor.dart';

import '../lib/idmui/new_user.dart';

import 'package:logging/logging.dart';




var log = new Logger("frangular");

@NgController(selector: '[frangular]', publishAs: 'ctrl')
class FrangularController {
  OIService svc;

  String manager = "manager1";
  List workflows = [];
  List runningWorkflows = [];
  String statusMsg = "";


  WFContext context = new WFContext();


  FrangularController(this.svc) {
    //svc.getManager().then((m) => manager = m);
    listWorkflows();
  }


  listWorkflows() {
    svc.queryAvailableWorkflows().then((v) => workflows = v);
    svc.queryAllRunningProcessInstances().then( (v) => runningWorkflows = v);
  }

  //var wid = "contractorOnboardingSimple:3:211";
  //var wid = "contractorOnboarding";
  //var wid = "Contractor onboarding process";

  //var wid = "simpleContractorOnboarding:1:403";
  var wid = "createUser";


  launchWorkflow() {

    var m = { "userName": "foo2", "description": "test",
              "password": "Passw0rd", "givenName": "Fred", "familyName": "Flinstone", "email":"fred2@foo.com"};

    log.fine("Context vars = ${context.variables}");
    svc.createProcessInstance(wid,context.variables).then((r) {
    //svc.createProcessInstance(wid,m).then((r) {
      statusMsg = r.toString();
    });
  }

  launchContractor() {

  }

  String url = "fpp";

  String get serverUrl => url;
}

class Frangular extends Module {
  Frangular() {
    install(new AngularUIModule());
    install(new OIServiceModule());
    install(new OIFormModule());
    install(new IDMUIModule());

    type(FrangularController);
    type(ServerConfig);
    type(Contractor);
    type(NewUser);

    //type(Profiler, implementedBy: Profiler);
  }
}

void main() {

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  ngDynamicApp().addModule(new Frangular()).run();
}
