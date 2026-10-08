/* BlazeFusion: offline UI preferences only; never reads/writes rental or billing state. */
(function () {
  'use strict';
  const key = 'blazepwifi.console.appearance.v1';
  const permitted = ['fusion', 'compact', 'comfort'];
  const icons = {
    dashboard:'◉',sessions:'◫',sales:'▥',wan:'↗',lan:'◎',remote:'⌁',
    vouchers:'◇',members:'♙',rentals:'▣',controllers:'⊞',
    portal:'▧',multimedia:'▶',games:'✦',storage:'▤',backups:'↺',
    updates:'⇪',tools:'⌘',alerts:'⚑',system:'⚙'
  };
  function normalize(value) { return permitted.indexOf(value) < 0 ? 'fusion' : value; }
  function apply(value) {
    const mode = normalize(value);
    document.body.setAttribute('data-blaze-style', mode);
    const selector = document.getElementById('blazeStyleSelect');
    if (selector) selector.value = mode;
    try { window.localStorage.setItem(key, mode); } catch (_) { /* private mode */ }
  }
  function boot() {
    const selector = document.getElementById('blazeStyleSelect');
    if (!selector) return;
    let current = 'fusion';
    try { current = window.localStorage.getItem(key) || current; } catch (_) { /* private mode */ }
    apply(current);
    selector.addEventListener('change', function () { apply(selector.value); });
    document.querySelectorAll('.nav-btn[data-page]').forEach(function (button) {
      const symbol = icons[button.getAttribute('data-page')];
      if (symbol) button.setAttribute('data-symbol', symbol);
    });
  }
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot, { once: true });
  } else boot();
})();
