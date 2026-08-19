/**
 * TGPanel iOS Liquid Glass Engine (2026)
 * Zero-touch server API client with reactive state and offline fallback
 */

const STATE = {
  serverUrl: localStorage.getItem('tg_server_url') || 'http://207.174.6.36:5000',
  currentTab: 'accounts',
  accounts: [],
  tasks: {},
  filter: 'all',
  searchQuery: '',
  activeLogTaskId: null,
  logInterval: null,
  pollInterval: null
};

// =========================================================
// Initialization
// =========================================================
document.addEventListener('DOMContentLoaded', () => {
  initTabs();
  initSearchAndFilters();
  initSettings();
  loadData();
  
  // Auto refresh poll every 3 seconds
  STATE.pollInterval = setInterval(loadTasks, 3000);
});

// Toast Helper
function showToast(msg) {
  const toast = document.getElementById('toast');
  if (!toast) return;
  toast.textContent = msg;
  toast.classList.add('show');
  setTimeout(() => toast.classList.remove('show'), 2400);
}

// =========================================================
// Tab Navigation
// =========================================================
function initTabs() {
  const tabItems = document.querySelectorAll('.tabbar-item');
  tabItems.forEach(item => {
    item.addEventListener('click', () => {
      const target = item.dataset.tab;
      if (!target) return;
      
      tabItems.forEach(t => t.classList.remove('active'));
      item.classList.add('active');
      
      document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
      const activeContent = document.getElementById(`tab-${target}`);
      if (activeContent) activeContent.classList.add('active');
      
      STATE.currentTab = target;
      if (target === 'tasks') loadTasks();
      if (target === 'accounts') loadAccounts();
    });
  });
}

// =========================================================
// API & Data Handlers
// =========================================================
async function fetchApi(endpoint, options = {}) {
  const url = `${STATE.serverUrl.replace(/\/$/, '')}${endpoint}`;
  try {
    const res = await fetch(url, {
      ...options,
      headers: {
        'Accept': 'application/json',
        ...(options.headers || {})
      }
    });
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    return await res.json();
  } catch (err) {
    console.warn(`[API] ${endpoint} failed:`, err);
    throw err;
  }
}

async function loadData() {
  updateServerStatus(true);
  await Promise.allSettled([loadAccounts(), loadTasks()]);
}

async function loadAccounts() {
  const container = document.getElementById('accounts-list');
  try {
    const data = await fetchApi('/api/sessions');
    const list = Array.isArray(data) ? data : (data.accounts || []);
    STATE.accounts = list;
    renderAccounts();
    updateServerStatus(true);
  } catch (e) {
    updateServerStatus(false);
    if (!STATE.accounts.length) {
      container.innerHTML = `
        <div class="glass-card" style="text-align:center; padding: 24px;">
          <p style="color:var(--accent-red); margin-bottom:8px; font-weight:600;">⚠️ 无法连接至服务器</p>
          <p style="color:var(--text-muted); font-size:13px;">请在「设置」中确认 VPS 地址: <code>${STATE.serverUrl}</code></p>
        </div>
      `;
    }
  }
}

async function loadTasks() {
  try {
    const data = await fetchApi('/api/tasks');
    STATE.tasks = data || {};
    renderTasks();
    updateTasksBadge();
  } catch (e) {
    // Silent fail in task polling
  }
}

function updateServerStatus(online) {
  const dot = document.getElementById('server-status-dot');
  const text = document.getElementById('server-status-text');
  if (dot && text) {
    if (online) {
      dot.className = 'status-dot';
      text.textContent = 'VPS 在线';
    } else {
      dot.className = 'status-dot offline';
      text.textContent = '连接中断';
    }
  }
}

function updateTasksBadge() {
  const runningCount = Object.values(STATE.tasks).filter(t => t.status === 'running').length;
  const badge = document.getElementById('task-running-badge');
  if (badge) {
    if (runningCount > 0) {
      badge.style.display = 'inline-block';
      badge.textContent = runningCount;
    } else {
      badge.style.display = 'none';
    }
  }
}

// =========================================================
// Account Render & Filtering
// =========================================================
function initSearchAndFilters() {
  const searchInput = document.getElementById('account-search-input');
  if (searchInput) {
    searchInput.addEventListener('input', (e) => {
      STATE.searchQuery = e.target.value.trim().toLowerCase();
      renderAccounts();
    });
  }

  const pills = document.querySelectorAll('#account-filter-row .glass-pill');
  pills.forEach(pill => {
    pill.addEventListener('click', () => {
      pills.forEach(p => p.classList.remove('active'));
      pill.classList.add('active');
      STATE.filter = pill.dataset.filter || 'all';
      renderAccounts();
    });
  });
}

function renderAccounts() {
  const container = document.getElementById('accounts-list');
  if (!container) return;

  let filtered = STATE.accounts.filter(acc => {
    const isOnline = (acc.status === 'online');
    if (STATE.filter === 'online' && !isOnline) return false;
    if (STATE.filter === 'offline' && isOnline) return false;

    if (STATE.searchQuery) {
      const q = STATE.searchQuery;
      const phone = String(acc.phone || '').toLowerCase();
      const name = String(acc.name || '').toLowerCase();
      const remark = String(acc.remark || '').toLowerCase();
      const tgId = String(acc.tg_user_id || '').toLowerCase();
      return phone.includes(q) || name.includes(q) || remark.includes(q) || tgId.includes(q);
    }
    return true;
  });

  document.getElementById('acc-count-all').textContent = STATE.accounts.length;
  document.getElementById('acc-count-online').textContent = STATE.accounts.filter(a => a.status === 'online').length;
  document.getElementById('acc-count-offline').textContent = STATE.accounts.filter(a => a.status !== 'online').length;

  if (!filtered.length) {
    container.innerHTML = `
      <div class="glass-card" style="text-align:center; padding:32px;">
        <p style="color:var(--text-muted); font-size:14px;">没有匹配的账号</p>
      </div>
    `;
    return;
  }

  container.innerHTML = filtered.map(acc => {
    const isOnline = acc.status === 'online';
    const tgId = acc.tg_user_id || acc.id || '-';
    return `
      <div class="glass-card account-card">
        <div class="account-card-header">
          <div class="account-title-row">
            <span class="status-dot ${isOnline ? '' : 'offline'}"></span>
            <span class="account-name">${escapeHtml(acc.name || '未命名')}</span>
            ${acc.remark ? `<span style="font-size:11px; color:var(--text-muted);">(${escapeHtml(acc.remark)})</span>` : ''}
          </div>
          <span class="account-phone" onclick="copyText('${acc.phone}')">${acc.phone} 📋</span>
        </div>
        <div class="account-meta">
          <div class="meta-box">TG ID: <span class="val">${tgId}</span></div>
          <div class="meta-box">状态: <span class="val" style="color:${isOnline ? 'var(--accent-green)' : 'var(--accent-red)'}">${isOnline ? '在线' : '离线'}</span></div>
        </div>
      </div>
    `;
  }).join('');
}

// =========================================================
// Task Render & Control
// =========================================================
function renderTasks() {
  const container = document.getElementById('tasks-list');
  if (!container) return;

  const entries = Object.entries(STATE.tasks);
  if (!entries.length) {
    container.innerHTML = `
      <div class="glass-card" style="text-align:center; padding:32px;">
        <p style="color:var(--text-muted); font-size:14px;">暂无运行中的任务</p>
      </div>
    `;
    return;
  }

  container.innerHTML = entries.map(([id, t]) => {
    const isRunning = t.status === 'running';
    const isPaused = t.status === 'paused';
    const progress = (t.total > 0) ? Math.min(100, Math.round((t.current / t.total) * 100)) : 0;

    return `
      <div class="glass-card task-item">
        <div class="task-item-top">
          <span style="font-weight:700; font-size:15px;">${escapeHtml(t.type || '任务 #' + id)}</span>
          <span class="task-badge-state state-${t.status || 'running'}">${t.status || 'RUNNING'}</span>
        </div>
        <div class="glass-progress-bar">
          <div class="glass-progress-fill" style="width: ${progress}%;"></div>
        </div>
        <div style="display:flex; justify-content:space-between; font-size:12px; color:var(--text-muted);">
          <span>进度: ${t.current || 0} / ${t.total || 0} (${progress}%)</span>
          <span>延迟: ${t.delay_min || 1}-${t.delay_max || 30}s</span>
        </div>
        <div style="display:flex; gap:8px; margin-top:4px;">
          ${isRunning ? `<button class="glass-btn glass-btn-sm" onclick="pauseTask('${id}')">⏸ 暂停</button>` : ''}
          ${isPaused ? `<button class="glass-btn glass-btn-sm" onclick="resumeTask('${id}')">▶️ 继续</button>` : ''}
          <button class="glass-btn glass-btn-sm" onclick="viewTaskLog('${id}')">📜 实时日志</button>
          <button class="glass-btn glass-btn-sm glass-btn-danger" onclick="cancelTask('${id}')">🛑 终止</button>
        </div>
      </div>
    `;
  }).join('');
}

async function pauseTask(tid) {
  try {
    await fetchApi(`/api/pause/${tid}`, { method: 'POST' });
    showToast('任务已暂停');
    loadTasks();
  } catch (e) { showToast('操作失败'); }
}

async function resumeTask(tid) {
  try {
    await fetchApi(`/api/resume/${tid}`, { method: 'POST' });
    showToast('任务已恢复');
    loadTasks();
  } catch (e) { showToast('操作失败'); }
}

async function cancelTask(tid) {
  if (!confirm('确定要终止此任务吗？')) return;
  try {
    await fetchApi(`/api/cancel/${tid}`, { method: 'POST' });
    showToast('任务已取消');
    loadTasks();
  } catch (e) { showToast('取消失败'); }
}

// =========================================================
// Realtime Log Viewer
// =========================================================
async function viewTaskLog(tid) {
  STATE.activeLogTaskId = tid;
  const modal = document.getElementById('log-modal');
  const logView = document.getElementById('terminal-log-content');
  const title = document.getElementById('log-modal-title');
  
  if (title) title.textContent = `任务 #${tid} 实时日志`;
  if (modal) modal.classList.add('open');
  if (logView) logView.textContent = '正在连接日志流...';

  fetchTaskLogContent();
  if (STATE.logInterval) clearInterval(STATE.logInterval);
  STATE.logInterval = setInterval(fetchTaskLogContent, 2000);
}

async function fetchTaskLogContent() {
  if (!STATE.activeLogTaskId) return;
  const logView = document.getElementById('terminal-log-content');
  if (!logView) return;
  try {
    const res = await fetchApi(`/api/log/${STATE.activeLogTaskId}`);
    const text = (typeof res === 'string') ? res : (res.log || res.content || JSON.stringify(res, null, 2));
    logView.textContent = text || '等待日志输出...';
    logView.scrollTop = logView.scrollHeight;
  } catch (e) {
    // Handle error
  }
}

function closeLogModal() {
  const modal = document.getElementById('log-modal');
  if (modal) modal.classList.remove('open');
  if (STATE.logInterval) {
    clearInterval(STATE.logInterval);
    STATE.logInterval = null;
  }
  STATE.activeLogTaskId = null;
}

// =========================================================
// Automations
// =========================================================
async function triggerAutoVerify() {
  const target = prompt('请输入目标群组链接或用户名（如: @groupname）:');
  if (!target) return;
  const delay = prompt('请输入账号间随机延迟秒数（最小值-最大值，例如: 1-180）:', '1-180');
  const [min, max] = (delay || '1-180').split('-').map(Number);
  
  try {
    await fetchApi('/api/auto_verify', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ group: target, delay_min: min || 1, delay_max: max || 180 })
    });
    showToast('🚀 自动入群验证任务已触发');
    setTimeout(() => {
      document.querySelector('[data-tab="tasks"]').click();
    }, 400);
  } catch (e) {
    showToast('触发失败: ' + e.message);
  }
}

async function triggerLuckyStar() {
  const link = prompt('请输入幸运星抽奖链接 (例如: https://t.me/MyLuckyStar8_Bot?start=...):');
  if (!link) return;
  try {
    await fetchApi('/api/luckystar', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ link })
    });
    showToast('🎰 幸运星抽奖任务已启动');
    document.querySelector('[data-tab="tasks"]').click();
  } catch (e) {
    showToast('启动失败');
  }
}

async function triggerDailyCheck() {
  try {
    await fetchApi('/api/check_accounts', { method: 'POST' });
    showToast('🔍 在线检测与状态同步任务已启动');
    document.querySelector('[data-tab="tasks"]').click();
  } catch (e) {
    showToast('触发失败');
  }
}

async function triggerExportSessions() {
  showToast('正在生成 Session 压缩包...');
  window.open(`${STATE.serverUrl.replace(/\/$/, '')}/api/sessions/export`, '_blank');
}

// =========================================================
// Settings
// =========================================================
function initSettings() {
  const input = document.getElementById('server-url-input');
  if (input) input.value = STATE.serverUrl;
}

function saveServerSettings() {
  const input = document.getElementById('server-url-input');
  if (!input) return;
  const val = input.value.trim();
  if (!val) return showToast('请输入有效的服务器地址');
  STATE.serverUrl = val;
  localStorage.setItem('tg_server_url', val);
  showToast('✅ 服务器地址已保存');
  loadData();
}

// Utils
function copyText(txt) {
  navigator.clipboard.writeText(txt).then(() => {
    showToast(`已复制: ${txt}`);
  }).catch(() => {
    showToast(`复制: ${txt}`);
  });
}

function escapeHtml(str) {
  return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}
