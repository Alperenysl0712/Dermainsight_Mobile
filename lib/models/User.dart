class User{
  late int? Id;
  late String Username;
  late String Name;
  late String Surname;
  late String Email;
  late String UserType;
  late String Phone;
  late String Password;

  User({this.Id, required this.Username, required this.Name, required this.Surname, required this.Email,
    required this.UserType, required this.Phone, required this.Password});

  User.fromJson(Map<String, dynamic> json){
    Id = json["Id"];
    Username = json["Username"];
    Name = json["Name"];
    Surname = json["Surname"];
    Email = json["Email"];
    UserType = json["UserType"];
    Phone = json["Phone"];
    Password = json["Password"];
  }

  Map<String, dynamic> toJson(){
    final data = {
      "Username": Username,
      "Name": Name,
      "Surname": Surname,
      "UserType": UserType,
      "Email": Email,
      "Phone": Phone,
      "Password": Password
    };

    return data;
  }

  @override
  String toString() {
    return 'User'
        '\n{'
        '\nId: $Id, '
        '\nUsername: $Username, '
        '\nName: $Name, '
        '\nSurname: $Surname, '
        '\nEmail: $Email, '
        '\nUserType: $UserType, '
        '\nPhone: $Phone, '
        '\nPassword: $Password'
        '\n}';
  }


}