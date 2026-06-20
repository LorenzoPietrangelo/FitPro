{*
 * detail.tpl
 * Schermata: dettaglio singolo prodotto (scheda standard o personalizzata).
 *
 * Variabili attese:
 *   $item       - oggetto prodotto: id, title, desc, price, img
 *                 opzionali: rating, reviews (solo per schede standard)
 *   $type       - stringa: 'program' | 'custom'
 *   $user       - oggetto utente corrente (null se ospite)
 *   $back_route - route per il pulsante "Indietro" (es. 'all-programs' o 'home')
 *}
{extends file="layout_base.tpl"}

{block name="content"}
<div class="min-h-screen py-12">
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">

        <a href="{url route=$back_route}"
           class="flex items-center gap-2 text-gray-500 hover:text-emerald-600 mb-8 transition font-medium">
            <i data-lucide="arrow-left" class="w-5 h-5"></i> Indietro
        </a>

        <div class="bg-white rounded-3xl shadow-xl overflow-hidden border border-gray-100">

            {* Immagine hero con titolo in overlay *}
            <div class="h-64 sm:h-96 w-full relative">
                <img src="{$item.img|escape}" alt="{$item.title|escape}" class="w-full h-full object-cover" />
                <div class="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent"></div>
                <div class="absolute bottom-6 left-6 right-6">
                    {if $type == 'custom'}
                        <span class="inline-block bg-emerald-500 text-white text-xs font-bold uppercase tracking-wider py-1 px-3 rounded-full mb-3">
                            Personalizzato
                        </span>
                    {/if}
                    <h1 class="text-4xl sm:text-5xl font-extrabold text-white mb-2">{$item.title|escape}</h1>

                    {if isset($item.rating)}
                        <div class="flex items-center gap-2 text-white/90 font-medium mt-2">
                            <i data-lucide="star" class="w-5 h-5 fill-amber-400 text-amber-400"></i>
                            <span class="text-lg">{$item.rating}</span>
                            <span class="text-white/70 text-sm">({$item.reviews} recensioni verificate)</span>
                        </div>
                    {/if}
                </div>
            </div>

            {* Corpo: prezzo + descrizione *}
            <div class="p-8 sm:p-12">
                <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-6 mb-8 pb-8 border-b border-gray-100">
                    <div class="flex flex-col">
                        <span class="text-sm text-gray-500 uppercase tracking-wide font-semibold mb-1">Prezzo</span>
                        <span class="text-4xl font-black text-slate-900">
                            €{$item.price}
                        </span>
                    </div>

                    {if !$user || $user.role != 'admin'}
                        <form action="{url route='cart-add'}" method="post" class="flex-shrink-0">
                            <input type="hidden" name="csrf_token" value="{$csrf_token|escape}">
                            <input type="hidden" name="id" value="{$item.id|escape}">
                            <input type="hidden" name="type" value="{$type|escape}">
                            <button type="submit"
                                    class="bg-emerald-500 hover:bg-emerald-600 text-white px-8 py-4 rounded-xl font-bold text-lg flex items-center justify-center gap-3 transition-transform active:scale-95 shadow-lg shadow-emerald-500/30">
                                <i data-lucide="shopping-cart" class="w-6 h-6"></i> Aggiungi al Carrello
                            </button>
                        </form>
                    {/if}
                </div>

                <div class="prose prose-emerald max-w-none">
                    <h3 class="text-2xl font-bold text-slate-900 mb-4">Descrizione del Servizio</h3>
                    <p class="text-gray-600 leading-relaxed text-lg whitespace-pre-line">{$item.desc|escape}</p>
                </div>
            </div>

        </div>
    </div>
</div>
{/block}
