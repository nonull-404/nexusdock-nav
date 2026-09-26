// nav: 自定义行为 —— 页面标题带上北京时间，方便一眼看时间
// 改动都带 nav: 前缀注释，方便跟上游 diff
(function () {
  const base = document.title;
  function tick() {
    const now = new Date(Date.now() + 8 * 60 * 60 * 1000);
    const hh = String(now.getUTCHours()).padStart(2, "0");
    const mm = String(now.getUTCMinutes()).padStart(2, "0");
    document.title = base + " · " + hh + ":" + mm + " (北京)";
  }
  tick();
  setInterval(tick, 30000);
})();
