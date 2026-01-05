# Google Play Console Setup Checklist 📋

Your app is currently in **Draft** mode. To enable Alpha/Beta testing tracks and publish updates automatically, you must complete the following sections in the [Google Play Console](https://play.google.com/console).

## 1. 🛡️ App Content (Policy)
Navigate to **Policy and programs** > **App content** (usually at the bottom of the left menu). You must complete all "To-do" items:

- [ ] **Privacy Policy**: Add a valid URL to your privacy policy.
    - *Link:* `https://github.com/Gruenbaer/FoulAndFortune/blob/master/PRIVACY_POLICY.md`
- [ ] **Ads**: Declare if your app contains ads (Yes/No).
- [ ] **App Access**: Declare if any parts of your app are restricted by login (e.g., "All functionality is available without special access").
- [ ] **Content Rating**: Fill out the IARC questionnaire.
    - This gives your app a rating (e.g., PEGI 3, ESRB E).
    - Takes ~5 minutes.
- [ ] **Target Audience**: Select age groups (e.g., 18+).
    - Answer "No" to "Appeal to children" if not specifically targeting kids.
- [ ] **News Apps**: Declare "No, it is not a news app".
- [ ] **COVID-19**: Declare "My app is not a publicly available COVID-19 contact tracing or status app".
- [ ] **Data Safety**:
    - **Data Collection**: strict rules. If you use generic libraries, checked what they collect.
    - If you are unsure, and use typical Flutter packages without tracking:
        - Does your app collect or share any of the required user data types? -> **No** (usually, unless you have analytics).
- [ ] **Government Apps**: Declare "No, this app is not developed by or on behalf of a government".
- [ ] **Financial Features**: Declare "My app doesn't provide any financial features".

## 2. 🎨 Store Presence (Main Store Listing)
Navigate to **Grow** > **Store presence** > **Main store listing**.

- [ ] **App Name**: `Foul & Fortune: Straight Pool`
    - *Why Straight Pool?* "Straight Pool" usually has higher search volume than "14.1" for casual players.
    - *Character Count:* 29 / 30 chars ✅ (Fits perfectly!)
- [ ] **Short Description**: (Max 80 chars)

`The Best Straight Pool Scorer. Track 14.1 runs, fouls & stats in style.`

*Keywords:* Straight Pool, Scorer, 14.1, Stats. (70/80 chars)

- [ ] **Full Description**: (Max 4000 chars)

**Elevate your 14.1 game with the most immersive scorer ever built.**

Foul & Fortune isn't just a scorekeeper—it's your digital referee, personal analyst, and the sleekest companion for your pool hall sessions. Designed exclusively for **14.1 Continuous (Straight Pool)**, it handles the complex math of the "King of Games" so you can stay in the zone.

🔥 Why Players Love Foul & Fortune:

🎱 Focus on the Flow
- One-Tap Scoring: We optimized the interface for speed. Score balls, mark errors, and finish racks without looking away from the table.
- Smart Safe-Zone: Dedicated buttons for Safeties and Fouls prevent accidental misses.
- Unlimited Undo: Made a mistake? Step back as many shots as you need. The scoreboard updates instantly.

🎨 Stunning Visuals
- Steampunk: Brass gears, steam vents, and mechanical counters for a vintage feel.
- Cyberpunk: Neon lights, holographic displays, and synth vibes for the modern player.
- Classic: A clean, distraction-free scoreboard for the purists.

📊 Pro-Level Stats
- Live Dashboard: See your Current Run, High Run, and Safety % in real-time.
- Match History: Every game is saved. Review your past performances and watch your average climb.
- Win Conditions: Set custom score targets or play open-ended.

🤖 The Digital Referee
- Foul Watchdog: Automatically tracks Breaking Fouls, standard fouls, and the dreaded Three-Foul Penalty (-15 points). We handle the math; you handle the cue ball.
- Re-Rack Alerts: The app knows when it's time to rack 'em balls.

💪 Built for the Long Game
- Works Offline: Reliable performance, no signal required.
- Battery Efficient: Optimized code ensures your phone lasts as long as your run.

Whether you're a casual league player or a high-run artist, Foul & Fortune is the upgrade your table needs. Download now and start your run!

- [ ] **Graphics**:
    - **App Icon**: `assets/icon/app_icon_512.png` (512x512 px)
        - *Path:* `c:\Users\Emili\SynologyDrive\AntiGravity\FoulAndFortune\assets\icon\app_icon_512.png`
        - *Note:* Resized from your 1024x1024 upload. Play Store requires exactly 512x512.
    - **Feature Graphic**: `assets/images/static_logo.jpg` (1024x500 px)
        - *Path:* `c:\Users\Emili\SynologyDrive\AntiGravity\FoulAndFortune\assets\images\static_logo.jpg`
    - **Phone Screenshots**: Upload at least 2 screenshots (aspect ratio < 2:1).
    - **Tablet Screenshots**: (Optional but recommended) Upload if you support tablets.

    > **📸 How to take screenshots:**
    > 1.  **Emulator Toolbar:** Click the **Camera icon** 📷 in the side menu.
    > 2.  **Shortcut:** Press `Ctrl + S`.
    > 3.  **Command:** Run `flutter screenshot` in your terminal while the app is running.
    >
    > *Tip:* Creating 2 screenshots (e.g., Main Menu, Scoreboard) is enough to pass the check.

### 🇩🇪 German (de-DE) Translations
Navigate to **Store settings** > **Manage translations** to add German.

- **App Name**: `Foul & Fortune: 14.1 Endlos`
    - *Character Count:* 27 / 30 chars ✅
- **Short Description**: (Max 80 chars)

`Dein Straight Pool Scoreboard. 14.1 Endlos Zähltafel, Statistiken & Themes.`

*Keywords:* Straight Pool, Scoreboard, 14.1 Endlos, Zähltafel. (75/80 chars)

- **Full Description**:

**Erlebe 14.1 Endlos wie nie zuvor.**

Foul & Fortune ist mehr als nur eine Zähltafel – es ist dein digitaler Schiedsrichter und persönlicher Coach. Entwickelt speziell für **14.1 Kontinuierlich (Straight Pool)**, trackt die App jeden Ball, jede Sicherheit und jedes Foul mit absoluter Präzision. Konzentriere dich auf deinen Run, nicht auf die Mathematik.

🔥 Highlights:

🎱 Dein Spiel im Fluss
- Intuitives Scoring: Eine Oberfläche, die mit deinem Rhythmus mithält. Ein Tap zum Punkten, keine unnötigen Menüs.
- Smarte Korrekturen: Tippfehler? Mit dem unbegrenzten Undo kein Problem.

🎨 Immersive Welten
- Steampunk: Messing-Zahnräder und Dampf-Ventile für einen edlen Retro-Look.
- Cyberpunk: Neon-Lichter und holografische Anzeigen für den modernen Touch.
- Classic: Puristisches Design für maximale Konzentration.

📊 Tiefgehende Analysen
- Live-Statistiken: Verfolge deinen aktuellen Run, High Run und Safety-Quote in Echtzeit.
- Match-Historie: Alle Spiele werden gespeichert. Analysiere deine Entwicklung über Wochen und Monate.

🤖 Der Digitale Schiedsrichter
- Regel-Wächter: Automatische Erkennung von Break-Fouls, Standard-Fouls und der Drei-Foul-Strafe (-15 Punkte).
- Re-Rack Logik: Die App sagt dir genau, wann aufgebaut werden muss.

💪 Bereit für den Marathon
- Offline-Modus: 100% zuverlässig, auch ohne Netz.
- Batterie-Effizient: Optimiert für lange Matches, ohne deinen Akku zu leeren.

Egal ob du die 100 knackst oder ein taktisches Sicherheitsduell führst – Foul & Fortune ist der Begleiter, den dein Spiel verdient. Gut Stoß!

## 3. 🚀 Publish the Initial Release

Once the above are green/completed:

1.  Go to **Testing** > **Internal testing**.
2.  You should see your uploaded release (Version `3.9.3+22`).
3.  Click **Edit Release** (or similar).
4.  Review the details.
5.  Click **Next** > **Save** > **Publish** (or "Start rollout to Internal testing").
    *   *Note: This might be instant or take a short review.*

## 4. 🔓 Enable Closed Testing (Alpha)

After the internal track is active and the Store Listing is complete:

1.  Go to **Testing** > **Closed testing**.
2.  Click **Manage track** (Alpha).
3.  **Testers**: Select your Google Group / Email list.
4.  **Create new release**:
    *   You can now try running `fastlane deploy` again!
    *   Or click "Promote release" from Internal Testing to move `3.9.3+22` to Alpha.

---

### 🆘 Common "Draft" Errors
If Fastlane says: `Only releases with status draft may be created on draft app`
*   **Fix**: You must manually click "Rollout" or "Publish" on your first release in the Play Console UI. Fastlane cannot push the "Publish" button for the very first upload on a draft app.
