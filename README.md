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

#Настройки (файл meta.xml)

#Экспортируемые функции
