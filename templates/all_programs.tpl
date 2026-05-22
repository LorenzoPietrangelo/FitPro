{*
 * all_programs.tpl
 * Schermata: lista di tutte le schede di allenamento.
 *
 * Variabili attese:
 *   $programs - array di oggetti programma
 *               ogni item: id, title, desc, price, rating, reviews, img, days, goal, level
 *}
{extends file="layout_base.tpl"}

{block name="content"}
<div class="py-12 min-h-screen">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">

        <a href="{url route='home'}"
           class="flex items-center gap-2 text-gray-500 hover:text-emerald-600 mb-8 transition font-medium">
            <i data-lucide="arrow-left" class="w-5 h-5"></i> Torna alla Home
        </a>

        {* Barra titolo + ricerca *}
        <div class="flex flex-col md:flex-row md:items-center justify-between mb-10 gap-6 bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
            <div class="flex flex-col sm:flex-row sm:items-center gap-3">
                <h1 class="text-3xl font-bold text-slate-900">Tutte le Schede</h1>
                <button type="button" onclick="openFilters()"
                        class="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-emerald-500 hover:bg-emerald-600 text-white font-semibold transition">
                    <i data-lucide="sliders-horizontal" class="w-4 h-4"></i>
                    Filtra
                </button>
            </div>
            <div class="relative max-w-md w-full">
                <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                    <i data-lucide="search" class="h-5 w-5 text-gray-400"></i>
                </div>
                <input
                    type="text"
                    id="search-input"
                    placeholder="Cerca un programma per nome..."
                    oninput="applyFilters()"
                    class="block w-full pl-12 pr-4 py-3 border border-gray-200 rounded-xl bg-gray-50 focus:bg-white focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent transition-all"
                />
            </div>
        </div>

        {* Popup filtri *}
        <div id="filters-modal" class="fixed inset-0 z-50 hidden">
            <div class="absolute inset-0 bg-black/40" onclick="closeFilters()"></div>
            <div class="relative mx-auto mt-20 w-full max-w-lg bg-white rounded-2xl shadow-xl border border-gray-100 p-6">
                <div class="flex items-center justify-between mb-4">
                    <h2 class="text-xl font-bold text-slate-900">Filtra schede</h2>
                    <button type="button" onclick="closeFilters()" class="p-2 rounded-lg hover:bg-gray-100">
                        <i data-lucide="x" class="w-5 h-5"></i>
                    </button>
                </div>

                <div class="grid grid-cols-1 gap-4">
                    <div>
                        <label class="block text-sm font-semibold text-slate-700 mb-1">Giorni a settimana</label>
                        <select id="filter-days" onchange="applyFilters()"
                                class="w-full px-3 py-2 border border-gray-200 rounded-xl bg-gray-50 focus:bg-white focus:outline-none focus:ring-2 focus:ring-emerald-500">
                            <option value="">Tutti</option>
                            <option value="3">3 giorni</option>
                            <option value="4">4 giorni</option>
                            <option value="5">5 giorni</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-sm font-semibold text-slate-700 mb-1">Scopo</label>
                        <select id="filter-goal" onchange="applyFilters()"
                                class="w-full px-3 py-2 border border-gray-200 rounded-xl bg-gray-50 focus:bg-white focus:outline-none focus:ring-2 focus:ring-emerald-500">
                            <option value="">Tutti</option>
                            <option value="ipertrofia">Ipertrofia</option>
                            <option value="forza">Forza</option>
                            <option value="powerlifting">Powerlifting</option>
                            <option value="dimagrimento">Dimagrimento</option>
                            <option value="calisthenics">Calisthenics</option>
                            <option value="mobilita">Mobilita</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-sm font-semibold text-slate-700 mb-1">Livello</label>
                        <select id="filter-level" onchange="applyFilters()"
                                class="w-full px-3 py-2 border border-gray-200 rounded-xl bg-gray-50 focus:bg-white focus:outline-none focus:ring-2 focus:ring-emerald-500">
                            <option value="">Tutti</option>
                            <option value="base">Base</option>
                            <option value="intermedio">Intermedio</option>
                            <option value="avanzato">Avanzato</option>
                        </select>
                    </div>
                </div>

                <div class="flex items-center justify-between mt-6">
                    <button type="button" onclick="resetFilters()"
                            class="px-4 py-2 rounded-xl border border-gray-200 text-slate-700 hover:bg-gray-50">
                        Reset
                    </button>
                    <div class="flex items-center gap-3">
                        <button type="button" onclick="closeFilters()"
                                class="px-4 py-2 rounded-xl border border-gray-200 text-slate-700 hover:bg-gray-50">
                            Chiudi
                        </button>
                        <button type="button" onclick="applyFilters(); closeFilters();"
                                class="px-4 py-2 rounded-xl bg-emerald-500 hover:bg-emerald-600 text-white font-semibold">
                            Applica
                        </button>
                    </div>
                </div>
            </div>
        </div>

        {* Griglia schede *}
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            {foreach from=$programs item=prog}
                <div class="program-card bg-white rounded-2xl shadow-sm hover:shadow-xl transition-shadow duration-300 overflow-hidden border border-gray-100 flex flex-col"
                     data-title="{$prog.title|lower|escape}"
                     data-days="{$prog.days|escape}"
                     data-goal="{$prog.goal|escape}"
                     data-level="{$prog.level|escape}">
                    <div class="relative h-48">
                        <img src="{$prog.img|escape}" alt="{$prog.title|escape}" class="w-full h-full object-cover" />
                        <div class="absolute top-4 right-4 bg-white px-3 py-1 rounded-full text-sm font-bold text-slate-900 shadow">
                            €{$prog.price}
                        </div>
                    </div>
                    <div class="p-6 flex-1 flex flex-col">
                        <h3 class="text-lg font-bold text-slate-900 mb-1 leading-tight">{$prog.title|escape}</h3>
                        <div class="flex items-center gap-1 mb-3">
                            <i data-lucide="star" class="w-4 h-4 fill-amber-400 text-amber-400"></i>
                            <span class="text-sm font-bold text-slate-700">{$prog.rating}</span>
                            <span class="text-xs text-gray-500">({$prog.reviews})</span>
                        </div>
                        <p class="text-gray-600 text-sm mb-4 flex-1 line-clamp-2">{$prog.desc|escape}</p>
                        <a href="{url route='program' id=$prog.id}"
                           class="w-full flex items-center justify-center gap-2 bg-slate-900 hover:bg-slate-800 text-white py-2 rounded-lg font-medium transition">
                            Vedi Dettagli <i data-lucide="chevron-right" class="w-4 h-4"></i>
                        </a>
                    </div>
                </div>
            {/foreach}
        </div>

        {* Stato vuoto (ricerca senza risultati) *}
        <div id="empty-search" style="display:none;"
             class="text-center py-16 bg-white rounded-2xl border border-gray-100 shadow-sm mt-6">
            <i data-lucide="search-x" class="w-16 h-16 text-gray-300 mx-auto mb-4"></i>
            <h3 class="text-xl font-bold text-slate-900 mb-2">Nessun programma trovato</h3>
            <p class="text-gray-500">Prova a cercare con un termine diverso.</p>
        </div>

    </div>
</div>
{/block}

{block name="scripts"}
<script>
{literal}
    function openFilters() {
        const modal = document.getElementById('filters-modal');
        if (!modal) return;
        modal.classList.remove('hidden');
        document.body.classList.add('overflow-hidden');
    }

    function closeFilters() {
        const modal = document.getElementById('filters-modal');
        if (!modal) return;
        modal.classList.add('hidden');
        document.body.classList.remove('overflow-hidden');
    }

    function resetFilters() {
        const days = document.getElementById('filter-days');
        const goal = document.getElementById('filter-goal');
        const level = document.getElementById('filter-level');
        if (days) days.value = '';
        if (goal) goal.value = '';
        if (level) level.value = '';
        applyFilters();
    }

    function applyFilters() {
        const termInput = document.getElementById('search-input');
        const daysInput = document.getElementById('filter-days');
        const goalInput = document.getElementById('filter-goal');
        const levelInput = document.getElementById('filter-level');
        const term = termInput ? termInput.value.toLowerCase() : '';
        const days = daysInput ? daysInput.value : '';
        const goal = goalInput ? goalInput.value : '';
        const level = levelInput ? levelInput.value : '';
        const cards = document.querySelectorAll('.program-card');
        let visible = 0;

        cards.forEach(card => {
            const title = card.getAttribute('data-title') || '';
            const cDays = card.getAttribute('data-days') || '';
            const cGoal = card.getAttribute('data-goal') || '';
            const cLevel = card.getAttribute('data-level') || '';

            const matchTerm = title.includes(term);
            const matchDays = !days || cDays === days;
            const matchGoal = !goal || cGoal === goal;
            const matchLevel = !level || cLevel === level;

            if (matchTerm && matchDays && matchGoal && matchLevel) {
                card.style.display = 'flex';
                visible++;
            } else {
                card.style.display = 'none';
            }
        });

        const emptyState = document.getElementById('empty-search');
        if (emptyState) {
            emptyState.style.display = visible === 0 ? 'block' : 'none';
        }
    }
{/literal}
</script>
{/block}
