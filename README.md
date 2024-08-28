# Proyecto 1 Requerimientos de Software

## Pasos para habilitar desarrollo Flutter

1. Instalar Flutter SDK:
  1.1 Abrir VSCode
  1.2 Abrir Command Palette, presionar 'Control+Shift+P'
  1.3 En la Command Palette, escribir 'flutter'
  1.4 Seleccionar: 'Flutter: New Project'
  1.5 VSCode va a lanzar un pop up para localizar el Flutter SDK en la compu o descargarlo
  1.6 Si no está descargado ya, clickear 'Download SDK'
  1.7 VSCode va a preguntar si desea agregar al PATH. Seleccionar que sí
  1.8 Una vez se instale, en el Command Palette van a salir opciones de elegir un Flutter template. Ignorarlo y presionar Esc

2. Instalar dependencias:
  2.1 Abrir una terminal de VSCode y ejecutar 'dart pub global activate flutterfire_cli'
    2.1.1 Si esto no funciona, agregar la ruta 'C:\Users\<nombreusuario>\AppData\Local\Pub\Cache\bin' al Path
    y probar de nuevo en una terminal nueva
  2.2 Ejecutar 'flutter pub get'

3. 

3. Setup para ejecutar en android (Instrucciones de chatgpt y estan en inglés)
  3.1: Install Required Tools
    * Ensure Android Studio is Installed:
      Make sure you have Android Studio installed, along with the Android SDK and Android Virtual Device (AVD) Manager.
    * Install Flutter and Dart Extensions in VSCode:
      - Open VSCode
      - Go to the Extensions view by clicking on the square icon in the sidebar or pressing Ctrl+Shift+X.
      - Search for "Flutter" and click Install.This will automatically install the Dart extension as well.
  3.2: Create an Android Virtual Device (AVD) Using Android Studio
    * Create Emulator
      - Open Android Studio.
      - Go to Configure > AVD Manager.
      - Click on Create Virtual Device....
      - Select a device model (e.g., Pixel 4) and click Next.
      - Choose a system image (e.g., Android 12.0 (S)). If you don't have any system images installed, click Download next to the desired version.
      - Click Next, then Finish after reviewing the configuration.
  3.3: Start the Android Emulator
    * Start the Emulator from Android Studio:
      - In AVD Manager, click the Play button next to your created emulator to start it.
  3.4: Set Up Environment Variables (if not already set)
    * To ensure VSCode can detect your Android SDK and tools, you may need to set up environment variables.
      - Find Your Android SDK Path:
      - Usually, it's located in your home directory under Android/Sdk (e.g., C:\Users\<YourUsername>\AppData\Local\Android\Sdk on Windows).
      * Set Environment Variables:
        - Right-click This PC or My Computer and select Properties.
        - Click Advanced system settings > Environment Variables.
        - Under User variables, click New and add:
          * Variable name: ANDROID_HOME
          * Variable value: Your SDK path (e.g., C:\Users\<YourUsername>\AppData\Local\Android\Sdk).
        - Add SDK tools to the PATH variable:
        - Edit the Path variable and add the following paths:
          %ANDROID_HOME%\emulator
          %ANDROID_HOME%\tools
          %ANDROID_HOME%\tools\bin
          %ANDROID_HOME%\platform-tools
  3.5: Verify Flutter and Android SDK Setup
    * Check if Flutter Can Detect the Android SDK and Emulator:
      - Run the following command in your terminal or command prompt:
        'flutter doctor'
        Check for the Following in the Output:
          [✓] Android toolchain - develop for Android devices indicates the Android SDK is correctly set up.
          [✓] Connected device shows the emulator is running and detected by Flutter.
  3.6: Run Your Flutter App on the Emulator from VSCode
    * Open Your Flutter Project in VSCode:
      - Go to File > Open Folder... and select your Flutter project folder.
      - Open the Command Palette: Press Ctrl+Shift+P (Windows/Linux) or Cmd+Shift+P (macOS).
      - Select the Emulator:
        * Type Flutter: Select Device and press Enter.
        * Choose the running Android Emulator from the list.
      - Run the Flutter App:
        * Open the Command Palette again and type Flutter: Run or press F5.
        * The Flutter app will now build and run on the selected Android emulator.
  3.7: Debugging and Hot Reload
    * Hot Reload: When you make changes to your code, press r in the terminal or Ctrl+S in VSCode to hot reload the app.
    * Hot Restart: Press R in the terminal to hot restart the app, which restarts the state as well.
