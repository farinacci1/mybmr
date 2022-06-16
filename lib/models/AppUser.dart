class AppUser{
  static AppUser _instance;
  AppUser._();
  static AppUser get instance => _instance ??= AppUser._();

  String _uuid = "";
  String _signInMethod;
  String _userName = "";
  List<String> _reportedRecipesIds =[];
  String _aboutUser;
  String _profileImagePath;
  int numCreated;
  int numLiked;
  int numFollowedBy;
  int numFollowing;
  List<String> likedRecipes = [];

  AppUser.fromJSON(Map<String,dynamic> data){
    this._userName = data["userName"] ?? this._uuid;
    this._reportedRecipesIds =  List.from(data["reportedRecipesIds"]);
    this._reportedRecipesIds = this._reportedRecipesIds.toSet().toList();
    this._aboutUser = data["aboutUser"] ?? "Chef Enthusiast";
    this._profileImagePath = data["profileImage"] ?? "";
    this.numCreated = data["numCreated"] ?? 0;
    this.numLiked = data["numLiked"] ?? 0;

  }
  String get uuid => _uuid;
  void set uuid(String idToken){this._uuid = idToken;}
  String get signInMethod => _signInMethod;
  void set signInMethod(String method){this._signInMethod =  method;}
  String get aboutUser => _aboutUser;
  void set aboutUser(String aboutMe){
    this._aboutUser = aboutMe;
  }


  List<String> get reportedRecipesIds => _reportedRecipesIds;
  void set userName(String userName){this._userName = userName;}
  String get userName => _userName;
  String get profileImagePath =>_profileImagePath;
  void set profileImagePath(String imagePath){this._profileImagePath = imagePath;}
  void clear(){

    _reportedRecipesIds.clear();
    likedRecipes.clear();
    _userName = "";
  }
  void addLikeRecipe(String recipeId){
    if(!likedRecipes.contains(recipeId)) likedRecipes.add(recipeId);
  }
  void removeLikedRecipe(String recipeId){
    if(likedRecipes.contains(recipeId)) likedRecipes.remove(recipeId);
  }

  void fromJSON(Map<String,dynamic> data){
    this._userName = data["userName"] ?? this._uuid;

    this._reportedRecipesIds =  List.from(data["reportedRecipesIds"]);
    this._reportedRecipesIds = this._reportedRecipesIds.toSet().toList();
    this._aboutUser = data["aboutUser"] ?? "Chef Enthusiast";
    this._profileImagePath = data["profileImage"] ?? null;
  }


  void insertReportedRecipe(String recipeId){
    if(!_reportedRecipesIds.contains(recipeId)) _reportedRecipesIds.add(recipeId);
  }
  bool isUserSignedIn(){
    return  this.uuid != null && this.uuid != "";
  }
}