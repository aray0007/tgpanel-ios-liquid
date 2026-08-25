const accounts = [
  { phone: '+1 929•••2608', remark: '小火箭', status: 'online', label: 'Online', activity: '2 min ago', initial: '+1' },
  { phone: '+1 323•••5222', remark: '悲鸣屿行冥', status: 'online', label: 'Online', activity: '6 min ago', initial: '+1' },
  { phone: '+1 786•••1921', remark: 'Expo', status: 'offline', label: 'Offline', activity: '18 min ago', initial: '+1' },
  { phone: '+1 516•••9696', remark: 'Mi', status: 'online', label: 'Online', activity: '21 min ago', initial: '+1' },
  { phone: '+1 571•••2111', remark: 'Siva', status: 'warning', label: 'Review', activity: '32 min ago', initial: '+1' },
  { phone: '+234 802•••7628', remark: 'Даша', status: 'online', label: 'Online', activity: '41 min ago', initial: '+2' },
  { phone: '+880 197•••5906', remark: 'Patricia', status: 'unauthorized', label: 'Unauthorized', activity: '1 hr ago', initial: '+8' },
  { phone: '+91 858•••9469', remark: 'Kenneth', status: 'online', label: 'Online', activity: '2 hr ago', initial: '+9' },
];

const state = { view: 'overview', query: '' };
const panels = [...document.querySelectorAll('[data-view-panel]')];
const tabs = [...document.querySelectorAll('[data-view]')];
const sheet = document.querySelector('#accountSheet');
const toast = document.querySelector('#toast');
const search = document.querySelector('#accountSearch');
let toastTimer;

function formatNow() {
  return new Intl.DateTimeFormat('en', { hour: '2-digit', minute: '2-digit' }).format(new Date());
}

function setSyncTime() {
  document.querySelectorAll('[data-sync-time]').forEach((node) => { node.textContent = formatNow(); });
}

function showToast(message) {
  toast.textContent = message;
  toast.classList.add('is-visible');
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => toast.classList.remove('is-visible'), 2100);
}

function switchView(view) {
  state.view = view;
  panels.forEach((panel) => {
    const active = panel.dataset.viewPanel === view;
    panel.hidden = !active;
    panel.classList.toggle('is-active', active);
  });
  tabs.forEach((tab) => tab.classList.toggle('is-selected', tab.dataset.view === view));
  if (view === 'accounts') renderAccounts();
  const activePanel = document.querySelector(`[data-view-panel="${view}"]`);
  if (activePanel) activePanel.scrollTo({ top: 0, behavior: 'smooth' });
}

function accountRow(account) {
  const row = document.createElement('button');
  row.className = 'account-row';
  row.type = 'button';
  row.dataset.phone = account.phone;
  row.innerHTML = `
    <span class="account-avatar">${account.initial}</span>
    <span class="account-copy"><strong>${account.phone}</strong><span>${account.remark} · ${account.activity}</span></span>
    <span class="account-trailing"><span class="status-badge ${account.status}">${account.label}</span><time>›</time></span>`;
  row.addEventListener('click', () => openSheet(account));
  return row;
}

function renderAccounts() {
  const list = document.querySelector('#accountList');
  const query = state.query.trim().toLowerCase();
  const filtered = accounts.filter((account) => `${account.phone} ${account.remark} ${account.label}`.toLowerCase().includes(query));
  list.replaceChildren();
  if (!filtered.length) {
    const empty = document.createElement('div');
    empty.className = 'empty-state';
    empty.textContent = 'No accounts found';
    list.appendChild(empty);
  } else {
    filtered.forEach((account) => list.appendChild(accountRow(account)));
  }
  document.querySelector('#accountCount').textContent = `${filtered.length} account${filtered.length === 1 ? '' : 's'}`;
}

function openSheet(account) {
  document.querySelector('#sheetAvatar').textContent = account.initial;
  document.querySelector('#sheetTitle').textContent = account.phone;
  document.querySelector('#sheetStatus').textContent = account.label;
  document.querySelector('#sheetStatus').className = `status-badge ${account.status}`;
  document.querySelector('#sheetRemark').textContent = account.remark;
  document.querySelector('#sheetActivity').textContent = account.activity;
  sheet.hidden = false;
  document.body.style.overflow = 'hidden';
}

function closeSheet() {
  sheet.hidden = true;
  document.body.style.overflow = '';
}

function handleAction(action) {
  if (action === 'accounts') switchView('accounts');
  if (action === 'settings') switchView('settings');
  if (action === 'refresh') { setSyncTime(); showToast('Demo data refreshed'); }
  if (action === 'close-sheet') closeSheet();
}

tabs.forEach((tab) => tab.addEventListener('click', () => switchView(tab.dataset.view)));
document.querySelectorAll('[data-action]').forEach((button) => button.addEventListener('click', () => handleAction(button.dataset.action)));
search.addEventListener('input', (event) => { state.query = event.target.value; renderAccounts(); });
sheet.addEventListener('click', (event) => { if (event.target === sheet) closeSheet(); });
document.addEventListener('keydown', (event) => {
  if (event.key === '/' && document.activeElement !== search) { event.preventDefault(); switchView('accounts'); search.focus(); }
  if (event.key === 'Escape') closeSheet();
});

renderAccounts();
setSyncTime();
