{*
 * login.tpl
 * Schermata: Login / Registrazione.
 *
 * Variabili attese:
 *   $is_login_mode - bool, true = modalità login, false = registrazione
 *   $error_message - stringa, messaggio di errore (opzionale)
 *   $login_action  - URL del form POST (es. '/login' o '/register')
 *}
{extends file="layout_base.tpl"}

{block name="content"}
<div class="min-h-[80vh] flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
    <div class="max-w-md w-full space-y-8 bg-white p-8 rounded-2xl shadow-xl border border-gray-100">

        <div>
            <h2 class="mt-6 text-center text-3xl font-extrabold text-slate-900">
                {if $is_login_mode}Bentornato!{else}Crea un account{/if}
            </h2>
            <p class="mt-2 text-center text-sm text-gray-600">
                {if $is_login_mode}
                    Accedi per vedere i tuoi programmi o acquistare.
                {else}
                    Registrati per iniziare il tuo percorso.
                {/if}
            </p>
        </div>

        {if isset($error_message) && $error_message}
            <div class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm">
                {$error_message|escape}
            </div>
        {/if}

        <form class="mt-8 space-y-6" method="POST" action="{$login_action|escape}">
            {* CSRF token *}
            <input type="hidden" name="csrf_token" value="{$csrf_token|escape}" />

            <div class="rounded-md shadow-sm space-y-4">
                <div>
                    <label for="login-email" class="sr-only">Email</label>
                    <input id="login-email"
                           name="email"
                           type="email"
                           required
                           class="appearance-none rounded-lg relative block w-full px-3 py-3 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-emerald-500 focus:border-emerald-500 sm:text-sm"
                           placeholder="Email" />
                </div>
                <div>
                    <label for="login-password" class="sr-only">Password</label>
                    <input id="login-password"
                           name="password"
                           type="password"
                           required
                           class="appearance-none rounded-lg relative block w-full px-3 py-3 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-emerald-500 focus:border-emerald-500 sm:text-sm"
                           placeholder="Password" />
                </div>
            </div>

            <div>
                <button type="submit"
                        class="w-full flex justify-center py-3 px-4 border border-transparent text-sm font-medium rounded-lg text-white bg-emerald-600 hover:bg-emerald-700 transition-colors">
                    {if $is_login_mode}Accedi{else}Registrati{/if}
                </button>
            </div>
        </form>

        <div class="text-center">
            {if $is_login_mode}
                <a href="{url route='register'}" class="text-sm font-medium text-emerald-600 hover:text-emerald-500">
                    Non hai un account? Registrati
                </a>
            {else}
                <a href="{url route='login'}" class="text-sm font-medium text-emerald-600 hover:text-emerald-500">
                    Hai già un account? Accedi
                </a>
            {/if}
        </div>

    </div>
</div>
{/block}
