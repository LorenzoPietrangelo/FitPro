{*
 * home.tpl
 * Schermata Home/Landing page.
 *
 * Variabili attese:
 *   $programs        - array di oggetti programma
 *                      ogni item: id, title, desc, price, rating, reviews, img
 *   $transformations - array di oggetti trasformazione
 *                      ogni item: id, name, result, quote, img
 *   $custom          - oggetto servizio scheda personalizzata: title, desc, price, img
 *}
{extends file="layout_base.tpl"}

{block name="content"}
<div class="pb-0">

    {* ============================
       Hero Section
       ============================ *}
    <div class="relative bg-slate-900 text-white overflow-hidden">
        <div class="absolute inset-0">
            <img src="https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&q=80&w=2000"
                 alt="Gym"
                 class="w-full h-full object-cover opacity-20" />
        </div>
        <div class="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-24 lg:py-32">
            <h1 class="text-4xl md:text-6xl font-extrabold tracking-tight mb-4">
                Eleva il tuo <span class="text-emerald-400">Allenamento</span>
            </h1>
            <p class="text-xl text-slate-300 max-w-2xl mb-8">
                Scegli tra programmi pre-impostati, richiedi una scheda su misura per te,
                o affidati alle nostre schede personalizzate per risultati garantiti.
            </p>
            <div class="flex gap-4">
                <button onclick="document.getElementById('programs-section').scrollIntoView({literal}{behavior: 'smooth'}{/literal})"
                        class="bg-emerald-500 hover:bg-emerald-600 px-6 py-3 rounded-lg font-bold transition">
                    Esplora Programmi
                </button>
            </div>
        </div>
    </div>

    {* ============================
       Carosello Schede
       ============================ *}
    <div id="programs-section" class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
        <div class="flex items-center justify-between mb-8">
            <h2 class="text-3xl font-bold text-slate-900">Le Nostre Schede</h2>
            <a href="{url route='all-programs'}"
               class="text-emerald-600 font-bold hover:text-emerald-700 flex items-center gap-1 group">
                Vedi tutte le schede
                <i data-lucide="arrow-right" class="w-5 h-5 transform group-hover:translate-x-1 transition-transform"></i>
            </a>
        </div>

        {if $has_programs_carousel}
        <div class="carousel-container">
            <div class="carousel-track">
                {foreach from=$programs_double item=prog}
                    <div class="carousel-card bg-white rounded-2xl shadow-sm hover:shadow-xl transition-shadow duration-300 overflow-hidden border border-gray-100 flex flex-col cursor-pointer group"
                         onclick="window.location='{url route='program' id=$prog.id}'">
                        <div class="relative h-48 overflow-hidden">
                            <img src="{$prog.img|escape}"
                                 alt="{$prog.title|escape}"
                                 class="w-full h-full object-cover transform group-hover:scale-105 transition-transform duration-500" />
                            <div class="absolute top-4 right-4 bg-white px-3 py-1 rounded-full text-sm font-bold text-slate-900 shadow">
                                €{$prog.price}
                            </div>
                        </div>
                        <div class="p-6 flex-1 flex flex-col">
                            <h3 class="text-xl font-bold text-slate-900 mb-1 line-clamp-1">{$prog.title|escape}</h3>
                            <div class="flex items-center gap-1 mb-3">
                                <i data-lucide="star" class="w-4 h-4 fill-amber-400 text-amber-400"></i>
                                <span class="text-sm font-bold text-slate-700">{$prog.rating}</span>
                                <span class="text-xs text-gray-500">({$prog.reviews})</span>
                            </div>
                            <p class="text-gray-600 text-sm mb-4 flex-1 line-clamp-2">{$prog.desc|escape}</p>
                            <div class="w-full flex items-center justify-center gap-2 bg-slate-50 text-slate-900 py-2.5 rounded-lg font-semibold border border-slate-200 group-hover:bg-slate-900 group-hover:text-white transition-colors">
                                Vedi Dettagli
                            </div>
                        </div>
                    </div>
                {/foreach}
            </div>
        </div>
        {else}
        <div class="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
            {foreach from=$programs item=prog}
                <div class="bg-white rounded-2xl shadow-sm hover:shadow-xl transition-shadow duration-300 overflow-hidden border border-gray-100 flex flex-col cursor-pointer group"
                     onclick="window.location='{url route='program' id=$prog.id}'">
                    <div class="relative h-48 overflow-hidden">
                        <img src="{$prog.img|escape}"
                             alt="{$prog.title|escape}"
                             class="w-full h-full object-cover transform group-hover:scale-105 transition-transform duration-500" />
                        <div class="absolute top-4 right-4 bg-white px-3 py-1 rounded-full text-sm font-bold text-slate-900 shadow">
                            €{$prog.price}
                        </div>
                    </div>
                    <div class="p-6 flex-1 flex flex-col">
                        <h3 class="text-xl font-bold text-slate-900 mb-1 line-clamp-1">{$prog.title|escape}</h3>
                        <div class="flex items-center gap-1 mb-3">
                            <i data-lucide="star" class="w-4 h-4 fill-amber-400 text-amber-400"></i>
                            <span class="text-sm font-bold text-slate-700">{$prog.rating}</span>
                            <span class="text-xs text-gray-500">({$prog.reviews})</span>
                        </div>
                        <p class="text-gray-600 text-sm mb-4 flex-1 line-clamp-2">{$prog.desc|escape}</p>
                        <div class="w-full flex items-center justify-center gap-2 bg-slate-50 text-slate-900 py-2.5 rounded-lg font-semibold border border-slate-200 group-hover:bg-slate-900 group-hover:text-white transition-colors">
                            Vedi Dettagli
                        </div>
                    </div>
                </div>
            {/foreach}
        </div>
        {/if}
    </div>

    {* ============================
       Sezione Schede Personalizzate
       ============================ *}
    <div class="py-20" style="background-color:#0f172a;border-top:1px solid rgba(255,255,255,0.06)">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="grid md:grid-cols-2 gap-12 items-center">
                <div class="order-2 md:order-1 relative h-[400px] rounded-2xl overflow-hidden shadow-xl">
                    <img src="{$custom.img|escape}" class="w-full h-full object-cover" alt="Schede Personalizzate" />
                </div>
                <div class="order-1 md:order-2">
                    <div class="mb-4 inline-flex items-center gap-2 text-emerald-400 font-bold text-sm tracking-wider uppercase">
                        <i data-lucide="plus" class="w-5 h-5"></i> 100% Su Misura
                    </div>
                    <h2 class="text-4xl md:text-5xl font-extrabold text-white mb-6">{$custom.title|escape}</h2>
                    <p class="text-lg text-slate-400 mb-8 leading-relaxed">{$custom.desc|escape}</p>
                    <div class="flex flex-wrap items-center gap-6">
                        <span class="text-4xl font-bold text-white">€{$custom.price}</span>
                        <a href="{url route='custom'}"
                           class="bg-emerald-500 hover:bg-emerald-600 text-white px-8 py-4 rounded-xl font-bold transition flex items-center gap-2 shadow-xl shadow-emerald-500/20">
                            Richiedi Scheda <i data-lucide="arrow-right" class="w-5 h-5"></i>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>

</div>

    {* ============================
       Sezione Trasformazioni
       ============================ *}
    <div class="bg-white py-20 border-t border-gray-100">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="text-center mb-12">
                <div class="inline-flex items-center justify-center gap-2 text-emerald-600 font-bold text-sm tracking-wider uppercase mb-3">
                    <i data-lucide="star" class="w-4 h-4 fill-emerald-600"></i> Oltre 500+ Clienti Soddisfatti
                </div>
                <h2 class="text-3xl md:text-4xl font-extrabold text-slate-900 mb-4">I Risultati dei Nostri Clienti</h2>
                <p class="text-lg text-gray-600 max-w-2xl mx-auto">
                    Non credere solo alle nostre parole. Guarda le trasformazioni di chi ha già scelto
                    di affidarsi ai nostri percorsi di allenamento personalizzati.
                </p>
            </div>

            {if $has_transformations_carousel}
            <div class="carousel-container">
                <div class="testimonial-track">
                    {foreach from=$transformations_double item=t}
                        <div class="testimonial-card bg-white rounded-2xl p-6 shadow-sm border border-gray-100 hover:shadow-lg transition-shadow duration-300" >
                            <div class="relative h-64 mb-6 rounded-xl overflow-hidden group">
                                <img src="{$t.img|escape}"
                                     alt="Trasformazione {$t.name|escape}"
                                     class="w-full h-full object-cover transform group-hover:scale-105 transition-transform duration-500" />
                                <div class="absolute bottom-3 right-3 bg-emerald-500 text-white px-3 py-1.5 rounded-full text-sm font-bold shadow-md flex items-center gap-1.5">
                                    <i data-lucide="trending-up" class="w-4 h-4"></i> {$t.result|escape}
                                </div>
                            </div>
                            <h3 class="font-bold text-xl text-slate-900 mb-3">{$t.name|escape}</h3>
                            <p class="text-gray-600 italic relative z-10">
                                <span class="text-4xl text-emerald-200 absolute -top-4 -left-2 -z-10">"</span>
                                {$t.quote|escape}
                            </p>
                        </div>
                    {/foreach}
                </div>
            </div>
            {else}
            <div class="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
                {foreach from=$transformations item=t}
                    <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100 hover:shadow-lg transition-shadow duration-300" >
                        <div class="relative h-64 mb-6 rounded-xl overflow-hidden group">
                            <img src="{$t.img|escape}"
                                 alt="Trasformazione {$t.name|escape}"
                                 class="w-full h-full object-cover transform group-hover:scale-105 transition-transform duration-500" />
                            <div class="absolute bottom-3 right-3 bg-emerald-500 text-white px-3 py-1.5 rounded-full text-sm font-bold shadow-md flex items-center gap-1.5">
                                <i data-lucide="trending-up" class="w-4 h-4"></i> {$t.result|escape}
                            </div>
                        </div>
                        <h3 class="font-bold text-xl text-slate-900 mb-3">{$t.name|escape}</h3>
                        <p class="text-gray-600 italic relative z-10">
                            <span class="text-4xl text-emerald-200 absolute -top-4 -left-2 -z-10">"</span>
                            {$t.quote|escape}
                        </p>
                    </div>
                {/foreach}
            </div>
            {/if}
        </div>
    </div>



{/block}
