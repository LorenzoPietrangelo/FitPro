<?php



declare(strict_types=1);
require_once dirname(__DIR__) . '/configs/bootstrap.php';

requireLogin();

$user   = currentUser();
$action = $_GET['action'] ?? null;

if ($_SERVER['REQUEST_METHOD'] === 'POST' && $action === 'rate') {
    verifyCsrf();
    $productId = (int) ($_POST['product_id'] ?? 0);
    $rating    = (int) ($_POST['rating']     ?? 0);

    $purchasedIds = (array) ($user['purchased'] ?? []);
    if (
        $productId > 0 && $rating >= 1 && $rating <= 5
        && in_array($productId, $purchasedIds, true)
    ) {
        dbSaveRating((int) $user['id'], $productId, $rating);
    }
    redirect('/purchased');
}

$standardPrograms = dbGetUserPurchasedProducts((int) $user['id']);
$customSchedules = dbGetUserCompletedCustomRequests((int) $user['id']);
$pendingRequests = array_filter(
    dbGetUserRequests((int) $user['id']),
    fn($r) => $r['status'] === 'pending'
);
$pendingRequests = array_values($pendingRequests);

render('purchased.tpl', 'I Miei Programmi – FitStore', [
    'standard_programs' => $standardPrograms,
    'custom_schedules'  => $customSchedules,
    'pending_requests'  => $pendingRequests,
    'user_ratings'      => dbGetUserRatings((int) $user['id']),
    'success_message'   => !empty($_GET['success'])
        ? 'Acquisto completato! I tuoi programmi sono ora disponibili qui.'
        : '',
]);
