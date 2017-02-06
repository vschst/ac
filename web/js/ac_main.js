'use strict';

var Admins = {Load: false, Data: {}, Length: 0, NumberOfAdmins: 0};

var Pages = {
    Index: {
        Selected: true
    },
    AddNewAdmin: {
        Selected: false
    },
    EditAdmin: {
        Selected: false,
        Login: null
    }
};

var Actions = {Internal: {Execute: false}, External: {Execute: false}}


function loadAdminsData(LoadData) {
    for (var ldKey in LoadData) {
        if (LoadData[ldKey].hasOwnProperty("Login") == false) {
            throw new SyntaxError("Error with function 'loadAdminsData' (Key: "+ ldKey +", Login undefined)");
        }
        else if (LoadData[ldKey].hasOwnProperty("Data") == false) {
            throw new SyntaxError("Error with function 'loadAdminsData' (Key: "+ ldKey +", Data undefined)");
        }

        try {
            checkAdminData(LoadData[ldKey].Data);
        }
        catch (e) {
            throw new SyntaxError("Error with function 'checkAdminData' (Login: "+ LoadData[ldKey].Login +", Message: "+ e.Message +")");
        }

        Admins.Data[LoadData[ldKey].Login] = LoadData[ldKey].Data;

        Admins.Length++;
    }
}


function removeAdminsData(LoginsData) {
    for (var ldKey in LoginsData) {
        if (Admins.Data.hasOwnProperty(LoginsData[ldKey]) == true) {
            delete Admins.Data[LoginsData[ldKey]];

            Admins.Length--;
        }
        else {
            throw new SyntaxError("Error with function 'removeAdminData' (Login '"+ LoginsData[ldKey] +"' undefined)");
        }
    }
}


function editAdminsData(ChangedAdminsData) {
    var adminLogin;

    for (var cbdKey in ChangedAdminsData) {
        if (ChangedAdminsData[cbdKey].hasOwnProperty("Login") == false) {
            throw new SyntaxError("Error with function 'updateAdminData' (Key: "+ cbdKey +", Login undefined)");
        }
        else if (ChangedAdminsData[cbdKey].hasOwnProperty("Data") == false) {
            throw new SyntaxError("Error with function 'updateAdminData' (Key: "+ cbdKey +", Data undefined)");
        }

        adminLogin = ChangedAdminsData[cbdKey].Login;

        if (Admins.Data.hasOwnProperty(adminLogin) == true) {
            if (ChangedAdminsData[cbdKey].Data.hasOwnProperty('Term') == true) {
                Admins.Data[adminLogin].Term = ChangedAdminsData[cbdKey].Data.Term;
            }

            if (ChangedAdminsData[cbdKey].Data.hasOwnProperty('ACLGroup') == true) {
                Admins.Data[adminLogin].ACLGroup = ChangedAdminsData[cbdKey].Data.ACLGroup;
            }

            if (ChangedAdminsData[cbdKey].Data.hasOwnProperty('BindingToSerial') == true) {
                Admins.Data[adminLogin].BindingToSerial = ChangedAdminsData[cbdKey].Data.BindingToSerial;
            }

            if (ChangedAdminsData[cbdKey].Data.hasOwnProperty('Name') == true) {
                Admins.Data[adminLogin].Name = ChangedAdminsData[cbdKey].Data.Name;
            }
        }
        else {
            throw new SyntaxError("Error with function 'updateAdminData' (Login '"+ ChangedAdminsData[adminLogin].Login +"' undefined)");
        }
    }
}


function checkAdminData(AdminData) {
    if (AdminData.hasOwnProperty("ACLGroup") == false) {
        throw new SyntaxError("'ACLGroup' undefined");
    }
    else if (AdminData.hasOwnProperty("Issued") == false) {
        throw new SyntaxError("'Issued' undefined");
    }
    else if (AdminData.hasOwnProperty("DateOfIssue") == false) {
        throw new SyntaxError("'DateOfIssue' undefined");
    }
    else if (AdminData.hasOwnProperty("Term") == false) {
        throw new SyntaxError("'Term' undefined");
    }
    else if (AdminData.hasOwnProperty("BindingToSerial") == false) {
        throw new SyntaxError("'BindingToSerial' undefined");
    }
}


function updateShownAdminsText() {
    $("#admins-shown").text(Admins.Length);
    $("#admins-all").text(Admins.NumberOfAdmins);
}


function getCheckElement() {
    return $('<i class="fa fa-check" aria-hidden="true"></i>');
}


function getTimesElement() {
    return $('<i class="fa fa-times" aria-hidden="true"></i>');
}


function getAdminsDataTableRow(rowNumber, adminLogin, AdminData) {
    var RowTR = $("<tr id="+ adminLogin +"></tr>");

    //Row number
    RowTR.append($('<td class="row-number"></td>').text(rowNumber));

    //Login
    RowTR.append($('<td class="admin-login"></td>').html($("<b></b>").text(adminLogin)));

    //ACL Group
    RowTR.append($('<td class="admin-acl-group"></td>').text(AdminData.ACLGroup));

    //Issued
    RowTR.append($('<td></td>').text(AdminData.Issued));

    //Date of issue
    var adminDateOfIssue = moment.unix(AdminData.DateOfIssue);

    RowTR.append($('<td></td>').text(adminDateOfIssue.format("DD/MM/YYYY hh:mm")));

    //Term
    RowTR.append($('<td class="admin-term"></td>').text(AdminData.Term));

    //Date of removal
    var adminDateOfRemoval = moment.unix(AdminData.DateOfIssue + (AdminData.Term * 86400));

    RowTR.append($('<td class="admin-date-of-removal"></td>').text(adminDateOfRemoval.format("DD/MM/YYYY hh:mm")));

    //Binding to serial
    var bindingToSerialElement = $('<td class="admin-binding-to-serial"></td>');

    if (AdminData.BindingToSerial == true) {
        RowTR.append(bindingToSerialElement.html(getCheckElement()));
    }
    else {
        RowTR.append(bindingToSerialElement.html(getTimesElement()));
    }

    //Choose
    var chooseElement = $('<input name="admin-check" value="'+ adminLogin +'" type="radio" class="form-check-input">');

    chooseElement.on("change",
        function(event) {
            event.preventDefault();

            $("#edit-admin-btn").prop("disabled", false);
            $("#remove-admin-btn").prop("disabled", false);
        }
    );

    RowTR.append($('<td><label class="form-check-label"></label></td>').html(chooseElement));

    return RowTR;
}


function removeAdminsDataTableRow(adminLogin, lastRemovedRow) {
    var banRow = $("#"+ adminLogin);

    banRow.find('input[name="admin-check"]').off("change");

    if (lastRemovedRow == false) {
        banRow.fadeOut("slow",
            function() {
                $(this).remove();
            }
        );
    }
    else {
        banRow.fadeOut("slow",
            function() {
                $(this).remove();

                updateAdminsRowNumbers();
            }
        );
    }
}


function editAdminsDataTableRow(adminLogin, ChangedAdminData) {
    var adminRow = $("#"+ adminLogin);

    if (ChangedAdminData.hasOwnProperty("Term") == true) {
        adminRow.find(".admin-term").text(ChangedAdminData.Term);

        var adminDateOfRemoval = moment.unix(Admins.Data[adminLogin].DateOfIssue + (ChangedAdminData.Term * 86400));

        adminRow.find(".admin-date-of-removal").text(adminDateOfRemoval.format("DD/MM/YYYY hh:mm"));
    }

    if (ChangedAdminData.hasOwnProperty("ACLGroup") == true) {
        adminRow.find(".admin-acl-group").text(ChangedAdminData.ACLGroup);
    }

    if (ChangedAdminData.hasOwnProperty("BindingToSerial") == true) {
        if (ChangedAdminData.BindingToSerial == true) {
            adminRow.find(".admin-binding-to-serial").html(getCheckElement());
        }
        else {
            adminRow.find(".admin-binding-to-serial").html(getTimesElement());
        }
    }
}


function setInputDanger(inputID) {
    var selector = $("#"+ inputID);

    selector.parent().addClass("has-danger");
    selector.addClass("form-control-danger");
}


function removeInputDanger(inputID) {
    var selector = $("#"+ inputID);

    selector.parent().removeClass("has-danger");
    selector.removeClass("form-control-danger");
}


function updateAdminsRowNumbers() {
    $("#adminsdata-table-rows").find("tr").each(
        function(i) {
            $(this).find(".row-number").text(i + 1);
        }
    );
}


function selectPage(pageKey) {
    for (var pKey in Pages) {
        if (Pages.hasOwnProperty(pageKey) == true) {
            if (pKey == pageKey) {
                Pages[pKey].Selected = true;
            }
            else {
                Pages[pKey].Selected = false;
            }
        }
    }
}


function backToIndexPage() {
    selectPage("Index");

    $("#add-new-admin-page, #edit-admin-page").addClass("ac-hide");

    $("#index-page").removeClass("ac-hide");
}


function hexToHtml(str) {
    var reg = /(#(?:[a-f\d]{2}){3})/gi
    var res = str.split(reg);

    var i = 0, substr;
    var result = "";

    while (i < res.length) {
    	substr = res[i];

        if ((substr.charAt(0) == "#") && (substr.length == 7)) {
      	    if (res[i+1] != "") {
      		    result = result + '<span style="color: '+ substr.toUpperCase() +'">';
            }
            else {
        	    i++;
            }
        }
        else {
      	    if (i == 0) {
        	    result = result + substr;
            }
            else {
      		    result = result + substr + "</span>";
            }
        }

    	i++;
    }

    if (result.length == 0) {
    	result = str;
    }

    return result;
}