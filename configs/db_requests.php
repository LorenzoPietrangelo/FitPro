<?php


declare(strict_types=1);

function dbSaveRequest(int $userId, int $productId, array $answers): int
{
    $payload = json_encode($answers, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);

    dbExecute(
        'INSERT INTO richieste (id_utente, id_prodotto, stato, answers_json)
         VALUES (:uid, :pid, :status, :answers)',
        [
            ':uid'     => $userId,
            ':pid'     => $productId,
            ':status'  => 'pending',
            ':answers' => $payload,
        ]
    );

    return (int) db()->lastInsertId();
}

function dbCreatePendingRequest(int $userId, int $productId): int
{
    dbExecute(
        'INSERT INTO richieste (id_utente, id_prodotto, stato, answers_json)
         VALUES (:uid, :pid, :status, :answers)',
        [
            ':uid'     => $userId,
            ':pid'     => $productId,
            ':status'  => 'pending',
            ':answers' => '{}',
        ]
    );

    return (int) db()->lastInsertId();
}

function dbCreatePendingRequestsForProducts(int $userId, array $productIds): array
{
    $createdIds = [];

    foreach ($productIds as $productId) {
        $productId = (int) $productId;
        if ($productId <= 0 || !dbIsPremiumProduct($productId)) {
            continue;
        }

        $createdIds[] = dbCreatePendingRequest($userId, $productId);
    }

    return $createdIds;
}

function dbGetRequestByIdForUser(int $requestId, int $userId): ?array
{
    $row = dbFetchOne(
        'SELECT r.id_richiesta AS id, r.id_utente AS user_id, r.id_prodotto AS product_id,
                r.stato, r.pdf_path, r.titolo_personalizzato, r.answers_json,
                p.titolo AS type
         FROM richieste r
         JOIN prodotto p ON p.id_prodotto = r.id_prodotto
         WHERE r.id_richiesta = :rid AND r.id_utente = :uid
         LIMIT 1',
        [':rid' => $requestId, ':uid' => $userId]
    );

    if (!$row) {
        return null;
    }

    $answers = json_decode((string) ($row['answers_json'] ?? ''), true);
    $row['answers'] = is_array($answers) ? $answers : [];
    $row['status'] = $row['stato'] ?? 'pending';
    $row['product_id'] = (int) ($row['product_id'] ?? 0);
    return $row;
}

function dbUpdateRequestAnswers(int $requestId, array $answers): void
{
    dbExecute(
        'UPDATE richieste
         SET answers_json = :answers
         WHERE id_richiesta = :id',
        [
            ':answers' => json_encode($answers, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES),
            ':id'      => $requestId,
        ]
    );
}

function dbCompleteRequest(int $requestId, string $pdfPath, string $titoloPersonalizzato): void
{
    dbExecute(
        'UPDATE richieste
         SET stato = :status,
             pdf_path = :pdf,
             titolo_personalizzato = :titolo
         WHERE id_richiesta = :id',
        [
            ':status' => 'completed',
            ':pdf'    => $pdfPath,
            ':titolo' => trim($titoloPersonalizzato),
            ':id'     => $requestId,
        ]
    );
}

function dbGetRequests(): array
{
    $rows = dbFetchAll(
        "SELECT r.id_richiesta AS id, r.stato, r.created_at,
                r.answers_json, r.pdf_path, r.titolo_personalizzato,
                u.email AS user, p.titolo AS type
         FROM richieste r
         JOIN utenti u   ON u.id_utente   = r.id_utente
         JOIN prodotto p ON p.id_prodotto = r.id_prodotto
         ORDER BY r.created_at DESC"
    );

    foreach ($rows as &$row) {
        $answers           = json_decode($row['answers_json'] ?? '', true);
        $row['answers']    = is_array($answers) ? $answers : [];
        $row['status']     = $row['stato'] ?? 'pending';
        $row['date']       = substr((string) ($row['created_at'] ?? ''), 0, 10);
        $row['download_link'] = $row['pdf_path'] ?? null;
        $row['titolo_personalizzato'] = $row['titolo_personalizzato'] ?? '';
    }
    unset($row);

    return $rows;
}

function dbGetUserRequests(int $userId): array
{
    $rows = dbFetchAll(
        "SELECT r.id_richiesta AS id, r.id_prodotto AS product_id, r.stato, r.pdf_path,
                r.titolo_personalizzato, r.answers_json, p.titolo AS type,
                p.immagine_path AS img
         FROM richieste r
         JOIN prodotto p ON p.id_prodotto = r.id_prodotto
         WHERE r.id_utente = :uid
         ORDER BY r.created_at DESC",
        [':uid' => $userId]
    );

    foreach ($rows as &$row) {
        $row['status']                = $row['stato'] ?? 'pending';
        $row['download_link']         = $row['pdf_path'] ?? null;
        $row['product_id']            = (int) ($row['product_id'] ?? 0);
        $row['titolo_personalizzato'] = $row['titolo_personalizzato'] ?? '';
        $row['display_title']         = trim((string) ($row['titolo_personalizzato'] ?? '')) !== ''
            ? (string) $row['titolo_personalizzato']
            : 'Scheda Personalizzata';
        $row['img']                   = (string) ($row['img'] ?? '');

        $answers = json_decode((string) ($row['answers_json'] ?? '{}'), true);
        $hasAnswers = is_array($answers) && count(array_filter(
            $answers,
            fn($v) => $v !== '' && $v !== [] && $v !== null
        )) > 0;
        $row['questionnaire_filled'] = $hasAnswers;
        unset($row['answers_json']);
    }
    unset($row);

    return $rows;
}

function dbGetUserCompletedCustomRequests(int $userId): array
{
    $rows = dbFetchAll(
        "SELECT r.id_richiesta AS id,
                r.titolo_personalizzato AS title,
                r.pdf_path AS download_link,
                DATE(r.created_at) AS date,
                p.immagine_path AS img
         FROM richieste r
         JOIN prodotto p ON p.id_prodotto = r.id_prodotto
         WHERE r.id_utente = :uid
           AND r.stato = 'completed'
         ORDER BY r.created_at DESC",
        [':uid' => $userId]
    );

    foreach ($rows as &$row) {
        $row['title']         = trim((string) ($row['title'] ?? '')) !== ''
            ? (string) $row['title']
            : 'Scheda Personalizzata';
        $row['download_link'] = (string) ($row['download_link'] ?? '');
        $row['date']          = (string) ($row['date']          ?? '');
        $row['img']           = (string) ($row['img']           ?? '');
    }
    unset($row);

    return $rows;
}

function dbCountPendingRequests(): int
{
    $row = dbFetchOne(
        "SELECT COUNT(*) AS cnt FROM richieste WHERE stato = 'pending'"
    );
    return (int) ($row['cnt'] ?? 0);
}

function dbParseTransformationDescription(?string $raw): array
{
    $data = json_decode($raw ?? '', true);
    if (is_array($data)) {
        return [
            'name'   => (string) ($data['name']   ?? ''),
            'result' => (string) ($data['result']  ?? ''),
            'quote'  => (string) ($data['quote']   ?? ''),
        ];
    }
    return ['name' => '', 'result' => '', 'quote' => (string) ($raw ?? '')];
}

function dbGetTransformations(): array
{
    $rows = dbFetchAll(
        'SELECT id_testimonianza AS id, foto, descrizione
         FROM testimonianze
         ORDER BY id_testimonianza DESC'
    );

    foreach ($rows as &$row) {
        $meta          = dbParseTransformationDescription($row['descrizione'] ?? '');
        $row['name']   = $meta['name'];
        $row['result'] = $meta['result'];
        $row['quote']  = $meta['quote'];
        $row['img']    = (string) ($row['foto'] ?? '');
    }
    unset($row);

    return $rows;
}

function dbGetTransformationById(int $id): ?array
{
    $row = dbFetchOne(
        'SELECT id_testimonianza AS id, foto, descrizione
         FROM testimonianze WHERE id_testimonianza = :id',
        [':id' => $id]
    );
    if (!$row) return null;

    $meta          = dbParseTransformationDescription($row['descrizione'] ?? '');
    $row['name']   = $meta['name'];
    $row['result'] = $meta['result'];
    $row['quote']  = $meta['quote'];
    $row['img']    = (string) ($row['foto'] ?? '');
    return $row;
}

function dbSaveTransformation(array $data, ?int $id = null): int
{
    $payload = json_encode(
        ['name' => $data['name'], 'result' => $data['result'], 'quote' => $data['quote']],
        JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES
    );

    if ($id) {
        dbExecute(
            'UPDATE testimonianze SET foto = :foto, descrizione = :desc WHERE id_testimonianza = :id',
            [':foto' => $data['img'], ':desc' => $payload, ':id' => $id]
        );
        return $id;
    }

    dbExecute(
        'INSERT INTO testimonianze (foto, descrizione) VALUES (:foto, :desc)',
        [':foto' => $data['img'], ':desc' => $payload]
    );
    return (int) db()->lastInsertId();
}

function dbDeleteTransformation(int $id): void
{
    dbExecute('DELETE FROM testimonianze WHERE id_testimonianza = :id', [':id' => $id]);
}



function dbGetUserRatings(int $userId): array
{
    $rows = dbFetchAll(
        'SELECT id_prodotto AS product_id, valore_recensioni AS rating
         FROM recensioni WHERE id_utente = :uid',
        [':uid' => $userId]
    );

    $ratings = [];
    foreach ($rows as $row) {
        $pid = (int) ($row['product_id'] ?? 0);
        if ($pid > 0) {
            $ratings[$pid] = (int) ($row['rating'] ?? 0);
        }
    }
    return $ratings;
}


function dbSaveRating(int $userId, int $productId, int $rating): void
{
    $rating = max(1, min(5, $rating));

    dbExecute(
        'INSERT INTO recensioni (id_utente, id_prodotto, valore_recensioni)
         VALUES (:uid, :pid, :rating)
         ON DUPLICATE KEY UPDATE valore_recensioni = VALUES(valore_recensioni)',
        [':uid' => $userId, ':pid' => $productId, ':rating' => $rating]
    );
}
