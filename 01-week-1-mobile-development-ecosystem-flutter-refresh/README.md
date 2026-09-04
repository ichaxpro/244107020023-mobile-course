<h1>Week-1 : Getting Started Modelling UI</h1>

Name: Dewi Chalissa Rania
Class: TI 3I
NIM: 244107020023


## Checklist

- [x] Flutter doctor has no issue blocking the Android target.
- [x] Flutter devices detects an emulator or physical device.
- [x] The application runs and its default UI has been replaced with a simple profile.
- [x] You can explain the difference between hot reload and hot restart.
- [x] The remote repository contains source code, README, screenshots, and commit history.

## Screenshots
### Flutter Doctor Before
![Flutter Doctor](screenshots/issue.png)
### Flutter Doctor After
![Flutter Doctor](screenshots/flutter_doctor.png)
### Flutter Devices
![Flutter Devices](screenshots/devices.png)
### Practical Lab Result
![Flutter Profile](screenshots/practical_lab.png)
### Mini Assignment Result
![Flutter Profile Mini Assignment](screenshots/result.png)

## Hot Reload vs Hot Restart
- **Hot reload:** Injects updated code into the running Dart VM directly without losing the current app state.
- **Hot restart:** Rebuilds the app state from scratch and restarts the application life cycle.

## Setup Problem & Solution

- **Problem:** The week 1 folder turned into a nested git repository / submodule on GitHub (grey folder icon that couldn't be opened) due to an accidental `.git` folder inside the subfolder.
- **Solution:** Removed the inner `.git` folder, cleared the git cache using `git rm -r --cached`, and recommitted from the root directory.

## Reflection

- **When is native development more appropriate than cross-platform development?**  
  Native development is ideal for graphics-heavy applications (such as 3D games), apps that require deep integration with specialized device hardware and sensors, or projects that need immediate, day-one support for new platform-specific OS features.

- **How does a state change relate to the widget tree and declarative UI?**  
  In declarative UI frameworks like Flutter ($UI = f(state)$), updating the underlying state notifies the system to re-render the relevant section of the widget tree, ensuring the interface efficiently reflects the current app data.

- **Why are small commits with clear messages useful for teamwork and a portfolio?**  
  Frequent, focused commits paired with descriptive messages streamline code reviews, simplify bug tracking, reduce merge conflicts, and showcase a disciplined, professional development workflow to reviewers or potential employers.



