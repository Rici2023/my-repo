const API = location.origin + '/api';
const qs = (s, el=document) => el.querySelector(s);
const qsa = (s, el=document) => [...el.querySelectorAll(s)];

// Konfiguracja nazw sekcji i ikon (dopasuj do „Dasboard Pro.html”)
const SECTIONS = [
  { key: 'overview', label: 'Przegląd', icon: `<svg width="18" height="18" viewBox="0 0 24 24"><path fill="currentColor" d="M3 13h8V3H3v10Zm0 8h8v-6H3v6Zm10 0h8V11h-8v10Zm0-18v6h8V3h-8Z"/></svg>` },
  { key: 'finance', label: 'Finanse', icon: `<svg width="18" height="18" viewBox="0 0 24 24"><path fill="currentColor" d="M3 3h18v2H3V3Zm2 6h14v2H5V9Zm-2 6h18v2H3v-2Zm2 6h14v2H5v-2Z"/></svg>` },
  { key: 'activities', label: 'Aktywności', icon: `<svg width= "18" height="18" viewBox="0 0 24 24"><path fill="currentColor" d="M4 17l4-10 4 8 3-6 5 8H4Z"/></svg>` },
  { key: 'agents', label: 'Health', icon: `<svg width="18" height="18" viewBox="0 0 24 24"><path fill="currentColor" d="M12 21q-3.75 0-6.375-2.625T3 12q0-3.75 2.625-6.375T12 3q3.75 0 6.375 2.625T21 12q0 3.75-2.625 6.375T12 21Zm-1-5h2v-3h3v-2h-3V8h-2v3H8v2h3v3Z"/></svg>` },
  { key: 'roles', label: 'Role', icon: `<svg width="18" height="18" viewBox="0 0 24 24"><path fill="currentColor" d="M12 12q-1.65 0-2.825-1.175T8 8q0-1.65 1.175-2.825T12 4q1.65 0 2.825 1.175T16 8q0 1.65-1.175 2.825T12 12Zm-8 8v-2q0-1.65 1.175-2.825T8 14h8q1.65 0 2.825 1.175T20 18v2H4Z"/></svg>` },
];

const state = {
  user: null,
  kpis: [],
  invoices: { rows: [], page: 1, pageSize: 20, pages: 1, total: 0, filters: { dateFrom: '', dateTo: '', status: '', q: '' } },
  activities: { rows: [], page: 1, pageSize: 20, pages: 1, total: 0, filters: { dateFrom: '', dateTo: '', type: '', status: '' } },
  agents: [],
  roles: []
};

async function api(path, opts={}){
  const res = await fetch(API + path, { credentials:'include', headers:{ 'Content-Type':'application/json' }, ...opts });
  if (!res.ok) throw new Error((await res.json()).error || res.statusText);
  return res.json();
}

function setTab(name){
  qsa('.tab').forEach(x=>x.classList.remove('active'));
  qs('#tab-'+name).classList.add('active');
  qsa('.sidebar nav button').forEach(b=>b.classList.toggle('active', b.dataset.tab===name));
}

function renderNav(){
  const nav = document.querySelector('.sidebar nav');
  nav.innerHTML = SECTIONS.map(s=>`<button data-tab="${s.key}" ${s.key==='overview'?'class="active"':''}>${s.icon}<span style="margin-left:8px;vertical-align:middle;">${s.label}</span></button>`).join('');
  if (state.user?.role !== 'admin') nav.querySelector('[data-tab="roles"]').classList.add('hidden');
  qsa('.sidebar nav button').forEach(btn=> btn.onclick = ()=> setTab(btn.dataset.tab));
}

function renderKPIs(){
  for(const k of state.kpis){
    const vEl = qs('#kpi-'+CSS.escape(k.label)); if (vEl) vEl.textContent = formatValue(k.value);
    const dEl = qs('#delta-'+CSS.escape(k.label)); if(dEl){ const delta = `${k.delta>0?'+':''}${k.delta}%`; dEl.textContent = delta; dEl.style.color = k.delta>=0 ? 'var(--ok)':'var(--down)'; }
  }
}

function formatValue(v){ return Intl.NumberFormat('pl-PL').format(v); }

function table(el, rows, columns){
  const thead = `<thead><tr>${columns.map(c=>`<th>${c.header}</th>`).join('')}</tr></thead>`;
  const tbody = `<tbody>${rows.map(r=>`<tr>${columns.map(c=>`<td>${c.cell(r)}</td>`).join('')}</tr>`).join('')}</tbody>`;
  el.innerHTML = thead + tbody;
}

function exportCsv(filename, rows){
  const csv = rows.map(r => r.map(x => `"${String(x).replaceAll('"','""')}"`).join(',')).join('\\n');
  const blob = new Blob([csv], {type:'text/csv;charset=utf-8;'});
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a'); a.href = url; a.download = filename; a.click(); URL.revokeObjectURL(url);
}

function printSection(title, html){
  const win = open('', '_blank');
  win.document.write(`<html><head><title>${title}</title></head><body>${html}</body></html>`);
  win.document.close(); win.focus(); win.print();
}

// ── Renderers ─────────────────────────────────────
function renderActivities(){
  const cols = [
    { header: 'Typ', cell: r=>r.type },
    { header: 'Tytuł', cell: r=>r.title },
    { header: 'Status', cell: r=>`<span class="status ${r.status==='OK'?'ok':(r.status==='WARN'?'warn':'down')}">${r.status}</span>` },
    { header: 'Kwota', cell: r=>formatValue(r.amount) },
    { header: 'Czas', cell: r=>new Date(r.created_at).toLocaleString('pl-PL') }
  ];
  table(qs('#activitiesTable'), state.activities.rows.slice(0,10), cols);
  table(qs('#activitiesTableFull'), state.activities.rows, cols);
  renderPager('actPager', state.activities, loadActivities);
}

function renderInvoices(){
  const cols = [
    { header: 'Klient', cell: r=>r.customer },
    { header: 'Kwota', cell: r=>`${formatValue(r.amount)} ${r.currency}` },
    { header: 'Status', cell: r=>`<span class="status ${r.status==='Paid'?'ok':(r.status==='Due'?'warn':'down')}">${r.status}</span>` },
    { header: 'Wystawiono', cell: r=>new Date(r.issued_at).toLocaleDateString('pl-PL') }
  ];
  table(qs('#invoicesTable'), state.invoices.rows, cols);
  renderPager('invPager', state.invoices, loadInvoices);
}

function renderAgents(){
  const grid = qs('#agentsGrid');
  grid.innerHTML = state.agents.map(a=>`
    <div class="card">
      <h4>${a.name}</h4>
      <div>Uptime: <strong>${a.uptime}%</strong></div>
      <div>SLO: <strong>${a.slo}%</strong></div>
      <div>Ostatni check: ${new Date(a.last_check).toLocaleString('pl-PL')}</div>
      <div class="status ${a.status==='OK'?'ok':(a.status==='WARN'?'warn':'down')}">${a.status}</div>
    </div>
  `).join('');
}

function renderRoles(){
  const list = qs('#rolesList');
  list.innerHTML = state.roles.map(r=>`
    <div class="role"><div><strong>${r.name}</strong> <span style="color:var(--muted)">— ${JSON.stringify(r.permissions)}</span></div>
    <button data-del="${r.id}">Usuń</button></div>`).join('');
  qsa('[data-del]').forEach(btn=>btn.onclick = async()=>{ await api(`/roles/${btn.dataset.del}`, { method:'DELETE' }); await loadRoles(); });
}

function renderPager(id, model, loader){
  const el = qs('#'+id);
  const { page, pages } = model;
  if (!el) return;
  const btn = (p, txt, dis=false)=>`<button ${dis?'disabled':''} data-page="${p}">${txt}</button>`;
  let html = btn(1,'«', page<=1) + btn(page-1,'‹', page<=1);
  html += `<span style="margin:0 8px">Strona ${page} / ${pages}</span>`;
  html += btn(page+1,'›', page>=pages) + btn(pages,'»', page>=pages);
  el.innerHTML = html;
  qsa('button', el).forEach(b=> b.onclick = ()=> loader({ page: parseInt(b.dataset.page,10) }));
}

// ── Drilldown modal ───────────────────────────────
const modal = qs('#modal');
qs('#modalClose').onclick = ()=> modal.classList.add('hidden');
function showDrilldown(label){
  const k = state.kpis.find(x=>x.label===label);
  if(!k) return;
  qs('#modalTitle').textContent = `Drilldown: ${label}`;
  const seg = k.segment || {};
  const segHtml = `<ul>${Object.entries(seg).map(([s,v])=>`<li><strong>${s}:</strong> ${v}%</li>`).join('')}</ul>`;
  qs('#modalBody').innerHTML = `
    <div style="display:grid;grid-template-columns:1fr 1fr; gap:12px;">
      <div class="card"><h4>Wartość</h4><div style="font-size:28px;font-weight:700">${formatValue(k.value)}</div><div>Δ ${k.delta>0?'+':''}${k.delta}%</div></div>
      <div class="card"><h4>Segmenty</h4>${segHtml}</div>
    </div>`;
  modal.classList.remove('hidden');
}
qsa('.kpi').forEach(el=>{ el.onclick = ()=> showDrilldown(el.dataset.kpi); });

// ── Auth flow ─────────────────────────────────────
qs('#loginForm').onsubmit = async (e)=>{
  e.preventDefault();
  try{ await api('/auth/login', { method:'POST', body: JSON.stringify({ email: qs('#email').value, password: qs('#password').value })}); await hydrate(); }
  catch(err){ alert('Błędne dane logowania'); }
};
qs('#logoutBtn').onclick = async ()=>{ await api('/auth/logout', { method:'POST' }); location.reload(); };

async function hydrate(){
  try{
    const me = await api('/auth/me');
    state.user = me; qs('#userEmail').textContent = me.email; qs('#roleBadge').textContent = me.role; qs('#logged').classList.remove('hidden'); qs('#loginForm').classList.add('hidden');
    renderNav();
    qs('#rolesTab')?.classList.toggle('hidden', me.role!=='admin');

    state.kpis = await api('/kpis');
    await Promise.all([loadInvoices({ page:1 }), loadActivities({ page:1 })]);
    state.agents = await api('/agents/health');

    renderKPIs(); renderAgents(); if(me.role==='admin'){ await loadRoles(); }
  }catch(e){ /* not logged */ renderNav(); }
}

async function loadRoles(){ state.roles = await api('/roles'); renderRoles(); }

async function loadInvoices({ page }){
  const f = state.invoices.filters;
  const params = new URLSearchParams({ page, pageSize: state.invoices.pageSize });
  if (f.dateFrom) params.set('dateFrom', f.dateFrom);
  if (f.dateTo) params.set('dateTo', f.dateTo);
  if (f.status) params.set('status', f.status);
  if (f.q) params.set('q', f.q);
  const data = await api('/finance/invoices?'+params.toString());
  state.invoices = { ...state.invoices, ...data, filters: f };
  renderInvoices();
}

async function loadActivities({ page }){
  const f = state.activities.filters;
  const params = new URLSearchParams({ page, pageSize: state.activities.pageSize });
  if (f.dateFrom) params.set('dateFrom', f.dateFrom);
  if (f.dateTo) params.set('dateTo', f.dateTo);
  if (f.type) params.set('type', f.type);
  if (f.status) params.set('status', f.status);
  const data = await api('/activities?'+params.toString());
  state.activities = { ...state.activities, ...data, filters: f };
  renderActivities();
}

// Hooki filtrów
qs('#invApply').onclick = ()=>{
  state.invoices.filters = {
    dateFrom: qs('#invFrom').value,
    dateTo: qs('#invTo').value,
    status: qs('#invStatus').value,
    q: qs('#invQuery').value.trim()
  };
  loadInvoices({ page: 1 });
};
qs('#actApply').onclick = ()=>{
  state.activities.filters = {
    dateFrom: qs('#actFrom').value,
    dateTo: qs('#actTo').value,
    type: qs('#actType').value,
    status: qs('#actStatus').value
  };
  loadActivities({ page: 1 });
};

// Exports
qs('#exportInvoicesCsv').onclick = ()=>{
  const rows = [["Klient","Kwota","Waluta","Status","Wystawiono"], ...state.invoices.rows.map(r=>[r.customer,r.amount,r.currency,r.status,new Date(r.issued_at).toLocaleDateString('pl-PL')])];
  exportCsv('invoices.csv', rows);
};
qs('#printInvoices').onclick = ()=>{ printSection('Faktury', qs('#invoicesTable').outerHTML); };

qs('#exportActivitiesCsv').onclick = ()=>{
  const rows = [["Typ","Tytuł","Status","Kwota","Czas"], ...state.activities.rows.slice(0,10).map(r=>[r.type,r.title,r.status,r.amount,new Date(r.created_at).toLocaleString('pl-PL')])];
  exportCsv('activities.csv', rows);
};
qs('#printActivities').onclick = ()=>{ printSection('Aktywności', qs('#activitiesTable').outerHTML); };

hydrate();
