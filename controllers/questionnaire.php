<?php



declare(strict_types=1);
require_once dirname(__DIR__) . '/configs/bootstrap.php';

requireLogin();

$user = currentUser();

$serviceId = (int) ($_GET['product_id'] ?? $_POST['product_id'] ?? 0);
$serviceTitle = trim($_GET['service'] ?? $_POST['service_title'] ?? '');
$requestId = (int) ($_GET['request_id'] ?? $_POST['request_id'] ?? 0);

if ($serviceId <= 0 && $serviceTitle === '') {
    redirect('/purchased');
}

$requiredId = $serviceId > 0 ? $serviceId : (int) (dbGetProductIdByTitle($serviceTitle) ?? 0);

if ($requiredId > 0 && $serviceTitle === '') {
    $productRow = dbFetchOne(
        'SELECT titolo FROM prodotto WHERE id_prodotto = :id LIMIT 1',
        [':id' => $requiredId]
    );
    $serviceTitle = trim((string) ($productRow['titolo'] ?? ''));
}

if ($requiredId <= 0 && $serviceTitle !== '') {
    $productRow = dbFetchOne(
        'SELECT id_prodotto AS id FROM prodotto WHERE LOWER(TRIM(titolo)) = LOWER(TRIM(:title)) LIMIT 1',
        [':title' => $serviceTitle]
    );
    $requiredId = (int) ($productRow['id'] ?? 0);
}

$purchasedIds = dbGetUserPurchasedIds((int) $user['id']);

if ($requiredId <= 0 || !in_array($requiredId, $purchasedIds, true)) {
    http_response_code(403);
    exit('<h1>403 – Accesso negato</h1><p>Non hai acquistato questo servizio.</p>');
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    verifyCsrf();

    $giorni = trim($_POST['giorni'] ?? '');
    if ($giorni === 'Altro') {
        $giorni = trim($_POST['giorni_altro'] ?? '');
    }

    $tempo = trim($_POST['tempo'] ?? '');
    if ($tempo === 'Altro') {
        $tempo = trim($_POST['tempo_altro'] ?? '');
    }

    $rawAttr = $_POST['attrezzatura'] ?? [];
    $attrezzatura = is_array($rawAttr) ? array_values($rawAttr) : (array) $rawAttr;
    $attrezzatura = array_filter($attrezzatura, fn($v) => $v !== 'Altro');
    $attrezzatura = array_values($attrezzatura);
    if (!empty($_POST['attrezzatura_altro'])) {
        $attrezzatura[] = 'Altro: ' . trim($_POST['attrezzatura_altro']);
    }

    $photos    = [];
    $uploadDir = dirname(__DIR__) . '/assets/questionari/' . $user['id'] . '/';
    if (!is_dir($uploadDir)) {
        mkdir($uploadDir, 0755, true);
    }

    for ($i = 1; $i <= 5; $i++) {
        $fieldName = 'foto_' . $i;

        if (!isset($_FILES[$fieldName]) || $_FILES[$fieldName]['error'] !== UPLOAD_ERR_OK) {
            continue;
        }

        $tmpPath = $_FILES[$fieldName]['tmp_name'];
        $ext     = strtolower(pathinfo($_FILES[$fieldName]['name'], PATHINFO_EXTENSION));

        $allowedExt = ['jpg', 'jpeg', 'png', 'webp'];
        if (!in_array($ext, $allowedExt, true)) {
            continue;
        }

        // getimagesize() verifica che sia un'immagine reale leggendo
        // l'header del file (non si fida solo dell'estensione).
        if (@getimagesize($tmpPath) === false) {
            continue; // Non è un'immagine reale
        }

        // Nome file univoco: foto_1_<timestamp>_<random>.ext
        // Aggiunto random per evitare collisioni su upload multipli nella stessa richiesta
        $fileName = $fieldName . '_' . time() . '_' . bin2hex(random_bytes(4)) . '.' . $ext;
        $destPath = $uploadDir . $fileName;

        if (move_uploaded_file($tmpPath, $destPath)) {
            // Salva il path web relativo alla root del sito
            $photos[$fieldName] = BASE_URL . '/assets/questionari/' . $user['id'] . '/' . $fileName;
        }
    }

    $answers = [
        'nome'         => trim($_POST['nome']        ?? ''),
        'motivazione'  => trim($_POST['motivazione'] ?? ''),
        'eta'          => trim($_POST['eta']         ?? ''),
        'altezza'      => trim($_POST['altezza']     ?? ''),
        'peso'         => trim($_POST['peso']        ?? ''),
        'esperienza'   => trim($_POST['esperienza']  ?? ''),
        'effort'       => trim($_POST['effort']      ?? ''),
        'giorni'       => $giorni,
        'tempo'        => $tempo,
        'evitare'      => trim($_POST['evitare']     ?? ''),
        'avere'        => trim($_POST['avere']       ?? ''),
        'infortuni'    => trim($_POST['infortuni']   ?? ''),
        'attrezzatura' => $attrezzatura,
        'photos'       => $photos,
    ];


    if ($requestId > 0) {
        $existingRequest = dbFetchOne(
            "SELECT id_richiesta FROM richieste
             WHERE id_richiesta = :rid AND id_utente = :uid AND stato = 'pending'
             LIMIT 1",
            [':rid' => $requestId, ':uid' => (int) $user['id']]
        );
    } else {
        $existingRequest = dbFetchOne(
            "SELECT id_richiesta FROM richieste
             WHERE id_utente = :uid AND id_prodotto = :pid AND stato = 'pending'
               AND (answers_json = '{}' OR answers_json IS NULL OR answers_json = '')
             ORDER BY created_at ASC LIMIT 1",
            [':uid' => (int) $user['id'], ':pid' => (int) $requiredId]
        );
        if (!$existingRequest) {
            $existingRequest = dbFetchOne(
                "SELECT id_richiesta FROM richieste
                 WHERE id_utente = :uid AND id_prodotto = :pid AND stato = 'pending'
                 ORDER BY created_at ASC LIMIT 1",
                [':uid' => (int) $user['id'], ':pid' => (int) $requiredId]
            );
        }
    }

    if ($existingRequest) {
        dbUpdateRequestAnswers((int) $existingRequest['id_richiesta'], $answers);
    } else {
        dbSaveRequest((int) $user['id'], (int) $requiredId, $answers);
    }

    redirect('/purchased');
}

render('questionnaire.tpl', 'Questionario – FitStore', [
    'product_id'    => $requiredId,
    'request_id'    => $requestId,
    'service_title' => $serviceTitle,
    'submit_action' => BASE_URL . '/questionnaire?product_id=' . $requiredId
        . '&service=' . urlencode($serviceTitle)
        . ($requestId > 0 ? '&request_id=' . $requestId : ''),
]);
