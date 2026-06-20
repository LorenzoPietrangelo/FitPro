<?php



declare(strict_types=1);
require_once dirname(__DIR__) . '/configs/bootstrap.php';

$action = $_GET['action'] ?? 'view';

if ($action === 'add' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    requireLogin();
    verifyCsrf();

    $type = $_POST['type'] ?? '';
    $id   = isset($_POST['id']) ? (int) $_POST['id'] : 0;

    if ($type === 'custom') {
        $item = dbGetServiceByCategory('custom');
    } else {
        $item = ($type === 'program' && $id > 0) ? dbGetProgramById($id) : null;
    }

    if ($item && isset($item['id']) && (int) $item['id'] > 0) {
        dbAddCartItem((int) $item['id']);
    }

    redirect('/cart');
}

if ($action === 'remove' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    requireLogin();
    verifyCsrf();

    $productId = isset($_POST['product_id']) ? (int) $_POST['product_id'] : 0;
    if ($productId > 0) {
        dbRemoveCartItem($productId);
    }

    redirect('/cart');
}

if ($action === 'toggle-mobile') {
    $_SESSION['mobile_menu_open'] = !($_SESSION['mobile_menu_open'] ?? false);
    redirect('/home');
}

if ($action === 'coupon' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    requireLogin();
    verifyCsrf();

    $code   = trim($_POST['coupon'] ?? '');
    $coupon = dbGetCouponByCode($code);

    // dbSetCartCoupon ora scrive in sessione, non nel DB
    dbSetCartCoupon($coupon ?: null);

    redirect('/cart');
}

if ($action === 'checkout' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    requireLogin();
    verifyCsrf();

    $user = currentUser();
    $cart = dbGetCartItems();

    if (empty($cart)) {
        redirect('/cart');
    }

    $orderId = dbCheckoutCart((int) $user['id']);
    dbRefreshUserSessionGroups((int) $user['id']);
    $_SESSION['user']['purchased'] = dbGetUserPurchasedIds((int) $user['id']);
    redirect('/purchased?success=1');
}

requireLogin();

$cart   = dbGetCartItems();
$coupon = dbGetCartCoupon();

$subtotal = array_sum(array_column($cart, 'price'));
$discount = 0.0;
if ($coupon && isset($coupon['discount'])) {
    $discount = round($subtotal * ((float) $coupon['discount']) / 100, 2);
}
$total = max(0.0, $subtotal - $discount);

render('cart.tpl', 'Carrello – FitStore', [
    'cart_items'      => $cart,
    'subtotal'        => $subtotal,
    'discount'        => $discount,
    'total'           => $total,
    'coupon_value'    => $coupon['name'] ?? '',
    'checkout_action' => BASE_URL . '/cart?action=checkout',
    'coupon_action'   => BASE_URL . '/cart?action=coupon',
]);
