{*
 * questionnaire.tpl
 * Schermata: Questionario iniziale post-acquisto (Coaching / Scheda Personalizzata).
 *
 * Variabili attese:
 *   $service_title   - nome del servizio acquistato (es. "Coaching 1-to-1")
 *   $submit_action   - URL POST per inviare il questionario
 *   $csrf_token      - token CSRF
 *}
{extends file="layout_base.tpl"}

{block name="content"}
<div class="py-12 bg-[#F0EBF8] min-h-screen font-sans">
    <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">

        <a href="{url route='purchased'}"
           class="flex items-center gap-2 text-gray-600 hover:text-emerald-600 mb-6 transition font-medium">
            <i data-lucide="arrow-left" class="w-5 h-5"></i> Indietro
        </a>

        <form method="POST" action="{$submit_action|escape}" enctype="multipart/form-data" class="space-y-4">
            <input type="hidden" name="csrf_token" value="{$csrf_token|escape}" />
            <input type="hidden" name="service_title" value="{$service_title|escape}" />
            {* FIX BUG 1: passa l'ID richiesta specifica così il controller sa quale aggiornare *}
            {if $request_id > 0}
                <input type="hidden" name="request_id" value="{$request_id}" />
            {/if}

            {* Header stile Google Forms *}
            <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
                <div class="h-3 bg-emerald-600 w-full"></div>
                <div class="p-6 md:p-8">
                    <h1 class="text-3xl font-normal text-slate-900 mb-2">Questionario Iniziale - FitStore</h1>
                    <h2 class="text-emerald-700 font-bold mb-4 uppercase tracking-wider text-sm">
                        {$service_title|escape}
                    </h2>
                    <p class="text-gray-600 text-sm leading-relaxed mb-4">
                        Compila questo modulo con la massima precisione. Le tue risposte ci aiuteranno
                        a strutturare il programma di allenamento perfetto per te.
                    </p>
                    <hr class="border-gray-200 my-4" />
                    <p class="text-red-500 text-sm font-medium">* Indica una domanda obbligatoria</p>
                </div>
            </div>

            {* 1. Nome *}
            <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6 md:p-8">
                <label class="block text-base text-slate-900 mb-4">
                    come ti chiami? <span class="text-red-500">*</span>
                </label>
                <input type="text" name="nome" required
                       class="w-full md:w-1/2 px-0 py-2 border-b border-gray-300 focus:border-emerald-600 focus:ring-0 outline-none transition-colors bg-transparent"
                       placeholder="La tua risposta">
            </div>

            {* 2. Motivazione *}
            <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6 md:p-8">
                <label class="block text-base text-slate-900 mb-4">
                    cosa ti spinge a voler intraprendere questo percorso? <span class="text-red-500">*</span>
                </label>
                <textarea name="motivazione" required rows="1"
                          class="w-full px-0 py-2 border-b border-gray-300 focus:border-emerald-600 focus:ring-0 outline-none transition-colors bg-transparent resize-none overflow-hidden"
                          placeholder="La tua risposta"
                          oninput="this.style.height = ''; this.style.height = this.scrollHeight + 'px'"></textarea>
            </div>

            {* 3. Età *}
            <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6 md:p-8">
                <label class="block text-base text-slate-900 mb-4">quanti anni hai? <span class="text-red-500">*</span></label>
                <div class="space-y-3">
                    {foreach from=['18-30','30-40','40<'] item=eta_val}
                        <label class="flex items-center gap-3 cursor-pointer group">
                            <input type="radio" value="{$eta_val}" name="eta" required
                                   class="w-5 h-5 text-emerald-600 focus:ring-emerald-500 border-gray-300 cursor-pointer">
                            <span class="text-slate-800">{$eta_val}</span>
                        </label>
                    {/foreach}
                </div>
            </div>

            {* 4. Altezza *}
            <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6 md:p-8">
                <label class="block text-base text-slate-900 mb-4">quanto sei alto? <span class="text-red-500">*</span></label>
                <input type="text" name="altezza" required
                       class="w-full md:w-1/2 px-0 py-2 border-b border-gray-300 focus:border-emerald-600 focus:ring-0 outline-none transition-colors bg-transparent"
                       placeholder="La tua risposta">
            </div>

            {* 5. Peso *}
            <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6 md:p-8">
                <label class="block text-base text-slate-900 mb-4">quanto pesi? <span class="text-red-500">*</span></label>
                <input type="text" name="peso" required
                       class="w-full md:w-1/2 px-0 py-2 border-b border-gray-300 focus:border-emerald-600 focus:ring-0 outline-none transition-colors bg-transparent"
                       placeholder="La tua risposta">
            </div>

            {* 6. Esperienza *}
            <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6 md:p-8">
                <label class="block text-base text-slate-900 mb-4">
                    quanti anni di esperienza hai nel mondo della palestra? <span class="text-red-500">*</span>
                </label>
                <div class="space-y-3">
                    {foreach from=['0','1-2','3-5','5<'] item=exp_val}
                        <label class="flex items-center gap-3 cursor-pointer group">
                            <input type="radio" value="{$exp_val}" name="esperienza" required
                                   class="w-5 h-5 text-emerald-600 focus:ring-emerald-500 border-gray-300">
                            <span class="text-slate-800">{$exp_val}</span>
                        </label>
                    {/foreach}
                </div>
            </div>

            {* 7. Effort *}
            <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6 md:p-8">
                <label class="block text-base text-slate-900 mb-4">
                    sei in grado di esprimere effort (arrivare a cedimento)? <span class="text-red-500">*</span>
                </label>
                <div class="space-y-3">
                    {foreach from=['si','No','abbastanza'] item=eff_val}
                        <label class="flex items-center gap-3 cursor-pointer group">
                            <input type="radio" value="{$eff_val}" name="effort" required
                                   class="w-5 h-5 text-emerald-600 focus:ring-emerald-500 border-gray-300">
                            <span class="text-slate-800">{$eff_val}</span>
                        </label>
                    {/foreach}
                </div>
            </div>

            {* 8. Giorni *}
            <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6 md:p-8">
                <label class="block text-base text-slate-900 mb-4">
                    quanti giorni a settimana ti vorresti allenare? <span class="text-red-500">*</span>
                </label>
                <div class="space-y-3">
                    {foreach from=['2 giorni','3 giorni','4 giorni','Giorni alterni'] item=day_val}
                        <label class="flex items-center gap-3 cursor-pointer group">
                            <input type="radio" value="{$day_val}" name="giorni" required
                                   class="w-5 h-5 text-emerald-600 focus:ring-emerald-500 border-gray-300">
                            <span class="text-slate-800">{$day_val}</span>
                        </label>
                    {/foreach}
                    <label class="flex items-center gap-3 cursor-pointer group">
                        <input type="radio" value="Altro" name="giorni" required
                               class="w-5 h-5 text-emerald-600 focus:ring-emerald-500 border-gray-300">
                        <span class="text-slate-800">Altro:</span>
                        <input type="text" name="giorni_altro"
                               class="flex-1 border-b border-gray-300 focus:border-emerald-600 focus:ring-0 outline-none transition-colors bg-transparent ml-2">
                    </label>
                </div>
            </div>

            {* 9. Tempo *}
            <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6 md:p-8">
                <label class="block text-base text-slate-900 mb-4">
                    quanto tempo vorresti spendere in palestra per seduta? <span class="text-red-500">*</span>
                </label>
                <div class="space-y-3">
                    {foreach from=['45 min','60 min','90 min','120 min','180 min'] item=time_val}
                        <label class="flex items-center gap-3 cursor-pointer group">
                            <input type="radio" value="{$time_val}" name="tempo" required
                                   class="w-5 h-5 text-emerald-600 focus:ring-emerald-500 border-gray-300">
                            <span class="text-slate-800">{$time_val}</span>
                        </label>
                    {/foreach}
                    <label class="flex items-center gap-3 cursor-pointer group">
                        <input type="radio" value="Altro" name="tempo" required
                               class="w-5 h-5 text-emerald-600 focus:ring-emerald-500 border-gray-300">
                        <span class="text-slate-800">Altro:</span>
                        <input type="text" name="tempo_altro"
                               class="flex-1 border-b border-gray-300 focus:border-emerald-600 focus:ring-0 outline-none transition-colors bg-transparent ml-2">
                    </label>
                </div>
            </div>

            {* 10. Esercizi da evitare *}
            <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6 md:p-8">
                <label class="block text-base text-slate-900 mb-4">
                    hai degli esercizi che vorresti EVITARE nella scheda?
                </label>
                <textarea name="evitare" rows="1"
                          class="w-full px-0 py-2 border-b border-gray-300 focus:border-emerald-600 focus:ring-0 outline-none transition-colors bg-transparent resize-none overflow-hidden"
                          placeholder="La tua risposta"
                          oninput="this.style.height = ''; this.style.height = this.scrollHeight + 'px'"></textarea>
            </div>

            {* 11. Esercizi da avere *}
            <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6 md:p-8">
                <label class="block text-base text-slate-900 mb-4">
                    hai degli esercizi che vorresti AVERE nella scheda?
                </label>
                <textarea name="avere" rows="1"
                          class="w-full px-0 py-2 border-b border-gray-300 focus:border-emerald-600 focus:ring-0 outline-none transition-colors bg-transparent resize-none overflow-hidden"
                          placeholder="La tua risposta"
                          oninput="this.style.height = ''; this.style.height = this.scrollHeight + 'px'"></textarea>
            </div>

            {* 12. Infortuni *}
            <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6 md:p-8">
                <label class="block text-base text-slate-900 mb-4">
                    soffri o hai sofferto di infortuni?
                </label>
                <textarea name="infortuni" rows="1"
                          class="w-full px-0 py-2 border-b border-gray-300 focus:border-emerald-600 focus:ring-0 outline-none transition-colors bg-transparent resize-none overflow-hidden"
                          placeholder="La tua risposta"
                          oninput="this.style.height = ''; this.style.height = this.scrollHeight + 'px'"></textarea>
            </div>

            {* 13. Attrezzatura *}
            <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6 md:p-8">
                <label class="block text-base text-slate-900 mb-4">
                    quali attrezzi hai a tua disposizione?
                </label>
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    {foreach from=['cavo alto/basso','cavo regolabile','multipower','lat machine','cable pulley',
                                   'chest supported tbar row','sbarra alta','peck deck/fly','chest press',
                                   'incline chest press','side delt machine','panca scot','hack squat',
                                   'leg press','leg extension','hyperextension 45','leg curl da seduto',
                                   'leg curl da allungato','adductor machine','Vulken'] item=att}
                        <label class="flex items-center gap-3 cursor-pointer group">
                            {* FIX BUG 2: name="attrezzatura[]" (con []) così PHP riceve un array
                               con TUTTI i checkbox selezionati, non solo l'ultimo *}
                            <input type="checkbox" value="{$att}" name="attrezzatura[]"
                                   class="w-5 h-5 rounded text-emerald-600 focus:ring-emerald-500 border-gray-300">
                            <span class="text-slate-800 text-sm capitalize">{$att}</span>
                        </label>
                    {/foreach}
                    <label class="flex items-center gap-3 cursor-pointer group col-span-full mt-2">
                        <input type="checkbox" value="Altro" name="attrezzatura[]"
                               class="w-5 h-5 rounded text-emerald-600 focus:ring-emerald-500 border-gray-300">
                        <span class="text-slate-800 text-sm">Altro:</span>
                        <input type="text" name="attrezzatura_altro"
                               class="flex-1 border-b border-gray-300 focus:border-emerald-600 focus:ring-0 outline-none transition-colors bg-transparent ml-2">
                    </label>
                </div>
            </div>

            {* 14. Foto *}
            <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-6 md:p-8">
                <label class="block text-base text-slate-900 mb-2">
                    Ti chiedo di caricare 5 fotografie <span class="text-red-500">*</span>
                </label>
                <p class="text-gray-600 text-sm mb-6">
                    Le immagini devono mostrare l'intero corpo (torso e arti visibili), non devono essere
                    scattate allo specchio e devono essere ben illuminate, nitide.
                    Questo sono le pose che vanno fotografate:
                </p>
                <div class="space-y-4">
                    {section name=foto loop=5}
                        <div>
                            <label class="block text-sm font-medium text-slate-700 mb-1">Foto {$smarty.section.foto.iteration}</label>
                            <input type="file"
                                   name="foto_{$smarty.section.foto.iteration}"
                                   required
                                   accept="image/*"
                                   class="w-full text-sm text-slate-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-emerald-50 file:text-emerald-700 hover:file:bg-emerald-100 transition-colors">
                        </div>
                    {/section}
                </div>
            </div>

            {* Submit *}
            <div class="flex items-center justify-between pt-4 pb-12">
                <button type="submit"
                        class="bg-emerald-600 hover:bg-emerald-700 text-white px-6 py-2.5 rounded-md font-medium transition-colors">
                    Invia
                </button>
                <button type="reset"
                        class="text-sm font-medium text-emerald-600 hover:bg-emerald-50 px-4 py-2 rounded transition-colors">
                    Svuota modulo
                </button>
            </div>

        </form>
    </div>
</div>
{/block}
