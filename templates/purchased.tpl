{*
 * purchased.tpl — I Miei Programmi
 *
 * Variabili attese:
 *   $standard_programs  - schede standard acquistate (PDF immediato)
 *                         ogni item: id, title, img, file_path
 *   $custom_schedules   - schede personalizzate completate
 *                         ogni item: id (id_richiesta), title (titolo_personalizzato),
 *                                    img, download_link, date
 *   $pending_requests   - richieste custom ancora in lavorazione
 *                         ogni item: id, type, status
 *   $user_ratings       - mappa [product_id => rating]
 *   $success_message    - stringa opzionale post-acquisto
 *}
{extends file="layout_base.tpl"}

{block name="content"}
<div class="py-12">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">

        <div class="flex items-center justify-between mb-8">
            <h1 class="text-3xl font-bold text-slate-900">I Miei Programmi</h1>
        </div>

        {if $success_message}
            <div class="mb-6 bg-emerald-50 border border-emerald-200 text-emerald-800 px-5 py-4 rounded-xl flex items-center gap-3">
                <i data-lucide="check-circle" class="w-5 h-5 text-emerald-500 shrink-0"></i>
                {$success_message|escape}
            </div>
        {/if}

        {* ── Schede personalizzate in lavorazione ──────────────────────────── *}
        {if $pending_requests|count > 0}
            <div class="mb-10">
                <h2 class="text-lg font-semibold text-slate-700 mb-4 flex items-center gap-2">
                    <i data-lucide="clock" class="w-5 h-5 text-amber-500"></i>
                    In Lavorazione
                </h2>
                <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {foreach from=$pending_requests item=req}
                        <div class="bg-white rounded-2xl p-6 shadow-sm border border-amber-100 flex flex-col h-full">
                            <div class="flex items-start gap-4 mb-6">
                                {if $req.img}
                                    <img src="{$req.img|escape}" alt="{$req.display_title|escape}"
                                         class="w-20 h-20 rounded-lg object-cover shrink-0" />
                                {else}
                                    <div class="w-20 h-20 rounded-lg bg-emerald-50 flex items-center justify-center shrink-0">
                                        <i data-lucide="dumbbell" class="w-8 h-8 text-emerald-400"></i>
                                    </div>
                                {/if}
                                <div>
                                    <span class="text-xs font-medium text-emerald-600 uppercase tracking-wide">Personalizzata</span>
                                    <h3 class="font-bold text-lg text-slate-900 leading-tight mt-0.5">
                                        Scheda Personalizzata
                                    </h3>
                                </div>
                            </div>

                            <div class="mt-auto">
                                {if $req.questionnaire_filled}
                                    {* Questionario già compilato: scheda in preparazione *}
                                    <div class="w-full flex items-center justify-center gap-2 bg-amber-50 border border-amber-200 text-amber-800 py-3 rounded-xl font-medium">
                                        <i data-lucide="clock" class="w-[18px] h-[18px]"></i>
                                        La tua scheda è in arrivo
                                    </div>
                                {else}
                                    {* Questionario non ancora compilato *}
                                    {if $req.product_id > 0}
                                        {* FIX BUG 1: passiamo request_id=$req.id così il controller
                                           aggiorna la richiesta corretta e non sempre l'ultima *}
                                        <a href="{url route='questionnaire' product_id=$req.product_id service=$req.display_title request_id=$req.id}"
                                           class="w-full flex items-center justify-center gap-2 bg-red-600 hover:bg-red-700 text-white py-3 rounded-xl font-medium transition shadow-lg shadow-red-600/20">
                                            <i data-lucide="clipboard-list" class="w-[18px] h-[18px]"></i>
                                            Compila Questionario
                                        </a>
                                    {/if}
                                {/if}
                            </div>
                        </div>
                    {/foreach}
                </div>
            </div>
        {/if}

        {* ── Schede personalizzate completate ──────────────────────────────── *}
        {if $custom_schedules|count > 0}
            <div class="mb-10">
                <h2 class="text-lg font-semibold text-slate-700 mb-4 flex items-center gap-2">
                    <i data-lucide="star" class="w-5 h-5 text-emerald-500"></i>
                    Le Tue Schede Personalizzate
                </h2>
                <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {foreach from=$custom_schedules item=item}
                        <div class="bg-white rounded-2xl p-6 shadow-sm border border-emerald-100 flex flex-col h-full">
                            <div class="flex items-start gap-4 mb-6">
                                {if $item.img}
                                    <img src="{$item.img|escape}" alt="{$item.title|escape}"
                                         class="w-20 h-20 rounded-lg object-cover shrink-0" />
                                {else}
                                    <div class="w-20 h-20 rounded-lg bg-emerald-50 flex items-center justify-center shrink-0">
                                        <i data-lucide="dumbbell" class="w-8 h-8 text-emerald-400"></i>
                                    </div>
                                {/if}
                                <div>
                                    <span class="text-xs font-medium text-emerald-600 uppercase tracking-wide">Personalizzata</span>
                                    <h3 class="font-bold text-lg text-slate-900 leading-tight mt-0.5">{$item.title|escape}</h3>
                                    {if $item.date}
                                        <p class="text-sm text-gray-400 mt-1">Completata il {$item.date|date_format:'%d/%m/%Y'}</p>
                                    {/if}
                                </div>
                            </div>
                            <div class="mt-auto">
                                <a href="{$item.download_link|escape}" target="_blank"
                                   class="w-full flex items-center justify-center gap-2 bg-slate-900 hover:bg-slate-800 text-white py-3 rounded-xl font-medium transition shadow-lg shadow-slate-900/20">
                                    <i data-lucide="download" class="w-[18px] h-[18px]"></i>
                                    Scarica Scheda PDF
                                </a>
                            </div>
                        </div>
                    {/foreach}
                </div>
            </div>
        {/if}

        {* ── Schede standard ───────────────────────────────────────────────── *}
        {if $standard_programs|count > 0}
            <div>
                <h2 class="text-lg font-semibold text-slate-700 mb-4 flex items-center gap-2">
                    <i data-lucide="layout-grid" class="w-5 h-5 text-slate-500"></i>
                    Schede Standard
                </h2>
                <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {foreach from=$standard_programs item=item}
                        {assign var="item_rating" value=$user_ratings[$item.id]|default:0}

                        <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-100 flex flex-col h-full">
                            <div class="flex items-start gap-4 mb-6">
                                <img src="{$item.img|escape}" alt="{$item.title|escape}"
                                     class="w-20 h-20 rounded-lg object-cover shrink-0" />
                                <div>
                                    <h3 class="font-bold text-lg text-slate-900 leading-tight">{$item.title|escape}</h3>
                                </div>
                            </div>

                            <div class="mt-auto space-y-3">
                                {* Stelle valutazione *}
                                <div>
                                    <p class="text-sm font-medium text-slate-700 mb-1">Valuta questo programma</p>
                                    {if $item_rating}
                                        <p class="text-xs text-slate-500 mb-2">La tua valutazione: {$item_rating}/5</p>
                                    {/if}
                                    <form method="POST" action="{url route='purchased'}?action=rate"
                                          class="flex items-center gap-1 rating-form"
                                          data-current-rating="{$item_rating}">
                                        <input type="hidden" name="csrf_token" value="{$csrf_token|escape}" />
                                        <input type="hidden" name="product_id" value="{$item.id}" />
                                        {section name=star loop=5}
                                            {assign var="star_value" value=$smarty.section.star.index+1}
                                            {assign var="is_filled"  value=$star_value <= $item_rating}
                                            <button type="submit" name="rating" value="{$star_value}"
                                                    class="p-1 rounded hover:bg-amber-50 rating-star"
                                                    data-star="{$star_value}"
                                                    aria-label="Valuta {$star_value} su 5">
                                                <i data-lucide="star" class="w-5 h-5 {if $is_filled}fill-amber-400 text-amber-500{else}text-amber-300{/if}"></i>
                                            </button>
                                        {/section}
                                    </form>
                                </div>

                                {* Download PDF *}
                                {if $item.file_path|default:''}
                                    <a href="{$item.file_path|escape}" target="_blank"
                                       class="w-full flex items-center justify-center gap-2 bg-slate-900 hover:bg-slate-800 text-white py-3 rounded-xl font-medium transition shadow-lg shadow-slate-900/20">
                                        <i data-lucide="download" class="w-[18px] h-[18px]"></i>
                                        Scarica PDF
                                    </a>
                                {else}
                                    <button disabled
                                            class="w-full flex items-center justify-center gap-2 bg-slate-100 text-slate-400 py-3 rounded-xl font-medium cursor-not-allowed">
                                        <i data-lucide="file-x" class="w-[18px] h-[18px]"></i>
                                        PDF non disponibile
                                    </button>
                                {/if}
                            </div>
                        </div>
                    {/foreach}
                </div>
            </div>
        {/if}

        {* ── Stato vuoto totale ─────────────────────────────────────────────── *}
        {if $standard_programs|count == 0 && $custom_schedules|count == 0 && $pending_requests|count == 0}
            <div class="bg-white p-12 text-center rounded-2xl shadow-sm border border-gray-100">
                <p class="text-gray-500 text-lg">Non hai ancora acquistato nessun programma.</p>
                <a href="{url route='all-programs'}"
                   class="mt-6 inline-block text-emerald-600 font-bold hover:underline">
                    Scopri i nostri programmi
                </a>
            </div>
        {/if}

    </div>
</div>

<script>
    document.querySelectorAll('.rating-form').forEach((form) => {
        const stars   = Array.from(form.querySelectorAll('.rating-star'));
        const current = Number(form.dataset.currentRating || 0);

        const paint = (value) => {
            stars.forEach((btn) => {
                const sv   = Number(btn.dataset.star || 0);
                const icon = btn.querySelector('i');
                if (!icon) return;
                if (sv <= value) {
                    icon.classList.add('fill-amber-400', 'text-amber-500');
                    icon.classList.remove('text-amber-300');
                } else {
                    icon.classList.remove('fill-amber-400', 'text-amber-500');
                    icon.classList.add('text-amber-300');
                }
            });
        };

        stars.forEach((btn) => {
            btn.addEventListener('mouseenter', () => paint(Number(btn.dataset.star)));
            btn.addEventListener('focus',      () => paint(Number(btn.dataset.star)));
        });
        form.addEventListener('mouseleave', () => paint(current));
        form.addEventListener('focusout',   () => paint(current));
        paint(current);
    });
</script>
{/block}
