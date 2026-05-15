<?php

declare(strict_types=1);

$docRoot  = rtrim(str_replace('\\', '/', $_SERVER['DOCUMENT_ROOT']), '/');
$projPath = rtrim(str_replace('\\', '/', __DIR__), '/');
$baseUrl  = str_replace($docRoot, '', $projPath);

define('BASE_URL', $baseUrl);
require_once __DIR__ . '/configs/bootstrap.php';

// Estrae e normalizza la route
$fullPath = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) ?? '/';
$fullPath = urldecode($fullPath);
$route = substr($fullPath, strlen(BASE_URL));
$route = '/' . ltrim($route, '/');
$route = rtrim($route, '/') ?: '/';


// Parametri GET automatici per route specifiche
$autoParams = [
    '/custom'   => ['type' => 'custom'],
    '/program'  => ['type' => 'program'],
    '/register' => ['mode' => 'register'],
];

if (isset($autoParams[$route])) {
    foreach ($autoParams[$route] as $key => $value) {
        if (!isset($_GET[$key])) $_GET[$key] = $value;
    }
}


// Tabella di routing
$routes = [
    '/'                => 'home.php',
    '/home'            => 'home.php',
    '/all-programs'    => 'all_programs.php',
    '/program'         => 'detail.php',
    '/custom'          => 'detail.php',
    '/login'           => 'login.php',
    '/register'        => 'login.php',
    '/logout'          => 'logout.php',
    '/cart'            => 'cart.php',
    '/purchased'       => 'purchased.php',
    '/questionnaire'   => 'questionnaire.php',
    '/admin-content'   => 'admin_content.php',
    '/admin-purchases' => 'admin_purchases.php',
    '/admin-requests'  => 'admin_requests.php',
];


// Carica il controller appropriato
if (isset($routes[$route])) {
    $file = __DIR__ . '/controllers/' . $routes[$route];
    if (file_exists($file)) {
        require $file;
        exit;
    }
}

// 404
http_response_code(404);
?>
<!DOCTYPE html>
<html lang="it">

<head>
    <meta charset="UTF-8">
    <title>404 – Pagina non trovata</title>
    <style>
        body {
            font-family: sans-serif;
            max-width: 640px;
            margin: 80px auto;
            color: #1e293b;
        }

        h1 {
            color: #e53e3e;
        }

        code {
            background: #f1f5f9;
            padding: 2px 8px;
            border-radius: 4px;
            font-size: 0.95em;
        }

        li {
            margin-bottom: 4px;
        }

        a {
            color: #059669;
        }
    </style>
</head>

<body>
    <h1>404</h1>
    <p>Pagina non trovata: <code><?= htmlspecialchars($route) ?></code></p>
    <ul>
        <?php foreach ($routes as $r => $c): ?>
            <li><a href="<?= htmlspecialchars(BASE_URL . $r) ?>"><?= htmlspecialchars(BASE_URL . $r) ?></a></li>
        <?php endforeach; ?>
    </ul>
</body>

</html>