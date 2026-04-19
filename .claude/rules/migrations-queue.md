# Migrations & Queue Jobs

## Migration Conventions

- **Naming**: `create_posts_table`, `add_slug_to_posts_table`, `drop_legacy_field_from_users_table`
- Every migration must implement `down()` for reversibility
- Never modify existing migration files — always create a new one

```php
<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('posts', function (Blueprint $table): void {
            $table->string('slug')->unique()->after('title');
        });
    }

    public function down(): void
    {
        Schema::table('posts', function (Blueprint $table): void {
            $table->dropColumn('slug');
        });
    }
};
```

## Queue Jobs via Laravel Actions

Use `AsJob` trait — no separate Job class needed:

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
    public array $backoff = [30, 60, 120]; // exponential backoff (seconds)
    public int $timeout = 120;

    public function handle(Post $post): void
    {
        // must be idempotent
    }
}

// Dispatch:
ProcessPostAnalytics::dispatch($post);
ProcessPostAnalytics::dispatch($post)->delay(now()->addMinutes(5));
```

## Idempotency

Jobs must produce the same result when run multiple times:

```php
public function handle(Post $post): void
{
    PostAnalytics::query()->updateOrCreate(
        ['post_id' => $post->getKey()],
        ['processed_at' => now()],
    );
}
```

## Unique Jobs

Prevent duplicate jobs for the same resource:

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
