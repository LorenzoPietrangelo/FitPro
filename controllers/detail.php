<?php

declare(strict_types=1);
require_once dirname(__DIR__) . '/configs/bootstrap.php';

$type = $_GET['type'] ?? 'program';
$id = isset($_GET['id']) ? (int) $_GET['id'] : 0;

switch ($type) {
    case 'custom':
        $item = dbGetServiceByCategory('custom');
        $backRoute = 'home';
        if (!$item) {
            http_response_code(404);
            exit('<h1>404</h1>');
        }
        break;

    default:
        $type = 'program';
        $item = dbGetProgramById($id);
        $backRoute = 'all-programs';
        if (!$item) {
            http_response_code(404);
            exit('<h1>404 – Non trovato</h1>');
        }
        break;
}

render('detail.tpl', ($item['title'] ?? '') . ' – FitStore', [
    'item'       => $item,
    'type'       => $type,
    'back_route' => $backRoute,
]);
