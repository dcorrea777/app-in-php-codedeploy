<?php

declare(strict_types=1);

namespace App;

final class Handler
{
    public function __invoke(): string
    {
        return 'Olá mundo';
    }
}
