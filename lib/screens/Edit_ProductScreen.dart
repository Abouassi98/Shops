import 'package:flutter/material.dart';
import '../providers/product.dart';
import '../providers/products.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspath;
import '../screens/image_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Edit_ProductScreen extends StatefulWidget {
  static const routedname = '/Edit_ProductScreen';

  @override
  _Edit_ProductScreenState createState() => _Edit_ProductScreenState();
}

class _Edit_ProductScreenState extends State<Edit_ProductScreen> {
  final _priceFoucsNode = FocusNode();
  final _descriptionFoucsNode = FocusNode();
  // final _imageUrl = TextEditingController();
  // final _imageUrlFoucsNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var camera = ImageSource.camera;
  var gallery = ImageSource.gallery;
  String _imageUrl;
  File _imagefile;
  //File _pickedImage;
  // void _selectedImage(File pickedImage) {
  // setState(() {
  //     _pickedImage = pickedImage;
  // });
  // }
  // Future _dowloadedPicture() async {
  //   final _storageReference = _storge.ref().child('images/${DateTime.now()}');
  //   String _downloadedAddress = await _storageReference.getDownloadURL();
  //   setState(() {
  //     _downloadUrl = _downloadedAddress;
  //   });
  // }
  final FirebaseStorage _storge =
      FirebaseStorage(storageBucket: 'gs://shops-fb193.appspot.com');
  Future<String> _uplodedPicture() async {
    String fileName = _imageUrl;
    var _storageReference =
        _storge.ref().child('$fileName at ${DateTime.now()}');
    var _uploadedPhoto = _storageReference.putFile(_imagefile);
    var completedTask = await _uploadedPhoto.onComplete;
    dynamic _downlaodUrl = await completedTask.ref.getDownloadURL();
    if (_downlaodUrl != null) {
      setState(() {
        _imageUrl = _downlaodUrl;
        print('Value : $_imageUrl');
      });
      Fluttertoast.showToast(msg: 'Upload image Complete');
    } else {
      Fluttertoast.showToast(msg: 'Upload image faild');
    }
  }
  Future _stateofpicture(ImageSource chooseSource) async {
    final _uploadedphoto =
        await ImagePicker().getImage(source: chooseSource, maxWidth: 600);
    if (_uploadedphoto == null) {
      return;
    }
    setState(() {
      _imagefile = File(_uploadedphoto.path);
      _imageUrl = _imagefile.hashCode.toString();
    });
    await _uplodedPicture();
    setState(() {
      _editedProduct.image = _imageUrl;
    });
    // final appDir = await syspath.getApplicationDocumentsDirectory();
    // final imagename = path.basename(_imagefile.path);
    // await _imagefile.copy('${appDir.path}/$imagename');
  }
  // await _dowloadedPicture();
  // setState(() {
  //    _pickedImage=savedImage;
  // });

  Future<void> _uploadphoto() async {
    await _stateofpicture(gallery);
  }

  Future<void> _takeaPicture() async {
    await _stateofpicture(camera);
  }

  var _editedProduct = Product(
    id: null,
    image: null,
    title: '',
    description: '',
    price: 0,
  );
  var _intitValues = {
    'title': '',
    'descriptions': '',
    'price': '',
    'image': '',
  };
  @override
  void initState() {
    // _imageUrlFoucsNode.addListener(_updateImageUr);
    super.initState();
  }

  var _isInit = true;
  var _loadedSpinner = false;
  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _intitValues = {
          'title': _editedProduct.title,
          'descriptions': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'image': _editedProduct.image,
        };
        //_imageUrl.text = _editedProduct.imageUrl;

      }
    }
    _isInit = false;

    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  void dispose() {
    //   _imageUrlFoucsNode.removeListener(_updateImageUr);
    // _imageUrlFoucsNode.dispose();
    _priceFoucsNode.dispose();
    _descriptionFoucsNode.dispose();
    // _imageUrl.dispose();
    super.dispose();
  }

  // void _updateImageUr() {
  //   if (!_imageUrlFoucsNode.hasFocus) {
  //     if (!_imageUrl.text.startsWith('http') &&
  //             !_imageUrl.text.startsWith('https') ||
  //         !_imageUrl.text.endsWith('.jpg') &&
  //             !_imageUrl.text.endsWith('.png') &&
  //             !_imageUrl.text.endsWith('.jpeg')) {
  //       return;
  //     }
  //     setState(() {});
  //   }
  // }

  Future<void> _saveForm() async {
    final _isValid = _form.currentState.validate();
    if (!_isValid || _imagefile == null) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _loadedSpinner = true;
    });
    if (_editedProduct.id != null) {
      setState(() {
        _loadedSpinner = false;
      });
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addproduct(_editedProduct);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error ocurred'),
            content: Text('Something went wrong'),
            actions: <Widget>[
              FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          ),
        );
      }
    }
    setState(() {
      _loadedSpinner = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    Widget button(String text, Function func) {
      FlatButton.icon(
        textColor: Theme.of(context).primaryColor,
        onPressed: func,
        icon: Icon(
          Icons.photo,
        ),
        label: Text(
          text,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _loadedSpinner
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: _intitValues['title'],
                      decoration: InputDecoration(labelText: 'Ttile'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFoucsNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide a value';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          title: value,
                          price: _editedProduct.price,
                          id: _editedProduct.id,
                          isFavourite: _editedProduct.isFavourite,
                          description: _editedProduct.description,
                          image: _imageUrl,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _intitValues['price'],
                      decoration: InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      focusNode: _priceFoucsNode,
                      keyboardType: TextInputType.number,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFoucsNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a vaild number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'please enter a number greater than zero.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          title: _editedProduct.title,
                          price: double.parse(value),
                          id: _editedProduct.id,
                          isFavourite: _editedProduct.isFavourite,
                          description: _editedProduct.description,
                          image: _imageUrl,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _intitValues['descriptions'],
                      decoration: InputDecoration(labelText: 'Description'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter a description ';
                        }
                        if (value.length < 10) {
                          return 'Please should be at least 10 characters long.';
                        }
                        return null;
                      },
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFoucsNode,
                      onSaved: (value) {
                        _editedProduct = Product(
                          title: _editedProduct.title,
                          price: _editedProduct.price,
                          id: _editedProduct.id,
                          isFavourite: _editedProduct.isFavourite,
                          description: value,
                          image: _imageUrl,
                        );
                      },
                    ),
                    // Row(
                    //   crossAxisAlignment: CrossAxisAlignment.end,
                    //   children: <Widget>[
                    //     Container(
                    //       height: 100,
                    //       width: 100,
                    //       margin: EdgeInsets.only(top: 18, right: 10),
                    //       decoration: BoxDecoration(
                    //         border: Border.all(color: Colors.grey, width: 1),
                    //       ),
                    //       child: _imageUrl.text.isEmpty
                    //           ? Text('Enter a URL')
                    //           : FittedBox(
                    //               child: Image.network(_imageUrl.text),
                    //               fit: BoxFit.cover,
                    //             ),
                    //     ),
                    //     Expanded(
                    //       child: TextFormField(
                    //         decoration: InputDecoration(labelText: 'Image'),
                    //         textInputAction: TextInputAction.done,
                    //         keyboardType: TextInputType.url,
                    //         controller: _imageUrl,
                    //         focusNode: _imageUrlFoucsNode,
                    //         onFieldSubmitted: (_) {
                    //           setState(() {});
                    //           _saveForm();
                    //         },
                    //         validator: (value) {
                    //           if (value.isEmpty) {
                    //             return 'Please enter an image URL';
                    //           }
                    //           if (!value.startsWith('http') &&
                    //               !value.startsWith('https')) {
                    //             return 'Please enter an valid URL';
                    //           }
                    //           if (!value.endsWith('.png') &&
                    //               !value.endsWith('.jpg') &&
                    //               !value.endsWith('.jpeg')) {
                    //             return 'Please enter an valid URL';
                    //           }
                    //           return null;
                    //         },
                    //         onSaved: (value) {
                    //           _editedProduct = Product(
                    //               title: _editedProduct.title,
                    //               price: _editedProduct.price,
                    //               id: _editedProduct.id,
                    //               isFavourite: _editedProduct.isFavourite,
                    //               description: _editedProduct.description,
                    //               imageUrl: value);
                    //         },
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            _imageUrl == null
                                ? () {}
                                : Navigator.of(context).pushNamed(
                                    image_screen.routedname,
                                    arguments: _imageUrl);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: MediaQuery.of(context).size.height * 0.25,
                            width: MediaQuery.of(context).size.width * 0.5,
                            margin: EdgeInsets.only(top: 18, right: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 2),
                            ),
                            child: _editedProduct.image != null
                                ? Image.network(_imageUrl,
                                    width: double.infinity, fit: BoxFit.cover)
                                : _imageUrl == null
                                    ? Text('Enter a photo')
                                    : Image.network(_imageUrl,
                                        width: double.infinity,
                                        fit: BoxFit.cover),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.25,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                FlatButton.icon(
                                  textColor: Theme.of(context).primaryColor,
                                  onPressed: _takeaPicture,
                                  icon: Icon(
                                    Icons.camera_alt,
                                  ),
                                  label: Text(
                                    'Take a photo',
                                  ),
                                ),
                                FlatButton.icon(
                                  textColor: Theme.of(context).primaryColor,
                                  onPressed: _uploadphoto,
                                  icon: Icon(
                                    Icons.photo,
                                  ),
                                  label: Text(
                                    'Upload a photo',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
