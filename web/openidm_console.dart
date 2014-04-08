
import 'package:angular/angular.dart';
import 'package:angular/angular_dynamic.dart';
import 'package:frangular/form/oi_form.dart';
import 'package:frangular/service/oi_service.dart';
import 'package:frangular/idmui/idmui.dart';

import 'package:angular_ui/angular_ui.dart';

import 'package:logging/logging.dart';



@NgController(selector: '[openidm-controller]', publishAs: 'ctrl')
class OpenIDMController {
  bool isAuthenticated = true;

  void logout() {
    isAuthenticated = false;
  }
}


class OpenIDMConsole extends Module {
  OpenIDMConsole() {
    install(new AngularUIModule());
    install(new OIServiceModule());
    install(new OIFormModule());
    install(new IDMUIModule());
    type(OpenIDMController);
    //type(ServerConfig);
    //type(Profiler, implementedBy: Profiler);
  }
}


void main() {

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  ngDynamicApp().addModule(new OpenIDMConsole()).run();
}
