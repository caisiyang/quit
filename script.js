// EVA SYSTEM - CORE LOGIC
// V.4.0 (Logic Refinement)

const app = {
    data: {
        startDate: null,
        reason: '我太菜了',
        years: 10,
        cost: 25,
        insults: [],
        failCount: 0,
        successCount: 0,
        sosActive: false,
        navIndex: 0, // 0: Home, 1: Stats, 2: Profile
    },

    elements: {
        views: {},
        timer: {},
        inputs: {},
        stats: {},
    },

    init() {
        this.bindElements();
        this.loadData();
        this.loadInsults();
        this.startTimer();
        this.setupListeners();
        this.checkPWA();

        // Default to Home
        this.navTo('home');

        console.log("EVA SYSTEM INITIALIZED. POLLUTION LEVEL: CHECKING");
    },

    bindElements() {
        // Views
        this.elements.views.home = document.getElementById('view-home');
        this.elements.views.stats = document.getElementById('view-stats');
        this.elements.views.profile = document.getElementById('view-profile');

        // Timer
        this.elements.timer.main = document.getElementById('main-timer');
        this.elements.timer.days = document.getElementById('days-count');
        this.elements.timer.pollution = document.getElementById('pollution-rate');

        // Inputs
        this.elements.inputs.reason = document.getElementById('inp-reason');
        this.elements.inputs.years = document.getElementById('inp-years');
        this.elements.inputs.cost = document.getElementById('inp-cost');
        this.elements.inputs.form = document.getElementById('profile-form');
        this.elements.inputs.saveInsult = document.getElementById('btn-save-insult');

        // Stats
        this.elements.stats.healthBar = document.getElementById('bar-health');
        this.elements.stats.money = document.getElementById('money-saved');
        this.elements.stats.failCount = document.getElementById('fail-count');
    },

    loadData() {
        const saved = localStorage.getItem('eva_quit_data');
        if (saved) {
            const parsed = JSON.parse(saved);
            this.data.startDate = parsed.startDate ? new Date(parsed.startDate) : new Date();
            this.data.reason = parsed.reason || '我太菜了';
            this.data.years = parsed.years || 10;
            this.data.cost = parsed.cost || 25;
            this.data.failCount = parsed.failCount || 0;
            this.data.successCount = parsed.successCount || 0;

            // Fill Inputs
            this.elements.inputs.reason.value = this.data.reason;
            this.elements.inputs.years.value = this.data.years;
            this.elements.inputs.cost.value = this.data.cost;
        } else {
            // First Time Init
            this.data.startDate = new Date(); // Start NOW
            this.data.reason = "我太菜了";
            this.data.years = 10;
            this.saveData();
        }
        this.updateStats();
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
        try {
            // Priority: Try R2 API first
            const res = await fetch('/api/insults');
            if (res.ok) {
                this.data.insults = await res.json();
            } else {
                throw new Error("API Error");
            }
        } catch (e) {
            console.warn("R2 API FAILED, FALLING BACK TO LOCAL ASSETS", e);
            // Fallback: Local file
            try {
                const localRes = await fetch('assets/insults.json');
                this.data.insults = await localRes.json();
            } catch (err) {
                this.data.insults = ["系统错误", "你连报错都看不懂", "这里只有绝望"];
            }
        }
    },

    startTimer() {
        setInterval(() => {
            if (!this.data.startDate) return;

            const now = new Date();
            const diff = now - this.data.startDate;

            const days = Math.floor(diff / (1000 * 60 * 60 * 24));
            const hours = Math.floor((diff / (1000 * 60 * 60)) % 24);
            const minutes = Math.floor((diff / 1000 / 60) % 60);
            const seconds = Math.floor((diff / 1000) % 60);

            this.elements.timer.main.innerText =
                `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
            this.elements.timer.days.innerText = days;

        }, 1000);
    },

    updateStats() {
        if (!this.data.startDate) return;

        const now = new Date();
        const daysPassed = (now - this.data.startDate) / (1000 * 60 * 60 * 24);

        // Money: Price of each cigarette * Successes
        // Assuming Cost is per pack (20 cigs)
        const pricePerCig = this.data.cost / 20;
        const money = (this.data.successCount * pricePerCig).toFixed(2);
        this.elements.stats.money.innerText = money;

        // Fail Count
        if (this.elements.stats.failCount) {
            this.elements.stats.failCount.innerText = this.data.failCount;
        }

        // Health: Based on smoking years / 10
        // e.g. 10 years smoking -> need 1 year (365 days) to recover
        const recoveryYears = Math.max(1, this.data.years / 10);
        const recoveryDays = recoveryYears * 365;
        let health = (daysPassed / recoveryDays) * 100;

        if (health > 100) health = 100;
        if (health < 0) health = 0; // Should not happen

        this.elements.stats.healthBar.style.width = `${health}%`;
        this.elements.stats.healthBar.nextElementSibling.innerText = `${health.toFixed(2)}%`;

        // Pollution Rate (Home Screen)
        // Starts at 100%, -2% per success. 50 successes = 0%.
        let pollution = 100 - (this.data.successCount * 2);
        if (pollution < 0) pollution = 0;
        this.elements.timer.pollution.innerText = `${pollution}%`;
    },

    setupListeners() {
        // Navigation Global Function
        window.navTo = (id) => {
            const views = ['home', 'stats', 'profile'];
            const idx = views.indexOf(id);

            this.elements.views.home.style.transform = `translateX(${(0 - idx) * 100}%)`;
            this.elements.views.stats.style.transform = `translateX(${(1 - idx) * 100}%)`;
            this.elements.views.profile.style.transform = `translateX(${(2 - idx) * 100}%)`;

            // Update Tab Styles
            document.querySelectorAll('.h-16 button').forEach((btn, i) => {
                if (i === idx) {
                    btn.classList.add('active');
                    btn.querySelector('.text-gray-500').classList.add('text-eva-orange');
                    btn.querySelector('.text-gray-500').classList.remove('text-gray-500');
                } else {
                    btn.classList.remove('active');
                    const num = btn.querySelector('span:first-child');
                    num.classList.add('text-gray-500');
                    num.classList.remove('text-eva-orange');
                }
            });
        };

        // SOS Button
        document.getElementById('btn-sos').addEventListener('click', () => this.startSOS());

        // Give Up Button
        document.getElementById('btn-giveup').addEventListener('click', () => this.handleGiveUp());

        // Profile Save
        this.elements.inputs.form.addEventListener('submit', (e) => {
            e.preventDefault();
            this.data.reason = this.elements.inputs.reason.value;
            this.data.years = parseFloat(this.elements.inputs.years.value);
            this.data.cost = parseFloat(this.elements.inputs.cost.value);
            this.saveData();
            alert("数据已更新。");
            window.navTo('home');
        });

        // Save Insult
        this.elements.inputs.saveInsult.addEventListener('click', () => {
            const text = this.elements.inputs.reason.value;
            if (!text) return;

            // Mock Save Interaction
            const div = document.createElement('div');
            div.className = 'fixed top-10 left-1/2 transform -translate-x-1/2 bg-eva-green text-black font-bold px-6 py-3 rounded shadow-[0_0_20px_#00FF00] z-[100] text-center w-64';
            div.innerText = "感谢你为所有人增加一条毒舌";
            document.body.appendChild(div);

            setTimeout(() => {
                div.remove();
            }, 2000);
        });
    },

    startSOS() {
        const modal = document.getElementById('sos-modal');
        const quoteEl = document.getElementById('glitch-quote');
        const timerEl = document.querySelector('#sos-timer');

        modal.classList.remove('hidden');
        // Add warning pulse effect (Readable)
        quoteEl.classList.add('animate-warning');

        // Immediate Random Quote
        if (this.data.insults.length > 0) {
            const startRnd = Math.floor(Math.random() * this.data.insults.length);
            quoteEl.innerText = this.data.insults[startRnd];
        }

        let timeLeft = 300; // 5 Minutes

        // Quote Cycle (Readable Warning Text)
        this.quoteInterval = setInterval(() => {
            if (this.data.insults.length > 0) {
                const rnd = Math.floor(Math.random() * this.data.insults.length);
                quoteEl.innerText = this.data.insults[rnd];
            }
        }, 2000);

        // Countdown
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

    handleGiveUp() {
        // 1. Prompt for "耻辱"
        const punishment = prompt("输入“耻辱”二字，承认你的软弱：");

        if (punishment === "耻辱") {
            this.clearSOS(); // Stop timer/quotes
            document.getElementById('sos-modal').classList.add('hidden');

            // 2. Punishment Sequence (5 insults)
            this.triggerPunishmentSequence();

        } else {
            alert("连承认错误的勇气都没有？回到地狱去吧！");
        }
    },

    async triggerPunishmentSequence() {
        // Show 4 insults, 1 per 2 seconds
        for (let i = 0; i < 4; i++) {
            const rnd = Math.floor(Math.random() * this.data.insults.length);
            const text = this.data.insults[rnd];
            this.showToast(text);
            await new Promise(r => setTimeout(r, 2000));
        }

        // Final Toast
        this.showToast("失败次数+1，懦夫");
        await new Promise(r => setTimeout(r, 2000));

        // 3. Explosion & Reset
        this.triggerExplosion();
    },

    showToast(text) {
        const div = document.createElement('div');
        div.className = 'insult-toast animate-pulse';
        div.innerText = text;
        document.body.appendChild(div);
        setTimeout(() => div.remove(), 1800);
    },

    triggerExplosion() {
        const timerMain = this.elements.timer.main;

        // Add explosion Class
        timerMain.classList.add('animate-explode');

        // Wait for animation to finish then reset
        setTimeout(() => {
            timerMain.classList.remove('animate-explode');

            // ACTUAL RESET LOGIC
            this.data.failCount++;
            this.data.startDate = new Date(); // Reset time to NOW
            this.saveData();

            // alert("时间线已重置。一切归零。\n失败次数 +1"); // REMOVED per user request
            this.updateStats(); // Will set timer text to 00:00:00

        }, 1000);
    },

    clearSOS() {
        if (this.timerInterval) clearInterval(this.timerInterval);
        if (this.quoteInterval) clearInterval(this.quoteInterval);
        const quoteEl = document.getElementById('glitch-quote');
        if (quoteEl) quoteEl.classList.remove('animate-warning');
    },

    endSOS(success) {
        if (success) {
            const modal = document.getElementById('sos-modal');
            modal.classList.add('hidden');
            this.data.successCount++;
            this.saveData();
            alert("居然挺过来了？是不是偷偷抽了没告诉我？\n\n香烟污染率下降 2%。\n获得金钱奖励。");
        }
    },

    checkPWA() {
        // Basic iOS check
        const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;
        const isStandalone = window.matchMedia('(display-mode: standalone)').matches;

        if (isIOS && !isStandalone) {
            const modal = document.getElementById('install-modal');
            if (modal) {
                setTimeout(() => {
                    modal.classList.remove('hidden');
                }, 2000); // Delay for effect
            }
        }
    }
};

document.addEventListener('DOMContentLoaded', () => {
    app.init();
});
