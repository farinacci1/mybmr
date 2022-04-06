class AppUser{
  static AppUser _instance;
  AppUser._();
  static AppUser get instance => _instance ??= AppUser._();

  String _uuid;
  String _signInMethod;
  String _userName;
  List<String> _myCreationIds =[];
  List<String> _likedRecipesIds =[];
  List<String> _reportedRecipesIds =[];
  String _aboutUser;
  String _profileImagePath;

  AppUser.fromJSON(Map<String,dynamic> data){
    this._userName = data["userName"] ?? this._uuid;
    this._myCreationIds =  List.from(data["myCreationIds"]);
    this._likedRecipesIds =  List.from(data["likedRecipesIds"]);
    this._reportedRecipesIds =  List.from(data["reportedRecipesIds"]);
    this._myCreationIds = this._myCreationIds.toSet().toList();
    this._likedRecipesIds = this._likedRecipesIds.toSet().toList();
    this._reportedRecipesIds = this._reportedRecipesIds.toSet().toList();
    this._aboutUser = data["aboutUser"] ?? "Chef Enthusiast";
    this._profileImagePath = data["profileImage"] ?? "";

  }
  String get uuid => _uuid;
  void set uuid(String idToken){this._uuid = idToken;}
  String get signInMethod => _signInMethod;
  void set signInMethod(String method){this._signInMethod =  method;}
  String get aboutUser => _aboutUser;
  void set aboutUser(String aboutMe){
    this._aboutUser = aboutMe;
  }
  List<String> get myCreationIds => _myCreationIds;
  List<String> get likedRecipesIds => _likedRecipesIds;
  List<String> get reportedRecipesIds => _reportedRecipesIds;
  void set userName(String userName){this._userName = userName;}
  String get userName => _userName;
  String get profileImagePath =>_profileImagePath;
  void set profileImagePath(String imagePath){this._profileImagePath = imagePath;}
  void clear(){
    _myCreationIds.clear();
    _likedRecipesIds.clear();
    _reportedRecipesIds.clear();
    _userName = null;
  }

  void fromJSON(Map<String,dynamic> data){
    this._userName = data["userName"] ?? this._uuid;
    this._myCreationIds =  List.from(data["myCreationIds"]);
    this._likedRecipesIds =  List.from(data["likedRecipesIds"]);
    this._reportedRecipesIds =  List.from(data["reportedRecipesIds"]);
    this._myCreationIds = this._myCreationIds.toSet().toList();
    this._likedRecipesIds = this._likedRecipesIds.toSet().toList();
    this._reportedRecipesIds = this._reportedRecipesIds.toSet().toList();
    this._aboutUser = data["aboutUser"] ?? "Chef Enthusiast";
    this._profileImagePath = data["profileImage"] ?? null;
  }

  void insertCreatedRecipe(String recipeId){
    _myCreationIds.add(recipeId);
  }

  void insertLikedRecipe(String recipeId){
    _likedRecipesIds.add(recipeId);
  }
  void insertReportedRecipe(String recipeId){
    _reportedRecipesIds.add(recipeId);
  }
}