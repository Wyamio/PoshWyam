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

int GitCommand(string command, string workingDirectory = null) {
    Information("git " + command);
    var settings = new ProcessSettings { Arguments = command };
    if (workingDirectory != null) settings.WorkingDirectory = workingDirectory;
    return StartProcess("git", settings);
}

int GitClonePages() {
    if (DirectoryExists("./pages")) {
        return 0;
    }
    return GitCommand("clone " + gitPagesRepo + " -b " + gitPagesBranch + " pages");
}

int GitCommitPages() {
    var result = GitCommand("add .", "./pages");
    if (result != 0) {
        return result;
    }
    result = GitCommand("commit -m \"Publishing pages " + DateTime.Now + "\"", "./pages");
    return result;
}

int GitPushPages() {
    return GitCommand("push", "./pages");
}
