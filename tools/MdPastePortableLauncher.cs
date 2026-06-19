using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Web.Script.Serialization;
using System.Windows.Forms;

internal static class MdPastePortableLauncher
{
    private const string AppExeName = "MdPaste.exe";

    [STAThread]
    private static int Main()
    {
        try
        {
            string home = AppDomain.CurrentDomain.BaseDirectory.TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);
            string appExe = Path.Combine(home, AppExeName);
            string pandocExe = Path.Combine(home, "_internal", "pandoc", "pandoc.exe");

            if (!File.Exists(appExe))
            {
                ShowError("MdPaste.exe was not found. Keep the launcher, MdPaste.exe, and _internal in the same folder.");
                return 1;
            }

            if (!File.Exists(pandocExe))
            {
                ShowError("Bundled Pandoc was not found. Download the complete portable ZIP.");
                return 1;
            }

            if (IsSameMdPasteRunning(appExe))
            {
                return 0;
            }

            ConfigurePortableHome(home);

            var startInfo = new ProcessStartInfo(appExe)
            {
                WorkingDirectory = home,
                UseShellExecute = false,
            };
            Process.Start(startInfo);
            return 0;
        }
        catch (Exception ex)
        {
            ShowError("MdPaste portable launcher failed:\r\n" + ex.Message);
            return 1;
        }
    }

    private static bool IsSameMdPasteRunning(string appExe)
    {
        string expected = Path.GetFullPath(appExe);
        foreach (Process process in Process.GetProcessesByName("MdPaste"))
        {
            using (process)
            {
                try
                {
                    string runningPath = process.MainModule.FileName;
                    if (string.Equals(Path.GetFullPath(runningPath), expected, StringComparison.OrdinalIgnoreCase))
                    {
                        return true;
                    }
                }
                catch
                {
                    // Some protected processes can deny MainModule access; ignore and keep checking.
                }
            }
        }
        return false;
    }

    private static void ConfigurePortableHome(string home)
    {
        string roaming = Path.Combine(home, "portable-data", "Roaming");
        string local = Path.Combine(home, "portable-data", "Local");
        string configDir = Path.Combine(roaming, "PasteMD");
        string cacheDir = Path.Combine(home, "cache");
        string pandocPath = Path.Combine(home, "_internal", "pandoc", "pandoc.exe");
        string configPath = Path.Combine(configDir, "config.json");
        string markerPath = Path.Combine(configDir, ".portable-home");

        Directory.CreateDirectory(configDir);
        Directory.CreateDirectory(local);
        Directory.CreateDirectory(cacheDir);

        Environment.SetEnvironmentVariable("APPDATA", roaming);
        Environment.SetEnvironmentVariable("LOCALAPPDATA", local);
        Environment.SetEnvironmentVariable(
            "PATH",
            home + ";" + Path.Combine(home, "_internal") + ";" + Path.Combine(home, "_internal", "pandoc") + ";" + Environment.GetEnvironmentVariable("PATH")
        );

        if (!NeedsPortableConfigRefresh(configPath, markerPath, home, pandocPath, cacheDir))
        {
            return;
        }

        var serializer = new JavaScriptSerializer();
        var config = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);
        if (File.Exists(configPath))
        {
            string existingJson = File.ReadAllText(configPath, Encoding.UTF8);
            if (!string.IsNullOrWhiteSpace(existingJson))
            {
                object parsed = serializer.DeserializeObject(existingJson);
                var parsedDict = parsed as Dictionary<string, object>;
                if (parsedDict != null)
                {
                    config = new Dictionary<string, object>(parsedDict, StringComparer.OrdinalIgnoreCase);
                }
            }
        }

        config["pandoc_path"] = pandocPath;
        config["save_dir"] = cacheDir;
        config["auto_start"] = false;
        config["notify"] = false;
        config["startup_notify"] = false;
        SetDefault(config, "hotkey", "<ctrl>+<alt>+b");
        SetDefault(config, "enable_latex_replacements", true);
        SetDefault(config, "fix_single_dollar_block", true);
        SetDefault(config, "convert_standard_latex_delimiters", true);

        var utf8NoBom = new UTF8Encoding(false);
        File.WriteAllText(configPath, serializer.Serialize(config), utf8NoBom);
        File.WriteAllText(markerPath, home, utf8NoBom);
    }

    private static bool NeedsPortableConfigRefresh(string configPath, string markerPath, string home, string pandocPath, string cacheDir)
    {
        if (!File.Exists(configPath) || !File.Exists(markerPath))
        {
            return true;
        }

        string markerHome = File.ReadAllText(markerPath, Encoding.UTF8).Trim();
        if (!string.Equals(markerHome, home, StringComparison.OrdinalIgnoreCase))
        {
            return true;
        }

        try
        {
            var serializer = new JavaScriptSerializer();
            object parsed = serializer.DeserializeObject(File.ReadAllText(configPath, Encoding.UTF8));
            var config = parsed as Dictionary<string, object>;
            if (config == null)
            {
                return true;
            }

            return !ConfigValueMatches(config, "pandoc_path", pandocPath)
                || !ConfigValueMatches(config, "save_dir", cacheDir)
                || !ConfigBoolMatches(config, "notify", false)
                || !ConfigBoolMatches(config, "startup_notify", false);
        }
        catch
        {
            return true;
        }
    }

    private static bool ConfigValueMatches(Dictionary<string, object> config, string key, string expected)
    {
        object value;
        if (!config.TryGetValue(key, out value) || value == null)
        {
            return false;
        }

        return string.Equals(value.ToString(), expected, StringComparison.OrdinalIgnoreCase);
    }

    private static bool ConfigBoolMatches(Dictionary<string, object> config, string key, bool expected)
    {
        object value;
        if (!config.TryGetValue(key, out value) || value == null)
        {
            return false;
        }

        if (value is bool)
        {
            return (bool)value == expected;
        }

        bool parsed;
        return bool.TryParse(value.ToString(), out parsed) && parsed == expected;
    }

    private static void SetDefault(Dictionary<string, object> config, string key, object value)
    {
        if (!config.ContainsKey(key))
        {
            config[key] = value;
        }
    }

    private static void ShowError(string message)
    {
        MessageBox.Show(message, "MdPaste Portable", MessageBoxButtons.OK, MessageBoxIcon.Error);
    }
}
