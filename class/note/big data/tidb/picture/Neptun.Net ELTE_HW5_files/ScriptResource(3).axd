function trim(str) {
    str = str.replace(/^\s+/, '');
    for (var i = str.length - 1; i >= 0; i--) {
        if (/\S/.test(str.charAt(i))) {
            str = str.substring(0, i + 1);
            break;
        }
    }
    return str;
}

function FieldAttachment(relatedControlID, documentationTypeID) {
    // Többalakúság miatt van, MVC-ben ugyanez a függvény postData-t hív, és nem submit-ot.
    window.event.returnValue = true;
}

var alertedIDs = [];
function CheckControls() {
    alertedIDs = [];

    var requiredControlErrorMessage = CheckRequiredControls();
    var complexFunctionsErrorMessage = CheckComplexFunctionControls();
    var keyFieldForComplexFunctionsErrorMessage = CheckKeyFieldsForComplexFunctions();
    var regularControlErrorMessage = CheckRegularControls();
    if (regularControlErrorMessage.length == 0) {
        CheckIfNullControls();
    }
    var subjectEquivalenceErrorMessage = CheckSubjectEqivalenceFields();

    if (requiredControlErrorMessage.length > 0 ||
        regularControlErrorMessage.length > 0 ||
        subjectEquivalenceErrorMessage.length > 0 ||
        complexFunctionsErrorMessage.length > 0 ||
        keyFieldForComplexFunctionsErrorMessage.length > 0) {

        var errMsgArray = [];

        if (requiredControlErrorMessage.length > 0) {
            // hozzáadjuk az üzeneteket a listához
            errMsgArray = errMsgArray.concat(requiredControlErrorMessage);
        }

        if (complexFunctionsErrorMessage.length > 0)
            errMsgArray = errMsgArray.concat(complexFunctionsErrorMessage);
        if (regularControlErrorMessage.length > 0)
            errMsgArray = errMsgArray.concat(regularControlErrorMessage);
        if (subjectEquivalenceErrorMessage.length > 0)
            errMsgArray = errMsgArray.concat(subjectEquivalenceErrorMessage);
        if (keyFieldForComplexFunctionsErrorMessage.length > 0) {
            errMsgArray = errMsgArray.concat(keyFieldForComplexFunctionsErrorMessage);
        }

        // sorrendezzük a visszajelző hibaüzeneteket control index alapján
        var orderedErrorMessages = errMsgArray.sort(function (a, b) {
            return a.Index - b.Index;
        });

        // minden hibaüzenet elé teszünk egy bogyót
        var result = [];
        for (var i = 0; i < orderedErrorMessages.length; i++) {
            result.push('&#149; ' + orderedErrorMessages[i].Message);
        }

        var errMsg = result.join("<br />");

        DialogConfirmation(alert_warning, errMsg, '', '', '', 'warning.png', 'Ok', null);
        return false;
    } else {
        return true;
    }
}

function CheckRequiredControls() {

    var errorMessages = [];

    ManageConditionalValidateControls();

    var requiredControlsData = JSON.parse(RequiredControls);

    for (var i = 0; i < requiredControlsData.length; i++) {
        var item = requiredControlsData[i];
        var wasValid = SetBackgroundColorForVisibleControl(item.ControlID);
        // ha látható és üres volt a mező
        if (!wasValid) {
            var msg = alert_requiredmessageformat.format(item.FieldName);

            var err = new Object();
            err.Index = item.Index;
            err.Message = msg;
            errorMessages.push(err);
        }
    }

    return errorMessages;
}

// string.Format implementáció
String.prototype.format = function () {
    var args = arguments;
    return this.replace(/\{\{|\}\}|\{(\d+)\}/g, function (m, n) {
        if (m == "{{") { return "{"; }
        if (m == "}}") { return "}"; }
        return args[n];
    });
};

function ManageConditionalValidateControls(e) {

    // OnChange visszahívás van, ekkor törölni kell az alerted id-kat!!!
    if (e != undefined)
        alertedIDs = [];

    var ConditionalValidateData = JSON.parse(ControlsToConditionalValidate);
    var RequiredControlsData = JSON.parse(RequiredControls);
    var requiredControlsChanged = false;

    for (var i = 0; i < ConditionalValidateData.length; i++) {

        var sourceControlID = ConditionalValidateData[i].SourceControlID;
        var sourceControlIndex = ConditionalValidateData[i].Index;
        var sourceControlFieldName = ConditionalValidateData[i].SourceControlFieldName;
        var sourceControlType = GetControlTypeByID(sourceControlID);
        var sourceControl = GetControlByID(sourceControlID);
        var isSourceEmpty = IsControlEmpty(sourceControl, sourceControlID);

        var conditionType = ConditionalValidateData[i].ConditionType;
        var conditionResult = new Array();

        var eventFunctionName = 'ManageConditionalValidateControls(this);'

        // több feltétel is meg lehet adva, ezeken végigmegyünk
        for (var j = 0; j < ConditionalValidateData[i].Conditions.length; j++) {

            var targetControlID = ConditionalValidateData[i].Conditions[j].TargetControlID;
            var targetControlType = GetControlTypeByID(targetControlID);
            var keywords = ConditionalValidateData[i].Conditions[j].Keywords;

            // kötelezőség meghatározás
            if (targetControlType == "radio") {

                var selectedTargetRadio = $(':radio[name=' + targetControlID + ']:checked');

                // onchange/onmouseup esemenyre rahelyezzuk ugyanezt a vizsgalatot, mert ha valtoztat, akkor ismet ellenorizni kell a source kotelezoseget
                // csak 1x iratjuk fel!
                var targetRadio = $(':radio[name=' + targetControlID + ']');

                if (targetRadio.attr('onchange') == undefined)
                    targetRadio.attr('onchange', '');
                if (targetRadio.attr('onchange').indexOf(eventFunctionName) == -1)
                    targetRadio.attr('onchange', targetRadio.attr('onchange') + eventFunctionName);

                // valami ki van választva
                if (selectedTargetRadio.length > 0) {

                    var selectedDisplayName = (e != undefined && e.id.indexOf('Radio') == 0) ? $('#' + e.id).attr('displayname') : selectedTargetRadio.attr('displayname');
                    var isMatch = $.inArray(selectedDisplayName.toLowerCase(), keywords) > -1;
                    conditionResult.push(isMatch);
                }
                else
                    conditionResult.push(false);
            }
            else if (targetControlType == "dropdown") {

                var targetCombo = GetDropdownControl(targetControlID);

                // onchange esemenyre rahelyezzuk ugyanezt a vizsgalatot, mert ha valtoztat, akkor ismet ellenorizni kell a source kotelezoseget
                // csak 1x iratjuk fel!
                if (e == undefined) {
                    targetCombo.autocomplete({
                        change: function (event, ui) { ManageConditionalValidateControls(this); }
                    });
                }

                var selectedItemName = $('#' + targetControlID).find('option:selected').text().toLowerCase();

                var isMatch = $.inArray(selectedItemName, keywords) > -1;
                conditionResult.push(isMatch);
            }
            else if (targetControlType == "checkbox") {

                var targetCheckBox = $('#' + targetControlID);

                // onchange esemenyre rahelyezzuk ugyanezt a vizsgalatot, mert ha valtoztat, akkor ismet ellenorizni kell a source kotelezoseget
                // csak 1x iratjuk fel!
                if (targetCheckBox.attr('onchange') == undefined)
                    targetCheckBox.attr('onchange', '');
                if (targetCheckBox.attr('onchange').indexOf(eventFunctionName) == -1)
                    targetCheckBox.attr('onchange', targetCheckBox.attr('onchange') + eventFunctionName);

                var selectedValue = targetCheckBox.is(':checked').toString();
                var isMatch = $.inArray(selectedValue, keywords) > -1;
                conditionResult.push(isMatch);
            }
            else {

                var targetControl = $('#' + targetControlID);

                // onkeyup esemenyre rahelyezzuk ugyanezt a vizsgalatot, mert ha valtoztat, akkor ismet ellenorizni kell a source kotelezoseget
                // csak 1x iratjuk fel!
                if (targetControl.attr('onkeyup') == undefined)
                    targetControl.attr('onkeyup', '');
                if (targetControl.attr('onkeyup').indexOf(eventFunctionName) == -1)
                    targetControl.attr('onkeyup', targetControl.attr('onkeyup') + eventFunctionName);

                var selectedItemName = targetControl.val().trim().toLocaleLowerCase();
                var isMatch = $.inArray(selectedItemName, keywords) > -1;
                conditionResult.push(isMatch);
            }
        }

        // kötelezőség meghatározása
        var trueCount = $.grep(conditionResult, function (n) { return n == true });

        var isControlRequired = false;
        // ÉS feltétel
        if (conditionType == "AND") {
            // ha az összes feltétel igaz, akkor kötelező a control
            isControlRequired = (trueCount.length == conditionResult.length);
        }
        else // OR feltétel
        {
            // ha legalább 1 feltétel igaz, akkor kötelező a control
            isControlRequired = trueCount.length >= 1;
        }

        var indexInArray = GetIndexInRequiredControlArray(sourceControlID);
        var isInArray = indexInArray > -1;

        if (isControlRequired) {
            // ha a source control ures es meg nincs megjelolve validalandonak, akkor megtesszuk
            if (isSourceEmpty && !isInArray) {
                RequiredControlsData.push({ ControlID: sourceControlID, Index: sourceControlIndex, FieldName: sourceControlFieldName });
                requiredControlsChanged = true;
                SetBackgroundColor(undefined, sourceControlID, true);
            }
        }
        else {
            // levesszuk a kotelezoseget (ha benne van a listaban) es levesszuk a pirositast
            if (isInArray) {
                RequiredControlsData.splice(indexInArray, 1);
                requiredControlsChanged = true;
                SetBackgroundColor(undefined, sourceControlID, false);
            }
        }
    }

    if (requiredControlsChanged) {
        // beletesszük az eredeti, sorosított listába a módosításokat
        RequiredControls = JSON.stringify(RequiredControlsData);
    }    
}

// visszaadja a control 'RequiredControls' tombben levo indexet. Ha nincs benne, akkor -1.
function GetIndexInRequiredControlArray(sourceControlID) {
    var indexInArray = -1;

    var RequiredControlsData = JSON.parse(RequiredControls);

    for (var i = 0; i < RequiredControlsData.length; i++) {

        var item = RequiredControlsData[i];
        if (item.ControlID == sourceControlID) {
            indexInArray = i;
            break;
        }
    }
    return indexInArray;
}

function SetAttachmentByRegular(btnID, textID, regular, required, caller) {
    var textControl = $get(textID);

    if (regular == '[0-9]')
        regular = '^[0-9]+$';

    var isRegularOk = false;
    if (caller.value != "") {
        if (textControl.value.match(regular))
            isRegularOk = true;
    }
    document.getElementById(btnID).disabled = !isRegularOk;

    // ha üres érték, akkor nem pirosítjuk a hátteret!
    if (caller.value == "")
        isRegularOk = true;

    var isRequiredOk = true;
    if (required.toLowerCase() == "true" && caller.value == "")
        isRequiredOk = false;

    textControl.style.backgroundColor = (!isRequiredOk || !isRegularOk) ? 'red' : '';
}

function SetAttachment(btnID, caller) {
    var disabledValue = false;

    // checkbox
    if (caller.type == 'checkbox') {
        disabledValue = caller.checked == false;
    }
    // dropdown
    else if (caller.type == 'select-one') {
        disabledValue = caller.value == "" || caller.value == comboDefaultEmptyValue;
    }
    // radio
    else if (caller.type == "radio") {
        // barmit valaszt, az jo
        disabledValue = false;
    }
    // textbox, datepicker
    else {
        disabledValue = caller.value.trim() == "";
    }

    document.getElementById(btnID).disabled = disabledValue;
}


function isMaxLength(textbox, maxLength) {
    if (textbox.getAttribute && textbox.value.length > maxLength)
        textbox.value = textbox.value.substring(0, maxLength);
    return (textbox.value.length <= maxLength);
}

function test() {
    alert('fut kérvényből!');
    // áthívás neptun.js-be
    kiir();
}

//onchangenel hivodik meg es allitja a kotelezoseget
function CheckRequired(control, type) {

    if (type == "radio") {
        //torlom a piros jelolest
        //torolni nem tudja a kivalasztott radiot
        $(':radio[name=' + control.name + ']').parent().css('backgroundColor', '');
    }
    else if (type == "dropdown") {
        var jqcombo = GetDropdownControl(control.id);
        if (trim(control.value) == '' || trim(control.value) == comboDefaultEmptyValue) {
            jqcombo.removeClass('ui-state-default');
            jqcombo.addClass('alert-combobox');
        }
        else {
            jqcombo.removeClass('alert-combobox');
            jqcombo.addClass('ui-state-default');
        }
    }
    else {
        if (trim(control.value) == '') {
            control.style.backgroundColor = 'red';
        }
        else {
            control.style.backgroundColor = '';
        }
    }
}

function CheckComplexFunctionControls() {
    // fontos törölni!
    alertedIDs = [];

    var errorMessages = [];

    var data = JSON.parse(ComplexFunctionsToValidate);
    var minRequiredData = JSON.parse(MinRequiredTable);

    // végigmegyünk a táblázatos változókon
    for (var i = 0; i < data.length; i++) {

        var tableHasAnyValue = false;
        // Végigmegyünk a táblázat controljain, és megnézzük töltött-e ki bármilyen látható mezőt. Ha igen, csak akkor foglalkozunk kötelezőség-vizsgálattal
        for (var j = 0; j < data[i].ControlIDs.length; j++) {
            var controlId = data[i].ControlIDs[j];
            var ctrl = GetControlByID(controlId);
            if (IsControlVisible(ctrl) == false) {
                continue;
            }

            // Találtunk szerkeszthető, nem üres controlt, foglalkozunk kell kötelezőség-vizsgálattal
            if (IsControlEmpty(ctrl, controlId) == false && IsControlEnabled(controlId)) {
                tableHasAnyValue = true;
                break;
            }

            // Ha üres, akkor beállítjuk defaultra a hátteret, mert lehet, h korábban piros volt!
            SetBackgroundColor(ctrl, controlId, false);
        }

        // Van kitöltve adat, kell kötelezőség-vizsgálat
        if (tableHasAnyValue) {
            for (var k = 0; k < data[i].RequiredControls.length; k++) {
                var item = data[i].RequiredControls[k];
                // ha érvénytelen volt (látható és üres), akkor flag-et állítunk
                if (SetBackgroundColorForVisibleControl(item.ControlID) == false) {
                    var msg = alert_requiredmessageformat.format(item.FieldName);

                    var err = new Object();
                    err.Index = item.Index;
                    err.Message = msg;
                    errorMessages.push(err);
                }
            }
        }
        // ha üres a táblázat és van Dokumentum feltöltés gomb, akkor inaktívra állítjuk, ne töltsön fel
        var docButtonId = data[i].DocumentationButtonID;
        if (docButtonId != null) {
            document.getElementById(docButtonId).disabled = !tableHasAnyValue;
        }

        // Kitöltött táblázatok számának beállítása adatkörönként
        if (tableHasAnyValue) {
            SetFilledTablesInMinRequiredTable(minRequiredData, data[i].GroupID);
        }
    }

    // Kötelezően kitöltendő táblázatok számának ellenőrzése (Min.Required)
    var resultOfMinRequiredTable = GetResultOfMinRequiredTable(minRequiredData);
    if (resultOfMinRequiredTable.length > 0) {
        errorMessages = errorMessages.concat(resultOfMinRequiredTable);
    }

    return errorMessages;
}

function SetFilledTablesInMinRequiredTable(minRequiredData, groupID) {

    for (var i = 0; i < minRequiredData.length; i++) {
        // Megkeressük melyik group listában van a kapott, és ha megtaláltuk, akkor növeljük a kitöltött táblázatok számát.
        var foundGroupIndex = $.inArray(groupID, minRequiredData[i].GroupIDs);
        if (foundGroupIndex > -1) {
            minRequiredData[i].FilledTables = minRequiredData[i].FilledTables + 1;
        }
    }
}

function GetResultOfMinRequiredTable(minRequiredData) {

    var errorMessages = [];

    for (var i = 0; i < minRequiredData.length; i++) {
        if (minRequiredData[i].FilledTables < minRequiredData[i].MinRequired) {

            var err = new Object();
            err.Index = minRequiredData[i].GroupIDs[0];
            err.Message = minRequiredData[i].WarningMessage;
            errorMessages.push(err);
        }
    }

    return errorMessages;
}

function IsControlEmpty(ctrl, controlID) {

    var isEmpty = false;

    var controlType = GetControlTypeByID(controlID);
    if (controlType == "radio") {
        var selectedradio = ctrl.filter(':checked').val();
        if (selectedradio == undefined || selectedradio.length == 0)
            isEmpty = true;
    }
    else if (controlType == "dropdown") {
        var selectedIndex = $get(controlID).selectedIndex;
        if (selectedIndex == 0)
            isEmpty = true;
    }
    else if (controlType == "checkbox") {
        var isChecked = ctrl.is(':checked');
        if (isChecked == false)
            isEmpty = true;
    } else {
        if (ctrl != null) {
            if (trim(ctrl.val()) == '')
                isEmpty = true;
        }
    }
    return isEmpty;
}

function SetBackgroundColorForVisibleControl(controlid) {
    var ok = true;

    var ctrl = GetControlByID(controlid);

    var isVisible = IsControlVisible(ctrl);
    var isEnabled = IsControlEnabled(controlid);
    var isEmpty = IsControlEmpty(ctrl, controlid);

    var isInvalid = isEmpty && isVisible && isEnabled;
    if (isInvalid)
        ok = false;

    SetBackgroundColor(ctrl, controlid, isInvalid);

    return ok;
}

function GetControlByID(controlId) {
    var ctrl;

    var type = GetControlTypeByID(controlId);
    if (type == "dropdown")  // dropdown (JQuery autocomplete combobox) esetén a köv. input mezőt kell vizsgálni, oda generálódik, elfedve az eredetit
        var ctrl = GetDropdownControl(controlId);
    else if (type == "radio")
        var ctrl = $(':radio[name=' + controlId + ']');
    else
        var ctrl = $('#' + controlId);

    return ctrl;
}

function IsControlVisible(ctrl) {
    return ctrl.is(":visible");
}

function IsControlVisibleByID(controlId) {
    var ctrl = GetControlByID(controlId);
    return IsControlVisible(ctrl);
}

function IsControlEnabled(controlId) {
    var ctrl = GetControlByID(controlId);

    if (GetControlTypeByID(controlId) == "datepicker") {
        return ctrl.data("noteditable") !== true;
    }
    return ctrl.is(":enabled") && ctrl.attr('readonly') !== "readonly";
}

function IsControlVisibleAndEnabled(controlId) {
    var ctrl = GetControlByID(controlId);
    return ctrl.is(":visible") && ctrl.is(":enabled");
}

function SetBackgroundColor(sourceControl, sourceControlID, setToRed) {
    // ha már meg van jelölve hibásként, akkor nem piszkáljuk
    if ($.inArray(sourceControlID, alertedIDs) > -1)
        return;

    if (sourceControl == undefined || sourceControl == null) {
        sourceControl = GetControlByID(sourceControlID);
    }

    var type = GetControlTypeByID(sourceControlID);
    if (type == "radio") {
        if (setToRed)
            sourceControl.parent().css('backgroundColor', 'red');
        else
            sourceControl.parent().css('backgroundColor', '');
    }
    else if (type == "dropdown") {
        if (setToRed) {
            sourceControl.removeClass('ui-state-default');
            sourceControl.addClass('alert-combobox');
        }
        else {
            sourceControl.removeClass('alert-combobox');
            sourceControl.addClass('ui-state-default');
        }
    }
    else {
        if (sourceControl != null) {
            var bgValue = setToRed ? 'red' : '';
            sourceControl.css('background-color', bgValue);
        }
    }

    // megjelöljük, hogy ezt már ne állítsuk
    if (setToRed)
        alertedIDs.push(sourceControlID);
}

function GetControlTypeByID(controlID) {
    if (controlID == null) {
        return "";
    } if (controlID.startsWith("R_")) {  //Radio
        return "radio";
    } else if (controlID.startsWith("D_")) {  //Select
        return "dropdown";
    } else if (controlID.startsWith("C_")) {  //CheckBox
        return "checkbox";
    } else if (controlID.startsWith("DP_")) {  //DatePicker
        return "datepicker";
    } else if (controlID.startsWith("L_")) {   // Label
        return "label";
    } else {
        return "text";
    }
}

function CheckKeyFieldsForComplexFunctions() {
    var errorMessages = [];

    var packages = JSON.parse(KeyFieldPackages);

    for (var i = 0; i < packages.length; i++) {

        var keyFields = packages[i].KeyFields;
        var keyFieldValues = new Array();
        for (var j = 0; j < keyFields.length; j++) {

            var keyField = keyFields[j];
            var keyFieldValue = '';
            var wasEmptyField = false;
            for (var k = 0; k < keyField.length; k++) {

                var controlID = keyField[k];
                var controlType = GetControlTypeByID(controlID);

                // Csak látható /*és szerkeszthető*/ controlt vizsgálunk
                // A szerkeszhetőséget nem kéne vizsgálni, mert pl. letiltott címtípus esetén fel lehetne venni új, azonos címet! #20155
                // A label kivétel, mert az mindig hidden inputban van!
                if (controlType != "label" && /*IsControlVisibleAndEnabled(controlID) == false*/ IsControlVisibleByID(controlID) == false) {

                    continue;
                }

                var controlValue = '';

                if (controlType === "checkbox") {
                    controlValue = $('#' + controlID).is(':checked');
                } else {
                    controlValue = $.trim($('#' + controlID).val());
                }

                // Ha nincs kitöltve érték, akkor nem hasonlíthatjuk a kulcsmezőket, mert pl. üres-üres még nem sérti a feltételt!
                if (controlValue.length === 0) {
                    wasEmptyField = true;
                    break;
                }

                if (controlType === "dropdown") {
                    if (controlValue !== comboDefaultEmptyValue) {
                        keyFieldValue += controlValue;
                    }
                }
                else {
                    keyFieldValue += controlValue;
                }
            }

            // Ha nem volt üres mező, és volt egyáltalán kitöltve kulcsmező, akkor gyűjtjük
            if (wasEmptyField == false && keyFieldValue.length > 0)
                keyFieldValues.push(keyFieldValue.toLowerCase());

            // Már van legalább két egyező, tovább nem is keresünk
            if (ArrayHasSameValue(keyFieldValues)) {
                break;
            }
        }

        // kulcsmező kiértékelés
        for (var ev = 0; ev < keyFieldValues.length; ev++) {

            var otherItems = keyFieldValues.slice();
            otherItems.splice(ev, 1);

            // Találtunk egyező kulcs mezőket
            if ($.inArray(keyFieldValues[ev], otherItems) >= 0) {

                var err = new Object();
                err.Index = packages[i].Index;
                err.Message = packages[i].ErrorMessage;
                errorMessages.push(err);

                break;
            }
        }
    }

    return errorMessages;
}

function ArrayHasSameValue(arr) {
    var sortedArr = arr.sort();
    for (var i = 0; i < sortedArr.length - 1; i++) {
        if (sortedArr[i + 1] == sortedArr[i]) {
            return true;
        }
    }
    return false;
}

//vegigmegy a regularist tartalmazo elemeken
//es megnezi hogy egyezik-e a kifejezessel
//ha nem akkor kiszinezi oket+hibauzi
function CheckRegularControls() {

    var errorMessages = [];

    var regularControlsData = JSON.parse(RegularControls);

    for (var i = 0; i < regularControlsData.length; i++) {
        var item = regularControlsData[i];
        var control = $get(item.ControlID);

        if (trim(control.value) == '') {
            continue;
        }

        var reg = item.Regex;

        // javascriptben másképp kell írni ezt a kifejezést
        if (reg == '[0-9]')
            reg = '^[0-9]+$';

        if (!control.value.match(reg)) {
            SetBackgroundColor(undefined, control.id, true);

            var msg = alert_regularmessageformat.format(item.FieldName);

            var err = new Object();
            err.Index = item.Index;
            err.Message = msg;
            errorMessages.push(err);
        }
        else {
            SetBackgroundColor(undefined, control.id, false);
        }
    }

    return errorMessages;
}

function CheckIfNullControls() {

    var data = JSON.parse(IfNullControls);

    for (var i = 0; i < data.length; i++) {
        var control = $get(data[i].ControlID);

        if (control.value == undefined || trim(control.value) == '') {
            control.value = data[i].ReplacementValue;
        }
    }
}

// Tárgyekvivalencia kérvény esetén nem egyezhet meg a 6. mező az 1-5 mezók egyikével sem
function CheckSubjectEqivalenceFields() {

    var field6 = '';
    var subjectcodes = [];
    var errorMessages = [];

    var data = JSON.parse(SubjectEquivalenceControls);
    for (var i = 0; i < data.length; i++) {
        var item = data[i];
        var index = parseInt(item.ControlIndex);
        var controlValue = $('#' + item.ControlID).val();

        if (controlValue.length == 0)
            continue;

        if (index == 6)
            field6 = controlValue.toUpperCase();
        else
            subjectcodes.push(controlValue.toUpperCase());
    }

    // meg van adva elismerni kívánt tárgy, és beszámítani kívánt tárgy is
    if (field6.length > 0 && subjectcodes.length > 0) {

        // Hiba! Megegyezik a 6-os mező az 1-5 mezők valamelyikével!
        if ($.inArray(field6, subjectcodes) > -1) {
            var err = new Object();
            err.Index = 1;
            err.Message = alert_subjectequivalence;
            errorMessages.push(err);
        }        
    }

    return errorMessages;
}

function GetDropdownControl(controlID)
{
    return $('#' + controlID).parent().find('input.ui-autocomplete-input');
}

function SetCityAndCountyAutocompleteOffIfAbroad(countrySelectorControlID, magyarorszagID, cityAutoCompleteControlID, countyAutoCompleteControlID) {
    var disabled = $get(countrySelectorControlID).value != magyarorszagID;
    $('#' + cityAutoCompleteControlID).autocomplete("option", "disabled", disabled);
    $('#' + countyAutoCompleteControlID).autocomplete("option", "disabled", disabled);
}

function DisableKervenyButtons(btnName) {
    // Kérvényleadáskor és felfüggesztéskor letiltjuk a gombokat
    if (btnName == "KervenyLeadas" || btnName == "Felfuggesztes")
    {
        var buttons = new Array("KervenyLeadas", "Felfuggesztes", "DokHozzarendeles");
        for (var i = 0; i < buttons.length; i++) {
            $("input[id$='" + buttons[i] + "']").prop('disabled', true).addClass("ui-state-disabled");
        }
    }

    if (btnName == "KervenyLeadas") {
        window.scrollTo(0, 0);
    }
}

function KervenyLeadasButtonClick(buttonItem) {
    buttonItem.setAttribute('disabled', 'disabled');
    window.scrollTo(0, 0);
}

// Ha a táblázatos változó megjelölhető törölésre, akkor annak bármely control értékének változására a törlésre jelölést meg kell szüntetni
// minden táblázaton belüli controlra beállítunk egy change eseményt, ami a jelölést kiveszi a jelölő controlból
function SetComplexFunctionControlsChangeEventToHandleDeletionMarker(request) {
    var data = JSON.parse(request); // List<ComplexFunctionsToDeleteDTO>
    for (var i = 0; i < data.length; i++) {
        var markerControlID = data[i].MarkForDeletionControlID;
        var controlIDs = data[i].ControlIDs;

        for (var j = 0; j < controlIDs.length; j++) {
            var controlID = controlIDs[j];
            $('#' + controlID).change({ ctrlID: markerControlID }, function (event) {
                $('#' + event.data.ctrlID).prop("checked", false);
            });
        }
    }
}
//------------------------- Group-kezelő függvények ------------------------------------------

function OpenGroup(groupid) {
    var groupData = GetGroupData(groupid);
    var groupElementID = groupData.GroupElementID;
    var groupElement = $('#' + groupElementID);
    
    if (groupElement.css('display') == 'block')
        SetGroupVisibility(groupElement, 'none');
    else
        SetGroupVisibility(groupElement, 'block');
}

// Csak akkor nyitjuk meg a group-ot, ha az erteke alapjan teljesul a nyitofeltetel
function OpenGroupByValue(control, type, commaSeparatedGroupIDs) {

    if (GroupData == undefined) {
        return;
    }
    
    var groupIDs = commaSeparatedGroupIDs.split(',');

    for (var i = 0; i < groupIDs.length; i++) {
        var groupID = groupIDs[i];
        var groupData = GetGroupData(groupID);
        var groupElementID = groupData.GroupElementID;
        var controlOpenConditions = groupData.ControlOpenConditions;

        var groupElement = $('#' + groupElementID);

        if (groupElement.length === 0 ||
            controlOpenConditions.hasOwnProperty(control.id) === false)
            continue;

        var controlValue = GetGroupOpenerControlValue(control, type);
        var conditions = controlOpenConditions[control.id];
        var needToOpen = IsOpenGroupConditionMet(controlValue, conditions);
        
        if (needToOpen) {
            SetGroupVisibility(groupElement, 'block');
        }
        else {
            // bezárjuk a groupot, ha nyitva van
            if (groupElement.css('display') == 'none')
                continue;

            SetGroupVisibility(groupElement, 'none');

            // rekurzivan bezárjuk azokat a groupokat is, amelyek ennek a gyermekei
            var groupIdToClose = groupID;
            while (true) {
                var groupdivs = $("div[pgid*='(" + groupIdToClose + ")']");
                if (groupdivs.length === 0)
                    break;
                groupIdToClose = groupdivs.attr('groupid');
                SetGroupVisibility(groupdivs, 'none');
            }
        }
    }
}

// Ellenőrzi, hogy a control értéke teljesíti-e valamely megadott feltételt
function IsOpenGroupConditionMet(controlValue, conditions) {
    if (conditions.length === 0) {
        return false;
    }

    var result = false;

    var controlValueIsInteger = $.isNumeric(controlValue) && Math.floor(controlValue).toString() === controlValue;

    $.each(conditions, function (index, condition) {
        // Bármely értékre nyitó feltétel
        if (condition.length === 0 && controlValue.length > 0) {
            result = true;
            return false;
        }
        // Intervallum feltétel
        else if ((condition.indexOf("<") > -1 || condition.indexOf(">") > -1) &&
            controlValueIsInteger) {
            var conditionNumber = parseInt(condition.substring(1));
            var controlNumber = parseInt(controlValue);

            // lehetséges pl.: "<5" vagy ">5" vagy "2<5"
            if (condition.indexOf("<") === 0 && controlNumber > 0) {
                if (controlNumber < conditionNumber) {
                    result = true;
                    return false;
                }
            } else if (condition.indexOf(">") === 0) {
                if (controlNumber > conditionNumber) {
                    result = true;
                    return false;
                }
            } else if (condition.indexOf("<") > 0) {
                var number = condition.split("<");
                if (parseInt(number[0]) < controlNumber && controlNumber < parseInt(number[1])) {
                    result = true;
                    return false;
                }
            }
            // Kulcsszavas nyitófeltétel
        } else if (controlValue.length > 0 &&
            condition.length > 0 &&
            controlValue.toLowerCase() === condition.toLowerCase()) {
            result = true;
            return false;
        }
    });

    return result;
}

function GetGroupOpenerControlValue(control, type) {

    var result = '';

    switch (type) {
        case 'checkbox':
            var isChecked = $('#' + control.name).is(':checked');
            result = isChecked.toString();
            break;
        case 'dropdown':
            var controlText = control[control.selectedIndex].text.trim().toString();
            if (controlText !== comboDefaultEmptyValue && control.value !== comboDefaultEmptyValue) {
                result = controlText;
            }
            break;
        case 'radio':
            result = $('#' + control.id).attr('displayname');
            break;
        case 'text':
            result = control.value;
            break;
    }

    return result.trim();
}

function GetGroupData(groupID) {

    var result;

    var parsedGroupData = JSON.parse(GroupData);

    for (var i = 0; i < parsedGroupData.length; i++) {
        if (parsedGroupData[i].GroupID == groupID) {
            result = parsedGroupData[i];
            break;
        }
    }

    return result;
}

// beállítja a group div display tulajdonságát, valamint frissíti a hidden mezőben tárolt láthatóság adatokat
function SetGroupVisibility(groupElement, displayValue) {
    groupElement.css('display', displayValue);

    var visibilitiesField = $('input[name="groupvisibilities"]:first');

    var groupInfo = visibilitiesField.val().split(',');
    var newValue = '';
    for (var i = 0; i < groupInfo.length; i++) {
        var data = groupInfo[i].split(':');
        var groupID = data[0];
        var visibility = data[1];

        // ennek a groupnak az ID-ja, módosítjuk a visible értéket
        if (groupID == groupElement.attr('groupid'))
            newValue += groupID + ':' + (displayValue == 'block' ? 'T' : 'F') + ',';
            // más group
        else
            newValue += groupID + ':' + visibility + ',';
    }
    if (newValue.length > 1)
        newValue = newValue.slice(0, -1);   // eltávolítjuk az utolsó vesszőt
    visibilitiesField.val(newValue);
}

//------------------------- Group-kezelő függvények vége --------------------------------------

//--------------------------- Summary-Group függvények ----------------------------------------

var sumImputs = function (label, inputs, sg) {
    var sum = 0;

    for (var i = 0; i < inputs[sg].length; i++) {
        if ($.isNumeric($(inputs[sg][i]).val())) {
            var value = parseFloat($(inputs[sg][i]).val());
            if (!isNaN(value)) {
                sum += value;
            }
        }
    }

    $(label).val(sum);
}

var kervenyResultAutoChangeItems = '';
var kervenyEredmenyLimitRangeWarningMessage = '';
function SetKervenyResultValue(label) {

    if (kervenyResultAutoChangeItems.length === 0) {
        return;
    }

    var pontszam = $(label).val();
    var result = JSON.parse(kervenyResultAutoChangeItems);
    var items = result.Items;
    var controlID = result.KervenyEredmenyControlID;

    var selectedIndex = 0;
    var selectedText = $('#' + controlID + ' option:first').text();

    var hataronKivuliPontszam = true;
    for (var i = 0; i < items.length; i++) {
        if (pontszam >= items[i].MinErtek && pontszam <= items[i].MaxErtek) {
            selectedIndex = items[i].ValueIndex;
            selectedText = items[i].ValueText;
            hataronKivuliPontszam = false;
            break;
        }
    }

    if (hataronKivuliPontszam) {
        DialogConfirmation(alert_warning, kervenyEredmenyLimitRangeWarningMessage, '', '', '', 'warning.png', 'Ok', null);
    }

    $get(controlID).selectedIndex = selectedIndex; // valós beállítás
    GetDropdownControl(controlID).val(selectedText);      // combó text beállítás
}

function FindSummaryGroupInputs() {
    var inputs = [];
	$('input').each(
		function (i, elem) {
			if ($.isNumeric($(elem).attr('sg')) && $(elem).attr('readonly') == 'readonly') {
			    if (inputs[$(elem).attr('sg')] == undefined) {
			        inputs[$(elem).attr('sg')] = [];
			    }

			    $('input').each(
					function (i, input) {
						if ($(input).attr('readonly') != 'readonly' && $(input).attr('sg') == $(elem).attr('sg')) {
						    if (-1 == $.inArray(input, inputs[$(elem).attr('sg')])) {
						        inputs[$(elem).attr('sg')].push(input);

						        $(input).on('input',
									function (e) {
										if ($.isNumeric($(this).val()) || $(this).val() == '') {
                                            sumImputs(elem, inputs, $(elem).attr('sg'));
                                            SetKervenyResultValue(elem);
										}
									}
								);
						    }
						}
					}
				);

			    sumImputs(elem, inputs, $(elem).attr('sg'));
			}
		}
	);
}

//------------------------ Summary-Group függvények vége --------------------------------------


//------------------------------- Egyedi függvények -------------------------------------------

function FillOkmanyAltipusok(sourceControl, targetControlID) {
    var okmanyTipus = sourceControl.value;

    var targetCombo = $('[id^=D_][id$=' + targetControlID + ']');

    // Az első elem kivételével (Kérem válasszon) minden elemet törlünk
    var defaultItem = targetCombo.children(0).html();
    targetCombo.empty();
    targetCombo.next().find('input').val(defaultItem);
    targetCombo.append($('<option>', { value: comboDefaultEmptyValue /* h_templates-ből küldve */, text: defaultItem }, '</option>'));

    var altipusok = JSON.parse(okmanyAltipusok /* h_templates-ből küldve */);
    var elemek = altipusok[okmanyTipus];

    if (elemek == undefined)
        return;

    for (var key in elemek) {
        if (elemek.hasOwnProperty(key)) {
            targetCombo.append(
                $('<option>', {
                    value: key,
                    text: elemek[key]
                }, '</option>')
            );
        }
    }
}

function DatePickerValidation(dateControl) {
    var dateFormat = $('#' + dateControl.name).datepicker("option", "dateFormat");

    var dateVal = dateControl.value;

    // Ha begépelt egy pontot a végére akkor vizsgálatnál figyelmen kívül hagyjuk
    if (dateVal.substring(dateVal.length - 1) == ".") {
        dateVal = dateVal.substring(0, dateVal.length - 1);
    }

    try {
        $.datepicker.parseDate(dateFormat, dateVal);
    }
    catch (Exception) {
        dateControl.value = '';
    }
}

function SetControlToEnabled(sourceControlID, destinationControlID, condition) {
    var sourceControlType = GetControlTypeByID(sourceControlID);
    var destinationControlType = GetControlTypeByID(destinationControlID);

    var needToEnableDestinationControl = false;
    if (sourceControlType == 'checkbox') {
        needToEnableDestinationControl = $('#' + sourceControlID).is(':checked') == JSON.parse(condition);
    }
    else if (sourceControlType == 'dropdown') {
        needToEnableDestinationControl = $('#' + sourceControlID).autocomplete().val() == condition;
    }

    if (destinationControlType == 'dropdown') {

        if (needToEnableDestinationControl) {
            // Enabled
            GetDropdownControl(destinationControlID).autocomplete('option', 'disabled', false).prop('disabled', false);
            $('#' + destinationControlID).parent().find('a.ui-button').button('enable');
        }
        else {
            // Disabled
            GetDropdownControl(destinationControlID).autocomplete('option', 'disabled', true).prop('disabled', true);
            $('#' + destinationControlID).parent().find('a.ui-button').button('disable');

            // Visszaállítjuk a dropdown-t, ha be volt állítva érték
            if ($('#' + destinationControlID).autocomplete().val() != '---') {
                GetDropdownControl(destinationControlID).val('');
                $get(destinationControlID).selectedIndex = 0;
            }
        }

        // a generált input-nak értékül adjuk az eredeti, hide-olt select értékét
        var hiddenSelectValue = $('#' + destinationControlID + ' option:selected').text();
        GetDropdownControl(destinationControlID).val(hiddenSelectValue);

        CheckComplexFunctionControls();
    }
}

function SetTextControlEditing(sourceControlID, commaSeparatedAllowedSelectedIDs, commaSeparatedDestinationControlIDs) {

    var selectedID = $('#' + sourceControlID).val();
    var allowedSelectedIDs = commaSeparatedAllowedSelectedIDs.split(',');

    var enabled = $.inArray(selectedID, allowedSelectedIDs) == -1;

    var destinationControlIDs = commaSeparatedDestinationControlIDs.split(',');
    for (var i = 0; i < destinationControlIDs.length; i++) {
        if (enabled) {
            $('#' + destinationControlIDs[i]).removeAttr('readonly');
        } else {
            $('#' + destinationControlIDs[i]).val('');
            $('#' + destinationControlIDs[i]).attr('readonly', 'readonly');
        }
    }
}

//---------------------------- Egyedi függvények vége -----------------------------------------

//------------------------ Kereszthivatkozás függvények ---------------------------------------

function UpdateFDLControlCascadeChilds(sender) {

    var fdlControlCascadeData = JSON.parse(fdlControlCascadeItems);

    for (var i = 0; i < fdlControlCascadeData.length; i++) {
        var item = fdlControlCascadeData[i];

        if (item.ParentControlID === sender.id) {
            for (var j = 0; j < item.Children.length; j++) {
                var child = item.Children[j];

                // Kitöröljük a child értékét. Nem foglalkozunk azzal az esettel, hogy a megváltozott parent értékek után is megmarad a child értéke.
                $('#' + child.ChildControlID).val('');
                var childControlType = GetControlTypeByID(child.ChildControlID);
                if (childControlType === "dropdown") {
                    // Dropdown esetén az értékeket is töröljük
                    RemoveDropdownItemsExceptFirst(child.ChildControlID);
                } else if (childControlType === "text") {
                    // Autocomplete esetén az ID mezőt is töröljük
                    $('#' + child.ChildControlID + 'ID').val('');
                } else if (childControlType === "label") {
                    // Label esetén az ID mezőt és a Span tartalmát is töröljük
                    UpdateLabelCascadeValues(child.ChildControlID, '', '');
                }

                // meg kell keresni van-e még más szülője, mert annak az értéke is kell az FDL-hez!
                var allParentControlValues = GetAllParentControlValues(child.ChildControlID);

                GetFDLValues(child.ChildControlFDLID, allParentControlValues, child.ChildControlID);
            }
        }
    }
}

function GetAllParentControlValues(childControlID) {
    var allParentControlID = [];
    var values = [];

    var fdlControlCascadeData = JSON.parse(fdlControlCascadeItems);

    for (var i = 0; i < fdlControlCascadeData.length; i++) {
        var item = fdlControlCascadeData[i];
        for (var j = 0; j < item.Children.length; j++) {
            var child = item.Children[j];
            if (child.ChildControlID === childControlID && $.inArray(item.ParentControlID, allParentControlID) === -1) {
                allParentControlID.push(item.ParentControlID);

                var parentControlValue = $('#' + item.ParentControlID).val();

                var parentControlType = GetControlTypeByID(item.ParentControlID);

                if (parentControlType === "text" || parentControlType === "label") {  // Autocomplete text, vagy Label esetén külön mezőben van az ID érték.
                    // Mivel autocomplete esetén először a szöveg törlődik ki, az ID-s mezője még nem, ezért előbbire is figyelni kell!
                    if (parentControlValue.length > 0) {
                        parentControlValue = $('#' + item.ParentControlID + "ID").val();
                    }
                }

                var vValue = $.isNumeric(parentControlValue) ? parentControlValue : -1;

                if (vValue !== -1) {
                    values.push({ key: item.ParentControlIndex, value: parseInt(vValue) });
                }
            }
        }
    }

    return values;
}

function GetFDLValues(fdlID, allParentControlValues, childControlID) {
    var serializedValues = '';
    if (allParentControlValues.length > 0) {
        serializedValues = '&Values=' + encodeURIComponent(JSON.stringify(allParentControlValues));
    }

    var url = 'KervenyHandler.ashx?Function=FDL&ID=' + fdlID + '&' + fdlParameterString + '&isFDLCascadeChildControl=true' + serializedValues;

    var childControlType = GetControlTypeByID(childControlID);
    var clientData = childControlID;

    if (childControlType === "dropdown") {
        PostData(url, UpdateDropdownCascade, clientData);
    } else if (childControlType === "text") {
        // Autocomplete source url-hez hozzá kell fűzni a values-t!
        $("#" + childControlID).autocomplete("option", "source", url);
    } else if (childControlType === "label") {
        PostData(url, UpdateLabelCascade, clientData);
    }
}

function PostData(url, successfunction, clientData) {

    $.ajax({
        type: 'GET',
        url: url,
        contentType: "application/json; charset=utf-8",
        dataType: "JSON",
        success: function (response) {
            successfunction.call(this, response, clientData);
        }
    });
}

// Sikeres adatlekérdezés után feltöltjük a dropdown típusú forrás controlt
function UpdateDropdownCascade(response, childControlID) {
    // az első kivételével az elemek törlése
    RemoveDropdownItemsExceptFirst(childControlID);

    // A dropdown-t elfedő text értékét is törölni kell -> Ez esetben 'Kérem válasszon' szöveg.
    var selectedText = $('#' + childControlID + ' option:first').text();
    GetDropdownControl(childControlID).val(selectedText);

    // új értékek betöltése
    $.each(response, function (index, item) {
        var value = item.id > 0 ? item.id : item.label;

        $('#' + childControlID).append($("<option></option>")
            .attr("value", value).text(item.label));
    });
}

function RemoveDropdownItemsExceptFirst(controlID) {
    // az első kivételével az elemek törlése
    $('#' + controlID + ' option:gt(0)').remove();
}

// Sikeres adatlekérdezés után feltöltjük a label típusú forrás controlt
function UpdateLabelCascade(response, childControlID) {
    if (!response || response.length === 0) {
        return;
    }

    var responseItem = response[0];

    UpdateLabelCascadeValues(childControlID, responseItem.label, responseItem.id);
}

function UpdateLabelCascadeValues(controlID, value, valueID) {
    // Span érték
    $('#' + controlID).prev('span, .fdlcascadeparent').html(value);
    // Hidden mezők
    $('#' + controlID).val(value);
    $('#' + controlID + 'ID').val(valueID);
}

//--------------------- Kereszthivatkozás függvények vége -------------------------------------
