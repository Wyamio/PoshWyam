#addin "Cake.PowerShell"
#addin "Cake.FileHelpers"
#addin "Cake.Git"

var target = Argument("target", "Default");
var nugetUrl = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe";
string version = null;
var output = MakeAbsolute(Directory("./output"));
var module = output.Combine("PoshWyam");

Task("Version")
    .Does(() =>
{
    version = GitVersion().MajorMinorPatch;
    Information("Version: {0}", version);
});

Task("Clean")
    .Does(() =>
{
    CleanDirectory(output);
    CleanDirectory(module);
});

Task("Build")
    .IsDependentOn("Version")
    .IsDependentOn("Clean")
    .Does(() =>
{
    CopyFiles("./PoshWyam/**/*", module, true);
    ReplaceTextInFiles(module.Combine("PoshWyam.psd1").FullPath, "ModuleVersion = '0.1'", string.Format("ModuleVersion = '{0}'", version));
    var nuget = Context.Tools.Resolve("nuget.exe");
    if (nuget == null)
    {
        Information("Downloading nuget.exe");
        nuget = MakeAbsolute(File("./tools/nuget.exe"));
        DownloadFile(nugetUrl, nuget);
    }
    StartProcess(nuget, new ProcessSettings()
        .WithArguments(args => args.Append("install")
            .Append("wyam")
            .Append("-Prerelease")
            .Append("-ExcludeVersion")
            .Append("-OutputDirectory")
            .AppendQuoted(module.FullPath)));
    StartProcess(nuget, new ProcessSettings()
        .WithArguments(args => args.Append("install")
            .Append("YamlDotNet")
            //.Append("-Prerelease")
            .Append("-ExcludeVersion")
            .Append("-OutputDirectory")
            .AppendQuoted(output.FullPath)));
    CreateDirectory("./output/PoshWyam/lib");
    Information("Copying library files");
    CopyFiles("./output/YamlDotNet/lib/portable*/**/YamlDotNet.*", "./output/PoshWyam/lib");
});

Task("Publish")
    .IsDependentOn("Build")
    .Does(() =>
{
    string repository = "PSGallery";
    if (BuildSystem.AppVeyor.IsRunningOnAppVeyor)
    {
        var branch = GitBranchCurrent(".").FriendlyName;
        if (branch != "master")
        {
            // TODO: Make sure myget repository exists
            branch = "myget";
        }
    }
    else
    {
        repository = "local";
    }
    Information("Publishing to repository {0}.", repository);
    var settings = new PowershellSettings()
        .WithArguments(args => args.Append("-Path")
            .AppendQuoted(module.FullPath)
            .Append("-Repository")
            .AppendQuoted(repository));
    StartPowershellScript("Publish-Module", settings);
});

Task("Default")
    .IsDependentOn("Build");

RunTarget(target);