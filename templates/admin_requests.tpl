{*
 * admin_requests.tpl
 *
 * Variabili attese:
 *   $requests      - array: id, user, type, status, date, answers, download_link,
 *                           titolo_personalizzato
 *   $pending_count - int
 *   $upload_action - URL POST
 *   $csrf_token    - token CSRF
 *
 * FIX: aggiunto |default:'' su tutti i campi answers.* per evitare
 *      "Warning: Undefined array key" in PHP 8 quando answers_json = '{}'
 *      (richieste create automaticamente all'acquisto, prima che l'utente
 *       compili il questionario).
 *}
{extends file="layout_base.tpl"}

{block name="content"}
<div class="py-12">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">

        <div class="flex items-center justify-between mb-8">
            <h1 class="text-3xl font-bold text-slate-900">Richieste Clienti</h1>
            <div class="bg-amber-100 text-amber-800 px-4 py-2 rounded-lg font-bold flex items-center gap-2">
                <i data-lucide="clock" class="w-5 h-5"></i> {$pending_count} Da Evadere
            </div>
        </div>

        <div class="bg-white rounded-2xl shadow-sm border border-gray-200 overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse">
                    <thead>
                        <tr class="bg-gray-50 border-b border-gray-200 text-xs uppercase tracking-wider text-gray-500">
                            <th class="p-4 font-medium">Data</th>
                            <th class="p-4 font-medium">Email Utente</th>
                            <th class="p-4 font-medium">Servizio</th>
                            <th class="p-4 font-medium">Stato</th>
                            <th class="p-4 font-medium text-right">Azioni</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100">

                        {if $requests|count == 0}
                            <tr>
                                <td colspan="5" class="p-8 text-center text-gray-500">Nessuna richiesta presente.</td>
                            </tr>
                        {else}
                            {foreach from=$requests item=req}
                                <tr class="hover:bg-gray-50 transition-colors">
                                    <td class="p-4 text-sm text-gray-600">{$req.date|escape}</td>
                                    <td class="p-4 text-sm text-slate-900 font-medium">{$req.user|escape}</td>
                                    <td class="p-4 text-sm text-emerald-700 font-medium">{$req.type|escape}</td>
                                    <td class="p-4 text-sm">
                                        {if $req.status == 'pending'}
                                            <span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-medium bg-amber-100 text-amber-800">
                                                <i data-lucide="clock" class="w-3 h-3"></i> In attesa
                                            </span>
                                        {else}
                                            <span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-medium bg-emerald-100 text-emerald-800">
                                                <i data-lucide="check-circle" class="w-3 h-3"></i> Completata
                                                {if $req.titolo_personalizzato}
                                                    — <span class="font-normal">{$req.titolo_personalizzato|escape}</span>
                                                {/if}
                                            </span>
                                        {/if}
                                    </td>
                                    <td class="p-4 text-right">
                                        <button onclick="toggleRequestDetails('{$req.id|escape}')"
                                                class="text-blue-600 hover:text-blue-800 text-sm font-medium mr-3 transition-colors">
                                            Vedi Dettagli
                                        </button>
                                    </td>
                                </tr>

                                {* Riga espandibile con dettagli + form upload *}
                                <tr id="details-{$req.id|escape}" class="hidden bg-slate-50 border-b-2 border-slate-200">
                                    <td colspan="5" class="p-6">
                                        <div class="bg-white rounded-xl border border-gray-200 p-6 shadow-inner">

                                            {* Se il questionario non è stato ancora compilato mostra avviso *}
                                            {assign var="has_answers" value=($req.answers.nome|default:'')|trim neq ''}

                                            <h4 class="font-bold text-slate-900 mb-4 border-b pb-4 flex items-start justify-between gap-4">
                                                <span>
                                                    {if $has_answers}
                                                        Questionario di {$req.answers.nome|default:$req.user|escape}
                                                    {else}
                                                        <span class="text-amber-700">
                                                            <i data-lucide="alert-circle" class="w-4 h-4 inline-block"></i>
                                                            Questionario non ancora compilato dall'utente
                                                        </span>
                                                    {/if}
                                                </span>

                                                {if $req.status == 'pending'}
                                                    {* ── Form upload con campo nome obbligatorio ── *}
                                                    <form method="POST" action="{$upload_action|escape}"
                                                          class="flex flex-col gap-2 min-w-[320px]"
                                                          enctype="multipart/form-data">
                                                        <input type="hidden" name="csrf_token" value="{$csrf_token|escape}" />
                                                        <input type="hidden" name="request_id" value="{$req.id|escape}" />

                                                        <label class="text-xs font-medium text-gray-500 uppercase tracking-wide">
                                                            Nome scheda (visibile all'utente)
                                                        </label>
                                                        <input type="text"
                                                               name="titolo_personalizzato"
                                                               placeholder="Es: Scheda Ipertrofia Maggio 2026"
                                                               required
                                                               class="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-400" />

                                                        <div class="flex items-center gap-3 mt-1">
                                                            <input type="file" name="pdf_file" accept="application/pdf"
                                                                   required class="text-sm text-gray-600 flex-1" />
                                                            <button type="submit"
                                                                    class="bg-emerald-500 hover:bg-emerald-600 text-white px-4 py-2 rounded-lg text-sm transition flex items-center gap-2 whitespace-nowrap">
                                                                <i data-lucide="upload" class="w-4 h-4"></i> Carica Scheda
                                                            </button>
                                                        </div>
                                                    </form>
                                                {else}
                                                    <div class="text-emerald-600 flex items-center gap-2 text-sm">
                                                        <i data-lucide="check-circle" class="w-4 h-4"></i>
                                                        Scheda inviata come <strong>{$req.titolo_personalizzato|escape}</strong>
                                                        {if $req.download_link}
                                                            — <a href="{$req.download_link|escape}" target="_blank"
                                                                 class="text-emerald-700 underline">Apri PDF</a>
                                                        {/if}
                                                    </div>
                                                {/if}
                                            </h4>

                                            {if $has_answers}
                                                {* ── Dati questionario ── *}
                                                <div class="grid md:grid-cols-2 gap-y-4 gap-x-8 text-sm">
                                                    <div class="md:col-span-2">
                                                        <span class="text-gray-500 block text-xs uppercase mb-1">Motivazione</span>
                                                        {* FIX: |default:'' previene "Undefined array key" su PHP 8 *}
                                                        <span class="font-medium text-slate-800">{$req.answers.motivazione|default:''|escape}</span>
                                                    </div>
                                                    <div>
                                                        <span class="text-gray-500 block text-xs uppercase mb-1">Età / Altezza / Peso</span>
                                                        <span class="font-medium text-slate-800">
                                                            {$req.answers.eta|default:''|escape} |
                                                            {$req.answers.altezza|default:''|escape} cm |
                                                            {$req.answers.peso|default:''|escape} kg
                                                        </span>
                                                    </div>
                                                    <div>
                                                        <span class="text-gray-500 block text-xs uppercase mb-1">Esperienza / Impegno</span>
                                                        <span class="font-medium text-slate-800">
                                                            {$req.answers.esperienza|default:''|escape} anni |
                                                            {$req.answers.effort|default:''|escape}
                                                        </span>
                                                    </div>
                                                    <div>
                                                        <span class="text-gray-500 block text-xs uppercase mb-1">Giorni a settimana</span>
                                                        <span class="font-medium text-slate-800">{$req.answers.giorni|default:''|escape}</span>
                                                    </div>
                                                    <div>
                                                        <span class="text-gray-500 block text-xs uppercase mb-1">Tempo per seduta</span>
                                                        <span class="font-medium text-slate-800">{$req.answers.tempo|default:''|escape}</span>
                                                    </div>
                                                    <div class="md:col-span-2">
                                                        <span class="text-gray-500 block text-xs uppercase mb-1">Attrezzatura</span>
                                                        <span class="font-medium text-slate-800">
                                                            {* FIX: isset() protegge da undefined key su array *}
                                                            {if isset($req.answers.attrezzatura) && $req.answers.attrezzatura|count > 0}
                                                                {foreach from=$req.answers.attrezzatura item=equip name=eqloop}
                                                                    {$equip|escape}{if not $smarty.foreach.eqloop.last}, {/if}
                                                                {/foreach}
                                                            {else}N/A{/if}
                                                        </span>
                                                    </div>
                                                    <div class="md:col-span-2">
                                                        <span class="text-gray-500 block text-xs uppercase mb-1">Da Evitare</span>
                                                        <span class="font-medium text-slate-800">{$req.answers.evitare|default:'Nessuno'|escape}</span>
                                                    </div>
                                                    <div class="md:col-span-2">
                                                        <span class="text-gray-500 block text-xs uppercase mb-1">Infortuni / Patologie</span>
                                                        <span class="font-medium text-slate-800">{$req.answers.infortuni|default:'Nessuno indicato'|escape}</span>
                                                    </div>

                                                    {* FIX: isset() protegge da undefined key su array *}
                                                    {if isset($req.answers.photos) && $req.answers.photos|count > 0}
                                                        <div class="md:col-span-2 mt-4 pt-4 border-t border-gray-100">
                                                            <span class="text-gray-500 block text-xs uppercase mb-2">Foto Allegate</span>
                                                            <div class="flex gap-4 overflow-x-auto pb-2">
                                                                {foreach from=$req.answers.photos key=k item=v}
                                                                    <a href="{$v|escape}" target="_blank" class="block shrink-0">
                                                                        <img src="{$v|escape}"
                                                                             class="h-32 w-24 object-cover rounded border border-gray-200 hover:opacity-80 transition shadow-sm"
                                                                             alt="{$k|escape}" title="{$k|escape}">
                                                                    </a>
                                                                {/foreach}
                                                            </div>
                                                        </div>
                                                    {/if}
                                                </div>
                                            {else}
                                                {* Questionario vuoto: messaggio placeholder *}
                                                <div class="text-center py-8 text-gray-400">
                                                    <i data-lucide="clipboard" class="w-10 h-10 mx-auto mb-2 opacity-40"></i>
                                                    <p class="text-sm">L'utente non ha ancora compilato il questionario.<br>
                                                    Potrai caricare la scheda una volta ricevute le informazioni.</p>
                                                </div>
                                            {/if}

                                        </div>
                                    </td>
                                </tr>
                            {/foreach}
                        {/if}
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
{/block}

{block name="scripts"}
<script>
{literal}
    function toggleRequestDetails(reqId) {
        const row = document.getElementById('details-' + reqId);
        if (!row) return;
        row.classList.toggle('hidden');
        row.classList.toggle('table-row');
        lucide.createIcons();
    }
{/literal}
</script>
{/block}
