import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});
  TextEditingController controller = TextEditingController();
  TextEditingController editController = TextEditingController();
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> addUser(String _completed, String _note) {
    // Call the user's CollectionReference to add a new user
    return users
        .doc(DateTime.now().toString())
        .set({
          'Text': _note,
          'Completed': _completed,
        })
        .then((value) => print("Text Added"))
        .catchError((error) => print("Failed to add Text: $error"));
  }

  Future<void> deleteUser(String docId) {
    return users
        .doc(docId)
        .delete()
        .then((value) => print("User Deleted"))
        .catchError((error) => print("Failed to delete user: $error"));
  }

  Future<void> editUser(String docId, String value) {
    return users
        .doc(docId)
        .update({'Completed': value})
        .then((value) => print("User Deleted"))
        .catchError((error) => print("Failed to delete user: $error"));
  }

  Future<void> updateUser(String docId, String note, String value) {
    return users
        .doc(docId)
        .update({
          'Completed': value,
          'Text': note,
        })
        .then((value) => print("User Deleted"))
        .catchError((error) => print("Failed to delete user: $error"));
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(
              margin: const EdgeInsets.only(left: 7),
              child: const Text("Loading...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('users').snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemGrey5,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: CupertinoColors.systemGrey5,
        centerTitle: true,
        title: const Text(
          "TO DO App",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 1.5,
                  child: Card(
                    elevation: 3,
                    color: CupertinoColors.systemGrey6,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: "Type Something here...",
                          fillColor: Colors.white,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide:
                                  const BorderSide(style: BorderStyle.none)),
                        )),
                  ),
                ),
              ),
              FloatingActionButton(
                backgroundColor: Colors.black,
                onPressed: () async {
                  showLoaderDialog(context);
                  await addUser("0", controller.text);
                  Navigator.pop(context);
                },
                child: const Icon(Icons.add),
              )
            ],
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _usersStream,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              return ListView(
                shrinkWrap: true,
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 5),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 3,
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        tileColor: CupertinoColors.systemGrey6,
                        leading: (data['Completed'] == "1")
                            ? IconButton(
                                icon: const Icon(
                                  Icons.done,
                                  color: Colors.green,
                                ),
                                onPressed: () async {
                                  showLoaderDialog(context);
                                  await editUser(document.id.toString(), "0");
                                  Navigator.pop(context);
                                },
                              )
                            : IconButton(
                                icon: const Icon(
                                  Icons.circle_outlined,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  showLoaderDialog(context);
                                  await editUser(document.id.toString(), "1");
                                  Navigator.pop(context);
                                },
                              ),
                        title: Text(
                          data['Text'],
                          maxLines: 3,
                        ),
                        trailing: Wrap(
                          children: [
                            IconButton(
                                onPressed: () {
                                  showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                      title: const Text('Edit'),
                                      content: TextFormField(
                                          controller: editController,
                                          decoration: InputDecoration(
                                            hintText: "Type Something here...",
                                            fillColor: Colors.white,
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              borderSide: const BorderSide(
                                                color: Colors.black,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                borderSide: const BorderSide(
                                                    style: BorderStyle.none)),
                                          )),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, 'Cancel'),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            showLoaderDialog(context);
                                            await updateUser(
                                                    document.id.toString(),
                                                    editController.text,
                                                    "0")
                                                .then((value) =>
                                                    Navigator.pop(context));
                                            Navigator.pop(context);
                                          },
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.edit)),
                            IconButton(
                                onPressed: () async {
                                  showLoaderDialog(context);
                                  await deleteUser(document.id.toString());
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.delete)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          )
        ],
      ),
    );
  }
}
