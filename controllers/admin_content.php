<?php



declare(strict_types=1);
require_once dirname(__DIR__) . '/configs/bootstrap.php';

requireAdmin();


function normalizeMime(string $raw): string
{
    return trim(explode(';', $raw)[0]);
}

function uploadLog(string $msg): void
{
    $logFile = ROOT . '/upload_debug.log';
    $line    = '[' . date('Y-m-d H:i:s') . '] ' . $msg . PHP_EOL;
    @file_put_contents($logFile, $line, FILE_APPEND | LOCK_EX);
}

function uploadImageFile(string $fieldName, string $subDir, ?string &$errorOut = null): ?string
{
    $errorOut = null;
    uploadLog("uploadImageFile() chiamata — field=$fieldName, subDir=$subDir");

    if (empty($_FILES[$fieldName]) || !is_array($_FILES[$fieldName])) {
        uploadLog("SKIP: \$_FILES['$fieldName'] non presente o non è array");
        return null;
    }

    $file     = $_FILES[$fieldName];
    $phpError = (int) ($file['error'] ?? UPLOAD_ERR_NO_FILE);
    uploadLog("PHP error code: $phpError | size: " . ($file['size'] ?? '?') . " bytes | name: " . ($file['name'] ?? '?'));

    if ($phpError === UPLOAD_ERR_NO_FILE) {
        uploadLog("SKIP: nessun file selezionato (UPLOAD_ERR_NO_FILE)");
        return null; // nessun file scelto: non è un errore
    }

    if ($phpError !== UPLOAD_ERR_OK) {
        $labels = [
            UPLOAD_ERR_INI_SIZE   => 'File troppo grande (upload_max_filesize in php.ini)',
            UPLOAD_ERR_FORM_SIZE  => 'File troppo grande (MAX_FILE_SIZE nel form)',
            UPLOAD_ERR_PARTIAL    => 'Upload parziale, riprova',
            UPLOAD_ERR_NO_TMP_DIR => 'Cartella temporanea PHP assente',
            UPLOAD_ERR_CANT_WRITE => 'Impossibile scrivere nella cartella temporanea',
            UPLOAD_ERR_EXTENSION  => "Upload bloccato da un'estensione PHP",
        ];
        $errorOut = $labels[$phpError] ?? "Errore PHP upload (codice $phpError)";
        uploadLog("FAIL: phpError=$phpError → $errorOut");
        return null;
    }

    $tmpName = (string) ($file['tmp_name'] ?? '');
    if ($tmpName === '' || !is_uploaded_file($tmpName)) {
        $errorOut = 'File temporaneo non valido';
        uploadLog("FAIL: tmpName vuoto o non è un uploaded file — tmpName='$tmpName'");
        return null;
    }

    // Limite dimensione: usa upload_max_filesize da php.ini (non un limite arbitrario)
    $maxBytes = self_upload_max_bytes();
    $fileSize = (int) ($file['size'] ?? 0);
    if ($maxBytes > 0 && $fileSize > $maxBytes) {
        $errorOut = 'Immagine troppo grande (max ' . round($maxBytes / 1048576, 1) . ' MB)';
        uploadLog("FAIL: file $fileSize bytes > limite $maxBytes bytes");
        return null;
    }

    $allowedMimes = ['image/jpeg', 'image/png', 'image/webp'];
    $allowedExts  = ['jpg', 'jpeg', 'png', 'webp'];
    $ext          = strtolower(pathinfo((string) ($file['name'] ?? ''), PATHINFO_EXTENSION));

    $mime = '';
    if (function_exists('finfo_open')) {
        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        if ($finfo !== false) {
            $raw = finfo_file($finfo, $tmpName);
            finfo_close($finfo);
            $mime = $raw !== false ? normalizeMime((string) $raw) : '';
        }
    }
    uploadLog("MIME rilevato: '$mime' | estensione: '.$ext'");

    if ($mime !== '' && !in_array($mime, $allowedMimes, true)) {
        $errorOut = "Tipo MIME non supportato ($mime). Accettati: JPG, PNG, WEBP";
        uploadLog("FAIL: MIME non supportato — $mime");
        return null;
    }
    if ($mime === '' && !in_array($ext, $allowedExts, true)) {
        $errorOut = "Estensione .$ext non supportata. Accettati: jpg, jpeg, png, webp";
        uploadLog("FAIL: estensione non supportata — .$ext");
        return null;
    }

    $mimeToExt = ['image/jpeg' => 'jpg', 'image/png' => 'png', 'image/webp' => 'webp'];
    $finalExt  = $mimeToExt[$mime] ?? ($ext ?: 'jpg');
    $fileName  = bin2hex(random_bytes(16)) . '.' . $finalExt;
    $subDir    = trim($subDir, '/');
    $targetDir = ROOT . '/assets/' . $subDir;
    uploadLog("targetDir: $targetDir | fileName: $fileName");

    if (!is_dir($targetDir) && !mkdir($targetDir, 0755, true)) {
        $errorOut = "Impossibile creare la cartella: assets/$subDir";
        uploadLog("FAIL: mkdir fallito su $targetDir");
        return null;
    }

    if (!is_writable($targetDir)) {
        $errorOut = "Cartella non scrivibile: assets/$subDir — controlla i permessi";
        uploadLog("FAIL: cartella non scrivibile — $targetDir");
        return null;
    }

    $targetPath = $targetDir . '/' . $fileName;
    if (!move_uploaded_file($tmpName, $targetPath)) {
        $errorOut = "move_uploaded_file() fallito su assets/$subDir — controlla i permessi";
        uploadLog("FAIL: move_uploaded_file fallito — src=$tmpName dest=$targetPath");
        return null;
    }

    $url = BASE_URL . '/assets/' . $subDir . '/' . $fileName;
    uploadLog("OK: file salvato → $url");
    return $url;
}

function self_upload_max_bytes(): int
{
    $val = trim((string) ini_get('upload_max_filesize'));
    if ($val === '') return 0;
    $unit  = strtolower(substr($val, -1));
    $num   = (int) $val;
    return match ($unit) {
        'g' => $num * 1073741824,
        'm' => $num * 1048576,
        'k' => $num * 1024,
        default => $num,
    };
}


function uploadPdfFileAdmin(string $fieldName, string $subDir): ?string
{
    if (empty($_FILES[$fieldName]) || !is_array($_FILES[$fieldName])) return null;

    $file     = $_FILES[$fieldName];
    $phpError = (int) ($file['error'] ?? UPLOAD_ERR_NO_FILE);

    if ($phpError === UPLOAD_ERR_NO_FILE) return null;
    if ($phpError !== UPLOAD_ERR_OK)      return null;

    $tmpName = (string) ($file['tmp_name'] ?? '');
    if ($tmpName === '' || !is_uploaded_file($tmpName)) return null;
    if ((int) ($file['size'] ?? 0) > 10 * 1024 * 1024) return null;

    $ext  = strtolower(pathinfo((string) ($file['name'] ?? ''), PATHINFO_EXTENSION));
    $mime = '';
    if (function_exists('finfo_open')) {
        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        if ($finfo !== false) {
            $raw = finfo_file($finfo, $tmpName);
            finfo_close($finfo);
            $mime = $raw !== false ? normalizeMime((string) $raw) : '';
        }
    }

    if ($mime !== '' && $mime !== 'application/pdf') return null;
    if ($mime === '' && $ext !== 'pdf')               return null;

    $fileName  = bin2hex(random_bytes(16)) . '.pdf';
    $subDir    = trim($subDir, '/');
    $targetDir = ROOT . '/assets/' . $subDir;

    if (!is_dir($targetDir) && !mkdir($targetDir, 0755, true)) return null;

    $targetPath = $targetDir . '/' . $fileName;
    if (!move_uploaded_file($tmpName, $targetPath)) return null;

    return BASE_URL . '/assets/' . $subDir . '/' . $fileName;
}

$action = $_GET['action'] ?? '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    verifyCsrf();

    if ($action === 'save-program') {
        uploadLog("=== POST save-program ricevuto === target_id=" . ($_POST['target_id'] ?? 'new') . " title='" . ($_POST['title'] ?? '') . "'");

        $targetId = (int) ($_POST['target_id'] ?? 0);

        $imgUploadError = null;
        $imgUrl = uploadImageFile('img_file', 'prodotti/foto_schede', $imgUploadError);

        // Fallback URL testuale solo se nessun file era stato scelto
        if ($imgUrl === null && $imgUploadError === null) {
            $imgUrl = trim($_POST['img'] ?? '');
            uploadLog("Nessun file caricato — uso URL testuale: '$imgUrl'");
        }

        $pdfPath = uploadPdfFileAdmin('pdf_file', 'prodotti/schede_standard')
            ?? trim($_POST['file_path'] ?? '');

        $data = [
            'title'     => trim($_POST['title']  ?? ''),
            'desc'      => trim($_POST['desc']   ?? ''),
            'price'     => (float) ($_POST['price'] ?? 0),
            'img'       => $imgUrl ?? '',
            'file_path' => $pdfPath,
        ];

        if ($data['title'] !== '' && $data['price'] >= 0) {
            $programId = dbSaveProgram($data, $targetId > 0 ? $targetId : null);
            dbSetProgramCategories(
                $programId,
                trim($_POST['days']  ?? ''),
                trim($_POST['goal']  ?? ''),
                trim($_POST['level'] ?? '')
            );
            $_SESSION['flash_success'] = $imgUploadError
                ? "Scheda salvata, ma immagine non caricata: $imgUploadError"
                : 'Scheda salvata correttamente.';
        } else {
            $_SESSION['flash_error'] = 'Titolo o prezzo mancante.';
        }

        redirect('/admin-content');
    }

    if ($action === 'delete-program') {
        $pid = (int) ($_POST['program_id'] ?? 0);
        if ($pid > 0) dbDeleteProgram($pid);
        redirect('/admin-content');
    }

    if ($action === 'save-transformation') {
        $targetId  = (int) ($_POST['target_id'] ?? 0);
        $uploadErr = null;
        $imgUrl    = uploadImageFile('img_file', 'foto_testimonianze', $uploadErr)
            ?? trim($_POST['img'] ?? '');

        $data = [
            'name'   => trim($_POST['name']   ?? ''),
            'result' => trim($_POST['result'] ?? ''),
            'quote'  => trim($_POST['quote']  ?? ''),
            'img'    => $imgUrl,
        ];

        if ($data['name'] !== '') {
            dbSaveTransformation($data, $targetId > 0 ? $targetId : null);
            $_SESSION['flash_success'] = $uploadErr
                ? "Trasformazione salvata, ma immagine non caricata: $uploadErr"
                : 'Trasformazione salvata.';
        }

        redirect('/admin-content');
    }

    if ($action === 'delete-transformation') {
        $tId = (int) ($_POST['transformation_id'] ?? 0);
        if ($tId > 0) dbDeleteTransformation($tId);
        redirect('/admin-content');
    }

    if ($action === 'save-coupon') {
        $name      = strtoupper(trim($_POST['name']      ?? ''));
        $discount  = (float)        ($_POST['discount']  ?? 0);
        $expiresAt = trim($_POST['expires_at'] ?? '');

        if ($name !== '' && $discount > 0) {
            dbSaveCoupon($name, $discount, $expiresAt !== '' ? $expiresAt : null);
            $_SESSION['flash_success'] = 'Coupon creato.';
        } else {
            $_SESSION['flash_error'] = 'Nome o sconto mancante.';
        }

        redirect('/admin-content');
    }

    if ($action === 'delete-coupon') {
        $cid = (int) ($_POST['coupon_id'] ?? 0);
        if ($cid > 0) dbDeleteCoupon($cid);
        redirect('/admin-content');
    }

    if ($action === 'save-service') {
        $category = $_GET['category'] ?? '';
        if (!in_array($category, ['coaching', 'custom'], true)) {
            redirect('/admin-content');
        }

        $uploadErr = null;
        $imgUrl    = uploadImageFile('img_file', 'prodotti/foto_schede', $uploadErr)
            ?? trim($_POST['img'] ?? '');

        $data = [
            'title' => trim($_POST['title'] ?? ''),
            'desc'  => trim($_POST['desc']  ?? ''),
            'price' => (float) ($_POST['price'] ?? 0),
            'img'   => $imgUrl,
        ];

        if ($data['title'] !== '') {
            dbSaveService($category, $data);
            $_SESSION['flash_success'] = $uploadErr
                ? "Servizio salvato, ma immagine non caricata: $uploadErr"
                : 'Servizio salvato.';
        }

        redirect('/admin-content');
    }
}

$modal = null;

if (isset($_GET['close_modal'])) {
    redirect('/admin-content');
}

if (isset($_GET['modal'])) {
    $modalType = $_GET['modal'];
    $modalId   = isset($_GET['id']) ? (int) $_GET['id'] : null;

    switch ($modalType) {
        case 'program':
            $existingData = ($modalId !== null) ? dbGetProgramById($modalId) : [];
            $modal = [
                'type'      => 'program',
                'title'     => $modalId ? 'Modifica Scheda' : 'Nuova Scheda',
                'action'    => BASE_URL . '/admin-content?action=save-program',
                'target_id' => $modalId,
                'data'      => $existingData ?? [],
            ];
            break;

        case 'transformation':
            $existingData = ($modalId !== null) ? dbGetTransformationById($modalId) : [];
            $modal = [
                'type'      => 'transformation',
                'title'     => $modalId ? 'Modifica Trasformazione' : 'Nuova Trasformazione',
                'action'    => BASE_URL . '/admin-content?action=save-transformation',
                'target_id' => $modalId,
                'data'      => $existingData ?? [],
            ];
            break;

        case 'coupon':
            $modal = [
                'type'      => 'coupon',
                'title'     => 'Nuovo Coupon',
                'action'    => BASE_URL . '/admin-content?action=save-coupon',
                'target_id' => null,
                'data'      => [],
            ];
            break;

        case 'coaching':
            $existingData = dbGetServiceByCategory('coaching');
            $modal = [
                'type'      => 'coaching',
                'title'     => 'Modifica Coaching',
                'action'    => BASE_URL . '/admin-content?action=save-service&category=coaching',
                'target_id' => $existingData['id'] ?? null,
                'data'      => $existingData ?? [],
            ];
            break;

        case 'custom':
            $existingData = dbGetServiceByCategory('custom');
            $modal = [
                'type'      => 'custom',
                'title'     => 'Modifica Schede Personalizzate',
                'action'    => BASE_URL . '/admin-content?action=save-service&category=custom',
                'target_id' => $existingData['id'] ?? null,
                'data'      => $existingData ?? [],
            ];
            break;
    }
}

$flashError   = $_SESSION['flash_error']   ?? null;
$flashSuccess = $_SESSION['flash_success'] ?? null;
unset($_SESSION['flash_error'], $_SESSION['flash_success']);

render('admin_content.tpl', 'Gestione Contenuti – FitStore Admin', [
    'programs'                     => dbGetPrograms(),
    'coaching'                     => dbGetServiceByCategory('coaching'),
    'custom'                       => dbGetServiceByCategory('custom'),
    'transformations'              => dbGetTransformations(),
    'coupons'                      => dbGetCoupons(),
    'modal'                        => $modal,
    'flash_error'                  => $flashError,
    'flash_success'                => $flashSuccess,

    'add_program_action'           => BASE_URL . '/admin-content?modal=program',
    'edit_program_action'          => BASE_URL . '/admin-content?action=save-program',
    'delete_program_action'        => BASE_URL . '/admin-content?action=delete-program',

    'add_transformation_action'    => BASE_URL . '/admin-content?modal=transformation',
    'edit_transformation_action'   => BASE_URL . '/admin-content?action=save-transformation',
    'delete_transformation_action' => BASE_URL . '/admin-content?action=delete-transformation',

    'edit_coaching_action'         => BASE_URL . '/admin-content?modal=coaching',
    'edit_custom_action'           => BASE_URL . '/admin-content?modal=custom',

    'add_coupon_action'            => BASE_URL . '/admin-content?modal=coupon',
    'delete_coupon_action'         => BASE_URL . '/admin-content?action=delete-coupon',
]);
