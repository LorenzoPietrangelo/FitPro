<?php

declare(strict_types=1);
require_once dirname(__DIR__) . '/configs/bootstrap.php';

$programs = dbGetPrograms();

render('all_programs.tpl', 'Tutte le Schede', [
    'programs' => $programs,
]);
