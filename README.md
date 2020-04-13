# EW309 Turret Simulation for Spring 2020 Coronavirus shutdown
### L Devries, D Evangelista, M Kutzer, and T Severson
This material is for simulating the autoturret used in EW309 at the US Naval Academy, since during a coronavirus shutdown the midshipmen will not have access to the turret rigs. The code includes simulations of ballistics; camera inputs from the turret for student machine vision code use; and an integrated simulation code for testing what would have been final system integration.

## Installation
### Using git
  - Use `git` to clone the lastest version. From the command line use `git clone https://github.com/usna-ew309/corona.git`. Alternatively, navigate to your MATLAB working directory, right click to get the Git GUI tool, select `clone a respository` and enter in the url <https://github.com/usna-ew309/corona.git>; you can place it in a subdirectory named corona or name it what you like. 
  - Open MATLAB as administrator
  - Within MATLAB, change directory to the directory where you have cloned the `corona` files to (e.g. `Documents/MATLAB/corona` or wherever you put them). 
  - From the MATLAB command window, run the `installEW309corona` script. This will copy some additional files, it may download some additional binary resources if needed, and it will set your PATH so that the corona files are visible to MATLAB.

### When downloading the *.zip
  - Download `corona-master.zip` from <https://github.com/usna-ew309/corona/archive/master.zip>
  - Open MATLAB as administrator
  - Unzip/extract `corona-master.zip`
  - Change your MATLAB directory to `..\corona-master\corona-master\support`
  - From the MATLAB command window, run the `EW309coronaUpdate` script. This will copy or download additional files if needed.
  - Allow the installation to complete. 
  
### Install procedure with three files (from Google Drive)
  - Download files
    - `installSupportToolboxes.m`
    - `EW309coronaUpdate.m`
    - `SCRIPT_PackageTest_EW309Corona.m`
  - Open MATLAB as administrator
  - Change MATLAB Current Directory to the location of the downloaded files
  - Run `installSupportToolboxes` from the MATLAB Commmand Window to install prerequisites
  - Run `EW309coronaUpdate` from the MATLAB Command Window to install the Corona stack
  - Run `SCRIPT_PackageTest_EW309Corona` from the Command Window to test the installation

### Troubleshooting installation issues
#### Known warnings:
``` 
Warning: Unable to remove temporary download folder. C:\User\midshipman\AppData\Local\Temp\EW309corona > In EW309coronaUpdate (line 64)
```
This is a non-critical write-error (MATLAB is still accessing files in a folder that the installer is trying to delete).

#### Known Errors:
``` 
Error using installPlottingToolbox (line 64)
```
This most likely means you are not running Matlab as administrator, most likely. To fix, close MATLAB, and open MATLAB as administrator. 


```
Error in SCRIPT_PackageTest_EW309Corona (line 187)
```
This means you are missing the Control System Toolbox. Run `supportPackageInstaller` from the MATLAB Command Window. Search for `Control System Toolbox` and install `Control System Toolbox`.


## Github notes
For faculty editing the files, to avoid conflcts, it's best to work on a specific item or module (or even us a separate branch). After you are happy with your revisions, add them, then commit, then push changes:
```bash
git add my-changed-file.m
git commit -m "I changed my-changed-file.m add a spinning turret using hgtransform"
git push
```
For others, including midshipmen cloning the files:
```bash
git clone https://github.com/usna-ew309/corona.git
```
If using Windows git GUI tools, use file browser to navigate to where you wish to clone the repository. Right click to obtain a dialog box; it should contain an option to run Git GUI. Run Git GUI and select `Clone a repository`; enter the URL as <https://github.com/usna-ew309/corona.git> and it should clone the repository.  To commit changes and push, use git GUI in the same way.

To pull the most recent version:
```bash
git pull
```
Using Windows git GUI tools, right click to get to the git GUI and select pull. 



## Windows Git and Github notes
To do this on a USNA windows machine:
  * Install git and git-lfs from <https://git-scm.com>
  * Download GitHub desktop from <https://desktop.github.com>
  * Install GitHub desktop. This will require administrator rights
  * Prof Kutzer can show you the rest... Github has a tutorial here once you get it installed: <https://guides.github.com/activities/hello-world/>
  * A tutorial for using the Github desktop client is here:
<https://idratherbewriting.com/learnapidoc/pubapis_github_desktop_client.html>

## Dependencies and prerequisties
Installation using the procedures above should install all the necessary dependencies and prerequisites.

For reference purposes only, to use these routines, your Matlab will need the following somewhere in its PATH:
  * <https://github.com/kutzer/PlottingToolbox>
    - `simulateImage.m` (needs to be updated to replace `print` & `imread` with `getframe`)
    - `plotCameraFOV.m`
  * <https://github.com/kutzer/WRC_MATLABCameraSupport>
     - `drawDFKCam.m` (we should make a `drawPicoICubieCam`)

## Ballistics simulation
## Turret view simulation
## Control simulation
## Integrated simulation

## Packaging note
Cloning the repository, via `git clone` or the GUI tool, will provide all the files needed, however, if you download the zip from Github it will replace the digital resource files with links (this method is not recommended). For ease of download from Google Drive, we can create zips of major releases and upload them there. To tag a major release and then zip it for this type of use:
```bash
git tag -a v1.2.0rc1 -m "Creating release candidate 1"
git push origin tags
git fetch --all --tags
zip -r coronoa-v1.2.0rc1.zip corona -x '*.git*'
```

### Contributors
L Devries, D Evangelista, M Kutzer, CAPT T Severson

### Thanks to
The Academy

