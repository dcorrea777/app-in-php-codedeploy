<?php

declare(strict_types=1);

require_once __DIR__ . '/../vendor/autoload.php';

use App\Handler;

$handler = new Handler();

echo $handler();
