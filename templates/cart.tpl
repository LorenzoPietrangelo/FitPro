{*
 * cart.tpl
 * Schermata: Carrello e Checkout.
 *
 * Variabili attese:
 *   $cart_items       - array di prodotti nel carrello: id, title, desc, price, img
 *   $subtotal         - float
 *   $discount         - float, sconto da coupon
 *   $total            - float, totale finale
 *   $coupon_value     - stringa coupon inserito
 *   $checkout_action  - URL POST per il checkout
 *   $coupon_action    - URL POST per applicare il coupon
 *   $csrf_token       - token CSRF
 *}
{extends file="layout_base.tpl"}

{block name="content"}

{if $cart_items|count == 0}

    {* Carrello vuoto *}
    <div class="min-h-[70vh] flex flex-col items-center justify-center text-center px-4">
        <i data-lucide="shopping-cart" class="w-16 h-16 text-gray-300 mb-6"></i>
        <h2 class="text-3xl font-bold text-slate-900 mb-4">Il tuo carrello è vuoto</h2>
        <p class="text-gray-500 mb-8">Non hai ancora aggiunto nessun programma al carrello.</p>
        <a href="{url route='all-programs'}"
           class="bg-emerald-500 text-white px-8 py-3 rounded-lg font-bold hover:bg-emerald-600 transition shadow-lg shadow-emerald-500/30">
            Esplora Programmi
        </a>
    </div>

{else}

    <div class="py-12">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <h1 class="text-3xl font-bold text-slate-900 mb-8">Checkout</h1>

            <div class="grid lg:grid-cols-12 gap-8">

                {* Lista prodotti *}
                <div class="lg:col-span-7 space-y-4">
                    {foreach from=$cart_items item=item}
                        <div class="bg-white p-4 rounded-xl shadow-sm border border-gray-100 flex items-center gap-4">
                            <img src="{$item.img|escape}" alt="{$item.title|escape}" class="w-24 h-24 object-cover rounded-lg" />
                            <div class="flex-1">
                                <h3 class="font-bold text-slate-900">{$item.title|escape}</h3>
                                <p class="text-sm text-gray-500 line-clamp-1">{$item.desc|escape}</p>
                            </div>
                            <div class="text-right">
                                <p class="font-bold text-lg text-slate-900">€{$item.price}</p>
                                <form method="POST" action="{url route='cart-remove'}" class="inline">
                                    <input type="hidden" name="csrf_token" value="{$csrf_token|escape}" />
                                    <input type="hidden" name="product_id" value="{$item.id}" />
                                    <button type="submit"
                                            class="text-red-500 text-sm hover:underline mt-1 font-medium flex items-center justify-end gap-1">
                                        <i data-lucide="trash-2" class="w-3 h-3"></i> Rimuovi
                                    </button>
                                </form>
                            </div>
                        </div>
                    {/foreach}
                </div>

                {* Riepilogo ordine *}
                <div class="lg:col-span-5">
                    <div class="bg-white p-6 rounded-2xl shadow-xl border border-gray-100 sticky top-24">
                        <h3 class="text-xl font-bold text-slate-900 mb-6 border-b pb-4">Riepilogo Ordine</h3>

                        <div class="space-y-3 mb-6">
                            <div class="flex justify-between text-gray-600">
                                <span>Subtotale</span>
                                <span>€{$subtotal|string_format:"%.2f"}</span>
                            </div>

                            {* Coupon *}
                            <form method="POST" action="{$coupon_action|escape}" class="flex gap-2 pt-2">
                                <input type="hidden" name="csrf_token" value="{$csrf_token|escape}" />
                                <input type="text"
                                       name="coupon"
                                       value="{$coupon_value|escape}"
                                       placeholder="Codice Coupon (es. SCONTO10)"
                                       class="flex-1 border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-emerald-500 focus:border-emerald-500" />
                                <button type="submit"
                                        class="bg-slate-900 text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-slate-800 transition">
                                    Applica
                                </button>
                            </form>

                            {if $discount > 0}
                                <div class="flex justify-between text-emerald-600 font-medium text-sm">
                                    <span>Sconto Coupon</span>
                                    <span>-€{$discount|string_format:"%.2f"}</span>
                                </div>
                            {/if}

                            <div class="flex justify-between text-xl font-bold text-slate-900 pt-4 border-t border-gray-200">
                                <span>Totale</span>
                                <span>€{$total|string_format:"%.2f"}</span>
                            </div>
                        </div>

                        {* Dati pagamento (mock) *}
                        <div class="space-y-4 mb-8">
                            <h4 class="font-semibold text-sm text-gray-700 uppercase tracking-wider mb-2">Dati Pagamento</h4>
                            <div class="relative">
                                <i data-lucide="credit-card" class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-5 h-5"></i>
                                <input type="text" placeholder="Numero Carta"
                                       class="w-full pl-10 pr-3 py-3 border border-gray-300 rounded-lg focus:ring-emerald-500 focus:border-emerald-500" />
                            </div>
                            <div class="grid grid-cols-2 gap-4">
                                <input type="text" placeholder="MM/AA"
                                       class="w-full px-3 py-3 border border-gray-300 rounded-lg focus:ring-emerald-500 focus:border-emerald-500" />
                                <input type="text" placeholder="CVC"
                                       class="w-full px-3 py-3 border border-gray-300 rounded-lg focus:ring-emerald-500 focus:border-emerald-500" />
                            </div>
                        </div>

                        <form method="POST" action="{$checkout_action|escape}">
                            <input type="hidden" name="csrf_token" value="{$csrf_token|escape}" />
                            <input type="hidden" name="total" value="{$total}" />
                            <button type="submit"
                                    class="w-full bg-emerald-500 hover:bg-emerald-600 text-white py-4 rounded-xl font-bold text-lg flex items-center justify-center gap-2 shadow-lg shadow-emerald-500/30 transition-transform active:scale-95">
                                <i data-lucide="lock" class="w-[18px] h-[18px]"></i>
                                Paga €{$total|string_format:"%.2f"}
                            </button>
                        </form>

                    </div>
                </div>
            </div>
        </div>
    </div>

{/if}
{/block}
