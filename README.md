# Bear Kare
#### Developed by Alex Daniels, Sophie Dasinger, Rachel Frenkel, Alice Lee, Tara Watson, and Colin Watts
An occupational therapy-focused iOS app. It is used to help a patient improve their Activities of Daily Life by having them care for a specially designed stuffed bear. The app responds to the patient's care and allows an OT/caregiver to track the patient's progress.

## Prerequisites
* iPhone 6 (should be run on simulator with iPhone 6 as target. In a future version, we would like to make this accessible to iPad users as well, however, the assets are specifically sized for the iPhone 6 currently)
* Swift v 2.1.1
* BearKare accesssories (toothbrush with sensor and wristband)
  * BearKare accessories are not final but currently consist of an Arduino Yun and an arrangement of hall sensors in the bear,
  * The toothbrush contains a magnet to trigger the hall sensors.
  * The bracelet contains an accelerometer. 
* Server hosted on Heroku (https://peaceful-woodland-42419.herokuapp.com/) - see Server directory for readme

## Instructions for use
* The user receives a local notification for a scheduled task when outside of the app. This can either be a banner or an alert, configurable via the device settings. 
* When the app is in the foreground, the alert to perform the task is presented via a speech bubble with an icon representing the ADL. 
* If the user has not completed the task for a certain amount of time, the bear's mood will change and the alert will become increasingly urgent (indicated by the color of the speech bubble). 
* When the user is in the process of doing a task, a progress bar indicates how many motions are required to complete it.
* Once the task has been performed on the bear, the user is then prompted to do the task on themself. 

## Limitations of prototype
* Please note that for demo purposes, we have dramatically decreased the time intervals. In the production version of the app, it will be 30 minutes before the bear's "mood" changes.
* In a production-ready version of this app, the user would be able to perform multiple ADLs.
* A production-ready version would also have an interface for the caretaker/occupational therapist to schedule various ADLs and track the patient's progress. This would be separate from the mobile app, because the app is specifically for Alexa (or any patient) to use.
