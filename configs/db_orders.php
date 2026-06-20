<?php



declare(strict_types=1);

function dbGetUserPurchasedIds(int $userId): array
{
    $rows = dbFetchAll(
        'SELECT id_prodotto FROM prodotti_acquistati WHERE id_utente = :uid',
        [':uid' => $userId]
    );
    return array_map('intval', array_column($rows, 'id_prodotto'));
}

function dbGetUserPurchasedProducts(int $userId): array
{
    $rows = dbFetchAll(
        "SELECT p.id_prodotto AS id, p.titolo AS title,
                p.descrizione AS `desc`, p.prezzo AS price,
                p.immagine_path AS img, p.file_path
         FROM prodotto p
         WHERE p.id_prodotto IN (
             SELECT id_prodotto FROM prodotti_acquistati WHERE id_utente = :uid
         )
         AND p.id_prodotto NOT IN (
             SELECT id_prodotto FROM categoria_prodotto
             WHERE categoria = 'custom'
         )
         ORDER BY p.id_prodotto ASC",
        [':uid' => $userId]
    );

    return $rows;
}

function dbSaveUserPurchases(int $userId, array $productIds): void
{
    $productIds = array_values(
        array_filter($productIds, fn($id) => is_numeric($id) && (int) $id > 0)
    );

    foreach ($productIds as $pid) {
        dbExecute(
            'INSERT IGNORE INTO prodotti_acquistati (id_utente, id_prodotto)
             VALUES (:uid, :pid)',
            [':uid' => $userId, ':pid' => (int) $pid]
        );
    }
}

function dbCheckoutCart(int $userId): int
{
    $cart = dbGetCartItems();
    if ($cart === []) {
        return 0;
    }

    $productIds = array_values(array_filter(array_map(fn($i) => (int) ($i['id'] ?? 0), $cart)));

    $subtotal = array_sum(array_column($cart, 'price'));
    $coupon   = dbGetCartCoupon();
    $discount = 0.0;
    if ($coupon && isset($coupon['discount'])) {
        $discount = round($subtotal * ((float) $coupon['discount']) / 100, 2);
    }
    $total = max(0.0, $subtotal - $discount);

    $pdo = db();
    $pdo->beginTransaction();

    try {
        dbExecute(
            'INSERT INTO ordine (id_utente, data, prezzo) VALUES (:uid, :date, :price)',
            [':uid' => $userId, ':date' => date('Y-m-d'), ':price' => $total]
        );
        $orderId = (int) $pdo->lastInsertId();

        foreach ($cart as $item) {
            $pid = (int) ($item['id'] ?? 0);
            if ($pid <= 0) continue;
            dbExecute(
                'INSERT INTO ordine_prodotto (id_ordine, id_prodotto) VALUES (:oid, :pid)',
                [':oid' => $orderId, ':pid' => $pid]
            );
        }

        dbSaveUserPurchases($userId, $productIds);
        dbCreatePendingRequestsForProducts($userId, $productIds);
        dbAssignGroupsForPurchasedProducts($userId, $productIds);

        $pdo->commit();

        // Pulisce il carrello solo dopo che la transazione è confermata
        dbClearCart();

        return $orderId;
    } catch (Throwable $e) {
        $pdo->rollBack();
        throw $e;
    }
}

function dbGetAdminPurchases(): array
{
    $rows = dbFetchAll(
        'SELECT o.id_ordine    AS id,
                o.data         AS date,
                o.prezzo       AS total,
                u.email        AS user,
                p.titolo       AS product_title,
                p.prezzo       AS product_price
         FROM ordine o
         JOIN utenti u           ON u.id_utente  = o.id_utente
         JOIN ordine_prodotto op ON op.id_ordine  = o.id_ordine
         JOIN prodotto p         ON p.id_prodotto = op.id_prodotto
         ORDER BY o.id_ordine DESC'
    );

    // Raggruppa: una entry per ordine, con array "products" contenente i prodotti
    $orders = [];
    foreach ($rows as $row) {
        $oid = (int) $row['id'];
        if (!isset($orders[$oid])) {
            $orders[$oid] = [
                'id'       => $oid,
                'date'     => $row['date'],
                'total'    => $row['total'],
                'user'     => $row['user'],
                'products' => [],
            ];
        }
        $orders[$oid]['products'][] = [
            'title' => $row['product_title'],
            'price' => (float) $row['product_price'],
        ];
    }

    return array_values($orders);
}
