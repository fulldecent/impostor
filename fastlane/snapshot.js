#import "SnapshotHelper.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();

// Hide intro screen
target.delay(1);
window.buttons()[0].tap();
target.delay(1);
captureLocalizedScreenshot("0-mainScreen");

window.buttons()[0].tap();
target.delay(3)
captureLocalizedScreenshot("9-easteregg");
target.delay(3)


window.buttons()[4].tap();
captureLocalizedScreenshot("1-mainScreen");

window.buttons()[0].tap();
captureLocalizedScreenshot("2-mainScreen");
window.images()[0].tap();
target.delay(1);

window.buttons()[0].tap();
window.images()[0].tap();
target.delay(1);

window.buttons()[0].tap();
window.images()[0].tap();
target.delay(3);

//target.collectionViews()[0].cells()[0].tap();
captureLocalizedScreenshot("3-mainScreen");
