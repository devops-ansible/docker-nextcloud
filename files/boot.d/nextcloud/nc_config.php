#!/usr/bin/env php
<?php
/**
 * Sync NC_* environment variables into a Nextcloud config.php file.
 *
 * Rules:
 *   - Env vars are prefixed with "NC_" (uppercase).
 *   - The remainder of the name is the exact config key, with "." encoded as "__".
 *     e.g. NC_htaccess__RewriteBase  => key "htaccess.RewriteBase" (case preserved)
 *   - Ignore NC_APPS
 *   - Values can be JSON, unquoted booleans/null, numbers, single-quoted strings, or plain strings.
 *   - Only write & back up if something actually changed.
 *
 * Usage:
 *   php nc_config.php /path/to/nextcloud/config/config.php
 */

if (PHP_SAPI !== 'cli') {
    fwrite(STDERR, "Run this script from the command line.\n");
    exit(1);
}

$configFile = $argv[1] ?? null;
if (!$configFile) {
    fwrite(STDERR, "Usage: php " . basename(__FILE__) . " /path/to/config.php\n");
    exit(1);
}
if (!is_file($configFile) || !is_readable($configFile)) {
    fwrite(STDERR, "Config file not found or not readable: {$configFile}\n");
    exit(1);
}

/** Load $CONFIG from file in isolated scope */
$CONFIG = [];
(static function($file) use (&$CONFIG) {
    $CONFIG = [];
    include $file;
    if (!isset($CONFIG) || !is_array($CONFIG)) {
        throw new RuntimeException("The file does not define \$CONFIG as an array.");
    }
    $GLOBALS['CONFIG'] = $CONFIG;
})($configFile);

$originalConfig = $CONFIG; // for diff comparison

/** Smart parser for env values */
function parse_nc_env_value(string $raw) {
    $trim = trim($raw);

    // 1) JSON (objects/arrays/"strings"/numbers/bools/null)
    $decoded = json_decode($trim, true);
    if (json_last_error() === JSON_ERROR_NONE) {
        return $decoded;
    }

    // 2) Unquoted booleans / null
    $lc = strtolower($trim);
    if ($lc === 'true')  return true;
    if ($lc === 'false') return false;
    if ($lc === 'null')  return null;

    // 3) Numbers (int/float, incl. scientific)
    if (preg_match('/^-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?$/', $trim)) {
        return (strpos($trim, '.') !== false || stripos($trim, 'e') !== false)
            ? (float)$trim
            : (int)$trim;
    }

    // 4) Single-quoted strings: 'foo' -> foo
    if (strlen($trim) >= 2 && $trim[0] === "'" && substr($trim, -1) === "'") {
        return substr($trim, 1, -1);
    }

    // 5) Fallback: raw string
    return $raw;
}

/** Apply NC_D_* env vars */
$env = getenv();
if (!is_array($env)) {
    fwrite(STDERR, "Could not read environment variables.\n");
    exit(1);
}

foreach ($env as $name => $value) {
    if (strpos($name, 'NC_D_') !== 0) continue;

    // Skip control vars
    if (in_array($name, ["NC_D_APPS", "NC_D_USER", "NC_D_BASE_PATH"])) continue;

    $rest = substr($name, 5);
    if ($rest === '' || $rest === false) continue;

    $key = str_replace('__', '.', $rest);

    $CONFIG[$key] = parse_nc_env_value((string)$value);
}

/** Detect changes before writing */
if ($CONFIG == $originalConfig) {
    echo "No changes detected — configuration already up to date.\n";
    exit(0);
}

/** Write back with backup (only when changed) */
$export = "<?php\n\$CONFIG = " . var_export($CONFIG, true) . ";\n";

$backupFile = $configFile . '.bak.' . date('YmdHis');
if (!@copy($configFile, $backupFile)) {
    fwrite(STDERR, "Warning: failed to create backup file {$backupFile}. Proceeding anyway.\n");
}

$dir = dirname($configFile);
$tmp = tempnam($dir, 'nc_cfg_');
if ($tmp === false) {
    fwrite(STDERR, "Failed to create a temporary file in {$dir}.\n");
    exit(1);
}
if (file_put_contents($tmp, $export) === false) {
    @unlink($tmp);
    fwrite(STDERR, "Failed to write updated config to temp file.\n");
    exit(1);
}
if (!@rename($tmp, $configFile)) {
    @unlink($tmp);
    fwrite(STDERR, "Failed to replace original config file. Check permissions.\n");
    exit(1);
}

echo "Config updated successfully.\n";
echo "Backup saved to {$backupFile}\n";