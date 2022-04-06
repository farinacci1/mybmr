

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_crop/image_crop.dart';

class ImageCropper extends StatefulWidget{
  @required final File imageFile;
  final double aspectRatio;
  const ImageCropper({Key key, this.imageFile, this.aspectRatio =  9 /19}) : super(key: key);
  @override
  _ImageCropperState createState() => _ImageCropperState();
}

class _ImageCropperState extends State<ImageCropper>{
  final cropKey = GlobalKey<CropState>();
  bool isFetching =false;
  File _file;
  File _sample;
  File _lastCropped;



  Widget _buildCroppingImage() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Crop.file(
              _sample,
              key: cropKey,
            aspectRatio: widget.aspectRatio,
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 20.0),
          alignment: AlignmentDirectional.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              TextButton(
                child: Text(
                  'Crop',
                  style: Theme.of(context)
                      .textTheme
                      .button
                      .copyWith(color: Colors.white),
                ),
                onPressed: () => _cropImage(),
              ),
            ],
          ),
        )
      ],
    );
  }



  Future<bool> _openImage() async {
    final sample = await ImageCrop.sampleImage(
      file: widget.imageFile,
      preferredSize: MediaQuery.of(context).size.height.toInt()
    );
    if(_sample != null) _sample.delete();
    if(_file != null) _file.delete();

    _sample = sample;
    _file = widget.imageFile;
   return true;

  }

  Future<void> _cropImage() async {
    final scale = cropKey.currentState.scale;
    final area = cropKey.currentState.area;
    if (area == null) {
      // cannot crop, widget is not setup
      return;
    }

    // scale up to use maximum possible number of pixels
    // this will sample image in higher resolution to make cropped image larger
    final sample = await ImageCrop.sampleImage(
      file: _file,
      preferredSize: (2000 / scale).round(),
    );

    final file = await ImageCrop.cropImage(
      file: sample,
      area: area,
    );

    sample.delete();

    if(_lastCropped!= null)_lastCropped.delete();
    _lastCropped = file;
    Navigator.pop(context,{"imageFile" : _lastCropped});

  }

  @override
  Widget build(BuildContext context) {
    if(_sample == null && !isFetching) {
      isFetching =true;
      _openImage().whenComplete(() => setState((){})).catchError((err){

      });
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
        color: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
        child: _sample != null ? _buildCroppingImage() : Container()

        ))
    );
  }

}