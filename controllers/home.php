<?php

declare(strict_types=1);

require_once dirname(__DIR__) . '/configs/bootstrap.php';

$programs = dbGetPrograms();
$transformations = dbGetTransformations();

$carouselMin = 3;
$showPrograms = count($programs) >= $carouselMin;
$showTransforms = count($transformations) >= $carouselMin;

render('home.tpl', 'FitStore', [
    'programs'               => $programs,
    'programs_double'        => $showPrograms ? array_merge($programs, $programs) : $programs,
    'has_programs_carousel'   => $showPrograms,
    'transformations'        => $transformations,
    'transformations_double' => $showTransforms ? array_merge($transformations, $transformations) : $transformations,
    'has_transformations_carousel' => $showTransforms,
    'custom'   => dbGetServiceByCategory('custom'),
]);
