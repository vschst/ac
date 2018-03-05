# ac
Admins Control

# Description
The resource is developed to control for server administrators.
Available functions: issuing admin office powers for a specified term, removing and editing data (term, ACL group binding to Serial). Expired admin powers automatically removed from the list automatically, together with removal of the relevant account from ACL group.
The administrator can be notified of the end of his admin term.
Client part of resource consists of two parts - public and private.

## Public part
This part is available to all players and is a GUI panel.
This pane displays the list of server administrators and the details of their admin powers.

## Private part
This part is available only to accounts from the Admin ACL group and is a web based interface.
This interface provides the ability to add, delete and edit admin powers in asynchronous mode.
The design of the web interface is based on the use of stylistic packages, Bootstrap and Font Awesome.
In the logical part of the interface uses the JavaScript library jQuery and Moment.js.

# Installation
Create a new directory with name **ac** in resource directory of your MTA server.
Open created directory and upload the resource files from archive.
To start resource, enter the following command in the server console
```
start ac
```
In case of successful start you will see the message
```
[AC] Resource was successfully loaded!
```
therwise, you will see a message with the place and the error code.
If you want to run a resource with the server running, then edit the configuration file *mtaserver.conf*, adding following string
```
<resource src="ac" startup="1" protected="0"/>
```
# ACL access and language
## ACL access
The resource requires ACL access to the function **kickPlayer** (To use binding to Serial), as well as functions of **aclGroupAddObject** and **aclGroupRemoveObject** (For adding administrator accounts to the appropriate ACL group, and delete).
To open access, enter in the server console the command
```
aclrequest allow ac all
```
## Language
To install English language, open a resource directory, and go to the `texts/data` directory.
Replace all xml files on the files from **en** folder and restart resource.

# Access to web interface
To access for web interface, open a browser and visit `http://address:port/resource/web/index.html`, where **address** - the IP address of your MTA server, **port** - the HTTP port of your MTA server, **resource** - name of resource Admins Control in your resource directory (default: ac).
For example, on a locally hosted server using default http port:
```
http://127.0.0.1:22005/ac/web/index.html
```
Next you need to enter the username and password of your account from Admin ACL group.
In case of successful authorization you will be redirected to the index page of the administrators web management interface.

## Access through resources browser
If your MTA server is running the default resource **resourcebrowser**, you can access the web interface directly.
To do this, open a browser and visit `http://address:port/` and login.
In case of successful authorization you will be redirected to the index page of the resources browser.
To access the administrators web management interface, click on the left side of the page the link Admins Control.

# Settings
Resource settings are available in the `meta.xml` file.
* **AdminsDataCleanPeriod**
  
  The period of data cleaning expired admin powers.
  The value isspecified in minutes and must be an integer greater than zero.
  
* **AllowedAdminsACLGroups**
  
  List of available ACL groups for issuing admin powers.
  Syntax: `[[’aclGroupName’, ...]]` , where `aclGroupName` - name of the ACL group.
  You can specify an existing ACL group.
  
* **WebMaxNumberOfRowsToShow**
  
  The maximum number of data columns admin powers to display on the index page of the web interface.
  The value must be an integer greater than zero.
  
* **ClientOpenAdminsListButton**
  
  The button to open the GUI-panel of the list of server administrators and data their admin powers.
  
* **ClientGUIScale**
  
  The parameter responsible for the increase in the size of GUI elements depending on the screen resolution.
  The value must be a valid integer greater than zero.

# Exported functions
* **addNewAdmin**
  
  Adds new admin data.

  * **Type**:
    Server-only function

  * **Syntax**:
    >int **addNewAdmin**(string **adminLogin**, table **NewAdminData**)

  * **Required Arguments**:
    * **adminLogin**: Login of new administrator.
      
    * **NewAdminData**:
    Table of admin powers data. Must have the following keys: `ACLGroup` - ACL Group, `Issued` - login of admin, issuing admin powers, `DateOfIssue` - date of issue of admin powers in the timestamp format, `Term` - the term of admin powers (in days), `BindingToSerial` - binding admin account to serial (The value of *true* - is binding *false* - no binding).

  * **Returns**:
    In case of successful completion, the function returns *0*, otherwise nonzero (error code).
    
* **removeAdmin**
  
  Removes admin data.

  * **Type**:
    Server-only function

  * **Syntax**:
    >int **removeAdmin**(string **adminLogin**)

  * **Required Arguments**:
    * **adminLogin**: Login on administrator is admin powers which you want to delete.

  * **Returns**:
    In case of successful completion, the function returns *0*, otherwise nonzero (error code).
    
* **editAdmin**
  
  Edit admin data.

  * **Type**:
    Server-only function

  * **Syntax**:
    >int **editAdmin**(string **adminLogin**, table **EditedAdminData**)

  * **Required Arguments**:
    * **adminLogin**: Login of administrator is admin powers which you want to edit.
    
    * **EditedAdminData**:
    The table containing changes in admin powers data.
    Allowed the following keys: `ACLGroup` - ACL group, `Term` - the term of admin powers (in days), `IP` - Administrator IP address, `Serial` - Administrator Serial, `Name` - Administrator nickname, `BindingToSerial` - binding admin account to serial (The value of *true* - is binding, *false* - no binding).

  * **Returns**:
    In case of successful completion, the function returns *0*, otherwise nonzero (error code).
