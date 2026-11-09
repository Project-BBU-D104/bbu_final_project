// shortcut: Flutter's web semantics resets autocomplete; remove when the SDK preserves autofill hints.
(() => {
  const selector = 'input[name="username"], input[name="current-password"]';
  function restore(root) {
    if (!(root instanceof Element)) return;
    const inputs = root.matches(selector) ? [root] : root.querySelectorAll(selector);
    for (const input of inputs) {
      const hint = input.getAttribute('name');
      if (input.autocomplete !== hint) input.autocomplete = hint;
    }
  }
  new MutationObserver(records => {
    for (const record of records) {
      if (record.type === 'attributes') restore(record.target);
      else for (const node of record.addedNodes) restore(node);
    }
  }).observe(document.body, {
    subtree: true, childList: true, attributes: true,
    attributeFilter: ['name', 'autocomplete'],
  });
  restore(document.body);
})();
