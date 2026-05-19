{*
 * navbar.tpl
 * Variabili attese:
 *   $user        - oggetto utente corrente (null se non autenticato)
 *                  $user.groups => ['admin'] | ['user']
 *                  $user.name  => nome visualizzato (derivato da email se assente)
 *   $cart_count  - numero di elementi nel carrello
 *   $pending_requests_count - richieste premium in attesa (solo admin)
 *   $mobile_menu_open - bool, menu mobile aperto o no
 *   $current_view - stringa della vista corrente (es. 'home', 'all-programs', ...)
 *}
<nav class="bg-slate-900 text-white sticky top-0 z-50 shadow-lg">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">

            {* Logo *}
            <div class="flex items-center">
                <a href="{$smarty.const.BASE_URL}" class="text-2xl font-black tracking-tighter text-emerald-400">
                    FIT<span class="text-white">STORE</span>
                </a>
            </div>

            {* Navigazione Desktop *}
            <div class="hidden md:flex items-center space-x-6">
                <a href="{url route='home'}" class="hover:text-emerald-400 font-medium transition{if $current_view == 'home'} text-emerald-400{/if}">Home</a>
                <a href="{url route='all-programs'}" class="hover:text-emerald-400 font-medium transition{if $current_view == 'all-programs'} text-emerald-400{/if}">Le Nostre Schede</a>
                <a href="{url route='custom'}" class="hover:text-emerald-400 font-medium transition{if $current_view == 'custom'} text-emerald-400{/if}">Schede Personalizzate</a>

                {if $user && $user.role == 'admin'}
                    <a href="{url route='admin-content'}" class="text-amber-400 hover:text-amber-300 font-medium transition">Contenuti</a>
                    <a href="{url route='admin-purchases'}" class="text-amber-400 hover:text-amber-300 font-medium transition">Acquisti</a>
                    <a href="{url route='admin-requests'}" class="text-amber-400 hover:text-amber-300 font-medium transition flex items-center gap-1">
                        Richieste
                        {if $pending_requests_count > 0}
                            <span class="bg-amber-400 text-amber-900 rounded-full px-1.5 py-0.5 text-[10px] font-bold">{$pending_requests_count}</span>
                        {/if}
                    </a>
                {/if}

                {if $user && $user.role == 'user'}
                    <a href="{url route='purchased'}" class="hover:text-emerald-400 font-medium transition">I Miei Programmi</a>
                {/if}

                <div class="flex items-center space-x-4 border-l border-slate-700 pl-4">
                    {if !$user || $user.role != 'admin'}
                        <a href="{url route='cart'}" class="relative p-2 hover:bg-slate-800 rounded-full transition">
                            <i data-lucide="shopping-cart" class="w-5 h-5"></i>
                            {if $cart_count > 0}
                                <span class="absolute top-0 right-0 inline-flex items-center justify-center px-2 py-1 text-xs font-bold leading-none text-white transform translate-x-1/4 -translate-y-1/4 bg-emerald-500 rounded-full">{$cart_count}</span>
                            {/if}
                        </a>
                    {/if}

                    {if $user}
                        <div class="flex items-center space-x-3">
                            <span class="text-sm text-slate-300">Ciao, {$user.name|default:$user.email|escape}</span>
                            <a href="{url route='logout'}" class="p-2 text-red-400 hover:bg-slate-800 rounded-full transition" title="Logout">
                                <i data-lucide="log-out" class="w-5 h-5"></i>
                            </a>
                        </div>
                    {else}
                        <a href="{url route='login'}" class="flex items-center space-x-2 bg-emerald-500 hover:bg-emerald-600 text-white px-4 py-2 rounded-lg font-medium transition">
                            <i data-lucide="user" class="w-[18px] h-[18px]"></i>
                            <span>Accedi</span>
                        </a>
                    {/if}
                </div>
            </div>

            {* Pulsanti Mobile *}
            <div class="md:hidden flex items-center">
                <a href="{url route='cart'}" class="relative p-2 mr-2">
                    <i data-lucide="shopping-cart" class="w-5 h-5"></i>
                    {if $cart_count > 0}
                        <span class="absolute top-0 right-0 w-4 h-4 bg-emerald-500 text-xs rounded-full flex items-center justify-center">{$cart_count}</span>
                    {/if}
                </a>
                <button id="mobile-menu-toggle" class="p-2" onclick="toggleMobileMenu()">
                    <i data-lucide="{if $mobile_menu_open}x{else}menu{/if}" class="w-6 h-6"></i>
                </button>
            </div>
        </div>
    </div>

    {* Menu Mobile *}
    {if $mobile_menu_open}
    <div class="md:hidden bg-slate-800 border-t border-slate-700">
        <div class="px-2 pt-2 pb-3 space-y-1 sm:px-3">
            <a href="{url route='home'}" class="block w-full text-left px-3 py-2 rounded-md text-base font-medium hover:bg-slate-700">Home</a>
            <a href="{url route='all-programs'}" class="block w-full text-left px-3 py-2 rounded-md text-base font-medium hover:bg-slate-700">Le Nostre Schede</a>
            <a href="{url route='custom'}" class="block w-full text-left px-3 py-2 rounded-md text-base font-medium hover:bg-slate-700">Schede Personalizzate</a>

            {if $user && $user.role == 'admin'}
                <a href="{url route='admin-content'}" class="block w-full text-left px-3 py-2 rounded-md text-base font-medium text-amber-400 hover:bg-slate-700">Gestione Contenuti</a>
                <a href="{url route='admin-purchases'}" class="block w-full text-left px-3 py-2 rounded-md text-base font-medium text-amber-400 hover:bg-slate-700">Gestione Acquisti</a>
                <a href="{url route='admin-requests'}" class="block w-full text-left px-3 py-2 rounded-md text-base font-medium text-amber-400 hover:bg-slate-700">Richieste Clienti</a>
            {/if}

            {if $user && $user.role == 'user'}
                <a href="{url route='purchased'}" class="block w-full text-left px-3 py-2 rounded-md text-base font-medium hover:bg-slate-700">I Miei Programmi</a>
            {/if}

            {if !$user}
                <a href="{url route='login'}" class="block w-full text-left px-3 py-2 rounded-md text-base font-medium text-emerald-400 hover:bg-slate-700">Accedi / Registrati</a>
            {else}
                <a href="{url route='logout'}" class="block w-full text-left px-3 py-2 rounded-md text-base font-medium text-red-400 hover:bg-slate-700">Logout</a>
            {/if}
        </div>
    </div>
    {/if}
</nav>

<script>
    function toggleMobileMenu() {
        window.location.href = '{url route="toggle-mobile-menu"}';
    }
</script>
