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
  List<String> following = [];
  String _businessUrl = "";
  String _youtubeUrl = "";
  String _tiktokUrl = "";


  AppUser.fromJSON(Map<String,dynamic> data){
    this._userName = data["userName"] ?? this._uuid;
    this._reportedRecipesIds =  List.from(data["reportedRecipesIds"]);
    this._reportedRecipesIds = this._reportedRecipesIds.toSet().toList();
    this._aboutUser = data["aboutUser"] ?? "Chef Enthusiast";
    this._profileImagePath = data["profileImage"] ?? "";
    this.numCreated = data["numCreated"] ?? 0;
    this.numLiked = data["numLiked"] ?? 0;
    this._businessUrl =data["businessUrl"] ?? "";
    this._youtubeUrl =data["youtubeUrl"] ?? "";
    this._tiktokUrl =data["tiktokUrl"] ?? "";

  }
  void fromJSON(Map<String,dynamic> data){
    this._userName = data["userName"] ?? this._uuid;
    this._reportedRecipesIds =  List.from(data["reportedRecipesIds"]);
    this._reportedRecipesIds = this._reportedRecipesIds.toSet().toList();
    this._aboutUser = data["aboutUser"] ?? "Chef Enthusiast";
    this._profileImagePath = data["profileImage"] ?? "";
    this.numCreated = data["numCreated"] ?? 0;
    this.numLiked = data["numLiked"] ?? 0;
    this._businessUrl =data["businessUrl"] ?? "";
    this._youtubeUrl =data["youtubeUrl"] ?? "";
    this._tiktokUrl =data["tiktokUrl"] ?? "";
  }

  String get uuid => _uuid;
  void set uuid(String idToken){this._uuid = idToken;}
  String get signInMethod => _signInMethod;
  void set signInMethod(String method){this._signInMethod =  method;}
  String get aboutUser => _aboutUser;
  void set aboutUser(String aboutMe){
    this._aboutUser = aboutMe;
  }
  String get businessUrl => _businessUrl;
  void set businessUrl(String businessUrl){
    this._businessUrl = businessUrl;
  }
  String get youtubeUrl => _youtubeUrl;
  void set youtubeUrl(String youtubeUrl){
    this._youtubeUrl = youtubeUrl;
  }
  String get tiktokUrl => _tiktokUrl;
  void set tiktokUrl(String tiktokUrl){
    this._tiktokUrl = tiktokUrl;
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
    _businessUrl = "";
    _tiktokUrl = "";
    _youtubeUrl = "";
     numCreated = 0;
     numLiked = 0;
     numFollowedBy = 0;
     numFollowing = 0;

  }
   bool hasWebLinks(){
    if(youtubeUrl.length > 0 || tiktokUrl.length > 0 || businessUrl.length > 0) return true;
    return false;
  }
  void addLikeRecipe(String recipeId){
    if(!likedRecipes.contains(recipeId)) likedRecipes.add(recipeId);
  }
  void removeLikedRecipe(String recipeId){
    if(likedRecipes.contains(recipeId)) likedRecipes.remove(recipeId);
  }

  void addFollow(String followId){
   following.add(followId);

  }
  void unFollow(String followId){
    following.remove(followId);
  }



  void insertReportedRecipe(String recipeId){
    if(!_reportedRecipesIds.contains(recipeId)) _reportedRecipesIds.add(recipeId);
  }

  bool isUserSignedIn(){
    return  this.uuid != null && this.uuid != "";
  }
}