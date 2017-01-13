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
                    Login: null}
            };

var Actions = {Internal: {Execute: false}, External: {Execute: false}}


function loadAdminsData(LoadData) {
    for (var ldKey = 0; ldKey < LoadData.length; ldKey++) {
        if (LoadData[ldKey].Login == undefined) {
            throw new SyntaxError("Error with function 'loadAdminsData' (Key: "+ ldKey +", Login undefined)");
        }
        else if (LoadData[ldKey].Data == undefined) {
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


function removeAdminData(LoginsData) {
    for (var ldKey = 0; ldKey < LoginsData.length; ldKey++) {
        if (Admins.Data[LoginsData[ldKey]] != undefined) {
            delete Admins.Data[LoginsData[ldKey]];

            Admins.Length--;
        }
        else {
            throw new SyntaxError("Error with function 'removeAdminData' (Login '"+ LoginsData[ldKey] +"' undefined)");
        }
    }
}


function updateAdminData(UpdatedData) {
    for (var udKey = 0; udKey < UpdatedData.length; udKey++) {
        if (UpdatedData[udKey].Login == undefined) {
            throw new SyntaxError("Error with function 'updateAdminData' (Key: "+ udKey +", Login undefined)");
        }
        else if (UpdatedData[udKey].Data == undefined) {
            throw new SyntaxError("Error with function 'updateAdminData' (Key: "+ udKey +", Data undefined)");
        }

        if (UpdatedData[udKey].Login != undefined) {
            if (UpdatedData[udKey].Data.Term != undefined) {
                Admins.Data[UpdatedData[udKey].Login].Term = UpdatedData[udKey].Data.Term;
            }

            if (UpdatedData[udKey].Data.ACLGroup != undefined) {
                Admins.Data[UpdatedData[udKey].Login].ACLGroup = UpdatedData[udKey].Data.ACLGroup;
            }

            if (UpdatedData[udKey].Data.BindingToSerial != undefined) {
                Admins.Data[UpdatedData[udKey].Login].BindingToSerial = UpdatedData[udKey].Data.BindingToSerial;
            }

            if (UpdatedData[udKey].Data.Name != undefined) {
                Admins.Data[UpdatedData[udKey].Login].Name = UpdatedData[udKey].Data.Name;
            }
        }
        else {
            throw new SyntaxError("Error with function 'updateAdminData' (Login '"+ UpdatedData[adminLogin].Login +"' undefined)");
        }
    }
}


function checkAdminData(AdminData) {
    if (AdminData.ACLGroup == undefined) {
        throw new SyntaxError("ACLGroup undefined");
    }
    else if (AdminData.Issued == undefined) {
        throw new SyntaxError("Issued undefined");
    }
    else if (AdminData.DateOfIssue == undefined) {
        throw new SyntaxError("DateOfIssue undefined");
    }
    else if (AdminData.Term == undefined) {
        throw new SyntaxError("Term undefined");
    }
    else if (AdminData.BindingToSerial == undefined) {
        throw new SyntaxError("BindingToSerial undefined");
    }
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
    RowTR.append($('<td class="admin-login"></td>').html($("<b>").text(adminLogin)));

    //ACL Group
    RowTR.append($('<td class="admin-acl-group"></td>').text(AdminData.ACLGroup));

    //Issued
    RowTR.append($('<td></td>').text(AdminData.Issued));

    //Date of issue
    RowTR.append($('<td></td>').text(formatDate(AdminData.DateOfIssue * 1000)));

    //Term
    RowTR.append($('<td class="admin-term"></td>').text(AdminData.Term));

    //Date of removal
    RowTR.append($('<td class="admin-date-of-removal"></td>').text(formatDate((AdminData.DateOfIssue + (AdminData.Term * 86400)) * 1000)));

    //Binding to serial
    var bindingToSerialElement = $('<td class="admin-binding-to-serial"></td>');

    if (AdminData.BindingToSerial == true) {
        RowTR.append(bindingToSerialElement.html(getCheckElement()));
    }
    else {
        RowTR.append(bindingToSerialElement.html(getTimesElement()));
    }

    //Choose
    var chooseElement = $('<label class="form-check-label"><input name="admin-check" value="'+ adminLogin +'" type="radio" class="form-check-input"></label>');

    chooseElement.on("change",
        function(event) {
            event.preventDefault();

            $("#edit-admin-btn").prop("disabled", false);
            $("#remove-admin-btn").prop("disabled", false);
        }
    );

    RowTR.append($('<td></td>').html(chooseElement));

    return RowTR;
}


function updateAdminsDataTableRow(adminLogin, UpdateData) {
    var adminRow = $("#"+ adminLogin);

    if (UpdateData.Term != undefined) {
        adminRow.find(".admin-term").text(UpdateData.Term);

        adminRow.find(".admin-date-of-removal").text(formatDate((Admins.Data[adminLogin].DateOfIssue + (UpdateData.Term * 86400)) * 1000));
    }

    if (UpdateData.ACLGroup != undefined) {
        adminRow.find(".admin-acl-group").text(UpdateData.ACLGroup);
    }

    if (UpdateData.BindingToSerial != undefined) {
        if (UpdateData.BindingToSerial == true) {
            adminRow.find(".admin-binding-to-serial").html(getCheckElement());
        }
        else {
            adminRow.find(".admin-binding-to-serial").html(getTimesElement());
        }
    }
}


function updateShownAdminsText() {
    $("#admins-shown").text(Admins.Length);
    $("#admins-all").text(Admins.NumberOfAdmins);
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


function formatDate(timestamp) {
	var date = new Date(timestamp)

	var dd = date.getDate();
	if (dd < 10) dd = '0' + dd;

	var mm = date.getMonth() + 1;
	if (mm < 10) mm = '0' + mm;

	var yy = date.getFullYear();

	var hh = date.getHours();
	if (hh < 10) hh = '0' + hh;

	var mmin = date.getMinutes();
	if (mmin < 10) mmin = '0' + mmin;

	return dd + '/' + mm + '/' + yy + ' ' + hh + ':' + mmin;
}