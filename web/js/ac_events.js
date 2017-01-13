'use strict';

$("#adminsdata-table").ready(
    function () {
        Actions.External.Execute = true;

        $.ajax({
            url: "/"+ resourceName +"/call/webGetAdminsData",
            type: "POST"
        })
        .done(
            function(data) {
                var ResponseObject = $.parseJSON(data)[0];

                try {
                    if (ResponseObject == undefined) {
                        throw new SyntaxError("Error with function 'webGetAdminsData' (Response undefined)");
                    }
                    else if (ResponseObject.ErrorCode == undefined) {
                        throw new SyntaxError("Error with function 'webGetAdminsData' ('ErrorCode' incorrect)");
                    }
                    else if (ResponseObject.ErrorCode != 0) {
                        throw new ReferenceError("Error with function 'webGetAdminsData' (Error code: "+ ResponseObject.ErrorCode +")");
                    }
                    else if ((ResponseObject.Response.Data == undefined) || (Array.isArray(ResponseObject.Response.Data) == false)) {
                        throw new SyntaxError("Error with function 'webGetAdminsData' (Response 'Data' incorrect)");
                    }
                    else if ((ResponseObject.Response.NumberOfAdmins == undefined) || (Number.isInteger(ResponseObject.Response.NumberOfAdmins) == false)) {
                        throw new SyntaxError("Error with function 'webGetAdminsData' (Response 'NumberOfAdmins' incorrect)");
                    }

                    var AdminsLoadData = ResponseObject.Response.Data;

                    loadAdminsData(AdminsLoadData);

                    Admins.NumberOfAdmins = ResponseObject.Response.NumberOfAdmins;

                    Admins.Load = true;


                    var adminRow;

                    for (var aldKey = 0; aldKey < AdminsLoadData.length; aldKey++) {
                        adminRow = getAdminsDataTableRow((aldKey + 1), AdminsLoadData[aldKey].Login, AdminsLoadData[aldKey].Data);

                        $("#adminsdata-table-rows").append(adminRow);
                    }


                    if ((Admins.Length != 0) && (Admins.Length < Admins.NumberOfAdmins)) {
                        $("#show-more-admins").removeClass("ac-hide");
                    }
                    else if (Admins.Length == 0) {
                        $("#no-admins").removeClass("ac-hide");
                    }

                    updateShownAdminsText();

                    UpdateTimers.Added = setTimeout(updateAddedAdmins, 10000);
                }
                catch (e) {
                    console.log("["+ e.name + "] "+ e.message);
                }

                Actions.External.Execute = false;
            }
        );
    }
);


$("#show-more-admins-link").click(
    function() {
        if (Actions.External.Execute == false) {
            Actions.External.Execute = true;

            var minDateOfIssue = 0;

            for (var adminLogin in Admins.Data) {
                if ((Admins.Data.hasOwnProperty(adminLogin) == true) && ((minDateOfIssue == 0) || (Admins.Data[adminLogin].DateOfIssue < minDateOfIssue))) {
                    minDateOfIssue = Admins.Data[adminLogin].DateOfIssue;
                }
            }

            $.ajax({
                url: "/"+ resourceName +"/call/webGetMoreAdminsData",
                data: JSON.stringify([minDateOfIssue]),
                type: "POST"
            })
            .done(
                function(data) {
                    var ResponseObject = $.parseJSON(data)[0];

                    try {
                        if (ResponseObject == undefined) {
                            throw new SyntaxError("Error with function 'webGetMoreAdminsData' (Response undefined)");
                        }
                        else if (ResponseObject.ErrorCode == undefined) {
                            throw new SyntaxError("Error with function 'webGetMoreAdminsData' ('ErrorCode' incorrect)");
                        }
                        else if (ResponseObject.ErrorCode != 0) {
                            throw new ReferenceError("Error with function 'webGetMoreAdminsData' (Error code: "+ ResponseObject.ErrorCode +")");
                        }
                        else if ((ResponseObject.Response.Data == undefined) || (Array.isArray(ResponseObject.Response.Data) == false)) {
                            throw new SyntaxError("Error with function 'webGetMoreAdminsData' (Response 'Data' incorrect)");
                        }
                        else if ((ResponseObject.Response.NumberOfAdmins == undefined) || (Number.isInteger(ResponseObject.Response.NumberOfAdmins) == false)) {
                            throw new SyntaxError("Error with function 'webGetMoreAdminsData' (Response 'NumberOfAdmins' incorrect)");
                        }

                        var lastAdminsDataLength = Admins.Length;

                        var AdminsLoadData = ResponseObject.Response.Data;

                        loadAdminsData(AdminsLoadData);

                        Admins.NumberOfAdmins = ResponseObject.Response.NumberOfAdmins;


                        var adminRow;

                        for (var aldKey = 0; aldKey < AdminsLoadData.length; aldKey++) {
                            adminRow = getAdminsDataTableRow((lastAdminsDataLength + aldKey + 1), AdminsLoadData[aldKey].Login, AdminsLoadData[aldKey].Data);

                            $("#adminsdata-table-rows").append(adminRow.hide());
                            adminRow.fadeIn("slow");
                        }


                        if (Admins.Length < Admins.NumberOfAdmins) {
                            $("#show-more-admins").removeClass("ac-hide");
                        }
                        else {
                            $("#show-more-admins").addClass("ac-hide");
                        }

                        updateShownAdminsText();
                    }
                    catch (e) {
                        console.log("["+ e.name + "] "+ e.message);
                    }

                    Actions.External.Execute = false;
                }
            );
        }
    }
);


$("#add-new-admin-link").click(
    function() {
        selectPage("AddNewAdmin");

        $("#index-page").addClass("ac-hide");

        $("#add-new-admin-page").removeClass("ac-hide");


        removeInputDanger("add-new-admin-login");

        removeInputDanger("add-new-admin-term");
    }
);


$("#add-new-admin-back-link, #edit-admin-back-link").click(backToIndexPage);


$("#add-new-admin-login, #add-new-admin-term, #add-new-admin-aclgroup, #add-new-admin-binding-to-serial").focus(
	function() {
		if (Admins.Load == true) {
			$('#add-new-admin-btn').prop("disabled", false);

            var selectorID = $(this).attr('id');

            if (selectorID != ("add-new-admin-aclgroup" || "add-new-admin-binding-to-serial")) {
			    removeInputDanger(selectorID);
			}
		}
	}
);


$("#add-new-admin-btn").click(
    function() {
        if ((Admins.Load == true) && (Pages.AddNewAdmin.Selected == true) && (Actions.External.Execute == false)) {
            var adminLogin = $('#add-new-admin-login').val();

            var adminTerm = Number.parseInt($('#add-new-admin-term').val());

            var adminACLGroup = $('#add-new-admin-aclgroup').val();

            var adminBindingToSerial = $('#add-new-admin-binding-to-serial').is(":checked");

            if(adminLogin == "") {
                setInputDanger("add-new-admin-login");

                alert("Admin login empty!");
            }
            else if ((Number.isInteger(adminTerm) == false) || (adminTerm <= 0)) {
                setInputDanger("add-new-admin-term");

                alert("Admin term empty!");
            }
            else {
                Actions.External.Execute = true;

                $.ajax({
                    url: "/"+ resourceName +"/call/webAddNewAdmin",
                    data: JSON.stringify([adminLogin, adminACLGroup, adminTerm, adminBindingToSerial]),
                    type: "POST"
                })
                .done(
                    function(data) {
                        var ResponseObject = $.parseJSON(data)[0];

                        try {
                            if (ResponseObject == undefined) {
                                throw new SyntaxError("Error with function 'webAddNewAdmin' (Response undefined)");
                            }
                            else if (ResponseObject.ErrorCode == undefined) {
                                throw new SyntaxError("Error with function 'webAddNewAdmin' ('ErrorCode' incorrect)");
                            }
                            else if (ResponseObject.ErrorCode != 0) {
                                if (ResponseObject.ErrorCode == (-8)) {
                                    setInputDanger("add-new-admin-login");

                                    alert("Admin login incorrect (or already exist)!");
                                }
                                else if (ResponseObject.ErrorCode == (-12)) {
                                    setInputDanger("add-new-admin-term");

                                    alert("Admin term incorrect!");
                                }
                                else {
                                    alert("Failed to add admin! Error code: " + ResponseObject.ErrorCode);
                                }

                                throw new ReferenceError("Error with function 'webAddNewAdmin' (Error code: "+ ResponseObject.ErrorCode +")");
                            }
                            else if ((ResponseObject.Response == undefined) || (typeof ResponseObject.Response != "object")) {
                                throw new SyntaxError("Error with function 'webAddNewAdmin' ('Response' incorrect)");
                            }

                            var NewAdminLoadData = ResponseObject.Response;

                            loadAdminsData(new Array(NewAdminLoadData));

                            Admins.NumberOfAdmins++;


                            alert("Admin '"+ NewAdminLoadData.Login +"' has been successfully added!")

                            var adminRow = getAdminsDataTableRow(1, NewAdminLoadData.Login, NewAdminLoadData.Data);

                            $("#adminsdata-table-rows").prepend(adminRow.hide());
                            adminRow.fadeIn("slow");

                            adminRow.nextAll().each(
                                function(i) {
                                    $(this).find(".row-number").text(i + 2);
                                }
                            );


                            if ($("#no-admins").css("display") == "table-row") {
                                $("#no-admins").addClass("ac-hide");
                            }

                            updateShownAdminsText();

                            $("#add-new-admin-login, #add-new-admin-term").val("");
                            $("#add-new-admin-binding-to-serial").prop("checked", false);
                            $("#add-new-admin-btn").prop("disabled", true);

                            backToIndexPage();
                        }
                        catch (e) {
                            console.log("["+ e.name + "] "+ e.message);
                        }

                        Actions.External.Execute = false;
                    }
                );
            }
        }
    }
);


$("#remove-admin-btn, #edit-remove-admin-btn").click(
    function() {
        if ((Admins.Load == true) && (Actions.External.Execute == false)) {
            var adminLogin = $('input[name="admin-check"]:checked').val();

            if (confirm("Are you sure you want to remove admin: " + adminLogin + " ? This cannot be undone.")) {
                Actions.External.Execute = true;

                $.ajax({
                    url: "/"+ resourceName +"/call/webRemoveAdmin",
                    data: JSON.stringify([adminLogin]),
                    type: "POST"
                })
                .done(
                    function(data) {
                        var ResponseObject = $.parseJSON(data)[0];

                        try {
                            if (ResponseObject == undefined) {
                                throw new SyntaxError("Error with function 'webRemoveAdmin' (Response undefined)");
                            }
                            if (ResponseObject.ErrorCode == undefined) {
                                throw new SyntaxError("Error with function 'webRemoveAdmin' ('ErrorCode' incorrect)");
                            }
                            else if (ResponseObject.ErrorCode != 0) {
                                throw new ReferenceError("Error with function 'webRemoveAdmin' (Error code: " + ResponseObject.ErrorCode + ")");
                            }

                            removeAdminData(new Array(adminLogin));

                            Admins.NumberOfAdmins--;


                            alert("Admin '" + adminLogin + "' has been successfully removed!");

                            var adminRow = $("#"+ adminLogin);

                            adminRow.find('.form-check-label').off("change");

                            adminRow.fadeOut("slow",
                                function() {
                                    var adminRowNumber = parseInt($(this).find(".row-number").text());

                                    $(this).nextAll().each(
                                        function(i) {
                                            $(this).find(".row-number").text(adminRowNumber + i);
                                        }
                                    );

                                    $(this).remove();
                                }
                            );


                            if (Admins.Length == 0) {
                                $("#no-admins").removeClass("ac-hide");
                            }

                            updateShownAdminsText();

                            $("#edit-admin-btn").prop("disabled", true);
                            $("#remove-admin-btn").prop("disabled", true);

                            backToIndexPage();
                        }
                        catch (e) {
                            console.log("["+ e.name + "] "+ e.message);
                        }

                        Actions.External.Execute = false;
                    }
                );
            }
        }
    }
);


$("#edit-admin-term, #edit-admin-aclgroup, #edit-admin-binding-to-serial").focus(
	function() {
		$('#edit-edit-admin-btn').prop("disabled", false);

        var selectorID = $(this).attr('id');

		if (selectorID == "edit-admin-term") {
            removeInputDanger(selectorID);
        }
	}
);


$("#edit-admin-btn").click(
    function() {
        if (Admins.Load == true) {
            var adminLogin = $('input[name="admin-check"]:checked').val();

            if(Admins.Data[adminLogin] != undefined) {
                selectPage("EditAdmin");

                Pages.EditAdmin.Login = adminLogin;


                $("#index-page").addClass("ac-hide");

                $("#edit-admin-page").removeClass("ac-hide");


                $("#edit-admin-login").text(adminLogin);

                $("#edit-admin-issued").text(Admins.Data[adminLogin].Issued);

                $("#edit-admin-date-of-issue").text(formatDate(Admins.Data[adminLogin].DateOfIssue * 1000));

                if (Admins.Data[adminLogin].Name != undefined) {
                    $("#edit-admin-name").parent().removeClass("ac-hide");
                    $("#edit-admin-name").html(hexToHtml(Admins.Data[adminLogin].Name));
                }
                else {
                    $("#edit-admin-name").parent().addClass("ac-hide");
                }


                $("#edit-admin-term").val(Admins.Data[adminLogin].Term);

                removeInputDanger("edit-admin-term");

                $("#edit-admin-aclgroup").val(Admins.Data[adminLogin].ACLGroup);

                $("#edit-admin-binding-to-serial").prop("checked", Admins.Data[adminLogin].BindingToSerial);


                $('#edit-edit-admin-btn').prop("disabled", true);
            }
        }
    }
);


$("#edit-edit-admin-btn").click(
    function() {
        if ((Pages.EditAdmin.Selected == true) && (Actions.External.Execute == false)) {
            var adminTerm = Number.parseInt($('#edit-admin-term').val());

            var adminACLGroup = $('#edit-admin-aclgroup').val();

            var adminBindingToSerial = $('#edit-admin-binding-to-serial').is(":checked");

            if ((Number.isInteger(adminTerm) == false) || (adminTerm <= 0)) {
                setInputDanger("edit-admin-term");

                alert("Admin term incorrect!");
            }
            else {
                Actions.External.Execute = true;

                $.ajax({
                    url: "/"+ resourceName +"/call/webEditAdmin",
                    data: JSON.stringify([Pages.EditAdmin.Login, adminTerm, adminACLGroup, adminBindingToSerial]),
                    type: "POST"
                })
                .done(
                    function(data) {
                        var ResponseObject = $.parseJSON(data)[0];

                        try {
                            if (ResponseObject == undefined) {
                                throw new SyntaxError("Error with function 'webEditAdmin' (Response undefined)");
                            }
                            else if (ResponseObject.ErrorCode == undefined) {
                                throw new SyntaxError("Error with function 'webEditAdmin' ('ErrorCode' incorrect)");
                            }
                            else if (ResponseObject.ErrorCode != 0) {
                                if (ResponseObject.ErrorCode == (-5)) {
                                    setInputDanger("edit-admin-term");

                                    alert("Admin term incorrect!");
                                }

                                throw new ReferenceError("Error with function 'webEditAdmin' (Error code: "+ ResponseObject.ErrorCode +")");
                            }
                            else if ((ResponseObject.Response == undefined) || (typeof ResponseObject.Response != "object")) {
                                throw new SyntaxError("Error with function 'webEditAdmin' ('Response' incorrect)");
                            }

                            var EditAdmin = ResponseObject.Response;

                            if (EditAdmin.Modified == true) {
                                updateAdminData(new Array({Login: Pages.EditAdmin.Login, Data: EditAdmin.Data}));


                                alert("Admin '" + Pages.EditAdmin.Login + "' has been successfully edited!");

                                updateAdminsDataTableRow(Pages.EditAdmin.Login, EditAdmin.Data);


                                $('#edit-edit-admin-btn').prop("disabled", true);

                                backToIndexPage();
                            }
                        }
                        catch (e) {
                            console.log("["+ e.name + "] "+ e.message);
                        }

                        Actions.External.Execute = false;
                    }
                );
            }
        }
    }
);