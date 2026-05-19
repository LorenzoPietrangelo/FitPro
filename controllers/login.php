<?php


declare(strict_types=1);
require_once dirname(__DIR__) . '/configs/bootstrap.php';

if (currentUser()) {
    $u = currentUser();
    redirect(in_array('admin', (array) ($u['groups'] ?? []), true) ? '/admin-content' : '/home');
}

$isRegisterMode = (($_GET['mode'] ?? '') === 'register');
$errorMessage = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && $isRegisterMode) {
    verifyCsrf();
    $email    = trim($_POST['email']    ?? '');
    $password = trim($_POST['password'] ?? '');

    if ($email === '' || $password === '') {
        $errorMessage = 'Email e password sono obbligatori.';
    } elseif (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $errorMessage = 'Email non valida.';
    } elseif (strlen($password) < 6) {
        $errorMessage = 'Password di almeno 6 caratteri.';
    } elseif (dbEmailExists($email)) {
        $errorMessage = 'Account già esistente.';
    } else {
        $newUserId = dbRegisterUser($email, $password);
        $cartBeforeLogin = $_SESSION['cart'] ?? [];
        session_regenerate_id(true);
        $_SESSION['cart'] = $cartBeforeLogin;
        $displayName = ucfirst(strtolower(explode('@', $email)[0]));
        $_SESSION['user'] = [
            'id'        => $newUserId,
            'email'     => $email,
            'name'      => $displayName,
            'groups'    => [],
            'purchased' => [],
            'role'      => 'user',
        ];
        redirect('/home');
    }
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && !$isRegisterMode) {
    verifyCsrf();
    $email    = trim($_POST['email']    ?? '');
    $password = trim($_POST['password'] ?? '');
    $attempts = (int) ($_SESSION['login_attempts'] ?? 0);
    $lastTime = (int) ($_SESSION['login_last']     ?? 0);

    if ($attempts >= 5 && (time() - $lastTime) < 600) {
        $errorMessage = 'Troppi tentativi. Riprova tra poco.';
    } else {
        if ((time() - $lastTime) >= 600) {
            $attempts = 0;
        }

        $userRow = dbGetUserByCredentials($email, $password);
        if ($userRow) {
            $cartBeforeLogin = $_SESSION['cart'] ?? [];
            session_regenerate_id(true);
            $_SESSION['cart'] = $cartBeforeLogin;
            unset($_SESSION['login_attempts'], $_SESSION['login_last']);
            $groups  = $userRow['groups'] ?? [];
            $isAdmin = in_array('admin', $groups, true);
            $purchasedIds = dbGetUserPurchasedIds((int) $userRow['id']);
            $displayName = ucfirst(strtolower(explode('@', (string) $userRow['email'])[0]));
            $_SESSION['user'] = [
                'id'        => (int) $userRow['id'],
                'email'     => (string) $userRow['email'],
                'name'      => $displayName,
                'groups'    => $groups,
                'purchased' => $purchasedIds,
                'role'      => $isAdmin ? 'admin' : 'user',
            ];
            redirect($isAdmin ? '/admin-content' : '/home');
        } else {
            $attempts++;
            $_SESSION['login_attempts'] = $attempts;
            $_SESSION['login_last']     = $lastTime ?: time();
            $errorMessage = 'Email o password non corretti.';
        }
    }
}

render('login.tpl', ($isRegisterMode ? 'Registrati' : 'Login') . ' – FitStore', [
    'is_login_mode' => !$isRegisterMode,
    'login_action'  => BASE_URL . ($isRegisterMode ? '/register' : '/login'),
    'error_message' => $errorMessage,
]);
