{*
 * admin_purchases.tpl
 * Schermata Admin: Gestione Acquisti Clienti.
 *
 * Variabili attese:
 *   $purchases       - array ordini: id, user, date, total, products[]
 *                      products[]: title, price
 *   $total_revenue   - float, somma di tutti i totali ordine
 *}
{extends file="layout_base.tpl"}

{block name="content"}
<div class="py-12">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">

        <h1 class="text-3xl font-bold text-slate-900 mb-8">Gestione Acquisti Clienti</h1>

        {* KPI Cards *}
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
            <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-200">
                <p class="text-sm text-gray-500 font-medium uppercase tracking-wider mb-1">Entrate Totali</p>
                <p class="text-3xl font-black text-emerald-600">€{$total_revenue|string_format:"%.2f"}</p>
            </div>
            <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-200">
                <p class="text-sm text-gray-500 font-medium uppercase tracking-wider mb-1">Totale Ordini</p>
                <p class="text-3xl font-black text-slate-900">{$purchases|count}</p>
            </div>
        </div>

        {* Tabella ordini *}
        <div class="bg-white rounded-2xl shadow-sm border border-gray-200 overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse">
                    <thead>
                        <tr class="bg-gray-50 border-b border-gray-200 text-xs uppercase tracking-wider text-gray-500">
                            <th class="p-4 font-medium w-8"></th>
                            <th class="p-4 font-medium">ID Ordine</th>
                            <th class="p-4 font-medium">Data</th>
                            <th class="p-4 font-medium">Utente</th>
                            <th class="p-4 font-medium">N° Prodotti</th>
                            <th class="p-4 font-medium text-right">Totale Ordine</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-100">
                        {if $purchases|count == 0}
                            <tr>
                                <td colspan="6" class="p-8 text-center text-gray-500">Nessun acquisto registrato.</td>
                            </tr>
                        {else}
                            {foreach from=$purchases item=order}
                                {* Riga principale dell'ordine — cliccabile *}
                                <tr class="hover:bg-gray-50 transition-colors cursor-pointer order-row"
                                    onclick="toggleOrder('order-{$order.id}', this)">
                                    <td class="p-4 text-center">
                                        <i data-lucide="chevron-down" class="chevron w-4 h-4 transition-transform"></i>
                                    </td>
                                    <td class="p-4 text-sm font-medium text-slate-900">#{$order.id}</td>
                                    <td class="p-4 text-sm text-gray-600">{$order.date|escape}</td>
                                    <td class="p-4 text-sm text-gray-600">{$order.user|escape}</td>
                                    <td class="p-4 text-sm text-gray-600">
                                        <span class="inline-flex items-center gap-1 bg-slate-100 text-slate-700 text-xs font-semibold px-2 py-0.5 rounded-full">
                                            {$order.products|count}
                                            {if $order.products|count == 1}prodotto{else}prodotti{/if}
                                        </span>
                                    </td>
                                    <td class="p-4 text-sm font-bold text-emerald-600 text-right">
                                        €{$order.total|string_format:"%.2f"}
                                    </td>
                                </tr>

                                {* Riga espandibile con i dettagli dei prodotti *}
                                <tr id="order-{$order.id}" class="hidden bg-gray-50/70">
                                    <td colspan="6" class="px-8 py-4">
                                        <p class="text-xs font-semibold uppercase tracking-wider text-gray-400 mb-3">Prodotti nell'ordine</p>
                                        <table class="w-full text-sm">
                                            <thead>
                                                <tr class="text-xs uppercase tracking-wider text-gray-400 border-b border-gray-200">
                                                    <th class="pb-2 font-medium text-left">Prodotto</th>
                                                    <th class="pb-2 font-medium text-right">Prezzo</th>
                                                </tr>
                                            </thead>
                                            <tbody class="divide-y divide-gray-100">
                                                {foreach from=$order.products item=prod}
                                                    <tr>
                                                        <td class="py-2 text-slate-800 font-medium">{$prod.title|escape}</td>
                                                        <td class="py-2 text-right text-emerald-600 font-semibold">€{$prod.price|string_format:"%.2f"}</td>
                                                    </tr>
                                                {/foreach}
                                            </tbody>
                                        </table>
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

<script>
function toggleOrder(rowId, triggerRow) {
    const detailRow = document.getElementById(rowId);
    const chevron   = triggerRow.querySelector('.chevron');

    if (detailRow.classList.contains('hidden')) {
        detailRow.classList.remove('hidden');
        chevron.style.transform = 'rotate(180deg)';
        triggerRow.classList.add('bg-slate-50');
    } else {
        detailRow.classList.add('hidden');
        chevron.style.transform = 'rotate(0deg)';
        triggerRow.classList.remove('bg-slate-50');
    }
}
</script>
{/block}
