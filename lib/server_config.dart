
library server_config;
import 'package:angular/angular.dart';


@NgComponent(
    selector: 'server',
    templateUrl: 'packages/frangular/server_config.html',
    publishAs: 'ctrl',
    cssUrl: 'packages/frangular/frangular.css',
    applyAuthorStyles: true,
    map:  const { 'url': '<=>url' }
)
class ServerConfig {
  String  url = 'http://openam.example.com/openam';
  String p = "XX";
}