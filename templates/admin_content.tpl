{*
 * admin_content.tpl
 * Schermata Admin: Gestione Contenuti (schede, coaching, custom, trasformazioni).
 *
 * Variabili attese:
 *   $user              - oggetto admin loggato
 *   $programs          - array schede: id, title, desc, price, img
 *   $coaching          - oggetto coaching: title, desc, price
 *   $custom            - oggetto custom: title, desc, price
 *   $transformations   - array trasformazioni: id, name, result, quote, img
 *   $coupons           - array coupon: id, name, discount, expires_at
 *   $modal             - oggetto modale aperta (null se chiusa):
 *                        type ('program'|'coaching'|'custom'|'transformation'),
 *                        target_id (int|null),
 *                        data (dati pre-compilati per la modifica)
 *   $csrf_token        - token CSRF
 *   $add_program_action, $edit_program_action, $delete_program_action
 *   $add_transformation_action, $edit_transformation_action, $delete_transformation_action
 *   $edit_coaching_action, $edit_custom_action
 *}
{extends file="layout_base.tpl"}

{block name="content"}
<div class="py-12 relative">

    {* ============================
       Modale Admin (se aperta)
       ============================ *}
    {if $modal}
    <div class="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-sm">
        <div class="bg-white rounded-2xl shadow-xl w-full max-w-lg overflow-hidden max-h-[90vh] flex flex-col">
            <div class="px-6 py-4 border-b border-gray-100 flex justify-between items-center bg-gray-50">
                <h3 class="font-bold text-xl text-slate-900">{$modal.title|escape}</h3>
                <a href="{url route='admin-modal-close'}"
                   class="text-gray-400 hover:text-gray-600 transition-colors">
                    <i data-lucide="x" class="w-6 h-6"></i>
                </a>
            </div>

            <form method="POST" action="{$modal.action|escape}" class="p-6 space-y-4 overflow-y-auto" enctype="multipart/form-data">
                <input type="hidden" name="csrf_token" value="{$csrf_token|escape}" />
                {if $modal.target_id}
                    <input type="hidden" name="target_id" value="{$modal.target_id}" />
                {/if}

                {if $modal.type == 'transformation'}
                    <div>
                        <label class="block text-sm font-medium text-slate-700 mb-1">Nome Cliente</label>
                        <input type="text" name="name" required value="{$modal.data.name|default:''|escape}"
                               class="w-full px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 outline-none transition-all">
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-slate-700 mb-1">Risultato (es. -12kg in 3 mesi)</label>
                        <input type="text" name="result" required value="{$modal.data.result|default:''|escape}"
                               class="w-full px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 outline-none transition-all">
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-slate-700 mb-1">Recensione / Citazione</label>
                        <textarea name="quote" required rows="3"
                                  class="w-full px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 outline-none transition-all resize-none"
                                  >{$modal.data.quote|default:''|escape}</textarea>
                    </div>
                          <div>
                           <label class="block text-sm font-medium text-slate-700 mb-1">URL Immagine Prima/Dopo</label>
                           <input type="url" name="img" value="{$modal.data.img|default:''|escape}"
                               placeholder="https://..."
                               class="w-full px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 outline-none transition-all">
                           <p class="text-xs text-gray-500 mt-1">Oppure carica un file.</p>
                           <input type="file" name="img_file" accept="image/jpeg,image/png,image/webp"
                               class="mt-2 w-full text-sm text-gray-600" />
                          </div>
                {elseif $modal.type == 'coupon'}
                    <div>
                        <label class="block text-sm font-medium text-slate-700 mb-1">Nome coupon</label>
                        <input type="text" name="name" required
                               class="w-full px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 outline-none transition-all" />
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-slate-700 mb-1">Sconto (%)</label>
                        <input type="number" name="discount" required step="0.01" min="0"
                               class="w-full px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 outline-none transition-all" />
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-slate-700 mb-1">Scadenza</label>
                        <input type="date" name="expires_at"
                               class="w-full px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 outline-none transition-all" />
                    </div>
                {else}
                    <div>
                        <label class="block text-sm font-medium text-slate-700 mb-1">Titolo</label>
                        <input type="text" name="title" required value="{$modal.data.title|default:''|escape}"
                               class="w-full px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 outline-none transition-all">
                    </div>
                    {if $modal.type == 'program'}
                        <div>
                            <label class="block text-sm font-medium text-slate-700 mb-1">Giorni a settimana</label>
                            <select name="days" required
                                    class="w-full px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 outline-none transition-all">
                                <option value="" disabled {if $modal.data.days|default:'' == ''}selected{/if}>Seleziona</option>
                                <option value="3" {if $modal.data.days|default:'' == '3'}selected{/if}>3 giorni</option>
                                <option value="4" {if $modal.data.days|default:'' == '4'}selected{/if}>4 giorni</option>
                                <option value="5" {if $modal.data.days|default:'' == '5'}selected{/if}>5 giorni</option>
                            </select>
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-slate-700 mb-1">Scopo</label>
                            <select name="goal" required
                                    class="w-full px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 outline-none transition-all">
                                <option value="" disabled {if $modal.data.goal|default:'' == ''}selected{/if}>Seleziona</option>
                                <option value="ipertrofia" {if $modal.data.goal|default:'' == 'ipertrofia'}selected{/if}>Ipertrofia</option>
                                <option value="forza" {if $modal.data.goal|default:'' == 'forza'}selected{/if}>Forza</option>
                                <option value="powerlifting" {if $modal.data.goal|default:'' == 'powerlifting'}selected{/if}>Powerlifting</option>
                                <option value="dimagrimento" {if $modal.data.goal|default:'' == 'dimagrimento'}selected{/if}>Dimagrimento</option>
                                <option value="calisthenics" {if $modal.data.goal|default:'' == 'calisthenics'}selected{/if}>Calisthenics</option>
                                <option value="mobilita" {if $modal.data.goal|default:'' == 'mobilita'}selected{/if}>Mobilita</option>
                            </select>
                        </div>
                        <div>
                            <label class="block text-sm font-medium text-slate-700 mb-1">Livello</label>
                            <select name="level" required
                                    class="w-full px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 outline-none transition-all">
                                <option value="" disabled {if $modal.data.level|default:'' == ''}selected{/if}>Seleziona</option>
                                <option value="base" {if $modal.data.level|default:'' == 'base'}selected{/if}>Base</option>
                                <option value="intermedio" {if $modal.data.level|default:'' == 'intermedio'}selected{/if}>Intermedio</option>
                                <option value="avanzato" {if $modal.data.level|default:'' == 'avanzato'}selected{/if}>Avanzato</option>
                            </select>
                        </div>
                    {/if}
                    <div>
                        <label class="block text-sm font-medium text-slate-700 mb-1">Descrizione</label>
                        <textarea name="desc" required rows="3"
                                  class="w-full px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 outline-none transition-all resize-none"
                                  >{$modal.data.desc|default:''|escape}</textarea>
                    </div>
                    {if $modal.type == 'program'}
                        {if $modal.data.file_path|default:''}
                            <input type="hidden" name="file_path" value="{$modal.data.file_path|escape}" />
                        {/if}
                        <div>
                            <label class="block text-sm font-medium text-slate-700 mb-1">PDF Scheda</label>
                            <input type="file" name="pdf_file" accept="application/pdf"
                                   class="w-full text-sm text-gray-600" />
                            {if $modal.data.file_path|default:''}
                                <p class="text-xs text-gray-500 mt-1">PDF attuale: {$modal.data.file_path|escape}</p>
                            {else}
                                <p class="text-xs text-gray-500 mt-1">Carica un PDF per la scheda standard.</p>
                            {/if}
                        </div>
                    {/if}
                    <div>
                        <label class="block text-sm font-medium text-slate-700 mb-1">Prezzo (€)</label>
                        <input type="number" name="price" required step="0.01" min="0"
                               value="{$modal.data.price|default:''}"
                               class="w-full px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 outline-none transition-all">
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-slate-700 mb-1">URL Immagine</label>
                        <input type="url" name="img" value="{$modal.data.img|default:''|escape}"
                               placeholder="https://..."
                               class="w-full px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 outline-none transition-all">
                        <p class="text-xs text-gray-500 mt-1">Oppure carica un file.</p>
                        <input type="file" name="img_file" accept="image/jpeg,image/png,image/webp"
                               class="mt-2 w-full text-sm text-gray-600" />
                    </div>
                {/if}

                <div class="flex justify-end gap-3 pt-2 border-t border-gray-100">
                    <a href="{url route='admin-modal-close'}"
                       class="px-5 py-2.5 bg-gray-100 text-gray-700 font-medium hover:bg-gray-200 rounded-xl transition-colors">
                        Annulla
                    </a>
                    <button type="submit"
                            class="px-5 py-2.5 bg-emerald-600 text-white font-medium hover:bg-emerald-700 rounded-xl transition-colors shadow-md shadow-emerald-500/20 flex items-center gap-2">
                        <i data-lucide="save" class="w-4 h-4"></i> Salva
                    </button>
                </div>
            </form>
        </div>
    </div>
    {/if}

    {* ============================
       Flash messages
       ============================ *}
    {if $flash_error}
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mb-4">
        <div class="bg-red-50 border border-red-200 text-red-800 rounded-xl px-5 py-3 flex items-start gap-3">
            <i data-lucide="alert-circle" class="w-5 h-5 mt-0.5 flex-shrink-0"></i>
            <span>{$flash_error|escape}</span>
        </div>
    </div>
    {/if}
    {if $flash_success}
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mb-4">
        <div class="bg-emerald-50 border border-emerald-200 text-emerald-800 rounded-xl px-5 py-3 flex items-start gap-3">
            <i data-lucide="check-circle" class="w-5 h-5 mt-0.5 flex-shrink-0"></i>
            <span>{$flash_success|escape}</span>
        </div>
    </div>
    {/if}

    {* ============================
       Corpo pagina
       ============================ *}
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">

        <div class="flex justify-between items-center mb-8">
            <h1 class="text-3xl font-bold text-slate-900">Gestione Contenuti</h1>
        </div>

        {* Tabella Schede *}
        <div class="bg-white rounded-2xl shadow-sm border border-gray-200 overflow-hidden mb-12">
            <div class="px-6 py-4 border-b border-gray-200 bg-gray-50 flex justify-between items-center">
                <h2 class="font-bold text-lg text-slate-800">Schede Allenamento</h2>
                <a href="{url route='admin-modal-open' type='program'}"
                   class="bg-emerald-100 text-emerald-700 hover:bg-emerald-200 px-3 py-1.5 rounded-lg text-sm font-bold transition flex items-center gap-1">
                    <i data-lucide="plus" class="w-4 h-4"></i> Aggiungi
                </a>
            </div>
            <div class="p-6">
                <details class="group">
                    <summary class="cursor-pointer list-none font-semibold text-slate-800 flex items-center justify-between">
                        <span>Mostra schede ({$programs|count})</span>
                        <i data-lucide="chevron-down" class="w-4 h-4 transition-transform group-open:rotate-180"></i>
                    </summary>
                    <div class="mt-4 divide-y divide-gray-200">
                        {if $programs|count == 0}
                            <div class="p-6 text-center text-gray-500">Nessuna scheda presente.</div>
                        {else}
                            {foreach from=$programs item=prog}
                                <div class="p-4 flex items-center gap-6 hover:bg-gray-50 transition">
                                    <img src="{$prog.img|escape}" alt="{$prog.title|escape}"
                                         class="w-16 h-16 rounded-lg object-cover shadow-sm" />
                                    <div class="flex-1">
                                        <h3 class="font-bold text-slate-900">{$prog.title|escape}</h3>
                                        <p class="text-sm text-gray-500 line-clamp-1">{$prog.desc|escape}</p>
                                    </div>
                                    <div class="font-bold text-slate-900 w-24 text-right">€{$prog.price}</div>
                                    <div class="flex items-center gap-2">
                                        <a href="{url route='admin-modal-open' type='program' id=$prog.id}"
                                           class="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition" title="Modifica">
                                            <i data-lucide="edit" class="w-[18px] h-[18px]"></i>
                                        </a>
                                        <form method="POST" action="{$delete_program_action|escape}"
                                              onsubmit="return confirm('Sei sicuro di voler eliminare questa scheda?')">
                                            <input type="hidden" name="csrf_token" value="{$csrf_token|escape}" />
                                            <input type="hidden" name="program_id" value="{$prog.id}" />
                                            <button type="submit" class="p-2 text-red-600 hover:bg-red-50 rounded-lg transition" title="Elimina">
                                                <i data-lucide="trash-2" class="w-[18px] h-[18px]"></i>
                                            </button>
                                        </form>
                                    </div>
                                </div>
                            {/foreach}
                        {/if}
                    </div>
                </details>
            </div>
        </div>

        {* Schede Personalizzate *}
        <div class="mb-12">
            {assign var="sdata" value=$custom}
            <div class="bg-white rounded-2xl shadow-sm border border-gray-200 overflow-hidden">
                <div class="px-6 py-4 border-b border-gray-200 bg-gray-50 flex justify-between items-center">
                    <h2 class="font-bold text-lg text-slate-800">Schede Personalizzate</h2>
                    <a href="{url route='admin-modal-open' type='custom'}"
                       class="text-blue-600 text-sm font-medium hover:underline flex items-center gap-1">
                        <i data-lucide="edit" class="w-3.5 h-3.5"></i> Modifica
                    </a>
                </div>
                <div class="p-6">
                    <h3 class="font-bold text-xl mb-2">{$sdata.title|escape}</h3>
                    <p class="text-gray-600 text-sm mb-4">{$sdata.desc|escape}</p>
                    <div class="font-black text-2xl">€{$sdata.price}</div>
                </div>
            </div>
        </div>

        {* Trasformazioni *}
        <div class="bg-white rounded-2xl shadow-sm border border-gray-200 overflow-hidden mb-12">
            <div class="px-6 py-4 border-b border-gray-200 bg-gray-50 flex justify-between items-center">
                <h2 class="font-bold text-lg text-slate-800">Trasformazioni Clienti (Recensioni)</h2>
                <a href="{url route='admin-modal-open' type='transformation'}"
                   class="bg-emerald-100 text-emerald-700 hover:bg-emerald-200 px-3 py-1.5 rounded-lg text-sm font-bold transition flex items-center gap-1">
                    <i data-lucide="plus" class="w-4 h-4"></i> Aggiungi
                </a>
            </div>
            <div class="p-6">
                <details class="group">
                    <summary class="cursor-pointer list-none font-semibold text-slate-800 flex items-center justify-between">
                        <span>Mostra trasformazioni ({$transformations|count})</span>
                        <i data-lucide="chevron-down" class="w-4 h-4 transition-transform group-open:rotate-180"></i>
                    </summary>
                    <div class="mt-4 divide-y divide-gray-200">
                        {if $transformations|count == 0}
                            <div class="p-6 text-center text-gray-500">Nessuna trasformazione presente.</div>
                        {else}
                            {foreach from=$transformations item=t}
                                <div class="p-4 flex flex-col md:flex-row md:items-center gap-6 hover:bg-gray-50 transition">
                                    <img src="{$t.img|escape}" alt="{$t.name|escape}"
                                         class="w-20 h-20 rounded-xl object-cover shadow-sm" />
                                    <div class="flex-1">
                                        <h3 class="font-bold text-slate-900">
                                            {$t.name|escape}
                                            <span class="text-emerald-600 text-sm ml-2 bg-emerald-50 px-2 py-0.5 rounded">
                                                {$t.result|escape}
                                            </span>
                                        </h3>
                                        <p class="text-sm text-gray-500 mt-1 italic">"{$t.quote|escape}"</p>
                                    </div>
                                    <div class="flex items-center gap-2 mt-4 md:mt-0">
                                        <a href="{url route='admin-modal-open' type='transformation' id=$t.id}"
                                           class="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition" title="Modifica">
                                            <i data-lucide="edit" class="w-[18px] h-[18px]"></i>
                                        </a>
                                        <form method="POST" action="{$delete_transformation_action|escape}"
                                              onsubmit="return confirm('Sei sicuro di voler eliminare questa trasformazione?')">
                                            <input type="hidden" name="csrf_token" value="{$csrf_token|escape}" />
                                            <input type="hidden" name="transformation_id" value="{$t.id}" />
                                            <button type="submit" class="p-2 text-red-600 hover:bg-red-50 rounded-lg transition" title="Elimina">
                                                <i data-lucide="trash-2" class="w-[18px] h-[18px]"></i>
                                            </button>
                                        </form>
                                    </div>
                                </div>
                            {/foreach}
                        {/if}
                    </div>
                </details>
            </div>
        </div>

        {* Coupon *}
        <div class="bg-white rounded-2xl shadow-sm border border-gray-200 overflow-hidden mb-12">
            <div class="px-6 py-4 border-b border-gray-200 bg-gray-50 flex justify-between items-center">
                <h2 class="font-bold text-lg text-slate-800">Coupon</h2>
                <a href="{url route='admin-modal-open' type='coupon'}"
                   class="bg-emerald-100 text-emerald-700 hover:bg-emerald-200 px-3 py-1.5 rounded-lg text-sm font-bold transition flex items-center gap-1">
                    <i data-lucide="plus" class="w-4 h-4"></i> Aggiungi
                </a>
            </div>
            <div class="p-6">
                <details class="group">
                    <summary class="cursor-pointer list-none font-semibold text-slate-800 flex items-center justify-between">
                        <span>Mostra coupon ({$coupons|count})</span>
                        <i data-lucide="chevron-down" class="w-4 h-4 transition-transform group-open:rotate-180"></i>
                    </summary>
                    <div class="mt-4 divide-y divide-gray-200">
                        {if $coupons|count == 0}
                            <div class="p-6 text-center text-gray-500">Nessun coupon presente.</div>
                        {else}
                            {foreach from=$coupons item=c}
                                <div class="p-4 flex flex-col md:flex-row md:items-center gap-4 hover:bg-gray-50 transition">
                                    <div class="flex-1">
                                        <h3 class="font-bold text-slate-900">{$c.name|escape}</h3>
                                        <p class="text-sm text-gray-500">Sconto: {$c.discount}%</p>
                                    </div>
                                    <div class="text-sm text-gray-500">
                                        {if $c.expires_at}Scade: {$c.expires_at|escape}{else}Nessuna scadenza{/if}
                                    </div>
                                    <form method="POST" action="{$delete_coupon_action|escape}"
                                          onsubmit="return confirm('Sei sicuro di voler eliminare questo coupon?')">
                                        <input type="hidden" name="csrf_token" value="{$csrf_token|escape}" />
                                        <input type="hidden" name="coupon_id" value="{$c.id}" />
                                        <button type="submit" class="p-2 text-red-600 hover:bg-red-50 rounded-lg transition" title="Elimina">
                                            <i data-lucide="trash-2" class="w-[18px] h-[18px]"></i>
                                        </button>
                                    </form>
                                </div>
                            {/foreach}
                        {/if}
                    </div>
                </details>
            </div>
        </div>

    </div>
</div>
{/block}
