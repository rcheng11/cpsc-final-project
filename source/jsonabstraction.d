/*!
@brief Abstracts common data conversions to from JSON and initialization using std.json.
(My own code, taken from a previous project)
*/
module jsonabstraction;

/// \cond DOXYGEN_SHOULD_SKIP_THIS
import std.stdio;
import std.conv;
import std.array;
import std.algorithm;
import std.json;
/// \endcond

JSONValue parseJSONFromFile(string jsonFilePath){
    assert(jsonFilePath[$ - 4 .. $] == "json", jsonFilePath ~ " is not a JSON file.");
    auto myFile = File(jsonFilePath, "r");
    auto jsonFileContents = myFile.byLine.joiner("\n");
    return parseJSON(jsonFileContents);
}
int jsonToInt(JSONValue val){
    return cast(int)val.integer;
}
string jsonToString(JSONValue val){
    return val.to!string.strip('"');
}
string jsonToFilePath(JSONValue val){
    return val.to!string.strip('"').strip('\\');
}
int[] jsonToIntArray(JSONValue val){
    return val.array.map!((v) {
        return jsonToInt(v);
    }).array;
}
string[] jsonGetAllKeys(JSONValue val){
    return val.object.keys().array;
}