module parser;

import std.stdio;
import std.file;
import std.json;
import jsonabstraction;
import std.path;
import std.array;
import std.conv;

import bindbc.sdl;
import bindbc.opengl;

import gtk.MessageDialog;
import texture;

/*
This file is responsible for parsing folders that contain
Psuedo3D data in a structured way and also for defining
P3D objects.

The folder must contain the following exactly named:
- ImageData folder: contains a series of images with number that
corresponds to the layer
- NormalData folder: contains a series of normal maps with a number that
corresponds to the layer
- spec.json file: contains a spec.json file that holds information
about each layer (such as the gap height between individual layers
or general lighting/angle presets)

Here is what a sample folder looks like:
-> MainFolder
----> ImageData
-------> 0.png
-------> 1.png
-------> 2.png
----> NormalData
-------> 0.png
-------> 1.png
-------> 2.png
----> spec.json
*/

void validateBounds(){

}

class P3DAppSettings{
    /*Class that stores information about general settings
    for the application including:
    - Whether the graphics app does instant or delayed rendering
    - Whether the graphcis app should simulate lighting or not
    */
}
class P3DLight{
    /* Class representing a light source. Holds
    information about:
    - mVangle: the vertical arc the "light" is coming from (degrees)
    - mHAngle: the horizontal arc the "light" is coming from (degrees)
    - mColor: the color of the light, stored as a hex string
    - intensity: how strong the light is (0 - 1)
    */
    int mVAngle;
    int mHAngle;
    string mColor;
    float mIntensity;
    this(int mVAngle, int mHAngle, string mColor, float mIntensity){

    }
}
class P3DSlice{
    /* Class representing a slice of a sprite stack. Slices
    are assumed to be two triangles forming a square.
    This includes:
    - mTexture: the textureID of the sprite image to be applied onto the slice
    - mX: the width of the slice
    - mY: the length of the slice
    - mZ: the slice height offset
    - mVAngle: the vAngle to skew the slice at (degrees)
    - mHAngle: the HAngle to skew the slice at (degrees)
    */
    Texture mSprite;
    Texture mNormalMap;
    string mSpriteFPath;
    string mNormalFPath;
    float mX;
    float mY;
    float mZ;
    int mVAngle;
    int mHAngle;

    this(string spriteFPath, string normalFPath, float x, float y, float z, int vAngle, int hAngle){
        mX = x;
        mY = y;
        mZ = z;
        mSpriteFPath = spriteFPath;
        mNormalFPath = normalFPath;
        mVAngle = vAngle;
        mHAngle = hAngle;
    }
    void generateTextures(){ 
        // load textures from file paths and store them
        // only when an OpenGL context has been created
        mSprite = new Texture(mSpriteFPath);
        mNormalMap = new Texture(mNormalFPath);

    }
}
class P3DSpriteStack{
    /* Class representing a sprite stack. This includes information about:
    - mVAngle: the vertical arc the "camera" lies on (degrees)
    - mHAngle: the horizontal arc the "camera" lies on (degrees) 
    - mSlices: an array of P3D slices representing the stack
    */
    int mVAngle = 0;
    int mHAngle = 0;
    P3DSlice[] mSlices;
    this(){
        mSlices = [];
    }
    void loadTextures(){
        foreach(slice ; mSlices){
            slice.generateTextures();
        }
    }
    P3DSlice addSlice(P3DSlice slice){
        mSlices ~= slice;
        return slice;
    }
    void setVAngle(int vAngle){
        mVAngle = vAngle;
    }
    void setHAngle(int hAngle){
        mHAngle = hAngle;
    }
}
class P3DObj{
    /* Class representing the parsed information from a P3D style
    folder as described in parser.d split into subparts:
    - P3DObj holds the original filepath, name, and other metadata
    - mSpriteStack: A P3DSpriteStack object holding information about the
    slices and how they are being transformed.
    - mLights: An array of P3DLight objects that represent all the
    light sources affecting this object. 
    */
    string mFilepath;
    string modelName;
    P3DSpriteStack mSpriteStack;
    P3DLight[] mLights;
    this(string filepath){
        mFilepath = filepath;
        modelName = split(mFilepath, dirSeparator)[$-1]; 
        // create mSpriteStack from directory:
        mSpriteStack = new P3DSpriteStack();
        // parse JSON to get whole stack VAngle and HAngle
        JSONValue fileContents = parseJSONFromFile(buildPath(filepath, "spec.json"));
        mSpriteStack.setVAngle(jsonToInt(fileContents["stackVAngle"]));
        mSpriteStack.setHAngle(jsonToInt(fileContents["stackHAngle"]));
        // use the JSON file to determine the number of layers to parse
        int numLayers = jsonToInt(fileContents["numLayers"]);
        JSONValue layerArr = fileContents["layers"];
        writeln("Parsing "~to!string(numLayers)~" layers...");
        for(int i = 0; i < numLayers; i++){
            // create a normal map and image texture (both png) 
            JSONValue layer = layerArr[i];
            string layerID = jsonToString(layer["id"]);
            // create a P3D slice
            P3DSlice slice = new P3DSlice(
                buildPath(filepath, "ImageData", layerID~".png"),
                buildPath(filepath, "NormalData", layerID~".png"),
                jsonToFloat(layer["x"]),
                jsonToFloat(layer["y"]),
                jsonToFloat(layer["z"]),
                jsonToInt(layer["vAngle"]),
                jsonToInt(layer["hAngle"])
            );
            // add slice to sprite stack
            mSpriteStack.addSlice(slice);
        }

    }
    void initialize(){
        // initializes textures and other info once OpenGL 
        // context has been opened
        mSpriteStack.loadTextures();
    }
    void setVAngle(int vAngle){
        mSpriteStack.mVAngle = vAngle;
    }
    void setHAngle(int hAngle){
        mSpriteStack.mHAngle = hAngle;
    }
    int getVAngle(){
        return mSpriteStack.mVAngle;
    }
    int getHAngle(){
        return mSpriteStack.mHAngle;
    }
    void addLight(P3DLight light){
        mLights ~= light;
    }
}

class P3DScene{
    /* To be implemented later, time permitting. */
}

bool validateFolder(string filePath){
    /* Helper function that throws an error
    if the filepath submitted IS NOT a folder
    or if it fails to meet the following:
    - Contain an ImageData & NormalData folder with at least 1 png file,
    and files of no other types
    - ImageData and NormalData need to have equal numbers of files.
    - Contains a Spec folder with a spec.json file
    */
    writeln("does not actually validate the file path yet!");
    return true;
}
P3DObj loadFolder(string filepath){
    /* Loads a P3DObj given a filepath to a valid P3DObj folder.
    */
    while(!validateFolder(filepath)){}
    writeln("Attempting to parse "~filepath);
    P3DObj res = new P3DObj(filepath);
    writeln("Successfully parsed folder at: "~filepath);

    return res;
}