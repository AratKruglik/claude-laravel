# Form Requests & Authorization

## Form Request

All form submissions require a Form Request. Never validate in the Action body.

```php
<?php

declare(strict_types=1);

namespace App\Http\Requests\Post;

use Illuminate\Foundation\Http\FormRequest;

final class StorePostRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true; // Auth check done via Policy in the Action
    }

    /** @return array<string, array<string>> */
    public function rules(): array
    {
        return [
            'title'       => ['required', 'string', 'max:255'],
            'description' => ['required', 'string', 'max:5000'],
        ];
    }
}
```

## Authorization in Actions

Use `authorize()` in `AsController` actions for Policy checks:

```php
class UpdatePost
{
    use AsController;

    public function authorize(UpdatePostRequest $request, Post $post): bool
    {
        return $request->user()->can('update', $post);
    }

    public function handle(UpdatePostRequest $request, Post $post): RedirectResponse
    {
        $post->update($request->validated());
        return redirect()->route('posts.index');
    }
}
```

## Policy Pattern

```php
<?php

declare(strict_types=1);

namespace App\Policies;

use App\Models\Post;
use App\Models\User;

final class PostPolicy
{
    public function update(User $user, Post $post): bool
    {
        return $user->getKey() === $post->author_id;
    }

    public function delete(User $user, Post $post): bool
    {
        return $user->getKey() === $post->author_id;
    }
}
```

Register in `AppServiceProvider::boot()`:
```php
Gate::policy(Post::class, PostPolicy::class);
```

## Validation Error Flow

Laravel Form Request errors → `$page.props.errors` in Inertia → `useForm().errors.field` in Vue.
