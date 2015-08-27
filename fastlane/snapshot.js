#import "SnapshotHelper.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();

// Hide intro screen
//target.delay(1);
//window.buttons()[0].tap();
target.delay(1);

captureLocalizedScreenshot("0-gameConfig");

window.buttons()[0].tap();
target.delay(3)
captureLocalizedScreenshot("9-easterEgg");
target.delay(1)

window.buttons()[4].tap();
captureLocalizedScreenshot("1-playerPage");

window.buttons()[0].tap(); // "show secret word"
captureLocalizedScreenshot("2-secretWord");
window.buttons()[0].tap(); // "ok"
target.delay(2);

window.buttons()[0].tap(); // "show secret word"
target.delay(1);
window.buttons()[0].tap(); // "ok"
target.delay(1);
window.buttons()[0].tap(); // "show secret word"
target.delay(1);
window.buttons()[0].tap(); // "ok"
target.delay(1);
window.buttons()[0].tap(); // "show secret word"
target.delay(1);
captureLocalizedScreenshot("3-whoDied");

//target.collectionViews()[0].cells()[0].tap();
