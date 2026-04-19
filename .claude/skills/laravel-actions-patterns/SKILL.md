---
name: laravel-actions-patterns
description: Use when working with lorisleiva/laravel-actions package - AsController, AsJob, AsObject, AsListener patterns, handle() signatures, and deciding which trait combination to use for a given Action class.
---

# Laravel Actions Patterns

This project uses `lorisleiva/laravel-actions` instead of traditional controllers, jobs, listeners.
One class, multiple capabilities via traits.

## Trait Combinations

| Trait | How Dispatched | Location |
|-------|---------------|----------|
| `AsController` | Via HTTP route | `app/Actions/Pages/` or `app/Actions/{Domain}/` |
| `AsObject` | `ActionClass::run(...)` | `app/Actions/{Domain}/` |
| `AsJob` | `ActionClass::dispatch(...)` | `app/Actions/{Domain}/` |
| `AsJob + AsObject` | Both HTTP and queue | `app/Actions/{Domain}/` |
| `AsListener` | Via Event | `app/Actions/{Domain}/` |

## When to Use Each

- **AsController** — page rendering or form handling via HTTP. Form Request injected into `handle()`.
- **AsObject** — reusable business logic called from other code. No HTTP context.
- **AsJob** — background processing. Add queue config properties (`$tries`, `$backoff`, `$timeout`).
- **AsJob + AsObject** — when same logic runs both inline AND queued.

## handle() Signatures

```php
// AsController — Page (GET)
public function handle(): Response { }

// AsController — Form (POST) with Form Request + route model binding
public function handle(StorePostRequest $request, Post $post): RedirectResponse { }

// AsObject — called via ::run()
public function handle(string $input, int $count): ResultType { }

// AsJob — called via ::dispatch()
public function handle(Post $post): void { }
```

## Authorization in AsController Actions

```php
public function authorize(Request $request, Post $post): bool
{
    return $request->user()->can('update', $post);
}
```

## Dispatch Patterns

```php
// Sync (AsObject)
$result = CreateItem::run($name, ItemTypeEnum::Default);

// Queued (AsJob)
ProcessItemAnalytics::dispatch($item);
ProcessItemAnalytics::dispatch($item)->delay(now()->addMinutes(5));

// Conditional sync/queue
ProcessItemAnalytics::dispatchIf($condition, $item);
ProcessItemAnalytics::dispatchUnless($condition, $item);
```

## Naming Conventions

- Page rendering: `ShowPostPage`, `ListPostsPage`
- Form handling: `StorePost`, `UpdatePost`, `DeletePost`
- Business logic: `CreateTag`, `CalculateDiscount`, `ProcessAnalytics`
- Background: `SendNotificationEmail`, `GenerateReport`

## Queue Properties (on AsJob classes)

```php
public int $tries = 3;
public array $backoff = [30, 60, 120];
public int $timeout = 120;
public string $queue = 'default';
```

## Canonical Examples

### Page Action (AsController — GET)

```php
<?php

declare(strict_types=1);

namespace App\Actions\Pages\Post;

use Inertia\Inertia;
use Inertia\Response;
use Lorisleiva\Actions\Concerns\AsController;

class ListPostPage
{
    use AsController;

    public function handle(): Response
    {
        $posts = auth()
            ->user()
            ->posts()
            ->with(['author:id,name'])
            ->orderByDesc('created_at')
            ->get();

        return Inertia::render('Post/ListPage', [
            'posts' => $posts,
        ]);
    }
}
```

### Store Action (AsController — POST)

```php
<?php

declare(strict_types=1);

namespace App\Actions\Posts;

use App\Http\Requests\Post\StorePostRequest;
use App\Models\Post;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\RedirectResponse;
use Lorisleiva\Actions\Concerns\AsController;

class StorePost
{
    use AsController;

    public function handle(StorePostRequest $request): RedirectResponse
    {
        Post::query()->create([
            ...$request->validated(),
            'author_id' => Auth::id(),
        ]);

        return redirect()->route('posts.index');
    }
}
```

### Business Logic Action (AsObject)

```php
<?php

declare(strict_types=1);

namespace App\Actions\Tag;

use App\Models\Tag;
use Illuminate\Support\Str;
use Lorisleiva\Actions\Concerns\AsObject;

class CreateTag
{
    use AsObject;

    public function handle(string $tag, string $type): Tag
    {
        $normalized = Str::lower(mb_trim($tag));

        return Tag::query()->firstOrCreate(
            ['tag' => $normalized, 'type' => $type],
        );
    }
}

// Usage: CreateTag::run($tagName, 'skill');
```

### Async Job Action (AsJob + AsObject)

```php
<?php

declare(strict_types=1);

namespace App\Actions\Post;

use App\Models\Post;
use Lorisleiva\Actions\Concerns\AsJob;
use Lorisleiva\Actions\Concerns\AsObject;

class ProcessPostAnalytics
{
    use AsJob, AsObject;

    public int $tries = 3;
    public array $backoff = [30, 60, 120];
    public int $timeout = 120;

    public function handle(Post $post): void
    {
        // Must be idempotent — safe to retry
        PostAnalytics::query()->updateOrCreate(
            ['post_id' => $post->getKey()],
            ['processed_at' => now()],
        );
    }
}

// Dispatch: ProcessPostAnalytics::dispatch($post);
// Inline: ProcessPostAnalytics::run($post);
```

### Unique Job (prevent duplicates)

```php
use Illuminate\Contracts\Queue\ShouldBeUnique;

class ProcessPostAnalytics implements ShouldBeUnique
{
    use AsJob, AsObject;

    public function uniqueId(): string
    {
        return (string) $this->post->getKey();
    }
}
```
