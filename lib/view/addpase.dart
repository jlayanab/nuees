import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Addpase extends StatefulWidget {
  @override
  _Addpase createState() => _Addpase();
}

class _Addpase extends State<Addpase> {
  SharedPreferences sharedPreferences;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final PermissionStatus permissionStatus = await _getPermission();
        if (permissionStatus == PermissionStatus.granted) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => ContactsPage()));
        } else {
          showDialog(
              context: context,
              builder: (BuildContext context) => CupertinoAlertDialog(
                    title: Text('Error del permiso'),
                    content: Text('Habilite el acceso a los contactos '
                        'Permiso en la configuración del sistema'),
                    actions: <Widget>[
                      CupertinoDialogAction(
                        child: Text('OK'),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    ],
                  ));
        }
      },
      child: Container(child: Text('Seleccionar Contactos')),
    );
  }

  Future<PermissionStatus> _getPermission() async {
    final PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.denied) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.contacts].request();
      return permissionStatus[Permission.contacts] ?? PermissionStatus.denied;
    } else {
      return permission;
    }
  }
}

class ContactsPage extends StatefulWidget {
  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  Iterable<Contact> _contacts;

  @override
  void initState() {
    getContacts();
    super.initState();
  }

  Future<void> getContacts() async {
    final Iterable<Contact> contacts = await ContactsService.getContacts();
    setState(() {
      _contacts = contacts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: (Text('Contactos')),
      ),
      body: _contacts != null
          ? ListView.builder(
              itemCount: _contacts?.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                Contact contact = _contacts?.elementAt(index);
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 18),
                  leading: (contact.avatar != null && contact.avatar.isNotEmpty)
                      ? CircleAvatar(
                          backgroundImage: MemoryImage(contact.avatar),
                        )
                      : CircleAvatar(
                          child: Text(contact.initials()),
                          backgroundColor: Theme.of(context).accentColor,
                        ),
                  title: Text(contact.displayName ?? ''),

                  // onPressed().
                );
              },
            )
          : Center(child: const CircularProgressIndicator()),
    );
  }
}
