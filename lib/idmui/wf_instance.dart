part of idmui;

@NgComponent(selector: 'wf-instance', templateUrl:
    'packages/frangular/idmui/wf_instance.html', publishAs: 'ctrl', cssUrl:
    'packages/frangular/frangular.css', applyAuthorStyles: true)
// Renders a control for a running workflow instance.
class WFInstance {

  String _processId;

  @NgOneWayOneTime("processId")
  set processId(String v) { _processId = v; _init(); }

  get processId => _processId;

  Map statusMap;

  OIService _svc;

  WFInstance(OIService this._svc) ;

  _init() {
    print('processid = $processId');
    _svc.getProcessInstanceStatus(processId).then( (data) {
      statusMap = data;
    });
  }

  terminate() {
    print("Terminate process id $_processId");
    _svc.stopProcessInstance(_processId).then( (data) {
      print("Terminated: $data");
    });
  }

}
