# EW309 Turret Simulation for Spring 2020 Coronavirus shutdown
### L Devries, D Evangelista, M Kutzer, and T Severson
This material is for simulating the autoturret used in EW309 at the US Naval Academy, since during a coronavirus shutdown the midshipmen will not have access to the turret rigs. The code includes simulations of ballistics; camera inputs from the turret for student machine vision code use; and an integrated simulation code for testing what would have been final system integration.

## Github notes
For faculty editing the files, to avoid conflcts, it's best to work on a specific item or module (or even us a separate branch). After you are happy with your revisions, add them, then commit, then push changes:
```bash
git add my-changed-file.m
git commit -m "I changed my-changed-file.m add a spinning turret using hgtransform"
git push
```
If using Windows git GUI tools, do XYZ. 

For others, including midshipmen cloning the files:
```bash
git clone https://github.com/usna-ew309/corona.git
```
If using Windows git GUI tools, do XYZ.

To pull the most recent version:
```bash
git pull
```
## Windows Git and Github notes
To do this on a USNA windows machine:
  * Download GitHub desktop from [https://desktop.github.com]
  * Install GitHub desktop. This will require administrator rights
  * Prof Kutzer can show you the rest... Github has a tutorial here once you get it installed: [https://guides.github.com/activities/hello-world/]
  * A tutorial for using the Github desktop client is here:
[https://idratherbewriting.com/learnapidoc/pubapis_github_desktop_client.html]

## Dependencies and prerequisties
To use these routines, your Matlab will need the following somewhere in its PATH:
  * [https://github.com/kutzer/PlottingToolbox ]
    - `simulateImage.m` (needs to be updated to replace `print` & `imread` with `getframe`)
    - `plotCameraFOV.m`
  * [https://github.com/kutzer/WRC_MATLABCameraSupport ]
     - `drawDFKCam.m` (we should make a `drawPicoICubieCam`)

## Ballistics simulation
## Turret view simulation
## Control simulation
## Integrated simulation

### Contributors
L Devries, D Evangelista, M Kutzer, CAPT T Severson

### Thanks to
The Academy

