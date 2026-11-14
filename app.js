/* 문학연구소 · 1단계 메인 페이지 스크립트 (순수 JavaScript, 외부 라이브러리 없음) */
(function () {
  "use strict";

  var WORKS = window.SAMPLE_WORKS || [];
  var state = { q: "", cat: "all", access: "all" };

  function $(id) { return document.getElementById(id); }

  // 사용자 입력/데이터를 HTML에 넣을 때 안전하게 변환
  function esc(s) {
    return String(s).replace(/[&<>"']/g, function (c) {
      return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c];
    });
  }

  function priceText(w) {
    return w.access === "free" ? "무료" : w.price.toLocaleString("ko-KR") + "원";
  }
  function badge(w) {
    return w.access === "free"
      ? '<span class="badge badge-free">무료</span>'
      : '<span class="badge badge-premium">프리미엄</span>';
  }

  function cardHTML(w) {
    return '<button type="button" class="card" data-work="' + esc(w.id) + '">' +
      '<div class="card-top">' + badge(w) +
        '<span class="badge badge-tag">' + esc(w.genre) + '</span>' +
        (w.exam ? '<span class="badge badge-tag">기출</span>' : "") +
      '</div>' +
      '<div class="card-title">' + esc(w.title) + '</div>' +
      '<div class="card-meta">' + esc(w.author) + ' · ' + esc(w.era) + '</div>' +
      '<p class="card-sum">' + esc(w.summary) + '</p>' +
      '<div class="card-foot"><span>분석 자료</span><span class="price">' + esc(priceText(w)) + '</span></div>' +
    '</button>';
  }

  function rankHTML(w, i) {
    return '<li><button type="button" data-work="' + esc(w.id) + '">' +
      '<span class="rank-no">' + (i + 1) + '</span>' +
      '<span class="rank-body"><span class="rank-title">' + esc(w.title) + '</span>' +
      '<span class="rank-meta">' + esc(w.author) + ' · ' + esc(w.genre) + '</span></span>' +
      badge(w) + '</button></li>';
  }

  function fill(id, list, renderer) {
    $(id).innerHTML = list.map(renderer).join("");
  }

  function byDateDesc(a, b) { return a.createdAt < b.createdAt ? 1 : -1; }
  function byPopDesc(a, b) { return b.popularity - a.popularity; }

  // 검색: 작품명, 작가명, 시대, 갈래 (공백 제거 후 포함 여부)
  function matches(w) {
    if (state.cat !== "all" && w.category !== state.cat) return false;
    if (state.access !== "all" && w.access !== state.access) return false;
    var q = state.q.replace(/\s+/g, "").toLowerCase();
    if (!q) return true;
    var hay = (w.title + w.author + w.era + w.genre).replace(/\s+/g, "").toLowerCase();
    return hay.indexOf(q) !== -1;
  }

  function isFiltering() {
    return state.q.trim() !== "" || state.cat !== "all" || state.access !== "all";
  }

  function render() {
    var filtering = isFiltering();
    $("results").hidden = !filtering;
    $("defaultSections").hidden = filtering;
    if (!filtering) return;

    var list = WORKS.filter(matches).sort(byPopDesc);
    $("resultCount").textContent = list.length + "건";
    fill("resultGrid", list, cardHTML);
    $("resultEmpty").hidden = list.length !== 0;
  }

  function renderDefaults() {
    fill("gridLatest", WORKS.slice().sort(byDateDesc).slice(0, 6), cardHTML);
    fill("listPopular", WORKS.slice().sort(byPopDesc).slice(0, 6), rankHTML);
    fill("gridClassic", WORKS.filter(function (w) { return w.category === "classic"; }).sort(byDateDesc), cardHTML);
    fill("gridModern", WORKS.filter(function (w) { return w.category === "modern"; }).sort(byDateDesc), cardHTML);
    fill("gridExam", WORKS.filter(function (w) { return w.exam; }).sort(byPopDesc), cardHTML);

    $("countClassic").textContent = WORKS.filter(function (w) { return w.category === "classic"; }).length + "개 작품";
    $("countModern").textContent = WORKS.filter(function (w) { return w.category === "modern"; }).length + "개 작품";
    $("countExam").textContent = WORKS.filter(function (w) { return w.exam; }).length + "개 작품";
  }

  // 아직 구현되지 않은 기능은 가짜로 동작시키지 않고 솔직하게 안내
  var NOTICES = {
    login:  { t: "로그인", b: "로그인은 5단계(회원가입 및 로그인)에서 Supabase Auth로 구현됩니다. 아직 사용할 수 없습니다." },
    signup: { t: "회원가입", b: "회원가입은 5단계(회원가입 및 로그인)에서 Supabase Auth로 구현됩니다. 아직 사용할 수 없습니다." },
    work:   { t: "작품 분석 페이지", b: "작품 상세 분석 페이지는 3단계에서 제작됩니다. 지금은 메인 화면만 확인할 수 있습니다." }
  };

  function showNotice(key) {
    var n = NOTICES[key];
    $("noticeTitle").textContent = n.t;
    $("noticeBody").textContent = n.b;
    var d = $("noticeDialog");
    if (typeof d.showModal === "function") d.showModal();
    else alert(n.t + "\n\n" + n.b);
  }

  function setOn(containerId, attr, value) {
    var chips = $(containerId).querySelectorAll(".chip");
    for (var i = 0; i < chips.length; i++) {
      chips[i].classList.toggle("is-on", chips[i].getAttribute(attr) === value);
    }
  }

  function resetAll() {
    state = { q: "", cat: "all", access: "all" };
    $("q").value = "";
    setOn("catChips", "data-cat", "all");
    setOn("accessChips", "data-access", "all");
    render();
  }

  function bind() {
    $("searchForm").addEventListener("submit", function (e) {
      e.preventDefault();
      state.q = $("q").value;
      render();
      if (isFiltering()) $("results").scrollIntoView();
    });
    $("q").addEventListener("input", function () { state.q = this.value; render(); });

    $("catChips").addEventListener("click", function (e) {
      var b = e.target.closest("[data-cat]");
      if (!b) return;
      state.cat = b.getAttribute("data-cat");
      setOn("catChips", "data-cat", state.cat);
      render();
    });
    $("accessChips").addEventListener("click", function (e) {
      var b = e.target.closest("[data-access]");
      if (!b) return;
      state.access = b.getAttribute("data-access");
      setOn("accessChips", "data-access", state.access);
      render();
    });
    $("resetBtn").addEventListener("click", resetAll);

    // 로그인/회원가입 버튼, 작품 카드 클릭
    document.addEventListener("click", function (e) {
      var n = e.target.closest("[data-notice]");
      if (n) { showNotice(n.getAttribute("data-notice")); return; }
      var w = e.target.closest("[data-work]");
      if (w) showNotice("work");
    });
  }

  renderDefaults();
  bind();
  render();
})();
