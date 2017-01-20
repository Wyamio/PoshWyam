#tool nuget:?package=Wyam&prerelease
#addin nuget:?package=Cake.Wyam&prerelease

var recipe = "Blog";
var theme = "%THEME%";
var isLocal = BuildSystem.IsLocalBuild;
var target = Argument("target", isLocal ? "Default" : "CIBuild");

Task("Clean")
    .Does(() => {
        if (DirectoryExists("./output")) DeleteDirectory("./output", true);
    });

Task("Build")
    .IsDependentOn("Clean")
    .Does(() => {
        Wyam(CreateSettings(false));
    });
    
Task("Preview")
    .Does(() => {
        Wyam(CreateSettings(true));        
    });
    
Task("Publish")
    .IsDependentOn("Build")
    .Does(() =>
    {
    });

Task("Default")
    .IsDependentOn("Build");    
    
RunTarget(target);

WyamSettings CreateSettings(bool preview)
{
    return new WyamSettings {
        Recipe = recipe,
        Theme = theme,
        Preview = preview,
        Watch = preview
    };
}
