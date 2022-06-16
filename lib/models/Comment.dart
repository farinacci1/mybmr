import 'dart:io';

enum COMMENT_TYPE{
  RECIPE,
  POST,
  VIDEO
}

class Comment{
  String _commendId;
  String _commenterId;
  String _parentId;
  COMMENT_TYPE _type;
  DateTime _createdOn;
  DateTime _updatedOn;

  String _content;
  List<String> _dbImages;
  List<File> _offlineImages;
  int  _childCount;

  Comment.fromJSON({String commentId,}){}




}