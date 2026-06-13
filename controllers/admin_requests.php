<?php


declare(strict_types=1);
require_once dirname(__DIR__) . '/configs/bootstrap.php';

requireAdmin();

$action = $_GET['action'] ?? 'view';

function uploadPdfFile(string $fieldName, string $subDir): ?string
{
    if (!isset($_FILES[$fieldName]) || !is_array($_FILES[$fieldName])) return null;

    $file    = $_FILES[$fieldName];
    $tmpName = $file['tmp_name'] ?? '';

    if (($file['error'] ?? UPLOAD_ERR_NO_FILE) !== UPLOAD_ERR_OK) return null;
    if ($tmpName === '' || !is_uploaded_file($tmpName))            return null;
    if (($file['size'] ?? 0) > 10 * 1024 * 1024)                  return null;

    // Verifica MIME (fix: OR logico corretto)
    $mime = '';
    if (function_exists('finfo_open')) {
        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        if ($finfo) {
            $mime = (string) finfo_file($finfo, $tmpName);
            finfo_close($finfo);
        }
    }
    $ext = strtolower(pathinfo($file['name'] ?? '', PATHINFO_EXTENSION));

    if ($mime !== '' && $mime !== 'application/pdf') return null;
    if ($mime === '' && $ext !== 'pdf')               return null;

    $fileName  = bin2hex(random_bytes(16)) . '.pdf';
    $subDir    = trim($subDir, '/');
    $targetDir = ROOT . '/assets/' . $subDir;

    if (!is_dir($targetDir)) mkdir($targetDir, 0755, true);

    $targetPath = $targetDir . '/' . $fileName;
    if (!move_uploaded_file($tmpName, $targetPath)) return null;

    return BASE_URL . '/assets/' . $subDir . '/' . $fileName;
}


if ($_SERVER['REQUEST_METHOD'] === 'POST' && $action === 'upload_pdf') {
    verifyCsrf();

    $reqId  = (int) ($_POST['request_id'] ?? 0);
    $titolo = trim($_POST['titolo_personalizzato'] ?? '');
    $pdfPath = uploadPdfFile('pdf_file', 'prodotti/schede_personalizate');

    if ($reqId > 0 && $pdfPath && $titolo !== '') {
        dbCompleteRequest($reqId, $pdfPath, $titolo);
    }

    redirect('/admin-requests');
}


$requests     = dbGetRequests();
$pendingCount = dbCountPendingRequests();

render('admin_requests.tpl', 'Richieste Clienti – FitStore Admin', [
    'requests'      => $requests,
    'pending_count' => $pendingCount,
    'upload_action' => BASE_URL . '/admin-requests?action=upload_pdf',
]);
