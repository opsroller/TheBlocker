# TheBlocker - A Code Challenge
## Block individual or random phone numbers via CallKit

TheBlocker makes it easy to block/allow phone numbers through the CallKit blocking functionality. The UI is minimal as the challenge description didn't place any emphasis on asthetic. However, there are some basic features like form validation and notice that the CallKit extension isn't enabled.

## Challenge
#### Time limit - 5 days

### Guidelines
Use any Apple documentation or Apple sample projects.
Don’t get too caught up in handling every edge case. We know this is being completed in your spare time and will not have the polish of an app where the developer has ample time. For example, do not spend time ensuring a phone number textfield checks for proper format, instead put a comment in code that says
// User expected to enter 10 digit numeric value
You may use any version of Swift or Objective-C, any version of Xcode, any UI approach like Storyboards or SwiftUI or XIBs that you choose.
You may use Cocoapods if you like. You can use any type of persistence that works in the solution, like core data, realm, user defaults, etc.

### Requirements
- Create an App with a CallKit Extension
- App should allow user to enter a phone number to be blocked
- App should allow user to enter a value between 1000-100,000 and the user can click a
button labeled ‘generate’
  - This will create that many unique phone numbers and block them in call kit
  
### Criteria
- Internal engineer can compile your code and install on a test device. (We’ll update signing and apple account if needed)
- Once installed, internal engineer can block a single number, place a call from that number on a different device, and observe the call was blocked.
- Internal Engineer can generate 1k-100k numbers and verify the numbers were added to the Call Kit Block list.

## Run it
An app group is used so that UserDefaults and CoreData are accessible by both the main target and extension. So be sure to update that. A SwiftLint config is at the root of the project so it may be helpful if that is installed and in your PATH.
