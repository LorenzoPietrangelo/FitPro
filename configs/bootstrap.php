<?php


declare(strict_types=1);

define('ROOT',        dirname(__DIR__));
define('TPL_DIR',     ROOT . '/templates/');
define('COMPILE_DIR', ROOT . '/templates_c/');
define('CACHE_DIR',   ROOT . '/cache/');
define('CONFIGS_DIR', ROOT . '/configs/');

if (!defined('BASE_URL')) {
    $docRoot  = rtrim(str_replace('\\', '/', $_SERVER['DOCUMENT_ROOT']), '/');
    $projPath = rtrim(str_replace('\\', '/', ROOT), '/');
    define('BASE_URL', str_replace($docRoot, '', $projPath));
}

require_once ROOT . '/vendor/autoload.php';
require_once CONFIGS_DIR . 'db.php';

if (session_status() === PHP_SESSION_NONE) {
    session_set_cookie_params([
        'lifetime' => 0,
        'path'     => '/',
        // Sicuro automaticamente su HTTPS, disabilitato su HTTP locale
        'secure'   => isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off',
        'httponly' => true,
        'samesite' => 'Lax',
    ]);
    session_start();
}

function getSmarty(): \Smarty\Smarty
{
    static $smarty = null;
    if ($smarty !== null) {
        return $smarty;
    }

    $smarty = new \Smarty\Smarty();
    $smarty->setTemplateDir(TPL_DIR);
    $smarty->setCompileDir(COMPILE_DIR);
    $smarty->setCacheDir(CACHE_DIR);
    $smarty->setConfigDir(CONFIGS_DIR);
    $smarty->caching     = false;
    $smarty->debugging   = false;
    $smarty->escape_html = true;

    $routeMap = [
        'home'               => BASE_URL . '/',
        'all-programs'       => BASE_URL . '/all-programs',
        'program'            => BASE_URL . '/program',
        'custom'             => BASE_URL . '/custom',
        'login'              => BASE_URL . '/login',
        'register'           => BASE_URL . '/register',
        'logout'             => BASE_URL . '/logout',
        'cart'               => BASE_URL . '/cart',
        'cart-add'           => BASE_URL . '/cart?action=add',
        'cart-remove'        => BASE_URL . '/cart?action=remove',
        'purchased'          => BASE_URL . '/purchased',
        'questionnaire'      => BASE_URL . '/questionnaire',
        'admin-content'      => BASE_URL . '/admin-content',
        'admin-purchases'    => BASE_URL . '/admin-purchases',
        'admin-requests'     => BASE_URL . '/admin-requests',
        'admin-modal-open'   => BASE_URL . '/admin-content?modal=',
        'admin-modal-close'  => BASE_URL . '/admin-content?close_modal=1',
        'toggle-mobile-menu' => BASE_URL . '/cart?action=toggle-mobile',
    ];

    $smarty->registerPlugin('function', 'url', function (array $params) use ($routeMap): string {
        $route = $params['route'] ?? '';
        unset($params['route']);

        if ($route === 'admin-modal-open') {
            $type = urlencode($params['type'] ?? '');
            $id   = isset($params['id']) ? '&id=' . urlencode((string) $params['id']) : '';
            return ($routeMap[$route] ?? '#') . $type . $id;
        }

        $base = $routeMap[$route] ?? (BASE_URL . '/' . $route);
        $qs   = '';
        foreach ($params as $k => $v) {
            $sep = str_contains($base . $qs, '?') ? '&' : '?';
            $qs .= $sep . urlencode((string) $k) . '=' . urlencode((string) $v);
        }

        return $base . $qs;
    });

    return $smarty;
}

function render(string $template, string $pageTitle, array $vars = []): void
{
    $smarty = getSmarty();
    foreach (globalVars() as $k => $v) {
        $smarty->assign($k, $v);
    }
    $smarty->assign('page_title', $pageTitle);
    foreach ($vars as $k => $v) {
        $smarty->assign($k, $v);
    }
    $smarty->display($template);
    exit;
}


function currentUser(): ?array
{
    return $_SESSION['user'] ?? null;
}

function requireLogin(): void
{
    if (!currentUser()) {
        redirect('/login');
    }
}


function requireAdmin(): void
{
    $u = currentUser();
    if (!$u || !in_array('admin', (array) ($u['groups'] ?? []), true)) {
        http_response_code(403);
        // Renderizza un template dedicato invece di HTML grezzo
        render('error.tpl', 'Accesso negato', ['error_code' => 403, 'error_message' => 'Non hai i permessi per accedere a questa pagina.']);
    }
}

// ── CSRF ──────────────────────────────────────────────────────────────────────

function csrfToken(): string
{
    if (empty($_SESSION['csrf_token'])) {
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['csrf_token'];
}

function verifyCsrf(): void
{
    if (!hash_equals(csrfToken(), $_POST['csrf_token'] ?? '')) {
        http_response_code(403);
        exit('<h1>403 – Token CSRF non valido</h1>');
    }
}


function cartCount(): int
{
    return count($_SESSION['cart'] ?? []);
}


function redirect(string $url): void
{
    if (str_starts_with($url, 'http') || str_starts_with($url, BASE_URL)) {
        header('Location: ' . $url);
        exit;
    }
    header('Location: ' . BASE_URL . '/' . ltrim($url, '/'));
    exit;
}


function globalVars(): array
{
    $user         = currentUser();
    $isAdmin      = $user && in_array('admin', (array) ($user['groups'] ?? []), true);
    $pendingCount = $isAdmin ? dbCountPendingRequests() : 0;

    return [
        'user'                   => $user,
        'is_admin'               => $isAdmin,
        'cart_count'             => cartCount(),
        'pending_requests_count' => $pendingCount,
        'mobile_menu_open'       => $_SESSION['mobile_menu_open'] ?? false,
        'csrf_token'             => csrfToken(),
        'current_view'           => basename($_SERVER['PHP_SELF'], '.php'),
    ];
}
