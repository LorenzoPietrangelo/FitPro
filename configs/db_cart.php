<?php



declare(strict_types=1);

function sessionCartIds(): array
{
    $ids = $_SESSION['cart'] ?? [];
    return array_values(array_filter(array_map('intval', $ids)));
}

function dbGetCartItems(): array
{
    $ids = sessionCartIds();
    if ($ids === []) {
        return [];
    }

    $placeholders = implode(',', array_fill(0, count($ids), '?'));
    $rows = dbFetchAll(
        "SELECT p.id_prodotto AS id, p.titolo AS title,
                p.descrizione AS `desc`, p.prezzo AS price,
                p.immagine_path AS img
         FROM prodotto p
         WHERE p.id_prodotto IN ($placeholders)
         ORDER BY p.id_prodotto ASC",
        $ids
    );

    $indexed = [];
    foreach ($rows as $r) {
        $indexed[(int) $r['id']] = $r;
    }

    $result = [];
    foreach ($ids as $pid) {
        if (isset($indexed[$pid])) {
            $result[] = $indexed[$pid];
        }
    }

    return $result;
}

function dbAddCartItem(int $productId): void
{
    $ids = sessionCartIds();
    if (!in_array($productId, $ids, true)) {
        $ids[] = $productId;
    }
    $_SESSION['cart'] = $ids;
}

function dbRemoveCartItem(int $productId): void
{
    $ids = sessionCartIds();
    $_SESSION['cart'] = array_values(array_filter($ids, fn($id) => $id !== $productId));
}

function dbClearCart(): void
{
    $_SESSION['cart']   = [];
    $_SESSION['coupon'] = null;
}

function dbGetCartCount(): int
{
    return count(sessionCartIds());
}

function dbSetCartCoupon(?array $coupon): void
{
    $_SESSION['coupon'] = $coupon;
}

function dbGetCartCoupon(): ?array
{
    $coupon = $_SESSION['coupon'] ?? null;
    if (!is_array($coupon) || empty($coupon['id'])) {
        return null;
    }
    return $coupon;
}

function dbGetCouponByCode(string $code): ?array
{
    $code = trim(strtoupper($code));
    if ($code === '') {
        return null;
    }

    $row = dbFetchOne(
        'SELECT id_coupon AS id, nome AS name,
                sconto AS discount, data_scadenza AS expires_at
         FROM coupon
         WHERE UPPER(nome) = :code
           AND (data_scadenza IS NULL OR data_scadenza >= CURDATE())
         LIMIT 1',
        [':code' => $code]
    );

    return $row ?: null;
}

function dbGetCoupons(): array
{
    return dbFetchAll(
        'SELECT id_coupon AS id, nome AS name,
                sconto AS discount, data_scadenza AS expires_at
         FROM coupon
         ORDER BY id_coupon DESC'
    );
}

function dbSaveCoupon(string $name, float $discount, ?string $expiresAt): int
{
    $discount = min(100.0, max(0.0, $discount));

    dbExecute(
        'INSERT INTO coupon (nome, sconto, data_scadenza) VALUES (:name, :discount, :expires)',
        [
            ':name'     => $name,
            ':discount' => $discount,
            ':expires'  => ($expiresAt !== '' && $expiresAt !== null) ? $expiresAt : null,
        ]
    );

    return (int) db()->lastInsertId();
}

function dbDeleteCoupon(int $id): void
{
    dbExecute('DELETE FROM coupon WHERE id_coupon = :id', [':id' => $id]);
}
