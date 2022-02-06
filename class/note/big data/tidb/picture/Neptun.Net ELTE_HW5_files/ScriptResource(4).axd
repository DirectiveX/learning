/// <reference path="https://ajax.microsoft.com/ajax/jquery/jquery-1.7.1.js"/>
/// <reference path="https://ajax.microsoft.com/ajax/jquery.ui/1.8.18/jquery-ui.js"/>
Type.registerNamespace("SDA.Neptun.WebControls");
SDA.Neptun.WebControls.SDAGadget = function (element) {
    SDA.Neptun.WebControls.SDAGadget.initializeBase(this, [element]);

    this._DivImageLoaderID = null;
    this._GadgetType = null;
    this._GadgetContainerUniqueID = null;
    this._GadgetID = null;
    this._GadgetTableID = null;
    this._BodyID = null;
    this._CloseButtonID = null;
    this._IsRefresh = null;
    this._DivChooseColorID = null;
    this._ChooseColorID = null;
    this._IsCollapseDivChooseColor = true;
};

SDA.Neptun.WebControls.SDAGadget.prototype = {
    initialize: function () {
        SDA.Neptun.WebControls.SDAGadget.callBaseMethod(this, "initialize");

        if (this._IsRefresh == true) {
            var prm = Sys.WebForms.PageRequestManager.getInstance();
            prm._doPostBack(this._GadgetID, 'refresh');
        }

        //self = this;
        var gadgetdiv = $('#' + this._GadgetID);
        var gadget = gadgetdiv.find('.Gadget');
        var upFunction = $('#upFunction');  // kulso updatepanel divje

        // gadget control
        gadget.width('100%');
        gadgetdiv.show();

        if (this._CloseButtonID && !this._GadgetContainerUniqueID /*&& modallevel == 0*/) {
          this.makeSortableLeftbox();
        }

        if (this._CloseButtonID && this._GadgetContainerUniqueID) {
            // gadget bezarasa ha containerben van
            this.makeSortable();
            var data = { containeruniqueid: this._GadgetContainerUniqueID, gadgettype: this._GadgetType };
            $('#' + this._CloseButtonID).bind('click', data, function (event) {
                var prm = Sys.WebForms.PageRequestManager.getInstance();
                prm._doPostBack(event.data.containeruniqueid, event.data.gadgettype);
            });
        }

        // szinvalasztas megvalositasa
        if (this._ChooseColorID) {
            var btnchoosecolor = $('#' + this._ChooseColorID);
            btnchoosecolor.click({ divchoosecolorid: this._DivChooseColorID }, function (event) {
                var divchoosecolorid = event.data.divchoosecolorid;
                var divchoosecolor = $('#' + divchoosecolorid);
                if (divchoosecolor.is(':hidden')) {
                    divchoosecolor.show();
                }

                // valamelyik szinre kattint, akkor egybol eletbe lep a valtoztatas
                divchoosecolor.find('.gadgetimage').click({ divchoosecolorctrl: divchoosecolor, gadgetctrl: gadget, gadgetid: gadgetdiv.parent()[0].id, gagdetobj: this }, function (event) {
                    // eloszor is becsukom a szinvalasztot
                    var divchoosecolorctrl = event.data.divchoosecolorctrl;
                    var divHeight = divchoosecolorctrl.height() + parseInt(divchoosecolorctrl.css('paddingTop')) + parseInt(divchoosecolorctrl.css('paddingBottom'));
                    divchoosecolorctrl.css('marginTop', -divHeight);

                    event.data.gagdetobj._IsCollapseDivChooseColor = false;

                    var gadgetbody = $(event.data.gadgetctrl).find('.GadgetBody');

                    gadgetbody.removeClass();

                    var gadgettitleimage = event.data.gadgetctrl.find('.gadgettitleimage');
                    gadgettitleimage.show();

                    gadgetbody.addClass('GadgetBody');
                    var element = event.srcElement ? event.srcElement : event.target;
                    var cmd = element.attributes['cmd'].value;
                    var skinname = '';
                    switch (cmd) {
                        case '1':
                            gadgetbody.addClass('gadgetskingray');
                            gadgettitleimage.attr('src', 'App_Themes/New_Common_Images/gadget_cc_gray.png');
                            skinname = 'gray';
                            break;
                        case '2':
                            gadgetbody.addClass('gadgetskinbrawn');
                            gadgettitleimage.attr('src', 'App_Themes/New_Common_Images/gadget_cc_brawn.png');
                            skinname = 'brawn';
                            break;
                        case '3':
                            gadgetbody.addClass('gadgetskinorange');
                            gadgettitleimage.attr('src', 'App_Themes/New_Common_Images/gadget_cc_orange.png');
                            skinname = 'orange';
                            break;
                        case '4':
                            gadgetbody.addClass('gadgetskinpink');
                            gadgettitleimage.attr('src', 'App_Themes/New_Common_Images/gadget_cc_pink.png');
                            skinname = 'pink';
                            break;
                        case '5':
                            gadgetbody.addClass('gadgetskinyellow');
                            gadgettitleimage.attr('src', 'App_Themes/New_Common_Images/gadget_cc_yellow.png');
                            skinname = 'yellow';
                            break;
                        case '6':
                            gadgetbody.addClass('gadgetskingreen');
                            gadgettitleimage.attr('src', 'App_Themes/New_Common_Images/gadget_cc_green.png');
                            skinname = 'green';
                            break;
                        case '7':
                            gadgetbody.addClass('gadgetskinblue');
                            gadgettitleimage.attr('src', 'App_Themes/New_Common_Images/gadget_cc_blue.png');
                            skinname = 'blue';
                            break;
                        case '8':
                            gadgetbody.addClass('gadgetskinviola');
                            gadgettitleimage.attr('src', 'App_Themes/New_Common_Images/gadget_cc_viola.png');
                            skinname = 'viola';
                            break;
                        default:
                            gadgettitleimage.attr('src', 'App_Themes/New_Common_Images/gadget_cc_default.png');
                            skinname = '';
                            break;
                    }

                    PageMethods.SetGadgetSkinState(event.data.gadgetid, skinname);
                });

                var divouter = $(divchoosecolor[0].parentNode);
                if (divouter.hasClass('gadgetchoosecolorwrapper') == false) {
                    divouter = divchoosecolor.wrap('<div class="gadgetchoosecolorwrapper"></div>');
                }

                var divHeight = divchoosecolor.height() + parseInt(divchoosecolor.css('paddingTop')) + parseInt(divchoosecolor.css('paddingBottom'));
                var _startmarginTop = this._IsCollapseDivChooseColor ? 0 : -divHeight;
                divchoosecolor.css('marginTop', _startmarginTop);
                var _marginTop = this._IsCollapseDivChooseColor ? -divHeight : 0;
                divchoosecolor.animate({ marginTop: _marginTop }, 'slow');

                divouter.width(gadgetdiv.width() - 7);
                this._IsCollapseDivChooseColor = !this._IsCollapseDivChooseColor;
            });

        }
    },
    get_GadgetType: function () {
        return this._GadgetType;
    },
    set_GadgetType: function (value) {
        this._GadgetType = value;
    },
    get_GadgetContainerUniqueID: function () {
        return this._GadgetContainerUniqueID;
    },
    set_GadgetContainerUniqueID: function (value) {
        this._GadgetContainerUniqueID = value;
    },
    get_GadgetID: function () {
        return this._GadgetID;
    },
    set_GadgetID: function (value) {
        this._GadgetID = value;
    },
    get_GadgetTableID: function () {
        return this._GadgetTableID;
    },
    set_GadgetTableID: function (value) {
        this._GadgetTableID = value;
    },
    get_BodyID: function () {
        return this._BodyID;
    },
    set_BodyID: function (value) {
        this._BodyID = value;
    },
    get_DivImageLoaderID: function () {
        return this._DivImageLoaderID;
    },
    set_DivImageLoaderID: function (value) {
        this._DivImageLoaderID = value;
    },
    get_GadgetState: function () {
        return this._GadgetState;
    },
    set_GadgetState: function (value) {
        this._GadgetState = value;
    },
    get_CloseButtonID: function () {
        return this._CloseButtonID;
    },
    set_CloseButtonID: function (value) {
        this._CloseButtonID = value;
    },
    get_IsRefresh: function () {
        return this._IsRefresh;
    },
    set_IsRefresh: function (value) {
        this._IsRefresh = value;
    },
    get_HfChangeViewID: function () {
        return this._HfChangeViewID;
    },
    set_HfChangeViewID: function (value) {
        this._HfChangeViewID = value;
    },
    get_DivChooseColorID: function () {
        return this._DivChooseColorID;
    },
    set_DivChooseColorID: function (value) {
        this._DivChooseColorID = value;
    },
    get_ChooseColorID: function () {
        return this._ChooseColorID;
    },
    set_ChooseColorID: function (value) {
        this._ChooseColorID = value;
    },
    dispose: function () {
        SDA.Neptun.WebControls.SDAGadget.callBaseMethod(this, "dispose");
    },
    makeSortable: function () {
        $('td[name*="gadgetheadertitle"]').css({
            cursor: 'move'
        });

        $('td[name*="gadgetheadertitle"]').parent('tr').css({
            cursor: 'move'
        }).mousedown(function (e) {
            $('tr.containerrowbody').css({ width: '' });
            $(this).parent().css({
                width: $(this).parent().width() + 'px'
            });
        }).mouseup(function () {
            if (!$(this).parent().hasClass('gadget-dragging')) {
                $(this).parent().css({ width: '' });
            } else {
                $('td.ContainerBody').sortable('disable');
            }
        });

        $('input.gadgetbutton').css({
            cursor: 'hand'
        });

        $('td.ContainerBody').sortable({
            items: $('tr.containerrowbody'),
            connectWith: $('td.ContainerBody'),
            handle: $('td[name*="gadgetheadertitle"]').parent('tr'),
            placeholder: 'gadget-placeholder',
            forcePlaceholderSize: true,
            revert: true,
            opacity: 0.75,
            containment: 'td.function',
            update: function (e, ui) {
                if (Sys.Browser.agent == Sys.Browser.InternetExplorer && Sys.Browser.version < 9)
                    $("tr.containerrowbody").draggable({ stack: "tr.containerrowbody" });
                $('td.ContainerBody:not(td.ContainerBody:has(tr.containerrowbody)) > table > tbody').append($('<tr class="containerrowbody" id="temp-gadget" />'));

                if ($(ui.item).parent().hasClass('ContainerBody')) {
                    $(ui.item).appendTo(($(ui.item).parent().find('#temp-gadget')).parent());
                    ($(ui.item).parent().find('#temp-gadget')).remove();
                }

                if (ui != null && ui.item != null && ui.item.context != null &&
                ui.item.context.id != null && ui.item.context.id != "" &&
                ui.item.context.parentNode != null && ui.item.context.parentNode.parentNode != null &&
                ui.item.context.parentNode.parentNode.parentNode != null &&
                ui.item.context.parentNode.parentNode.parentNode.cellIndex > 0 &&
                ui.item.context.rowIndex >= 0) {
                    PageMethods.SetGadgetSortedList(
                        $('span.container')[0].id,
                        ui.item.context.id,
                        ui.item.context.parentNode.parentNode.parentNode.cellIndex - 1,
                        ui.item.context.rowIndex
                    );
                }
            },
            start: function (e, ui) {
                $(ui.helper).addClass('gadget-dragging');
            },
            stop: function (e, ui) {
                $(ui.item).css({ width: '' }).removeClass('gadget-dragging');
                $('td.ContainerBody').sortable('enable');
            },
            create: function (e, ui) {
                $('td.ContainerBody:not(td.ContainerBody:has(tr.containerrowbody)) > table > tbody').append($('<tr class="containerrowbody" id="temp-gadget" />'));
                $('td.ContainerBody:not(td.ContainerBody:has(tbody)) > table').append($('<tbody><tr class="containerrowbody" id="temp-gadget" /></tbody>'));
            }
        });
        if (Sys.Browser.agent == Sys.Browser.InternetExplorer && Sys.Browser.version < 9)
            $("tr.containerrowbody").draggable({ stack: "tr.containerrowbody" });
        //$("tr.containerrowbody").disableSelection();
        $('td.ContainerBody').sortable('enable');
        $("tr.containerrowbody").css('visibility', 'visible');
    },
    makeSortableLeftbox: function () {
        if ($("td.leftbox").length > 0 && $("td.leftbox")[0].id != null) {
            $("td.leftbox").css('visibility', 'visible');
            $(".gadgettitleimage").css('visibility', 'hidden');
        }
    }
};

SDA.Neptun.WebControls.SDAGadget.registerClass("SDA.Neptun.WebControls.SDAGadget", Sys.UI.Control);
