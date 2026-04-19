# Inertia v2 + Vue 3 Conventions

## Stack

- **Inertia.js v2** — server-driven SPA routing
- **Vue 3 Composition API** — `<script setup>` always; never Options API
- **TypeScript** — hybrid stack, migrating to TS; use `lang="ts"` on new components
- **Pinia** — shared reactive state
- **Ziggy** — `route()` helper for named routes

## Component Structure

```vue
<script setup lang="ts">
import { ref, computed } from 'vue'
import { usePage, useForm } from '@inertiajs/vue3'
import { route } from 'ziggy-js'
</script>
```

## Shared Props

Access shared props (from `HandleInertiaRequests`) via `usePage()` — never re-pass them as component props:

```typescript
const page = usePage<{ auth: { user: User }; flash: Flash }>()
const user = computed(() => page.props.auth.user)
```

## useForm + Form Request

```typescript
const form = useForm({ title: '', body: '' })

function submit(): void {
    form.post(route('posts.store'), {
        onSuccess: () => form.reset(),
    })
}
```

Form Request validation errors map automatically to `form.errors.field`.

## Deferred Props (v2)

```php
return Inertia::render('Dashboard', [
    'user'  => $user,
    'stats' => Inertia::defer(fn () => $stats),
]);
```

```vue
<template>
    <div v-if="!stats" class="animate-pulse h-20 bg-gray-200 rounded" />
    <StatsCard v-else :stats="stats" />
</template>
```

## Partial Reloads

```typescript
import { router } from '@inertiajs/vue3'

router.reload({ only: ['posts'] })
```

## WhenVisible (Lazy Loading)

```vue
<WhenVisible :data="['comments']">
    <template #fallback><LoadingSpinner /></template>
    <CommentsList :comments="comments" />
</WhenVisible>
```

## Redirects

```php
return redirect()->route('posts.index');           // Inertia redirect
return Inertia::location(route('posts.index'));     // external/full redirect
```

## SSR Caveats

- No `window`/`document`/`localStorage` in `<script setup>` top-level — wrap in `onMounted`
- Pinia stores must be initialized server-safe (no browser APIs in state initializers)
