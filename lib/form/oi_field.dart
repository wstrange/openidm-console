part of oi_form;

class OIField {
  OIForm _form;

  //@NgOneWayOneTime("key")
  String key;

  OIField(this._form) {
    _form.registerField(this);
  }

}