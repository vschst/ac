'use strict';

var UpdateTimers = {Added: null, Removed: null, Edited: null};

function updateAddedAdmins() {
    if ((Actions.Internal.Execute == false) && (Actions.External.Execute == false)) {
        var maxDateOfIssue = 0;

        for (var adminLogin in Admins.Data) {
            if ((Admins.Data.hasOwnProperty(adminLogin) == true) && ((maxDateOfIssue == 0) || (Admins.Data[adminLogin].DateOfIssue > maxDateOfIssue))) {
                maxDateOfIssue = Admins.Data[adminLogin].DateOfIssue;
            }
        }

        if (maxDateOfIssue != null) {
            Actions.Internal.Execute = true;

            $.ajax({
                url: "/"+ resourceName +"/call/webUpdateAddedAdmins",
                data: JSON.stringify([maxDateOfIssue]),
                type: "POST"
            })
            .done(
                function(data) {
                    var ResponseObject = $.parseJSON(data)[0];

                    try {
                        if (ResponseObject == undefined) {
                            throw new SyntaxError("Error with function 'webUpdateAddedAdmins' (Response object undefined)");
                        }
                        else if (ResponseObject.hasOwnProperty("ErrorCode") == false) {
                            throw new SyntaxError("Error with function 'webUpdateAddedAdmins' ('ErrorCode' undefined)");
                        }
                        else if (ResponseObject.ErrorCode != 0) {
                            throw new ReferenceError("Error with function 'webUpdateAddedAdmins' (Error code: "+ ResponseObject.ErrorCode +")");
                        }
                        else if (ResponseObject.hasOwnProperty("Response") == false) {
                            throw new SyntaxError("Error with function 'webUpdateAddedAdmins' ('Response' undefined)");
                        }
                        else if ((ResponseObject.Response.hasOwnProperty("Data") == false) || (Array.isArray(ResponseObject.Response.Data) == false)) {
                            throw new SyntaxError("Error with function 'webUpdateAddedAdmins' ('Response.Data' incorrect)");
                        }
                        else if ((ResponseObject.Response.hasOwnProperty("NumberOfAdmins") == false) || (Number.isInteger(ResponseObject.Response.NumberOfAdmins) == false)) {
                            throw new SyntaxError("Error with function 'webUpdateAddedAdmins' ('Response.NumberOfAdmins' incorrect)");
                        }

                        var AddedAdminsLoadData = ResponseObject.Response.Data;

                        loadAdminsData(AddedAdminsLoadData);

                        Admins.NumberOfAdmins = ResponseObject.Response.NumberOfAdmins;

                        if (AddedAdminsLoadData.length > 0) {
                            var adminRow;

                            for (var aaldKey = 0; aaldKey < AddedAdminsLoadData.length; aaldKey++) {
                                adminRow = getAdminsDataTableRow((AddedAdminsLoadData.length - aaldKey), AddedAdminsLoadData[aaldKey].Login, AddedAdminsLoadData[aaldKey].Data);

                                $("#adminsdata-table-rows").prepend(adminRow.hide());
                                adminRow.fadeIn("slow");
                            }

                            adminRow.nextAll().each(
                                function(i) {
                                    $(this).find(".row-number").text(AddedAdminsLoadData.length + i + 1);
                                }
                            );


                            if ($("#no-admins").css("display") == "table-row") {
                                $("#no-admins").css("display", "none");
                            }
                        }

                        updateShownAdminsText();
                    }
                    catch (e) {
                        console.log("["+ e.name + "] "+ e.message);
                    }

                    Actions.Internal.Execute = false;
                }
            );
        }
    }

    UpdateTimers.Removed = setTimeout(updateRemovedAdmins, 3000);
}


function updateRemovedAdmins() {
    if ((Actions.Internal.Execute == false) && (Actions.External.Execute == false) && (Pages.EditAdmin.Selected == false)) {
        var LastAdminsLoginData = new Array();

        for (var adminLogin in Admins.Data) {
            if (Admins.Data.hasOwnProperty(adminLogin) == true) {
                LastAdminsLoginData.push(adminLogin);
            }
        }

        if (LastAdminsLoginData.length != 0) {
            Actions.Internal.Execute = true;

            $.ajax({
                url: "/"+ resourceName +"/call/webUpdateRemovedAdmins",
                data: JSON.stringify([LastAdminsLoginData]),
                type: "POST"
            })
            .done(
                function(data) {
                    var ResponseObject = $.parseJSON(data)[0];

                    try {
                        if (ResponseObject == undefined) {
                            throw new SyntaxError("Error with function 'webUpdateRemovedAdmins' (Response object undefined)");
                        }
                        else if (ResponseObject.hasOwnProperty("ErrorCode") == false) {
                            throw new SyntaxError("Error with function 'webUpdateRemovedAdmins' ('ErrorCode' undefined)");
                        }
                        if (ResponseObject.ErrorCode != 0) {
                            throw new ReferenceError("Error with function 'webUpdateRemovedAdmins' (Error code: "+ ResponseObject.ErrorCode +")");
                        }
                        else if ((ResponseObject.hasOwnProperty("Response") == false) || (Array.isArray(ResponseObject.Response) == false)) {
                            throw new SyntaxError("Error with function 'webUpdateRemovedAdmins' ('Response' incorrect)");
                        }

                        var RemovedAdminsLoginData = ResponseObject.Response;

                        removeAdminsData(RemovedAdminsLoginData);

                        Admins.NumberOfAdmins = (Admins.NumberOfAdmins - RemovedAdminsLoginData.length);


                        var lastRemovedRow = false;

                        for (var raldKey in RemovedAdminsLoginData) {
                            if (raldKey == (RemovedAdminsLoginData.length - 1)) {
                                lastRemovedRow = true;
                            }

                            removeAdminsDataTableRow(RemovedAdminsLoginData[raldKey], lastRemovedRow);
                        }


                        if (Admins.Length == 0) {
                            $("#no-admins").css("display", "table-row");
                            $("#show-more-admins").css("display", "none");
                        }

                        updateShownAdminsText();
                    }
                    catch (e) {
                        console.log("["+ e.name + "] "+ e.message);
                    }

                    Actions.Internal.Execute = false;
                }
            );
        }
    }

    UpdateTimers.Edited = setTimeout(updateEditedAdmins, 3000);
}


function updateEditedAdmins() {
    if ((Actions.Internal.Execute == false) && (Actions.External.Execute == false) && (Pages.EditAdmin.Selected == false) && (Admins.Length > 0)) {
        Actions.Internal.Execute = true;

        var LastAdminsData = new Array();

        for (var adminLogin in Admins.Data) {
            if (Admins.Data.hasOwnProperty(adminLogin) == true) {
                LastAdminsData.push({Login: adminLogin, Data: Admins.Data[adminLogin]});
            }
        }

        $.ajax({
            url: "/"+ resourceName +"/call/webUpdateEditedAdmins",
            data: JSON.stringify([LastAdminsData]),
            type: "POST"
        })
        .done(
            function(data) {
                var ResponseObject = $.parseJSON(data)[0];

                try {
                    if (ResponseObject == undefined) {
                        throw new SyntaxError("Error with function 'webUpdateEditedAdmins' (Response object undefined)");
                    }
                    else if (ResponseObject.hasOwnProperty("ErrorCode") == false) {
                        throw new SyntaxError("Error with function 'webUpdateEditedAdmins' ('ErrorCode' undefined)");
                    }
                    if (ResponseObject.ErrorCode != 0) {
                        throw new ReferenceError("Error with function 'webUpdateEditedAdmins' (Error code: "+ ResponseObject.ErrorCode +")");
                    }
                    else if ((ResponseObject.hasOwnProperty("Response") == false) || (Array.isArray(ResponseObject.Response) == false)) {
                        throw new SyntaxError("Error with function 'webUpdateEditedAdmins' ('Response' incorrect)");
                    }

                    var ChangedAdminsData = ResponseObject.Response;

                    editAdminsData(ChangedAdminsData);


                    for (var cbdKey in ChangedAdminsData) {
                        editAdminsDataTableRow(ChangedAdminsData[cbdKey].Login, ChangedAdminsData[cbdKey].Data);
                    }
                }
                catch (e) {
                    console.log("["+ e.name + "] "+ e.message);
                }

                Actions.Internal.Execute = false;
            }
        );
    }

    UpdateTimers.Added = setTimeout(updateAddedAdmins, 3000);
}