/**
 * TGPanel iOS 27 VisionOS: Hyper-Fluid Liquid Glass Simulation & Controller
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

document.addEventListener('DOMContentLoaded', () => {
  initFluidCanvas();
  initTouchRipples();
  initLiquidTabs();
  initSearchAndFilters();
  initSettings();
  loadData();
  
  STATE.pollInterval = setInterval(loadTasks, 3000);
});

// ==========================================================================
// 1. High-Energy Realtime 60FPS Fluid Light Mesh Simulation
// ==========================================================================
function initFluidCanvas() {
  const canvas = document.getElementById('fluid-canvas');
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  
  let width = canvas.width = window.innerWidth;
  let height = canvas.height = window.innerHeight;

  window.addEventListener('resize', () => {
    width = canvas.width = window.innerWidth;
    height = canvas.height = window.innerHeight;
  });

  // Glowing Plasma Metaballs
  const metaballs = [
    { x: width * 0.2, y: height * 0.2, r: 240, vx: 1.1, vy: 0.8, color: 'rgba(0, 240, 255, 0.55)' },
    { x: width * 0.8, y: height * 0.3, r: 280, vx: -0.9, vy: 1.2, color: 'rgba(157, 0, 255, 0.6)' },
    { x: width * 0.5, y: height * 0.7, r: 300, vx: 1.0, vy: -1.0, color: 'rgba(255, 0, 127, 0.55)' },
    { x: width * 0.15, y: height * 0.8, r: 220, vx: -0.8, vy: -0.7, color: 'rgba(0, 255, 136, 0.45)' }
  ];

  let time = 0;
  function render() {
    time += 0.025;
    ctx.fillStyle = '#030712';
    ctx.fillRect(0, 0, width, height);

    metaballs.forEach(b => {
      b.x += b.vx + Math.sin(time + b.y * 0.008) * 1.2;
      b.y += b.vy + Math.cos(time + b.x * 0.008) * 1.2;

      if (b.x < -120) b.x = width + 120;
      if (b.x > width + 120) b.x = -120;
      if (b.y < -120) b.y = height + 120;
      if (b.y > height + 120) b.y = -120;

      const grad = ctx.createRadialGradient(b.x, b.y, 0, b.x, b.y, b.r);
      grad.addColorStop(0, b.color);
      grad.addColorStop(0.6, b.color.replace(/[\d\.]+\)$/, '0.15)'));
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

// Touch Water Ripple
function initTouchRipples() {
  document.addEventListener('pointerdown', (e) => {
    const ripple = document.createElement('div');
    ripple.className = 'water-ripple';
    ripple.style.left = `${e.clientX}px`;
    ripple.style.top = `${e.clientY}px`;
    ripple.style.width = '140px';
    ripple.style.height = '140px';
    document.body.appendChild(ripple);
    setTimeout(() => ripple.remove(), 800);
  });
}

// Toast
function showToast(msg) {
  const toast = document.getElementById('toast');
  if (!toast) return;
  toast.textContent = msg;
  toast.classList.add('show');
  setTimeout(() => toast.classList.remove('show'), 2200);
}

// ==========================================================================
// 2. Liquid Elastic Morphing Tab Bar Controller
// ==========================================================================
function initLiquidTabs() {
  const bubble = document.getElementById('liquid-bubble');
  const tabItems = document.querySelectorAll('.liquid-tab-item');
  if (!bubble || !tabItems.length) return;

  function updateBubblePosition(activeItem, animate = true) {
    const rect = activeItem.getBoundingClientRect();
    const parentRect = activeItem.parentElement.getBoundingClientRect();
    const left = rect.left - parentRect.left;
    const width = rect.width;

    if (animate) {
      // Apply elastic liquid stretching during transition
      bubble.style.transform = 'scaleX(1.25) scaleY(0.85)';
      setTimeout(() => {
        bubble.style.transform = 'scale(1)';
      }, 250);
    }
    
    bubble.style.left = `${left}px`;
    bubble.style.width = `${width}px`;
  }

  // Initial layout
  setTimeout(() => {
    const initialActive = document.querySelector('.liquid-tab-item.active') || tabItems[0];
    updateBubblePosition(initialActive, false);
  }, 100);

  tabItems.forEach(item => {
    item.addEventListener('click', () => {
      const target = item.dataset.tab;
      if (!target) return;
      
      tabItems.forEach(t => t.classList.remove('active'));
      item.classList.add('active');
      updateBubblePosition(item, true);

      document.querySelectorAll('.tab-content').forEach(c => c.style.display = 'none');
      const activeContent = document.getElementById(`tab-${target}`);
      if (activeContent) {
        activeContent.style.display = 'block';
        activeContent.style.animation = 'tabSlideIn 0.35s cubic-bezier(0.34, 1.56, 0.64, 1)';
      }
      
      STATE.currentTab = target;
      if (target === 'tasks') loadTasks();
      if (target === 'accounts') loadAccounts();
    });
  });
}

// ==========================================================================
// 3. API & Data Handlers
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
        <div class="liquid-card" style="text-align:center; padding: 28px;">
          <p style="color:#ff007f; margin-bottom:8px; font-weight:800;">⚠️ 无法连接到 VPS 面板</p>
          <p style="color:rgba(255,255,255,0.7); font-size:13px;">请在「设置」中确认服务器地址: <code>${STATE.serverUrl}</code></p>
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
      dot.className = 'liquid-pulse-dot';
      text.textContent = 'VPS 在线';
    } else {
      dot.className = 'liquid-pulse-dot offline';
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
// Accounts & Tasks Render
// ==========================================================================
function initSearchAndFilters() {
  const searchInput = document.getElementById('account-search-input');
  if (searchInput) {
    searchInput.addEventListener('input', (e) => {
      STATE.searchQuery = e.target.value.trim().toLowerCase();
      renderAccounts();
    });
  }

  const pills = document.querySelectorAll('#account-filter-row .liquid-capsule-btn');
  pills.forEach(pill => {
    pill.addEventListener('click', () => {
      pills.forEach(p => {
        p.style.background = 'rgba(255,255,255,0.08)';
        p.style.borderColor = 'rgba(255,255,255,0.3)';
      });
      pill.style.background = 'linear-gradient(135deg,rgba(0,240,255,0.35),rgba(157,0,255,0.45))';
      pill.style.borderColor = '#fff';
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
      <div class="liquid-card" style="text-align:center; padding:36px;">
        <p style="color:rgba(255,255,255,0.6); font-size:14px;">没有匹配的账号</p>
      </div>
    `;
    return;
  }

  container.innerHTML = filtered.map(acc => {
    const isOnline = acc.status === 'online';
    const tgId = acc.tg_user_id || acc.id || '-';
    return `
      <div class="liquid-card">
        <div style="display:flex; justify-content:space-between; align-items:center;">
          <div style="display:flex; align-items:center; gap:10px;">
            <span class="liquid-pulse-dot ${isOnline ? '' : 'offline'}"></span>
            <span style="font-size:16px; font-weight:800; color:#fff;">${escapeHtml(acc.name || '未命名')}</span>
            ${acc.remark ? `<span style="font-size:12px; color:rgba(255,255,255,0.55);">(${escapeHtml(acc.remark)})</span>` : ''}
          </div>
          <span style="font-size:13px; font-weight:800; color:var(--fluid-cyan); font-family:ui-monospace,monospace; background:rgba(0,240,255,0.15); padding:4px 12px; border-radius:10px; border:1px solid rgba(0,240,255,0.5); cursor:pointer; box-shadow:0 0 14px rgba(0,240,255,0.25);" onclick="copyText('${acc.phone}')">${acc.phone} 📋</span>
        </div>
        <div style="display:grid; grid-template-columns:1fr 1fr; gap:8px; font-size:12px; margin-top:10px;">
          <div style="background:rgba(255,255,255,0.06); padding:8px 12px; border-radius:12px; border:1px solid rgba(255,255,255,0.1);">TG ID: <span style="font-family:ui-monospace,monospace; font-weight:700; color:#fff;">${tgId}</span></div>
          <div style="background:rgba(255,255,255,0.06); padding:8px 12px; border-radius:12px; border:1px solid rgba(255,255,255,0.1);">状态: <span style="font-weight:700; color:${isOnline ? 'var(--fluid-emerald)' : '#ff007f'};">${isOnline ? '在线' : '离线'}</span></div>
        </div>
      </div>
    `;
  }).join('');
}

function renderTasks() {
  const container = document.getElementById('tasks-list');
  if (!container) return;

  const entries = Object.entries(STATE.tasks);
  if (!entries.length) {
    container.innerHTML = `
      <div class="liquid-card" style="text-align:center; padding:36px;">
        <p style="color:rgba(255,255,255,0.6); font-size:14px;">暂无运行中的后台任务</p>
      </div>
    `;
    return;
  }

  container.innerHTML = entries.map(([id, t]) => {
    const isRunning = t.status === 'running';
    const isPaused = t.status === 'paused';
    const progress = (t.total > 0) ? Math.min(100, Math.round((t.current / t.total) * 100)) : 0;

    return `
      <div class="liquid-card" style="display:flex; flex-direction:column; gap:14px;">
        <div style="display:flex; justify-content:space-between; align-items:center;">
          <span style="font-weight:800; font-size:16px;">${escapeHtml(t.type || '任务 #' + id)}</span>
          <span style="font-size:11px; font-weight:800; padding:4px 10px; border-radius:8px; background:rgba(0,240,255,0.25); color:var(--fluid-cyan); border:1px solid rgba(0,240,255,0.5);">${t.status || 'RUNNING'}</span>
        </div>
        <div style="width:100%; height:8px; background:rgba(255,255,255,0.12); border-radius:99px; overflow:hidden; border:1px solid rgba(255,255,255,0.1);">
          <div style="height:100%; width:${progress}%; background:linear-gradient(90deg,var(--fluid-cyan),var(--fluid-purple),var(--fluid-pink)); border-radius:99px; box-shadow:0 0 16px var(--fluid-cyan);"></div>
        </div>
        <div style="display:flex; justify-content:space-between; font-size:12px; color:rgba(255,255,255,0.7);">
          <span>进度: ${t.current || 0} / ${t.total || 0} (${progress}%)</span>
          <span>延迟: ${t.delay_min || 1}-${t.delay_max || 30}s</span>
        </div>
        <div style="display:flex; gap:10px; margin-top:4px;">
          ${isRunning ? `<button class="liquid-btn liquid-btn-sm" onclick="pauseTask('${id}')">⏸ 暂停</button>` : ''}
          ${isPaused ? `<button class="liquid-btn liquid-btn-sm" onclick="resumeTask('${id}')">▶️ 继续</button>` : ''}
          <button class="liquid-btn liquid-btn-sm" onclick="viewTaskLog('${id}')">📜 实时日志</button>
          <button class="liquid-btn liquid-btn-sm liquid-btn-danger" onclick="cancelTask('${id}')">🛑 终止</button>
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
  if (modal) modal.style.display = 'flex';
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
  if (modal) modal.style.display = 'none';
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
  const delay = prompt('请输入延迟范围（如: 1-180）:', '1-180');
  const [min, max] = (delay || '1-180').split('-').map(Number);
  
  try {
    await fetchApi('/api/auto_verify', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ group: target, delay_min: min || 1, delay_max: max || 180 })
    });
    showToast('🚀 自动进群任务已启动');
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
