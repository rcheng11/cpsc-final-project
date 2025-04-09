/*
Handles functions for the GUI interface.
*/
module gui;
import std.stdio;
import std.conv;
import core.thread;

import gtk.MainWindow;
import gtk.Window;
import gtk.Main;
import gtk.Widget;
import gtk.Button;
import gdk.Event;
import gtk.Label;
import gtk.Entry;
import gtk.Box;
import gtk.EditableIF;
import gtk.EventBox;

import graphics_app;
import bindbc.sdl;

import glib.Idle;

import parser;

GraphicsApp app;
void QuitApp(){
	writeln("Closing Pseudo3D App.");
    app.mGameIsRunning = false;
	Main.quit();
}

/*
Temp GUI function to be refactored later as
a class.
*/
void runGUI(string[] args){
    string loadingFile = "./assets/samples/sample1"; // preloaded
    // window setup
	Main.init(args);
	MainWindow mainApp = new MainWindow("Pseudo-3D App");
    mainApp.setDefaultSize(640,480);
	mainApp.addOnDestroy(delegate void(Widget w) { QuitApp(); });


    // Create a centered horizontal box container
    auto loadProjectBox = new Box(Orientation.HORIZONTAL, 5);
    loadProjectBox.setHalign(Align.CENTER);
    auto otherOptionsBox = new Box(Orientation.HORIZONTAL, 5);
    otherOptionsBox.setHalign(Align.CENTER);
	
    // create buttons
    Button loadProjectBtn = new Button("Load Project");
    loadProjectBtn.addOnClicked(delegate void(Button b) {
		writeln("Loading Project");
        P3DObj data = loadFolder(loadingFile);
        launchProjectWindow(data);
	});
    Button newProjectBtn = new Button("New Project");
    newProjectBtn.addOnClicked(delegate void(Button b) {
		writeln("Creating New Project");
	});
    Button runSpriteStackerBtn = new Button("Run Sprite Stacker");
    runSpriteStackerBtn.addOnClicked(delegate void(Button b){
        writeln("Launching sprite stacker...");
    });
    

    // create label
    auto label = new Label("Relative File Path: ");

    // create entry
    Entry entry = new Entry("./assets/samples/sample1");
    entry.setSizeRequest(300, 50);
    entry.addOnChanged(delegate void(EditableIF e){
        loadingFile = entry.getText();
        writeln(loadingFile);
    });

    // event box for sizing
    auto firstRowBox = new EventBox();
    firstRowBox.setSizeRequest(640, 50);
    auto secondRowBox = new EventBox();
    secondRowBox.setSizeRequest(640, 50);

    // pack items together
    // widgets > hBox > eventBox > socketWrap
    loadProjectBox.packStart(label, false, false, 0);
    loadProjectBox.packStart(entry, false, false, 0);
    loadProjectBox.packStart(loadProjectBtn, false, false, 0);
    firstRowBox.add(loadProjectBox);

    otherOptionsBox.packStart(newProjectBtn, false, false, 0);
    otherOptionsBox.packStart(runSpriteStackerBtn, false, false, 0);
    secondRowBox.add(otherOptionsBox);

    auto mainContainer = new Box(Orientation.VERTICAL, 5);
    mainContainer.setHalign(Align.CENTER);
    mainContainer.setValign(Align.CENTER);
    mainContainer.packStart(firstRowBox, false, false, 5); 
    mainContainer.packStart(secondRowBox, false, false, 5);
    mainApp.add(mainContainer);

    // show and run window
	mainApp.showAll();
	Main.run();
}


void launchProjectWindow(P3DObj model){
    // make window
    int windowH = 800;
    int windowW = 1300;
    auto projectWindow = new Window(model.modelName);
    projectWindow.setDefaultSize(windowW, windowH);

    // create containers
    auto mainContainer = new Box(Orientation.HORIZONTAL, 5);
    mainContainer.setHalign(Align.CENTER);
    mainContainer.setValign(Align.CENTER);

    // LEFT COLUMN: contains most options
    auto leftColumn = new Box(Orientation.VERTICAL, 5);
    leftColumn.setHalign(Align.CENTER);
    leftColumn.setValign(Align.CENTER);
    auto leftColumnWrap = new EventBox();
    leftColumnWrap.setSizeRequest(windowW / 2, windowH);
    leftColumnWrap.add(leftColumn);
    // RIGHT COLUMN: preview + export button
    auto rightColumn = new Box(Orientation.VERTICAL, 5);
    rightColumn.setHalign(Align.CENTER);
    rightColumn.setValign(Align.CENTER);
    auto rightColumnWrap = new EventBox();
    rightColumnWrap.setSizeRequest(windowW / 2, windowH);
    rightColumnWrap.add(rightColumn);

    mainContainer.packStart(leftColumnWrap, false, false, 5);
    mainContainer.packStart(rightColumnWrap, false, false, 5);

    // left column widgets
    EventBox[] leftRows = [];
    // row 1
    Box spritePathRow = new Box(Orientation.HORIZONTAL, 5);
    Entry spritePathEntry = new Entry();
    spritePathEntry.setSizeRequest(300, 50);
    Button spritePathBtn = new Button("Load Sprite");
    spritePathRow.packStart(spritePathEntry, false, false, 5);
    spritePathRow.packStart(spritePathBtn, false, false, 5);

    Box spriteVAngleRow = new Box(Orientation.HORIZONTAL, 5);
    Entry spriteVAngleEntry = new Entry(to!string(model.getVAngle)); // get initial val from spec
    spriteVAngleEntry.setSizeRequest(50, 50);
    spriteVAngleEntry.addOnChanged(delegate void(EditableIF e){
        // update values of the model
        try{
            model.setVAngle(to!int(spriteVAngleEntry.getText()));
        }
        catch(ConvException){ // set to 0 if invalid
            spriteVAngleEntry.setText("0");
        }
    });
    Button spriteVAngleLeftBtn = new Button("◀");
    spriteVAngleLeftBtn.addOnClicked(delegate void(Button b){
        spriteVAngleEntry.setText(
            to!string(to!int(spriteVAngleEntry.getText()) - 1)
        );
    });
    Button spriteVAngleRightBtn = new Button("▶");
    spriteVAngleRightBtn.addOnClicked(delegate void(Button b){
        spriteVAngleEntry.setText(
            to!string(to!int(spriteVAngleEntry.getText()) + 1)
        );
    });
    Label spriteVAngleLabel = new Label("Sprite VAngle");
    spriteVAngleRow.packStart(spriteVAngleLabel, false, false, 5);
    spriteVAngleRow.packStart(spriteVAngleLeftBtn, false, false, 5);
    spriteVAngleRow.packStart(spriteVAngleEntry, false, false, 5);
    spriteVAngleRow.packStart(spriteVAngleRightBtn, false, false, 5);

    Box spriteHAngleRow = new Box(Orientation.HORIZONTAL, 5);
    Entry spriteHAngleEntry = new Entry(to!string(model.getHAngle)); // get initial val from spec
    spriteHAngleEntry.setSizeRequest(50, 50);
    spriteHAngleEntry.addOnChanged(delegate void(EditableIF e){
        // update values of the model
        try{
            model.setHAngle(to!int(spriteHAngleEntry.getText()));
        }
        catch(ConvException){ // set to 0 if invalid
            spriteHAngleEntry.setText("0");
        }
    });
    Button spriteHAngleLeftBtn = new Button("◀");
    spriteHAngleLeftBtn.addOnClicked(delegate void(Button b){
        spriteHAngleEntry.setText(
            to!string(to!int(spriteHAngleEntry.getText()) - 1)
        );
    });
    Button spriteHAngleRightBtn = new Button("▶");
    spriteHAngleRightBtn.addOnClicked(delegate void(Button b){
        spriteHAngleEntry.setText(
            to!string(to!int(spriteHAngleEntry.getText()) + 1)
        );
    });
    Label spriteHAngleLabel = new Label("Sprite HAngle");
    spriteHAngleRow.packStart(spriteHAngleLabel, false, false, 5);
    spriteHAngleRow.packStart(spriteHAngleLeftBtn, false, false, 5);
    spriteHAngleRow.packStart(spriteHAngleEntry, false, false, 5);
    spriteHAngleRow.packStart(spriteHAngleRightBtn, false, false, 5);

    leftRows ~= new EventBox();
    leftRows[0].add(spritePathRow);
    leftRows ~= new EventBox();
    leftRows[1].add(spriteVAngleRow);
    leftRows ~= new EventBox();
    leftRows[2].add(spriteHAngleRow);
    
    // add to main container
    foreach(row ; leftRows){
        row.setHalign(Align.CENTER);
        leftColumn.packStart(row, false, false, 5);
    }

    // right column widgets
    EventBox[] rightRows = [];
    auto launchSDL = new Box(Orientation.VERTICAL, 5);
    auto launchSDLBtn = new Button("Launch Preview"); 

    int previewH = 480;
    int previewW = 640;
    launchSDLBtn.addOnClicked(delegate void(Button b) {
        writeln("button clicked");
        app = GraphicsApp(previewW, previewH);
        app.SetupScene();
        app.loadModel(model);
        // technique here borrowed from former groupmate Alexis Nketia
        // from our final project for Game Engines class
        int counter = 0;
        auto idle = new Idle(delegate bool(){
            app.AdvanceFrame();
            bool appRunning = app.mGameIsRunning;
            if(!appRunning){ // kill the app data/window when running stops
                destroy(app);
            }
            return appRunning;
        });
    });

    launchSDL.packStart(launchSDLBtn, false, false, 5);
    rightRows ~= new EventBox();
    rightRows[0].add(launchSDL);

    foreach(row ; rightRows){
        row.setHalign(Align.CENTER);
        rightColumn.packStart(row, false, false, 5);
    }

    projectWindow.add(mainContainer);
    
    // Show the new window
    projectWindow.showAll();
}