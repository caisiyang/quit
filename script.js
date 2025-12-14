// EVA SYSTEM - CORE LOGIC
// V.4.4 (Visual Enhancements)

// 随机戒烟理由列表
const QUIT_REASONS = [
    "为了家人的健康",
    "不想再咳嗽了",
    "想多活几年",
    "省下买烟的钱",
    "牙齿太黄了",
    "身上烟味太重",
    "孩子说我嘴巴臭",
    "跑步喘不上气",
    "医生警告我了",
    "不想得肺癌",
    "女朋友嫌弃我",
    "想当一个好榜样",
    "保险费太贵了",
    "爬楼梯都累",
    "皮肤越来越差"
];

const app = {
    data: {
        startDate: null,
        reason: '',
        years: 10,
        cost: 25,
        insults: [],
        failCount: 0,
        successCount: 0,
        sosActive: false,
        navIndex: 0,
    },

    elements: {
        views: {},
        timer: {},
        inputs: {},
        stats: {},
    },

    mainTimerInterval: null,
    timerInterval: null,
    quoteInterval: null,
    shameClickCount: 0,
    lastShameBtn: null,
    lastTimerValue: '',

    init() {
        this.initTheme();
        this.bindElements();
        this.loadData();
        this.loadInsults();
        this.startTimer();
        this.setupListeners();
        this.bindShameButtons();
        this.checkPWA();
        window.navTo('home');
        console.log("EVA SYSTEM INITIALIZED. POLLUTION LEVEL: CHECKING");
    },

    initTheme() {
        const theme = localStorage.getItem('eva_theme') || 'dark';
        if (theme === 'light') {
            document.body.classList.add('light-theme');
        }
    },

    toggleTheme() {
        document.body.classList.toggle('light-theme');
        const theme = document.body.classList.contains('light-theme') ? 'light' : 'dark';
        localStorage.setItem('eva_theme', theme);
    },

    bindElements() {
        this.elements.views.home = document.getElementById('view-home');
        this.elements.views.stats = document.getElementById('view-stats');
        this.elements.views.profile = document.getElementById('view-profile');
        this.elements.timer.main = document.getElementById('main-timer');
        this.elements.timer.days = document.getElementById('days-count');
        this.elements.timer.pollution = document.getElementById('pollution-rate');
        this.elements.inputs.reason = document.getElementById('inp-reason');
        this.elements.inputs.years = document.getElementById('inp-years');
        this.elements.inputs.cost = document.getElementById('inp-cost');
        this.elements.inputs.form = document.getElementById('profile-form');
        this.elements.inputs.saveInsult = document.getElementById('btn-save-insult');
        this.elements.stats.healthBar = document.getElementById('bar-health');
        this.elements.stats.healthText = document.getElementById('val-health');
        this.elements.stats.money = document.getElementById('money-saved');
        this.elements.stats.failCount = document.getElementById('fail-count');
    },

    loadData() {
        const saved = localStorage.getItem('eva_quit_data');
        if (saved) {
            const parsed = JSON.parse(saved);
            this.data.startDate = parsed.startDate ? new Date(parsed.startDate) : new Date();
            this.data.reason = parsed.reason || '';
            this.data.years = parsed.years || 10;
            this.data.cost = parsed.cost || 25;
            this.data.failCount = parsed.failCount || 0;
            this.data.successCount = parsed.successCount || 0;
            this.elements.inputs.years.value = this.data.years;
            this.elements.inputs.cost.value = this.data.cost;
        } else {
            this.data.startDate = new Date();
            this.data.reason = '';
            this.data.years = 10;
            this.saveData();
        }
        // 每次刷新页面都显示随机理由作为placeholder
        const randomReason = QUIT_REASONS[Math.floor(Math.random() * QUIT_REASONS.length)];
        this.elements.inputs.reason.placeholder = randomReason;
        // 如果用户之前保存过理由，显示已保存的值
        if (this.data.reason) {
            this.elements.inputs.reason.value = this.data.reason;
        }
        this.updateStats();
    },

    handlePunishment() {
        this.data.startDate = new Date();
        this.data.failCount++;
        this.data.cost = this.data.cost || 25;
        this.saveData();
        if (this.elements.stats.failCount) {
            this.elements.stats.failCount.innerText = this.data.failCount;
        }
        if (this.elements.timer.main) {
            this.elements.timer.main.innerText = "00:00:00";
        }
        if (this.elements.timer.days) {
            this.elements.timer.days.innerText = "0";
        }
        this.stopMainTimer();
        this.startTimer();
    },

    saveData() {
        const payload = {
            startDate: this.data.startDate,
            reason: this.data.reason,
            years: this.data.years,
            cost: this.data.cost,
            failCount: this.data.failCount,
            successCount: this.data.successCount
        };
        localStorage.setItem('eva_quit_data', JSON.stringify(payload));
        this.updateStats();
    },

    async loadInsults() {
        let official = [];
        try {
            const res = await fetch('https://r2.quit.saaaai.com/insults.json');
            if (res.ok) official = await res.json();
        } catch (e) {
            try {
                const local = await fetch('assets/insults.json');
                official = await local.json();
            } catch (err) { }
        }
        let community = [];
        try {
            const res = await fetch('https://r2.quit.saaaai.com/community.json');
            if (res.ok) community = await res.json();
        } catch (e) { }
        this.data.insults = [...official, ...community];
        if (this.data.insults.length === 0) {
            this.data.insults = ["系统错误", "你连报错都看不懂", "这里只有绝望"];
        }
        // 启动随机毒舌滚动
        this.startRandomInsultScroll();
    },

    startRandomInsultScroll() {
        const insultEl = document.getElementById('random-insult');
        if (!insultEl) return;

        // 显示第一条
        if (this.data.insults.length > 0) {
            insultEl.innerText = this.data.insults[Math.floor(Math.random() * this.data.insults.length)];
        }

        // 每3秒切换，带丝滑动画
        this.randomInsultInterval = setInterval(() => {
            if (this.data.insults.length === 0) return;

            // 淡出
            insultEl.style.opacity = '0';
            insultEl.style.transform = 'translateY(-10px)';

            setTimeout(() => {
                // 切换文字
                const rnd = Math.floor(Math.random() * this.data.insults.length);
                insultEl.innerText = this.data.insults[rnd];

                // 从下方淡入
                insultEl.style.transform = 'translateY(10px)';

                // 触发重绘后淡入
                requestAnimationFrame(() => {
                    insultEl.style.opacity = '1';
                    insultEl.style.transform = 'translateY(0)';
                });
            }, 300);
        }, 3000);
    },

    stopMainTimer() {
        if (this.mainTimerInterval) {
            clearInterval(this.mainTimerInterval);
            this.mainTimerInterval = null;
        }
    },

    startTimer() {
        this.stopMainTimer();
        this.mainTimerInterval = setInterval(() => {
            if (!this.data.startDate) return;
            const now = new Date();
            const diff = now - this.data.startDate;
            const days = Math.floor(diff / (1000 * 60 * 60 * 24));
            const hours = Math.floor((diff / (1000 * 60 * 60)) % 24);
            const minutes = Math.floor((diff / 1000 / 60) % 60);
            const seconds = Math.floor((diff / 1000) % 60);
            const timeStr = `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;

            // Diff Logic for Smart Glow
            let html = '';
            if (!this.lastTimerValue || this.lastTimerValue.length !== timeStr.length) {
                // First run or format change: just print
                html = timeStr;
            } else {
                for (let i = 0; i < timeStr.length; i++) {
                    const char = timeStr[i];
                    const oldChar = this.lastTimerValue[i];

                    // Only animate numbers, ignore colons
                    if (char !== oldChar && char !== ':') {
                        html += `<span class="digit-active">${char}</span>`;
                    } else {
                        html += char;
                    }
                }
            }
            this.lastTimerValue = timeStr;

            if (this.elements.timer.main) {
                this.elements.timer.main.innerHTML = html;
            }
            if (this.elements.timer.days) {
                this.elements.timer.days.innerText = days;
            }
        }, 1000);
    },

    updateStats() {
        if (!this.data.startDate) return;
        const now = new Date();
        const daysPassed = (now - this.data.startDate) / (1000 * 60 * 60 * 24);
        const pricePerCig = this.data.cost / 20;
        const money = (this.data.successCount * pricePerCig).toFixed(2);
        this.elements.stats.money.innerText = money;
        if (this.elements.stats.failCount) {
            this.elements.stats.failCount.innerText = this.data.failCount;
        }
        const recoveryYears = Math.max(1, this.data.years / 10);
        const recoveryDays = recoveryYears * 365;
        let health = (daysPassed / recoveryDays) * 100;
        if (health > 100) health = 100;
        if (health < 0) health = 0;
        this.elements.stats.healthBar.style.width = `${health}%`;
        if (this.elements.stats.healthText) {
            this.elements.stats.healthText.innerText = `${health.toFixed(2)}%`;
        }
        let pollution = 100 - (this.data.successCount * 2);
        if (pollution < 0) pollution = 0;
        this.elements.timer.pollution.innerText = `${pollution}%`;
    },

    setupListeners() {
        window.navTo = (id) => {
            const views = ['home', 'stats', 'profile'];
            const idx = views.indexOf(id);
            this.elements.views.home.style.transform = `translateX(${(0 - idx) * 100}%)`;
            this.elements.views.stats.style.transform = `translateX(${(1 - idx) * 100}%)`;
            this.elements.views.profile.style.transform = `translateX(${(2 - idx) * 100}%)`;
            document.querySelectorAll('.h-16 button').forEach((btn, i) => {
                if (i === idx) {
                    btn.classList.add('active');
                } else {
                    btn.classList.remove('active');
                }
            });
        };
        document.getElementById('btn-theme-toggle').addEventListener('click', () => this.toggleTheme());
        document.getElementById('btn-sos').addEventListener('click', () => this.startSOS());
        document.getElementById('btn-giveup').addEventListener('click', () => this.handleGiveUp());
        this.elements.inputs.form.addEventListener('submit', (e) => {
            e.preventDefault();
            this.data.reason = this.elements.inputs.reason.value;
            this.data.years = parseFloat(this.elements.inputs.years.value);
            this.data.cost = parseFloat(this.elements.inputs.cost.value);
            this.saveData();
            alert("数据已更新。");
            window.navTo('home');
        });
        this.elements.inputs.saveInsult.addEventListener('click', async () => {
            const text = this.elements.inputs.reason.value;
            if (!text) return;
            const btn = this.elements.inputs.saveInsult;
            const originalText = btn.innerText;
            btn.innerText = "...";
            btn.disabled = true;
            try {
                const res = await fetch('/api/submit', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ text: text })
                });
                if (res.ok) {
                    alert("毒舌已收录。感谢你为所有人贡献攻击力。");
                    this.elements.inputs.reason.value = "";
                    this.loadInsults();
                } else {
                    alert("发送失败。可能是网络问题或内容太长。");
                }
            } catch (e) {
                alert("系统错误：无法连接到神经中枢。");
            } finally {
                btn.innerText = originalText;
                btn.disabled = false;
            }
        });
    },

    startSOS() {
        const modal = document.getElementById('sos-modal');
        const quoteEl = document.getElementById('glitch-quote');
        const timerEl = document.querySelector('#sos-timer');
        modal.classList.remove('hidden');
        this.data.sosActive = true;

        // Initial quote with shake effect
        if (this.data.insults.length > 0) {
            const startRnd = Math.floor(Math.random() * this.data.insults.length);
            quoteEl.innerText = this.data.insults[startRnd];
            this.triggerQuoteAnimation(quoteEl);
        }

        let timeLeft = 300;

        // Quote cycle with animation
        this.quoteInterval = setInterval(() => {
            if (this.data.insults.length > 0) {
                const rnd = Math.floor(Math.random() * this.data.insults.length);
                quoteEl.innerText = this.data.insults[rnd];
                this.triggerQuoteAnimation(quoteEl);
            }
        }, 2000);

        this.timerInterval = setInterval(() => {
            timeLeft--;
            const mins = Math.floor(timeLeft / 60);
            const secs = timeLeft % 60;
            const timeStr = `${String(mins).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
            timerEl.setAttribute('data-text', timeStr);
            timerEl.innerText = timeStr;
            if (timeLeft <= 0) {
                this.clearSOS();
                this.endSOS(true);
            }
        }, 1000);
    },

    triggerQuoteAnimation(quoteEl) {
        // Add shake class temporarily
        quoteEl.classList.add('shake');
        setTimeout(() => {
            quoteEl.classList.remove('shake');
        }, 500);
    },

    clearSOS() {
        if (this.timerInterval) {
            clearInterval(this.timerInterval);
            this.timerInterval = null;
        }
        if (this.quoteInterval) {
            clearInterval(this.quoteInterval);
            this.quoteInterval = null;
        }
        const quoteEl = document.getElementById('glitch-quote');
        if (quoteEl) quoteEl.classList.remove('animate-warning', 'shake');
        const sosBtn = document.getElementById('btn-sos');
        if (sosBtn) sosBtn.classList.remove('animate-warning');
    },

    endSOS(success) {
        this.clearSOS();
        this.data.sosActive = false;
        const modal = document.getElementById('sos-modal');
        if (modal) modal.classList.add('hidden');
        if (success) {
            this.data.successCount++;
            this.saveData();
            alert("居然挺过来了？是不是偷偷抽了没告诉我？\n\n香烟污染率下降 2%。\n获得金钱奖励。");
        }
    },

    handleGiveUp() {
        const modal = document.getElementById('giveup-modal');
        modal.classList.remove('hidden');
        this.shameClickCount = 0;
        this.lastShameBtn = null;
    },

    bindShameButtons() {
        const buttons = document.querySelectorAll('.btn-shame-opt');
        buttons.forEach(btn => {
            btn.addEventListener('click', (e) => {
                const currentBtn = e.currentTarget;
                if (this.lastShameBtn !== currentBtn) {
                    this.shameClickCount = 0;
                    this.lastShameBtn = currentBtn;
                    buttons.forEach(b => {
                        b.classList.remove('bg-red-900/50', 'text-eva-red', 'border-eva-red');
                        b.style.transform = 'scale(1)';
                    });
                }
                this.shameClickCount++;
                currentBtn.style.transform = `scale(${1 + this.shameClickCount * 0.05})`;
                if (this.shameClickCount === 1) {
                    currentBtn.classList.add('bg-red-900/50');
                } else if (this.shameClickCount === 2) {
                    currentBtn.classList.add('text-eva-red', 'border-eva-red');
                } else if (this.shameClickCount >= 3) {
                    this.triggerSystemFailure();
                }
            });
        });
    },

    async triggerSystemFailure() {
        const modal = document.getElementById('giveup-modal');
        const sosModal = document.getElementById('sos-modal');
        const overlay = document.getElementById('failure-overlay');
        const timerText = document.getElementById('main-timer');
        const overlayTextContainer = overlay.querySelector('.failure-overlay-text');

        modal.classList.add('hidden');
        sosModal.classList.add('hidden');
        this.clearSOS();
        this.data.sosActive = false;

        try {
            overlay.classList.remove('hidden');
            const insults = this.data.insults.length > 0 ? this.data.insults : ["废物", "没救了", "软骨头", "去死吧"];

            for (let i = 0; i < 4; i++) {
                const rnd = Math.floor(Math.random() * insults.length);
                overlayTextContainer.innerHTML = insults[rnd];
                overlayTextContainer.classList.remove('animate-glitch-text');
                void overlayTextContainer.offsetWidth; // Trigger reflow
                overlayTextContainer.classList.add('animate-glitch-text');
                await new Promise(r => setTimeout(r, 2000));
            }

            // Fix Color for Light Theme: Use semantic variable
            overlayTextContainer.innerHTML = "防御失败<br><span style='font-size:0.5em;color:var(--text-primary)'>DEFENSE FAILED +1</span>";
            await new Promise(r => setTimeout(r, 2000));

        } catch (e) {
            console.error("System Failure Sequence Error:", e);
        } finally {
            // Ensure overlay is hidden and we navigate home
            overlay.classList.add('hidden');
            window.navTo('home');

            // Trigger shatter and reset
            if (timerText) {
                setTimeout(() => timerText.classList.add('animate-shatter'), 100);

                setTimeout(() => {
                    this.data.startDate = new Date();
                    this.data.failCount++;
                    this.saveData();
                    if (this.elements.stats.failCount) {
                        this.elements.stats.failCount.innerText = this.data.failCount;
                    }
                    if (timerText) {
                        timerText.innerText = "00:00:00";
                        timerText.classList.remove('animate-shatter');
                    }
                    if (this.elements.timer.days) {
                        this.elements.timer.days.innerText = "0";
                    }
                    this.stopMainTimer();
                    this.startTimer();
                    this.showToast("系统重置完成。耻辱记录已上传。", "error");
                }, 1500);
            }
        }
    },

    showToast(text, type = 'default') {
        const div = document.createElement('div');
        div.className = 'insult-toast animate-pulse';
        if (type === 'error') {
            div.style.borderColor = '#E60000';
            div.style.color = '#E60000';
        } else if (type === 'success') {
            div.style.borderColor = '#39FF14';
            div.style.color = '#39FF14';
        }
        div.innerText = text;
        document.body.appendChild(div);
        setTimeout(() => div.remove(), 1800);
    },

    checkPWA() {
        const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;
        const isStandalone = window.matchMedia('(display-mode: standalone)').matches;
        if (isIOS && !isStandalone) {
            const modal = document.getElementById('install-modal');
            if (modal) {
                setTimeout(() => {
                    modal.classList.remove('hidden');
                }, 2000);
            }
        }
    }
};

document.addEventListener('DOMContentLoaded', () => {
    app.init();
});
