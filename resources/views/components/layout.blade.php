<div class="layout">
    @if(isset($title))
        <h1>{{ $title }}</h1>
    @endif

    @if(!empty($vars))
        <section class="view-vars">
            <h2>View variables</h2>
            <pre>{{ json_encode($vars, JSON_PRETTY_PRINT|JSON_UNESCAPED_UNICODE) }}</pre>
        </section>
    @endif

    <main class="content">
        {{ $slot ?? '' }}
    </main>
</div>
