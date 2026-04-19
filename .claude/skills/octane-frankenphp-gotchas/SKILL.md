---
name: octane-frankenphp-gotchas
description: Use when debugging unexpected behavior in Laravel Octane with FrankenPHP - stale data between requests, memory leaks, singleton contamination, static property state, or anything that "works once then breaks".
---

# Octane + FrankenPHP Gotchas

Laravel Octane keeps the application bootstrapped between requests. State that resets in PHP-FPM **persists** in Octane.

## The Core Problem

PHP-FPM: fresh process per request → no state leakage.
Octane: same process handles N requests → any mutable shared state leaks.

## Common Issues & Fixes

### Singleton State Contamination

```php
// ❌ Singleton modified during request A leaks into request B
app()->singleton('my-service', fn() => new MyService());
// If MyService stores request-specific state → leak

// ✅ Use scoped binding (reset each request)
app()->scoped('my-service', fn() => new MyService());
```

### Static Property Pollution

```php
// ❌ Static properties persist across requests
class MyClass {
    public static array $cache = [];
}

// ✅ Reset in Octane flush or use instance properties
```

### Service Provider State

If a ServiceProvider stores state in `$this` properties, it persists across requests. Use `flushState()` if provided, or restructure to be stateless.

### Request-Specific Data in Singletons

```php
// ❌ Auth::user() result cached in singleton
class ReportService {
    private User $user;
    public function __construct() {
        $this->user = auth()->user(); // captured at boot time
    }
}

// ✅ Resolve auth()->user() at call time, not construction time
public function generate(): Report {
    $user = auth()->user();
}
```

### File Upload Issues

Octane may buffer request bodies differently. Always use `$request->file()`, not PHP's `$_FILES`.

### Memory Leaks

Symptoms: memory grows with each request, worker restarts frequently.
- Avoid appending to static collections across requests
- Use `Octane::tick()` for periodic cleanup if needed
- Check `memory_get_usage()` before/after request in Telescope

## Octane Config (`config/octane.php`)

```php
'warm' => [
    // Add services to pre-warm (booted once, shared safely)
],
'flush' => [
    // Add services to flush per-request (stateful services)
],
```

## Debugging Checklist

When "works first time, breaks on second request":
1. Look for static properties modified during a request
2. Look for singletons that capture request-specific data (auth, locale, tenant)
3. Check `app()->scoped()` vs `app()->singleton()`
4. Enable Telescope — compare request #1 vs #2 memory/queries
5. Test with `OCTANE_MAX_REQUESTS=1` to confirm FPM-style reset fixes it

## FrankenPHP-Specific Notes

- Workers are true long-lived PHP processes (not Swoole coroutines)
- No fiber/coroutine isolation — one request at a time per worker
- `php_sapi_name() === 'frankenphp'` for conditional code
- Xdebug works normally (unlike Swoole)
