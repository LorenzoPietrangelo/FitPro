<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{$page_title|default:'FitStore - Fitness E-Commerce'}</title>
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Lucide Icons -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
{literal}
        body { font-family: 'Inter', sans-serif; -webkit-font-smoothing: antialiased; }
        .line-clamp-1 { display: -webkit-box; -webkit-line-clamp: 1; -webkit-box-orient: vertical; overflow: hidden; }
        .line-clamp-2 { display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }

        /* CSS per il Carosello Infinito */
        .carousel-container {
            width: 100%;
            overflow: hidden;
            position: relative;
            padding: 1rem 0;
        }
        .carousel-container::before, .carousel-container::after {
            content: "";
            position: absolute;
            top: 0;
            width: 100px;
            height: 100%;
            z-index: 2;
            pointer-events: none;
        }
        .carousel-container::before {
            left: 0;
            background: linear-gradient(to right, rgba(249,250,251,1) 0%, rgba(249,250,251,0) 100%);
        }
        .carousel-container::after {
            right: 0;
            background: linear-gradient(to left, rgba(249,250,251,1) 0%, rgba(249,250,251,0) 100%);
        }
        .carousel-track {
            display: flex;
            width: max-content;
            animation: scroll-carousel 40s linear infinite;
        }
        .carousel-track:hover {
            animation-play-state: paused;
        }
        .carousel-card {
            width: 320px;
            flex-shrink: 0;
            margin-right: 2rem;
        }

        .testimonial-track {
            display: flex;
            width: max-content;
            animation: scroll-carousel 50s linear infinite;
        }
        .testimonial-track:hover {
            animation-play-state: paused;
        }
        .testimonial-card {
            width: 360px;
            flex-shrink: 0;
            margin-right: 2rem;
            white-space: normal;
        }

        @media (max-width: 640px) {
            .carousel-card { width: 280px; }
            .testimonial-card { width: 300px; }
        }

        @keyframes scroll-carousel {
            0% { transform: translateX(0); }
            100% { transform: translateX(-50%); }
        }
{/literal}
    </style>
</head>
<body class="font-sans text-gray-900 bg-gray-50 selection:bg-emerald-200 flex flex-col min-h-screen">

    {* Navbar inclusa dinamicamente *}
    {include file="navbar.tpl"}

    {* Contenuto principale della pagina corrente *}
    <main class="flex-grow">
        {block name="content"}{/block}
    </main>

    {* Footer *}
    {include file="footer.tpl"}

    {* Script JS globale *}
    <script>
{literal}
        document.addEventListener('DOMContentLoaded', () => {
            lucide.createIcons();
        });
{/literal}
    </script>

    {* Blocco opzionale per script specifici della pagina *}
    {block name="scripts"}{/block}

</body>
</html>
