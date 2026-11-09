import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import test from 'node:test';
import vm from 'node:vm';

const script = await readFile(new URL('../web/auth_autofill.js', import.meta.url), 'utf8');

class Element {
  constructor(name, autocomplete = 'off', children = []) {
    this.name = name;
    this.autocomplete = autocomplete;
    this.children = children;
  }
  getAttribute(name) { return this[name]; }
  matches(selector) { return Boolean(this.name && selector.includes(`[name="${this.name}"]`)); }
  querySelectorAll(selector) {
    return this.children.flatMap(child => [
      ...(child.matches(selector) ? [child] : []), ...child.querySelectorAll(selector),
    ]);
  }
}

function mount(children = []) {
  const body = new Element(null, '', children);
  let notify;
  vm.runInNewContext(script, {
    Element, document: {body},
    MutationObserver: class {
      constructor(callback) { notify = callback; }
      observe(target, options) {
        assert.equal(target, body);
        assert.equal(options.subtree, true);
        assert.deepEqual(Array.from(options.attributeFilter), ['name', 'autocomplete']);
      }
    },
  });
  return notify;
}

test('restores framework-provided login hints while preserving unrelated fields', () => {
  const username = new Element('username');
  const password = new Element('current-password');
  const other = new Element('email');
  const notify = mount([username, password, other]);
  assert.equal(username.autocomplete, 'username');
  assert.equal(password.autocomplete, 'current-password');
  assert.equal(other.autocomplete, 'off');
  username.autocomplete = 'off';
  notify([{type: 'attributes', target: username}]);
  assert.equal(username.autocomplete, 'username');
  notify([{type: 'attributes', target: username}]);
  assert.equal(username.autocomplete, 'username');
});

test('handles nested newly inserted editors and ignores text nodes', () => {
  const notify = mount();
  const username = new Element('username');
  notify([{type: 'childList', addedNodes: [new Element(null, '', [username]), {}]}]);
  assert.equal(username.autocomplete, 'username');
});
