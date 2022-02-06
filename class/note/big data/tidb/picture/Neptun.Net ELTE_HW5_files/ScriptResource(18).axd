Type.registerNamespace('SDA.Neptun.WebControls');
SDA.Neptun.WebControls.TimeTable = function (element) {
    SDA.Neptun.WebControls.TimeTable.initializeBase(this, [element]);
    this._uniqueID = null;
    this._isNewEventEnabled = null;
    this._isBlind = null;
    this._TimeTableFunctionMode = null;
}
SDA.Neptun.WebControls.TimeTable.prototype = {
    initialize: function () {
        var isblind= this.get_isBlind();
        var view = this._timetableview;
        var DATA_FEED_URL = "TimeTableHandler.ashx";
        var op =
                {
                    id: this.get_uniqueID(),
                    view: view,
                    theme: 3,
                    showday: new Date(),
                    EditCmdhandler: Edit,
                    DeleteCmdhandler: Delete,
                    ViewCmdhandler: View,
                    onWeekOrMonthToDay: wtd,
                    onBeforeRequestData: cal_beforerequest,
                    onAfterRequestData: cal_afterrequest,
                    onRequestDataError: cal_onerror,
                    autoload: true,
                    url: DATA_FEED_URL,
                    quickAddUrl: "valami",
                    quickUpdateUrl: "",
                    quickDeleteUrl: "",
                    isDynamicView: true,
                    isNormalPost: true,
                    isNewEventEnabled: this.get_isNewEventEnabled(),
                    TimeTableFunctionMode: this.get_TimeTableFunctionMode()
                };

        var $dv = $("#calhead");
        var $alldaycont = $("#dvwkcontaienr");
        var $napokdiv = $("#dvwkcontaienr");

        var _MH = 618;
        var dvH = $dv.height() + 2;
        op.height = _MH - dvH;
        op.eventItems = [];
        var self = this;
        var p = $("#gridcontainer").bcalendar(op).BcalGetOp();
        if (p && p.datestrshow) {
            $("#txtdatetimeshow").text(p.datestrshow);
        }

        $("#caltoolbar").noSelect();

        $("#hdtxtshow").datepicker({ picker: "#txtdatetimeshow", showtarget: $("#txtdatetimeshow"),
            onReturn: function (r) {
                var p = $("#gridcontainer").gotoDate(r).BcalGetOp();
                if (p && p.datestrshow) {
                    $("#txtdatetimeshow").text(p.datestrshow);
                }
            }
        });

        function cal_beforerequest(type) {
            var t = "Loading data...";
            switch (type) {
                case 1:
                    t = "Loading data...";
                    break;
                case 2:
                case 3:
                case 4:
                    t = "The request is being processed ...";
                    break;
            }
            $("#errorpannel").hide();
            $("#loadingpannel").html(t).show();
        }

        function cal_afterrequest(type) {
            switch (type) {
                case 1:
                    $("#loadingpannel").hide();
                    break;
                case 2:
                case 3:
                case 4:
                    $("#loadingpannel").html("Success!");
                    window.setTimeout(function () { $("#loadingpannel").hide(); }, 2000);
                    break;
            }
            if (isblind) {
                var datestr = '/Date(0)/';
                var startdatewithoututc = new Date();
                startdatewithoututc = new Date(startdatewithoututc.getUTCFullYear(),
                                    startdatewithoututc.getUTCMonth(),
                                    startdatewithoututc.getUTCDate(),
                                    startdatewithoututc.getUTCHours(),
                                    startdatewithoututc.getUTCMinutes());
                var enddatewithoututc = new Date();
                enddatewithoututc = new Date(enddatewithoututc.getUTCFullYear(),
                                    enddatewithoututc.getUTCMonth(),
                                    enddatewithoututc.getUTCDate(),
                                    enddatewithoututc.getUTCHours(),
                                    enddatewithoututc.getUTCMinutes());
                var neptunparams =
              {
                  id: -2,
                  type: 0,
                  subjectid: 0,
                  courseid: 0,
                  examid: 0,
                  termid: 0,
                  startdate: datestr.replace('0', startdatewithoututc.valueOf()),
                  enddate: datestr.replace('0', enddatewithoututc.valueOf()),
                  ownername: "",
                  events: ""                  
              };
                var jsonBackString = JSON.stringify(neptunparams);                
                __doPostBack(self._uniqueID, jsonBackString);
            }
        }

        function cal_onerror(type, data) {
            $("#errorpannel").show();
        }

        function Edit(data) {
            var datestr = '/Date(0)/';
            var startdatewithoututc = data.startdate - (data.startdate.getTimezoneOffset() * 60000);
            var enddatewithoututc = data.enddate - (data.enddate.getTimezoneOffset() * 60000);
            var neptunparams =
            {
                id: -1,
                type: 0,
                subjectid: 0,
                courseid: 0,
                examid: 0,
                termid: 0,
                startdate: datestr.replace('0', startdatewithoututc.valueOf()),
                enddate: datestr.replace('0', enddatewithoututc.valueOf()),
                type: data.eventtype,
                events: ""              
            };
            var jsonBackString = JSON.stringify(neptunparams);
            __doPostBack(self._uniqueID, jsonBackString);
        }

        function View(data) {
            var myevents = $("#gridcontainer").BcalGetOp().eventItems;
            var id = data[4];
            var neptunparams;
            $.each(myevents, function (index, value) {
                if (id == value.id) {
                    if (value.neptunparams.type == 3/*talalkozo*/)
                        value.neptunparams.taldontesrevar = value.iskiemelt;
                    value.neptunparams.menuindex = data[13] == null ? 0 : data[13];
                    neptunparams = value.neptunparams;
                }
            });
            var jsonBackString = JSON.stringify(neptunparams);
            __doPostBack(self._uniqueID, jsonBackString);
        }

        function Delete(data, callback) {
            $.alerts.okButton = "Ok";
            $.alerts.cancelButton = "Cancel";
            hiConfirm("Are You Sure to Delete this Event", 'Confirm', function (r) { r && callback(0); });
        }

        function wtd(p) {
            if (p && p.datestrshow) {
                $("#txtdatetimeshow").text(p.datestrshow);
            }
            $("#caltoolbar div.fcurrent").each(function () {
                $(this).removeClass("fcurrent");
            })
            $("#showdaybtn").addClass("fcurrent");
        }
        //to show day view
        $("#showdaybtn").click(function (e) {
            //document.location.href="#day";
            $("#caltoolbar div.fcurrent").each(function () {
                $(this).removeClass("fcurrent");
            })
            $(this).addClass("fcurrent");
            var p = $("#gridcontainer").swtichView("day").BcalGetOp();
            if (p && p.datestrshow) {
                $("#txtdatetimeshow").text(p.datestrshow);
            }
        });
        //to show week view
        $("#showweekbtn").click(function (e) {
            //document.location.href="#week";
            $("#caltoolbar div.fcurrent").each(function () {
                $(this).removeClass("fcurrent");
            })
            $(this).addClass("fcurrent");
            var p = $("#gridcontainer").swtichView("week").BcalGetOp();
            if (p && p.datestrshow) {
                $("#txtdatetimeshow").text(p.datestrshow);
            }
        });
        //to show month view
        $("#showmonthbtn").click(function (e) {
            //document.location.href="#month";
            $("#caltoolbar div.fcurrent").each(function () {
                $(this).removeClass("fcurrent");
            })
            $(this).addClass("fcurrent");
            var p = $("#gridcontainer").swtichView("month").BcalGetOp();
        });
        //agenda view
        $("#showagendabtn").click(function (e) {
            $("#caltoolbar div.fcurrent").each(function () {
                $(this).removeClass("fcurrent");
            })
            $(this).addClass("fcurrent");

            $("#mvEventContainer").attr('style', 'overflow:scroll');

            var p = $("#gridcontainer").swtichView("agenda").BcalGetOp();
        });



        $("#showreflashbtn").click(function (e) {
            $("#gridcontainer").reload();
        });

        //Add a new event
        $("#faddbtn").click(function (e) {
            var url = "edit.php";
            OpenModelWindow(url, { width: 500, height: 400, caption: "Create New Calendar" });
        });
        //go to today
        $("#showtodaybtn").click(function (e) {
            var p = $("#gridcontainer").gotoDate().BcalGetOp();
            if (p && p.datestrshow) {
                $("#txtdatetimeshow").text(p.datestrshow);
            }
        });
        //previous date range
        $("#sfprevbtn").click(function (e) {
            var p = $("#gridcontainer").previousRange().BcalGetOp();
        });
        //next date range
        $("#sfnextbtn").click(function (e) {
            var p = $("#gridcontainer").nextRange().BcalGetOp();
        });



        $("#btndynamicview").click(function (e) {
            op.isDynamicView = !op.isDynamicView;
            $("#btndynamicview").attr("isDynamicViewPost", true);
            $("#gridcontainer").BcalSetOp(op);
            $("#gridcontainer").reload();
        });

        //outlook export
        $("#btnoutlookexporttimetable").click(function (e) {
            var datestr = '/Date(0)/';
            var startdatewithoututc = new Date();
            startdatewithoututc = new Date(startdatewithoututc.getUTCFullYear(),
                                startdatewithoututc.getUTCMonth(),
                                startdatewithoututc.getUTCDate(),
                                startdatewithoututc.getUTCHours(),
                                startdatewithoututc.getUTCMinutes());
            var enddatewithoututc = new Date();
            enddatewithoututc = new Date(enddatewithoututc.getUTCFullYear(),
                                enddatewithoututc.getUTCMonth(),
                                enddatewithoututc.getUTCDate(),
                                enddatewithoututc.getUTCHours(),
                                enddatewithoututc.getUTCMinutes());

            var neptunparams =
          {
              id: -3,
              type: 0,
              subjectid: 0,
              courseid: 0,
              examid: 0,
              termid: 0,
              startdate: datestr.replace('0', startdatewithoututc.valueOf()),
              enddate: datestr.replace('0', enddatewithoututc.valueOf()),
              ownername: "",
              events: ""
          };
            var jsonBackString = JSON.stringify(neptunparams);
            __doPostBack(self._uniqueID, jsonBackString);
        });
        SDA.Neptun.WebControls.TimeTable.callBaseMethod(this, "initialize");
    },
    dispose: function () {
        SDA.Neptun.WebControls.TimeTable.callBaseMethod(this, "dispose");
    },
    get_uniqueID: function () {
        return this._uniqueID;
    },
    set_uniqueID: function (value) {
        this._uniqueID = value;
        this.raisePropertyChanged('_uniqueID');
    },
    get_isNewEventEnabled: function () {
        return this._isNewEventEnabled;
    },

    set_isNewEventEnabled: function (value) {
        this._isNewEventEnabled = value;
        this.raisePropertyChanged('_isNewEventEnabled');
    },
    get_TimeTableFunctionMode: function () {
        return this._TimeTableFunctionMode;
    },
    set_TimeTableFunctionMode: function (value) {
        this._TimeTableFunctionMode = value;
        this.raisePropertyChanged('_TimeTableFunctionMode');
    },

    get_isBlind: function () {
        return this._isBlind;
    },

    set_isBlind: function (value) {
        this._isBlind = value;
        this.raisePropertyChanged('_isBlind');
    }

}
SDA.Neptun.WebControls.TimeTable.registerClass("SDA.Neptun.WebControls.TimeTable", Sys.UI.Control);