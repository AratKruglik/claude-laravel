# Testing Rules

## Models Testing Policy

**DO NOT** create unit tests for Laravel Eloquent models.

Rationale:
- Laravel's Eloquent ORM is extensively tested by the Laravel team
- Testing basic CRUD, relationships, and standard functionality provides no value
- Models are excluded from code coverage metrics (see phpunit.xml)

What NOT to test:
- Basic relationships (hasOne, hasMany, belongsTo, etc.)
- Simple CRUD operations
- Standard Eloquent functionality
- Factory creation without custom logic
- Basic fillable/guarded attributes, standard casting

Exceptions — What TO test:
- Custom business logic methods
- Complex accessors/mutators with business rules
- Custom scopes with specific logic
- Observer behavior and side effects

Where to test model functionality instead:
- Feature tests via HTTP endpoints and workflows
- Integration tests for model interactions
- Observer tests for event handlers
- Action/Service tests for business logic

## Framework & Tools

- **Pest PHP** — BDD-style syntax (`describe()` + `it()` + `expect()`)
- **Mutation Testing** with Infection — `--mutate --covered-only --parallel --min=100`
- **Architectural Testing** — enforced via `tests/Unit/ArchTest.php`

## Test Structure

```
tests/
├── Feature/          # Integration tests (Auth, Posts, Pages)
├── Unit/             # Unit tests (Actions, Models, Observers, Support)
├── Pest.php          # Pest configuration
└── TestCase.php      # Base test case
```

## Running Tests

All tests run in Docker. Feature tests do not need to mutate.

```bash
docker compose exec app php artisan test                    # all tests
docker compose exec app php artisan test --coverage         # with coverage
docker compose exec app php artisan test --mutate --covered-only --parallel --min=100  # mutation
docker compose exec app php artisan test tests/Unit/ExampleTest.php  # specific file
```

## Test Configuration

- **Database**: RefreshDatabase trait for clean state
- **Environment**: phpunit.xml with testing-specific settings
- **Coverage**: reports in `coverage/` directory
- **Memory Limit**: 512M

## Writing Tests

```php
<?php

declare(strict_types=1);

mutates(YourClass::class);

describe('Feature Description', function (): void {
    beforeEach(function (): void {
        $this->user = User::factory()->create();
    });

    it('describes what it tests', function (): void {
        $result = someFunction();
        expect($result)->toBe('expected_value');
    });
});
```

### Testing Actions

```php
it('handles the action correctly', function (): void {
    $action = new YourAction();
    $result = $action->handle($request, $parameters);

    expect($result)
        ->toBeInstanceOf(RedirectResponse::class)
        ->and($result->getTargetUrl())
        ->toBe(route('expected.route'));
});
```

## Architectural Testing

Enforced rules (`tests/Unit/ArchTest.php`):
- No debugging functions in production code
- Models must extend Eloquent Model
- Page actions must have 'Page' suffix
- Enums must be proper enum classes
