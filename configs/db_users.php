<?php


declare(strict_types=1);

function dbEmailExists(string $email): bool
{
    $row = dbFetchOne(
        'SELECT 1 FROM utenti WHERE email = :email LIMIT 1',
        [':email' => trim($email)]
    );
    return (bool) $row;
}

function dbRegisterUser(string $email, string $password): int
{
    $hash = password_hash($password, PASSWORD_DEFAULT);
    dbExecute(
        'INSERT INTO utenti (email, password) VALUES (:email, :password)',
        [':email' => trim($email), ':password' => $hash]
    );
    return (int) db()->lastInsertId();
}

function dbGetUserByCredentials(string $email, string $password): ?array
{
    $row = dbFetchOne(
        'SELECT id_utente AS id, email, password
         FROM utenti
         WHERE email = :email
         LIMIT 1',
        [':email' => trim($email)]
    );

    if (!$row) {
        return null;
    }

    if (!password_verify($password, (string) ($row['password'] ?? ''))) {
        return null;
    }

    $row['groups'] = dbGetUserGroups((int) $row['id']);

    return $row;
}

function dbGetUserGroups(int $userId): array
{
    $rows = dbFetchAll(
        'SELECT g.nome
         FROM `groups` g
         JOIN users_has_groups ug ON ug.id_group = g.id_group
         WHERE ug.id_utente = :uid',
        [':uid' => $userId]
    );

    return array_column($rows, 'nome');
}

function dbUserHasGroup(int $userId, string $groupName): bool
{
    $row = dbFetchOne(
        'SELECT 1
         FROM `groups` g
         JOIN users_has_groups ug ON ug.id_group = g.id_group
         WHERE ug.id_utente = :uid AND g.nome = :name
         LIMIT 1',
        [':uid' => $userId, ':name' => $groupName]
    );

    return (bool) $row;
}

function dbUserIsAdmin(int $userId): bool
{
    return dbUserHasGroup($userId, 'admin');
}

function dbGetGroups(): array
{
    return dbFetchAll(
        'SELECT id_group AS id, nome AS name, descrizione AS description
         FROM `groups`
         ORDER BY id_group ASC'
    );
}

function dbAddUserToGroup(int $userId, int $groupId): void
{
    dbExecute(
        'INSERT IGNORE INTO users_has_groups (id_utente, id_group) VALUES (:uid, :gid)',
        [':uid' => $userId, ':gid' => $groupId]
    );
}

function dbRemoveUserFromGroup(int $userId, int $groupId): void
{
    dbExecute(
        'DELETE FROM users_has_groups WHERE id_utente = :uid AND id_group = :gid',
        [':uid' => $userId, ':gid' => $groupId]
    );
}

function dbGetUserServices(int $userId): array
{
    return dbFetchAll(
        'SELECT DISTINCT s.username, s.descrizione
         FROM services s
         JOIN services_has_groups sg ON sg.username  = s.username
         JOIN users_has_groups ug   ON ug.id_group   = sg.id_group
         WHERE ug.id_utente = :uid',
        [':uid' => $userId]
    );
}

function dbUserHasService(int $userId, string $serviceUsername): bool
{
    $row = dbFetchOne(
        'SELECT 1
         FROM services_has_groups sg
         JOIN users_has_groups ug ON ug.id_group = sg.id_group
         WHERE ug.id_utente = :uid AND sg.username = :svc
         LIMIT 1',
        [':uid' => $userId, ':svc' => $serviceUsername]
    );

    return (bool) $row;
}

function dbGetServices(): array
{
    return dbFetchAll(
        'SELECT s.username, s.descrizione,
                GROUP_CONCAT(g.nome ORDER BY g.nome SEPARATOR \', \') AS groups
         FROM services s
         LEFT JOIN services_has_groups sg ON sg.username = s.username
         LEFT JOIN `groups` g             ON g.id_group  = sg.id_group
         GROUP BY s.username, s.descrizione
         ORDER BY s.username ASC'
    );
}

function dbAssignGroupsForPurchasedProducts(int $userId, array $productIds): array
{
    if (empty($productIds)) {
        return [];
    }

    // Trova le categorie premium (= username in services) dei prodotti acquistati
    $placeholders = implode(',', array_fill(0, count($productIds), '?'));

    $serviceRows = dbFetchAll(
        "SELECT DISTINCT cp.categoria AS service_username
         FROM categoria_prodotto cp
         INNER JOIN services s ON s.username = cp.categoria
         WHERE cp.id_prodotto IN ($placeholders)
           AND cp.categoria = 'custom'",
        array_values($productIds)
    );

    if (empty($serviceRows)) {
        return [];
    }

    $serviceUsernames = array_column($serviceRows, 'service_username');
    $svcsPlaceholders = implode(',', array_fill(0, count($serviceUsernames), '?'));

    $groupRows = dbFetchAll(
        "SELECT DISTINCT sg.id_group, g.nome
         FROM services_has_groups sg
         JOIN `groups` g ON g.id_group = sg.id_group
         WHERE sg.username IN ($svcsPlaceholders)",
        array_values($serviceUsernames)
    );

    $assignedGroups = [];
    foreach ($groupRows as $gRow) {
        $groupId = (int) ($gRow['id_group'] ?? 0);
        if ($groupId > 0) {
            dbAddUserToGroup($userId, $groupId);
            $assignedGroups[] = (string) ($gRow['nome'] ?? '');
        }
    }

    return $assignedGroups;
}

function dbRefreshUserSessionGroups(int $userId): void
{
    $groups = dbGetUserGroups($userId);

    if (isset($_SESSION['user']) && (int) ($_SESSION['user']['id'] ?? 0) === $userId) {
        $_SESSION['user']['groups'] = $groups;
    }
}
