# ac
[MTA] AC - Admins Control

#Описание
Ресурс предназначен для управления администраторами сервера. Доступные функции: выдача админ-полномочий на определенный срок,
удаление и редактирование данных (Срок действия полномочий, ACL-группа, привязка к Serial). Истекшие полномочия удаляются из списка
автоматически, вместе с удалением соответствующего аккаунта из ACL-группы. Администратор получает уведомление о конце срока его
полномочий. Клиентская часть ресурса состоит из двух частей - публичной и приватной. Публичная часть доступна всем игрокам сервера и
представляет собой GUI панель. В этой панели отображается список администраторов сервера и данные их админ-полномочий. Приватная часть
доступна только аккаунтам из ACL-группы Admin и представляет собой веб-интерфейс. В данном интерфейсе предусмотрена возможность для
добавления, удаления и редактирования админ-полномочий в асинхронном режиме. Дизайн веб-интерфейса основан на использовании стилевых
пакетов Bootstrap и Font Awesome. В логической части интерфейса используется JavaScript библиотека jQuery.

#Доступ к веб-интерфейсу
Для доступа к веб-интерфейсу, откройте в браузере URL-адрес `http://адрес:порт/имяресурса/web/index.html`, где `адрес` - IP-адрес вашего
MTA сервера, `порт` - HTTP-порт вашего MTA сервера, `имяресурса` - название ресурса Admins Control в вашей директории ресурсов (По
умолчанию: *ac*). Например, на локальном сервере, использующем HTTP-порт по умолчанию: ` http://127.0.0.1:22005/ac/web/index.html`.
Далее вам необходимо ввести логин и пароль вашего аккаунта из ACL-группы Admin. В случае успешной авторизации вы попадете на главную
страницу веб-интерфейса управления администраторами.

##Доступ через браузер ресурсов
Если на вашем MTA сервере запущен стандартный ресурс **resourcebrowser**, то вы можете получить доступ к веб-интерфейсу напрямую.
Для этого, откройте в браузере URL-адрес `http://адрес:порт/` и авторизируйтесь. В случае успешной авторизации вы попадете на главную
страницу браузера ресурсов. Для доступа к веб-интерфейсу управления администраторами, нажмите в левой части страницы на ссылку
Admins Control.

#Настройки (файл meta.xml)

* ##AdminsDataCleanPeriod
  Период очистки данных истекших админ-полномочий. Значение указывается в минутах и должно быть целым числом, большим нуля.
  
* ##AllowedAdminsACLGroups
  Список доступных ACL-групп для выдачи админ-полномочий. Синтаксис: `[['aclGroupName', ..]]`, где `aclGroupName` - название ACL-группы.
  Допускается указывать существующие ACL-группы.
  
* ##WebMaxNumberOfRowsToShow
  Максимальное количество столбцов данных админ-полномочий, отображаемых для показа на главной странице веб-интерфейса. Значение
  должно быть целым числом, большим нуля.
  
* ##ClientOpenAdminsListButton
  Кнопка для открытия GUI-панели списка администраторов сервера и данных их админ-полномочий.
  
* ##ClientGUIScale
  Параметр, отвечающий за увеличение размера GUI элементов, в зависимости от разрешения экрана. Значение должно быть действительным
  числом, большим нуля.

#Экспортируемые функции
* ##addNewAdmin
  Добавляет данные админ-полномочий.

  * ###Тип
    Серверная функция

  * ###Синтаксис:
    >int **addNewAdmin**(string **adminLogin**, table **NewAdminData**)

  * ###Аргументы:
    * **adminLogin**:
    Логин нового администратора.
      
    * **NewAdminData**:
    Таблица данных админ-полномочий. Должна иметь следующие ключи: `ACLGroup` - ACL-группа, `Issued` - логин
    администратора, выдающего админ-полномочия, `DateOfIssue` - дата выдачи админ-полномочий в формате timestamp, `Term` - срок
    действия полномочий (в днях), `BindingToSerial` - привязка аккаунта к Serial (Значение *true* - есть привязка, *false* - нет
    привязки).

  * ###Возвращаемое значение:
    В случае успешного завершения функция возвращает *0*, в противном случае — ненулевое значение (код ошибки).
    
* ##removeAdmin
  Удаляет данные админ-полномочий.

  * ###Тип
    Серверная функция

  * ###Синтаксис:
    >int **removeAdmin**(string **adminLogin**)

  * ###Аргументы:
    * **adminLogin**:
    Логин администратора, данные админ-полномочий которого требуется удалить.

  * ###Возвращаемое значение:
    В случае успешного завершения функция возвращает *0*, в противном случае — ненулевое значение (код ошибки).
    
* ##updateAdmin
  Редактирует данные админ-полномочий.

  * ###Тип
    Серверная функция

  * ###Синтаксис:
    >int **updateAdmin**(string **adminLogin**, table **UpdatedData**)

  * ###Аргументы:
    * **adminLogin**:
    Логин администратора, данные админ-полномочий которого требуется отредактировать.
    
    * **UpdatedData**:
    Таблица, содержащяя изменения в данных админ-полномочий. Допускаются следующие ключи: `ACLGroup` - ACL-группа, `Term` - срок
    действия полномочий (в днях), `IP` - IP-адрес администратора, `Serial` - Serial администратора, `Name` - никнейм администратора,
    `BindingToSerial` - привязка аккаунта к Serial (Значение *true* - есть привязка, *false* - нет привязки).

  * ###Возвращаемое значение:
    В случае успешного завершения функция возвращает *0*, в противном случае — ненулевое значение (код ошибки).
