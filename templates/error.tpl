{*
 * error.tpl
 * Variabili attese:
 *   $error_code    - int (es. 403, 404)
 *   $error_message - stringa descrittiva
 *}
{extends file="layout_base.tpl"}

{block name="content"}
<div class="min-h-[70vh] flex flex-col items-center justify-center text-center px-4">
    <p class="text-7xl font-black text-emerald-500 mb-2">{$error_code|default:403}</p>
    <h1 class="text-2xl font-bold text-slate-900 mb-3">Accesso negato</h1>
    <p class="text-gray-500 mb-8 max-w-sm">{$error_message|default:'Non hai i permessi per visualizzare questa pagina.'|escape}</p>
    <a href="{url route='home'}"
       class="bg-emerald-500 hover:bg-emerald-600 text-white px-6 py-3 rounded-lg font-bold transition">
        Torna alla Home
    </a>
</div>
{/block}
