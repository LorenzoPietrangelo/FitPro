<?php



declare(strict_types=1);

// ── Credenziali DB ───────────────────────────────────────────────────────────
// In produzione su InfinityFree sostituisci i valori qui sotto con quelli
// forniti dal pannello di controllo (MySQL Databases).
// In sviluppo locale puoi usare variabili d'ambiente per non toccare questo file.
define('DB_HOST', getenv('DB_HOST') ?: 'sql308.infinityfree.com'); // ← host InfinityFree
define('DB_PORT', getenv('DB_PORT') ?: '3306');
define('DB_NAME', getenv('DB_NAME') ?: 'if0_42228033_fitprodb2');    // ← nome DB InfinityFree
define('DB_USER', getenv('DB_USER') ?: 'if0_42228033');            // ← utente DB InfinityFree
define('DB_PASS', getenv('DB_PASS') ?: 'bElpOJ5KqSh4OIc');            // ← password DB

function db(): PDO
{
    static $pdo = null;
    if ($pdo instanceof PDO) {
        return $pdo;
    }

    $dsn = sprintf(
        'mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4',
        DB_HOST,
        DB_PORT,
        DB_NAME
    );

    $pdo = new PDO($dsn, DB_USER, DB_PASS, [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES   => false,
    ]);

    return $pdo;
}

// Query helpers
function dbFetchAll(string $sql, array $params = []): array
{
    $stmt = db()->prepare($sql);
    $stmt->execute($params);
    return $stmt->fetchAll();
}

function dbFetchOne(string $sql, array $params = []): ?array
{
    $stmt = db()->prepare($sql);
    $stmt->execute($params);
    $row = $stmt->fetch();
    return $row === false ? null : $row;
}

function dbExecute(string $sql, array $params = []): int
{
    $stmt = db()->prepare($sql);
    $stmt->execute($params);
    return $stmt->rowCount();
}

// File asset deletion - safe path validation
function dbDeleteAssetFile(?string $url): void
{
    if (!$url || !defined('ROOT')) {
        return;
    }

    $path = $url;
    if (defined('BASE_URL') && str_starts_with($path, BASE_URL)) {
        $path = substr($path, strlen(BASE_URL));
    }

    $fullPath  = ROOT . '/' . ltrim($path, '/');
    $assetsDir = ROOT . '/assets/';

    // Block path traversal
    if (!str_starts_with($fullPath, $assetsDir)) {
        return;
    }

    if (is_file($fullPath)) {
        @unlink($fullPath);
    }
}
