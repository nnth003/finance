## 1. Cài đặt môi trường
- SDK: 35
- Gradle 8.4

## 2. Run in terminal: 
```
  flutter clean
  flutter pub get
  cd android
  .\gradlew clean build
  ```

## 3. Screenshot

[//]: # (| Home                                         | Expense                                   | Category Management                        | Profile                                  | Notifications                                   | Signup                                   | Signin                                   | Login                                    | Add Transaction                              | Add Category                               | AI Chat                                   | Plan                                    |)

[//]: # (|----------------------------------------------|-------------------------------------------|--------------------------------------------|------------------------------------------|-------------------------------------------------|------------------------------------------|------------------------------------------|------------------------------------------|--------------------------------------------|-------------------------------------------|-------------------------------------------|-----------------------------------------|)

[//]: # (| ![Home]&#40;assets/screenshot/hom.png&#41;           | ![Expense]&#40;assets/screenshot/expens.png&#41;  | ![Categories]&#40;assets/screenshot/categories.png&#41; | ![Profile]&#40;assets/screenshot/profil.png&#41; | ![Notifications]&#40;assets/screenshot/notifications.png&#41; | ![Signup]&#40;assets/screenshot/signup.png&#41;  | ![Signin]&#40;assets/screenshot/signin.png&#41;  | ![Login]&#40;assets/screenshot/login.png&#41;     | ![Add Transaction]&#40;assets/screenshot/addtransaction.png&#41; | ![Add Category]&#40;assets/screenshot/addcategory.png&#41; | ![AI Chat]&#40;assets/screenshot/aichat.png&#41;  | ![Plan]&#40;assets/screenshot/plan.png&#41;      |)

<div style="display: flex; flex-wrap: wrap; justify-content: space-between;">
  <div style="width: 22%; margin-bottom: 10px;">
    <img src="assets/screenshot/hom.png" alt="Home" style="width: 100%; height: auto;" />
    <p>Home</p>
  </div>
  <div style="width: 22%; margin-bottom: 10px;">
    <img src="assets/screenshot/expens.png" alt="Expense" style="width: 100%; height: auto;" />
    <p>Expense</p>
  </div>
  <div style="width: 22%; margin-bottom: 10px;">
    <img src="assets/screenshot/categories.png" alt="Category Management" style="width: 100%; height: auto;" />
    <p>Category Management</p>
  </div>
  <div style="width: 22%; margin-bottom: 10px;">
    <img src="assets/screenshot/profil.png" alt="Profile" style="width: 100%; height: auto;" />
    <p>Profile</p>
  </div>
</div>

<div style="display: flex; flex-wrap: wrap; justify-content: space-between;">
  <div style="width: 22%; margin-bottom: 10px;">
    <img src="assets/screenshot/notifications.png" alt="Notifications" style="width: 100%; height: auto;" />
    <p>Notifications</p>
  </div>
  <div style="width: 22%; margin-bottom: 10px;">
    <img src="assets/screenshot/signup.png" alt="Signup" style="width: 100%; height: auto;" />
    <p>Signup</p>
  </div>
  <div style="width: 22%; margin-bottom: 10px;">
    <img src="assets/screenshot/signin.png" alt="Signin" style="width: 100%; height: auto;" />
    <p>Signin</p>
  </div>
  <div style="width: 22%; margin-bottom: 10px;">
    <img src="assets/screenshot/login.png" alt="Login" style="width: 100%; height: auto;" />
    <p>Login</p>
  </div>
</div>

<div style="display: flex; flex-wrap: wrap; justify-content: space-between;">
  <div style="width: 22%; margin-bottom: 10px;">
    <img src="assets/screenshot/addtransaction.png" alt="Add Transaction" style="width: 100%; height: auto;" />
    <p>Add Transaction</p>
  </div>
  <div style="width: 22%; margin-bottom: 10px;">
    <img src="assets/screenshot/addcategory.png" alt="Add Category" style="width: 100%; height: auto;" />
    <p>Add Category</p>
  </div>
  <div style="width: 22%; margin-bottom: 10px;">
    <img src="assets/screenshot/aichat.png" alt="AI Chat" style="width: 100%; height: auto;" />
    <p>AI Chat</p>
  </div>
  <div style="width: 22%; margin-bottom: 10px;">
    <img src="assets/screenshot/plan.png" alt="Plan" style="width: 100%; height: auto;" />
    <p>Plan</p>
  </div>
</div

## 4. Xử lý lỗi: 
- Nếu source nằm trên ổ C và project nằm trên ổ D và gặp lỗi như sau:``` 
    PS D:\Workspace\flutter\MyFinance_Management\android> .\gradlew clean build
    Configure project :gradle
    WARNING: Unsupported Kotlin plugin version.
    The `embedded-kotlin` and `kotlin-dsl` plugins rely on features of Kotlin `1.9.10` that might work differently than in the requested version `1.9.20`.
    WARNING: We recommend using a newer Android Gradle plugin to use compileSdk = 35
    This Android Gradle plugin (8.2.1) was tested up to compileSdk = 34.
    You are strongly encouraged to update your project to use a newer
    Android Gradle plugin that has been tested with compileSdk = 35.
    If you are already using the latest version of the Android Gradle plugin,
    you may need to wait until a newer version with support for compileSdk = 35 is available.
    To suppress this warning, add/update android.suppressUnsupportedCompileSdk=35 to this project's gradle.properties.
    FAILURE: Build failed with an exception.
        * What went wrong:
          Could not determine the dependencies of task ':path_provider_android:test'.
        >   Could not create task ':path_provider_android:testProfileUnitTest'.
        >   this and base files have different roots: D:\Workspace\flutter\MyFinance_Management\build\path_provider_android and C:\Users\haing\AppData\Local\Pub\Cache\hosted\pub.dev\path_provider_android-2.2.15\android.
        * Try:
        >   Run with --stacktrace option to get the stack trace.
        >   Run with --info or --debug option to get more log output.
        >   Run with --scan to get full insights.
        >   Get more help at https://help.gradle.org.
        BUILD FAILED in 3s
        6 actionable tasks: 1 executed, 5 up-to-date
        PS D:\Workspace\flutter\MyFinance_Management\android>```
- Xử lý lỗi:
  - Tạo một thư mục mới trong ổ D: ```D:\FlutterPubCache```
  - Thêm biến môi trường: 
    - Nhấn **Windows + S**, tìm **Environment Variables** 
    - Chọn Environment Variables... 
    - Ở mục **User variables**, nhấn **New...** 
    - Variable name: ```PUB_CACHE``` 
    - Variable value: ```D:\FlutterPubCache```
   
  Thêm Database  vào
  chọn androi/app/google-services.json
  {
  "project_info": {
    "project_number": "348738583132",
    "project_id": "finance-400a3",
    "storage_bucket": "finance-400a3.firebasestorage.app"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:348738583132:android:485c43ed4d774f04624499",
        "android_client_info": {
          "package_name": "com.example.finance"
        }
      },
      "oauth_client": [],
      "api_key": [
        {
          "current_key": "AIzaSyCkqKeP8Kjb2B2wimSTtVOE7dSRT_kSAak"
        }
      ],
      "services": {
        "appinvite_service": {
          "other_platform_oauth_client": []
        }
      }
    }
  ],
  "configuration_version": "1"

}

tiếp tục vào file main
await Firebase.initializeApp(
      options: const FirebaseOptions(
         apiKey: "AIzaSyAVJqTSPQqVZNQBc4ltmv-W_kdgcWJzwsE",
  authDomain: "finance-400a3.firebaseapp.com",
  projectId: "finance-400a3",
  storageBucket: "finance-400a3.firebasestorage.app",
  messagingSenderId: "348738583132",
  appId: "1:348738583132:web:1fd0d46063844ec5624499",)
    );


  
