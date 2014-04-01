library idmui;

import 'dart:async';
import 'package:angular/angular.dart';
import 'package:angular_ui/angular_ui.dart';

import 'package:frangular/service/oi_service.dart';

import 'package:logging/logging.dart';

part 'oi_users.dart';
part 'oi_settings.dart';
part 'sync_panel.dart';

part 'wf_instance.dart';

var log = new Logger("idmui");

class IDMUIModule extends Module {

  IDMUIModule() {
    type(OIUsers);
    type(WFInstance);
    type(OISettings);
    type(SyncPanel);
  }
}

