<?php



declare(strict_types=1);

function dbGetPrograms(): array
{
    $rows = dbFetchAll(
        "SELECT
            p.id_prodotto AS id,
            p.titolo      AS title,
            p.descrizione AS `desc`,
            p.prezzo      AS price,
            p.immagine_path AS img,
            p.file_path,
            COALESCE(r.rating,  0) AS rating,
            COALESCE(r.reviews, 0) AS reviews,
            MAX(CASE WHEN cp.categoria LIKE 'days:%'
                THEN SUBSTRING(cp.categoria, 6) END) AS days,
            MAX(CASE WHEN cp.categoria LIKE 'goal:%'
                THEN SUBSTRING(cp.categoria, 6) END) AS goal,
            MAX(CASE WHEN cp.categoria LIKE 'level:%'
                THEN SUBSTRING(cp.categoria, 7) END) AS level
         FROM prodotto p
         LEFT JOIN categoria_prodotto cp ON cp.id_prodotto = p.id_prodotto
         LEFT JOIN (
             SELECT id_prodotto,
                    AVG(valore_recensioni) AS rating,
                    COUNT(*)              AS reviews
             FROM recensioni
             GROUP BY id_prodotto
         ) r ON r.id_prodotto = p.id_prodotto
         WHERE NOT EXISTS (
             SELECT 1 FROM categoria_prodotto c
             WHERE c.id_prodotto = p.id_prodotto
               AND c.categoria IN ('coaching','custom')
         )
         GROUP BY p.id_prodotto, p.titolo, p.descrizione,
                  p.prezzo, p.immagine_path, p.file_path,
                  r.rating, r.reviews
         ORDER BY p.id_prodotto ASC"
    );

    foreach ($rows as &$row) {
        $row['rating']  = (float) ($row['rating']  ?? 0);
        $row['reviews'] = (int)   ($row['reviews'] ?? 0);
        $row['days']    = (string) ($row['days']   ?? '');
        $row['goal']    = (string) ($row['goal']   ?? '');
        $row['level']   = (string) ($row['level']  ?? '');
    }
    unset($row);

    return $rows;
}

function dbGetProgramById(int $id): ?array
{
    $row = dbFetchOne(
        "SELECT
            p.id_prodotto AS id,
            p.titolo      AS title,
            p.descrizione AS `desc`,
            p.prezzo      AS price,
            p.immagine_path AS img,
            p.file_path,
            COALESCE(r.rating,  0) AS rating,
            COALESCE(r.reviews, 0) AS reviews,
            MAX(CASE WHEN cp.categoria LIKE 'days:%'
                THEN SUBSTRING(cp.categoria, 6) END) AS days,
            MAX(CASE WHEN cp.categoria LIKE 'goal:%'
                THEN SUBSTRING(cp.categoria, 6) END) AS goal,
            MAX(CASE WHEN cp.categoria LIKE 'level:%'
                THEN SUBSTRING(cp.categoria, 7) END) AS level
         FROM prodotto p
         LEFT JOIN categoria_prodotto cp ON cp.id_prodotto = p.id_prodotto
         LEFT JOIN (
             SELECT id_prodotto,
                    AVG(valore_recensioni) AS rating,
                    COUNT(*)              AS reviews
             FROM recensioni
             GROUP BY id_prodotto
         ) r ON r.id_prodotto = p.id_prodotto
         WHERE p.id_prodotto = :id
         GROUP BY p.id_prodotto, p.titolo, p.descrizione,
                  p.prezzo, p.immagine_path, p.file_path,
                  r.rating, r.reviews",
        [':id' => $id]
    );

    if (!$row) {
        return null;
    }

    $row['rating']  = (float)  ($row['rating']  ?? 0);
    $row['reviews'] = (int)    ($row['reviews'] ?? 0);
    $row['days']    = (string) ($row['days']    ?? '');
    $row['goal']    = (string) ($row['goal']    ?? '');
    $row['level']   = (string) ($row['level']   ?? '');

    return $row;
}

function dbGetServiceByCategory(string $category): ?array
{
    $row = dbFetchOne(
        "SELECT p.id_prodotto AS id, p.titolo AS title,
                p.descrizione AS `desc`, p.prezzo AS price,
                p.immagine_path AS img
         FROM prodotto p
         INNER JOIN categoria_prodotto c ON c.id_prodotto = p.id_prodotto
         WHERE c.categoria = :category
         LIMIT 1",
        [':category' => $category]
    );

    return $row ?: [
        'id'    => 0,
        'title' => '',
        'desc'  => '',
        'price' => 0.0,
        'img'   => '',
    ];
}

function dbSaveProgram(array $data, ?int $id = null): int
{
    if ($id) {
        dbExecute(
            'UPDATE prodotto
             SET titolo = :title, descrizione = :desc, prezzo = :price,
                 immagine_path = :img, file_path = :file
             WHERE id_prodotto = :id',
            [
                ':title' => $data['title'],
                ':desc'  => $data['desc'],
                ':price' => $data['price'],
                ':img'   => $data['img'],
                ':file'  => $data['file_path'],
                ':id'    => $id,
            ]
        );
        return $id;
    }

    dbExecute(
        'INSERT INTO prodotto (titolo, descrizione, prezzo, immagine_path, file_path, tipo)
         VALUES (:title, :desc, :price, :img, :file, :tipo)',
        [
            ':title' => $data['title'],
            ':desc'  => $data['desc'],
            ':price' => $data['price'],
            ':img'   => $data['img'],
            ':file'  => $data['file_path'],
            ':tipo'  => 'scheda',
        ]
    );

    return (int) db()->lastInsertId();
}

function dbSetProgramCategories(int $productId, string $days, string $goal, string $level): void
{
    dbExecute('DELETE FROM categoria_prodotto WHERE id_prodotto = :id', [':id' => $productId]);

    $tags = [
        $days  !== '' ? 'days:'  . trim($days)  : null,
        $goal  !== '' ? 'goal:'  . trim($goal)  : null,
        $level !== '' ? 'level:' . trim($level) : null,
    ];

    foreach (array_filter($tags) as $tag) {
        dbExecute(
            'INSERT INTO categoria_prodotto (id_prodotto, categoria) VALUES (:id, :cat)',
            [':id' => $productId, ':cat' => $tag]
        );
    }
}

function dbSaveService(string $category, array $data): int
{
    $existing = dbFetchOne(
        'SELECT p.id_prodotto AS id
         FROM prodotto p
         INNER JOIN categoria_prodotto c ON c.id_prodotto = p.id_prodotto
         WHERE c.categoria = :cat
         LIMIT 1',
        [':cat' => $category]
    );

    if ($existing && (int) $existing['id'] > 0) {
        $id = (int) $existing['id'];
        dbExecute(
            'UPDATE prodotto
             SET titolo = :title, descrizione = :desc,
                 prezzo = :price, immagine_path = :img
             WHERE id_prodotto = :id',
            [
                ':title' => $data['title'],
                ':desc'  => $data['desc'],
                ':price' => $data['price'],
                ':img'   => $data['img'],
                ':id'    => $id,
            ]
        );
        return $id;
    }

    dbExecute(
        'INSERT INTO prodotto (titolo, descrizione, prezzo, immagine_path, tipo)
         VALUES (:title, :desc, :price, :img, :tipo)',
        [
            ':title' => $data['title'],
            ':desc'  => $data['desc'],
            ':price' => $data['price'],
            ':img'   => $data['img'],
            ':tipo'  => $category,
        ]
    );

    $newId = (int) db()->lastInsertId();
    dbExecute(
        'INSERT INTO categoria_prodotto (id_prodotto, categoria) VALUES (:id, :cat)',
        [':id' => $newId, ':cat' => $category]
    );

    return $newId;
}

function dbDeleteProgram(int $id): void
{
    $row = dbFetchOne(
        'SELECT immagine_path AS img, file_path FROM prodotto WHERE id_prodotto = :id',
        [':id' => $id]
    );

    if ($row) {
        dbDeleteAssetFile($row['img']       ?? null);
        dbDeleteAssetFile($row['file_path'] ?? null);
    }

    dbExecute('DELETE FROM categoria_prodotto WHERE id_prodotto = :id', [':id' => $id]);
    dbExecute('DELETE FROM prodotto WHERE id_prodotto = :id',           [':id' => $id]);
}

function dbGetProductIdByTitle(string $title): ?int
{
    $row = dbFetchOne(
        'SELECT id_prodotto AS id FROM prodotto
         WHERE LOWER(TRIM(titolo)) = LOWER(TRIM(:title))
         LIMIT 1',
        [':title' => $title]
    );

    return $row ? (int) $row['id'] : null;
}

function dbIsPremiumProduct(int $productId): bool
{
    $row = dbFetchOne(
        "SELECT 1 FROM categoria_prodotto
         WHERE id_prodotto = :id
           AND categoria IN ('coaching','custom')
         LIMIT 1",
        [':id' => $productId]
    );

    return (bool) $row;
}
