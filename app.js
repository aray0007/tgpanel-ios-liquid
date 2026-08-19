/**
 * TGPanel iOS 27 VisionOS Edition: Organic Liquid Simulation & Client Engine
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

// ==========================================================================
// Initialization & Liquid Engine
// ==========================================================================
document.addEventListener('DOMContentLoaded', () => {
  initLiquidCanvas();
  initTouchRipples();
  initTabs();
  initSearchAndFilters();
  initSettings();
  loadData();
  
  STATE.pollInterval = setInterval(loadTasks, 3000);
});

// Real-time Organic Liquid Fluid Simulation
function initLiquidCanvas() {
  const canvas = document.getElementById('liquid-canvas');
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  
  let width = canvas.width = window.innerWidth;
  let height = canvas.height = window.innerHeight;

  window.addEventListener('resize', () => {
    width = canvas.width = window.innerWidth;
    height = canvas.height = window.innerHeight;
  });

  // Dynamic Neon Fluid Blobs
  const blobs = [
    { x: width * 0.2, y: height * 0.2, r: 180, vx: 0.8, vy: 0.6, color: 'rgba(0, 240, 255, 0.45)' },
    { x: width * 0.8, y: height * 0.35, r: 210, vx: -0.7, vy: 0.9, color: 'rgba(138, 43, 226, 0.48)' },
    { x: width * 0.5, y: height * 0.75, r: 230, vx: 0.6, vy: -0.8, color: 'rgba(255, 0, 127, 0.4)' },
    { x: width * 0.25, y: height * 0.85, r: 160, vx: -0.5, vy: -0.5, color: 'rgba(0, 255, 170, 0.35)' }
  ];

  let time = 0;
  function render() {
    time += 0.02;
    ctx.fillStyle = '#03060c';
    ctx.fillRect(0, 0, width, height);

    blobs.forEach(b => {
      b.x += b.vx + Math.sin(time + b.y * 0.01) * 0.5;
      b.y += b.vy + Math.cos(time + b.x * 0.01) * 0.5;

      if (b.x < -100) b.x = width + 100;
      if (b.x > width + 100) b.x = -100;
      if (b.y < -100) b.y = height + 100;
      if (b.y > height + 100) b.y = -100;

      const grad = ctx.createRadialGradient(b.x, b.y, 0, b.x, b.y, b.r);
      grad.addColorStop(0, b.color);
      grad.addColorStop(1, 'rgba(0,0,0,0)');

      ctx.beginPath();
      ctx.arc(b.x, b.y, b.r, 0, Math.PI * 2);
      ctx.fillStyle = grad;
      ctx.fill();
    });

    requestAnimationFrame(render);
  }
  render();
}

// Touch Liquid Ripple Wave
function initTouchRipples() {
  document.addEventListener('pointerdown', (e) => {
    const ripple = document.createElement('div');
    ripple.className = 'ripple-wave';
    ripple.style.left = `${e.clientX}px`;
    ripple.style.top = `${e.clientY}px`;
    ripple.style.width = '120px';
    ripple.style.height = '120px';
    document.body.appendChild(ripple);
    setTimeout(() => ripple.remove(), 1200);
  });
}

// Toast Alert
function showToast(msg) {
  const toast = document.getElementById('toast');
  if (!toast) return;
  toast.textContent = msg;
  toast.classList.add('show');
  setTimeout(() => toast.classList.remove('show'), 2400);
}

// ==========================================================================
// Tab Navigation
// ==========================================================================
function initTabs() {
  const tabItems = document.querySelectorAll('.tab-btn');
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

// ==========================================================================
// API & Data Handlers
// ==========================================================================
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
        <div class="crystal-card" style="text-align:center; padding: 28px;">
          <p style="color:var(--neon-crimson); margin-bottom:8px; font-weight:700;">⚠️ 无法连接到 VPS 面板</p>
          <p style="color:rgba(255,255,255,0.6); font-size:13px;">请在「设置」中确认服务器地址: <code>${STATE.serverUrl}</code></p>
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
  } catch (e) {}
}

function updateServerStatus(online) {
  const dot = document.getElementById('server-status-dot');
  const text = document.getElementById('server-status-text');
  if (dot && text) {
    if (online) {
      dot.className = 'neon-dot';
      text.textContent = 'VPS 在线';
    } else {
      dot.className = 'neon-dot offline';
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

// ==========================================================================
// Accounts Render
// ==========================================================================
function initSearchAndFilters() {
  const searchInput = document.getElementById('account-search-input');
  if (searchInput) {
    searchInput.addEventListener('input', (e) => {
      STATE.searchQuery = e.target.value.trim().toLowerCase();
      renderAccounts();
    });
  }

  const pills = document.querySelectorAll('#account-filter-row .crystal-pill');
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
      <div class="crystal-card" style="text-align:center; padding:36px;">
        <p style="color:rgba(255,255,255,0.5); font-size:14px;">没有找到匹配的账号</p>
      </div>
    `;
    return;
  }

  container.innerHTML = filtered.map(acc => {
    const isOnline = acc.status === 'online';
    const tgId = acc.tg_user_id || acc.id || '-';
    return `
      <div class="crystal-card">
        <div style="display:flex; justify-content:space-between; align-items:center;">
          <div style="display:flex; align-items:center; gap:10px;">
            <span class="neon-dot ${isOnline ? '' : 'offline'}"></span>
            <span style="font-size:16px; font-weight:800; color:#fff;">${escapeHtml(acc.name || '未命名')}</span>
            ${acc.remark ? `<span style="font-size:12px; color:rgba(255,255,255,0.5);">(${escapeHtml(acc.remark)})</span>` : ''}
          </div>
          <span class="account-phone-badge" onclick="copyText('${acc.phone}')">${acc.phone} 📋</span>
        </div>
        <div class="meta-grid">
          <div class="meta-item">TG ID: <span class="val">${tgId}</span></div>
          <div class="meta-item">状态: <span class="val" style="color:${isOnline ? 'var(--neon-mint)' : 'var(--neon-crimson)'}">${isOnline ? '正常在线' : '异常离线'}</span></div>
        </div>
      </div>
    `;
  }).join('');
}

// ==========================================================================
// Tasks Render & Log Handlers
// ==========================================================================
function renderTasks() {
  const container = document.getElementById('tasks-list');
  if (!container) return;

  const entries = Object.entries(STATE.tasks);
  if (!entries.length) {
    container.innerHTML = `
      <div class="crystal-card" style="text-align:center; padding:36px;">
        <p style="color:rgba(255,255,255,0.5); font-size:14px;">暂无运行中的后台任务</p>
      </div>
    `;
    return;
  }

  container.innerHTML = entries.map(([id, t]) => {
    const isRunning = t.status === 'running';
    const isPaused = t.status === 'paused';
    const progress = (t.total > 0) ? Math.min(100, Math.round((t.current / t.total) * 100)) : 0;

    return `
      <div class="crystal-card" style="display:flex; flex-direction:column; gap:12px;">
        <div style="display:flex; justify-content:space-between; align-items:center;">
          <span style="font-weight:800; font-size:16px;">${escapeHtml(t.type || '任务 #' + id)}</span>
          <span style="font-size:11px; font-weight:800; padding:4px 10px; border-radius:8px; background:rgba(0,240,255,0.2); color:var(--neon-cyan); border:1px solid rgba(0,240,255,0.4);">${t.status || 'RUNNING'}</span>
        </div>
        <div style="width:100%; height:8px; background:rgba(255,255,255,0.1); border-radius:99px; overflow:hidden; border:1px solid rgba(255,255,255,0.08);">
          <div style="height:100%; width:${progress}%; background:linear-gradient(90deg,var(--neon-cyan),var(--neon-violet),var(--neon-magenta)); border-radius:99px; box-shadow:0 0 14px var(--neon-cyan);"></div>
        </div>
        <div style="display:flex; justify-content:space-between; font-size:12px; color:rgba(255,255,255,0.6);">
          <span>进度: ${t.current || 0} / ${t.total || 0} (${progress}%)</span>
          <span>延迟: ${t.delay_min || 1}-${t.delay_max || 30}s</span>
        </div>
        <div style="display:flex; gap:10px; margin-top:4px;">
          ${isRunning ? `<button class="crystal-btn crystal-btn-sm" onclick="pauseTask('${id}')">⏸ 暂停</button>` : ''}
          ${isPaused ? `<button class="crystal-btn crystal-btn-sm" onclick="resumeTask('${id}')">▶️ 继续</button>` : ''}
          <button class="crystal-btn crystal-btn-sm" onclick="viewTaskLog('${id}')">📜 实时日志</button>
          <button class="crystal-btn crystal-btn-sm crystal-btn-danger" onclick="cancelTask('${id}')">🛑 终止</button>
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

async function viewTaskLog(tid) {
  STATE.activeLogTaskId = tid;
  const modal = document.getElementById('log-modal');
  const logView = document.getElementById('terminal-log-content');
  const title = document.getElementById('log-modal-title');
  
  if (title) title.textContent = `任务 #${tid} 实时控制台`;
  if (modal) modal.classList.add('open');
  if (logView) logView.textContent = '正在连接实时日志流...';

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
  } catch (e) {}
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

// Automations
async function triggerAutoVerify() {
  const target = prompt('请输入目标群组链接或用户名（如: @groupname）:');
  if (!target) return;
  const delay = prompt('请输入随机延迟范围（如: 1-180）:', '1-180');
  const [min, max] = (delay || '1-180').split('-').map(Number);
  
  try {
    await fetchApi('/api/auto_verify', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ group: target, delay_min: min || 1, delay_max: max || 180 })
    });
    showToast('🚀 自动入群验证任务已启动');
    document.querySelector('[data-tab="tasks"]').click();
  } catch (e) {
    showToast('触发失败: ' + e.message);
  }
}

async function triggerLuckyStar() {
  const link = prompt('请输入幸运星链接 (如: https://t.me/MyLuckyStar8_Bot?start=...):');
  if (!link) return;
  try {
    await fetchApi('/api/luckystar', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ link })
    });
    showToast('🎰 幸运星抽奖任务已启动');
    document.querySelector('[data-tab="tasks"]').click();
  } catch (e) { showToast('启动失败'); }
}

async function triggerDailyCheck() {
  try {
    await fetchApi('/api/check_accounts', { method: 'POST' });
    showToast('🔍 巡检任务已启动');
    document.querySelector('[data-tab="tasks"]').click();
  } catch (e) { showToast('触发失败'); }
}

async function triggerExportSessions() {
  showToast('正在生成 Session 压缩包...');
  window.open(`${STATE.serverUrl.replace(/\/$/, '')}/api/sessions/export`, '_blank');
}

function initSettings() {
  const input = document.getElementById('server-url-input');
  if (input) input.value = STATE.serverUrl;
}

function saveServerSettings() {
  const input = document.getElementById('server-url-input');
  if (!input) return;
  const val = input.value.trim();
  if (!val) return showToast('请输入有效地址');
  STATE.serverUrl = val;
  localStorage.setItem('tg_server_url', val);
  showToast('✅ 服务器地址已保存');
  loadData();
}

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
