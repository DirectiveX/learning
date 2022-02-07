var AriaObject = function (Id, File, FajlFeltoltese) {
    this.Id = Id;
    this.File = File;
    this.FajlFeltoltese = FajlFeltoltese;

    this.object_aria =
      function object_aria() {
          var object = $('#' + Id);
          if ($(object).parent().find("label[for='" + Id + "']").length == 0) {
              if (!File) {
                  var tablerowdataparent = $(object).parents("td[class='tableRowData'],span[class='tableRowData']");
                  if (tablerowdataparent.length > 0 && $($(tablerowdataparent)[0]).prev("td[class='tableRowName'],span[class='tableRowName']").length > 0)
                      $(object).parent().prepend("<label  for='" + Id + "'> <span class='labelcontext'>" + GetInnerTextFromNode($($(tablerowdataparent)[0]).prev("td[class='tableRowName'],span[class='tableRowName']").first()[0]) + "</span> </label>");
                  else {
                      var tablealtrowdataparent = $(object).parents("td[class ='tableAlternateRowData'],span[class ='tableAlternateRowData']");
                      if (tablealtrowdataparent.length > 0)
                          $(object).parent().prepend("<label  for='" + Id + "'> <span class='labelcontext'>" + GetInnerTextFromNode($($(tablealtrowdataparent)[0]).prev("td[class='tableRowName'],span[class='tableRowName']").first()[0]) + " </span></label>");
                  }
              }
              else if (File) {
                  var span = $(object).parent().find("span");
                  if (span.length > 0 && span[0].innerHTML != null)
                      $(object).parent().prepend("<label  for='" + Id + "'> <span class='labelcontext'>" + span[0].innerHTML + " </span> </label>");
                  else
                      $(object).parent().prepend("<label  for='" + Id + "'> <span class='labelcontext'>" + FajlFeltoltese + "</span> </label>");
              }
          }
      }

    function ariaobjectOnKeyPressHandler(e) {
        if ((e.which && e.which == 13) || (e.keyCode && e.keyCode == 13)) {
            $(this).click();
            return false;
        } else {
            return true;
        }
    }

    function assignKeyPressHandler(selector) {
        var controls = $(selector);
        for (var i = 0; i < controls.length; i++) {
            var keypressAssigned = false;
            var control = controls[i];

            var events = $._data(control, "events");
            if (events && events.keypress) {
                for (var j = 0; j < events.keypress.length; j++) {
                    var event = events.keypress[j];
                    if (event && event.handler.name == 'ariaobjectOnKeyPressHandler') {
                        keypressAssigned = true;
                    }
                }
            }

            if (!keypressAssigned) {
                $(control).keypress(ariaobjectOnKeyPressHandler);
            }
        }
    }

    var ariaobject = this;
    $(document).ready(function (e) {
        ariaobject.object_aria();

        assignKeyPressHandler(".button");
        assignKeyPressHandler("#panCloseHeader");
        assignKeyPressHandler(".img_excel");
    });

};

function GetInnerTextFromNode(ctrl){

    if (ctrl.innerText != null && ctrl.innerText != undefined && ctrl.innerText != '') {
        ctrl.innerHTML = ctrl.innerText;
    }
    else if (ctrl.textContent != null && ctrl.textContent != undefined && ctrl.textContent != '') {
        ctrl.innerHTML = ctrl.textContent;
    }
    else {
        ctrl.innerHTML = '';
    }
    return ctrl.innerHTML;
}