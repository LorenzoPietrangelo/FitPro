<?php



declare(strict_types=1);
require_once dirname(__DIR__) . '/configs/bootstrap.php';

requireAdmin();

$purchases = dbGetAdminPurchases();

$totalRevenue = array_sum(array_column($purchases, 'total'));

render('admin_purchases.tpl', 'Gestione Acquisti – FitStore Admin', [
    'purchases'     => $purchases,
    'total_revenue' => $totalRevenue,
]);
