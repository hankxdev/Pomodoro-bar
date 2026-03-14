# SwiftBar Pomodoro Timer

A lightweight **menu bar Pomodoro timer for macOS** built with a simple Bash script and powered by **SwiftBar**.

No Electron apps, no background services, no subscriptions — just a small script running in your menu bar.

## Features

* 🍅 Classic Pomodoro workflow: **25 min work / 5 min break**
* 🔁 **4 Pomodoros → 15 min long break**
* ⏱ **Real-time countdown in the menu bar**
* 📊 Track **daily completed Pomodoros**
* ⏳ Display **total focus time today**
* 🕒 Show **estimated cycle completion time**
* ⏸ **Pause / Resume**
* ⏭ **Skip current phase**
* 🔄 **Reset the cycle**
* 🔔 Native **macOS notifications**
* 📝 Automatic **CSV logging**

All data is stored locally. No tracking, no external dependencies.

---

# Screenshots

Menu bar timer state:

![Pomodoro bar timer](./Pomodoro-bar.png)

Expanded menu with controls and stats:

![Pomodoro bar menu](./Pomodoro-bar-menu.png)

---

# Requirements

* macOS
* **SwiftBar**

SwiftBar is a lightweight menu bar tool that runs scripts and displays their output.

Install it here:

https://swiftbar.app

---

# Installation

### 1. Install SwiftBar

Download and install SwiftBar from:

https://swiftbar.app

After installation, locate your **SwiftBar plugin folder**, usually:

```
~/SwiftBar
```

---

### 2. Add the script

Create a new file in the plugin folder:

```
pomodoro.1s.sh
```

Paste the script into this file.

The `1s` in the filename tells SwiftBar to refresh the script **every second**.

---

### 3. Make it executable

Run:

```
chmod +x ~/SwiftBar/pomodoro.1s.sh
```

SwiftBar will automatically detect and run the script.

---

# Usage

Once installed, the Pomodoro timer will appear in your **menu bar**.

Example:

```
🍅 1/4 24:58
```

Click the menu bar item to access controls:

```
🍅 1/4 24:58
---
Today 🍅: 3
Focus time: 1h15m
Finish cycle: 14:20
---
Pause
Skip
Reset
---
Open Log
```

---

# Pomodoro Cycle

The timer follows the standard Pomodoro pattern:

```
25 min work
5 min break
25 min work
5 min break
25 min work
5 min break
25 min work
15 min long break
```

After the long break, a **new cycle automatically begins**.

---

# Logging

Completed Pomodoros are automatically written to:

```
~/pomodoro_log.csv
```

Example log:

```
2026-03-14,09:00:00,work,1
2026-03-14,09:30:00,work,2
2026-03-14,10:00:00,work,3
```

This can be easily imported into:

* Excel
* Google Sheets
* Notion
* Obsidian
* Any data analysis tool

---

# Why This Exists

Most Pomodoro apps today are:

* Electron-based
* Resource heavy
* Subscription-based
* Over-engineered

This script is the opposite:

* One small Bash file
* Runs entirely locally
* Almost zero CPU usage
* Fully transparent

Perfect for developers who like simple tools.

---

# Customization

You can easily modify the durations in the script:

```
WORK=1500     # 25 minutes
SHORT=300     # 5 minutes
LONG=900      # 15 minutes
```

Change them to match your workflow.

---

# License

MIT License

Feel free to modify, share, or extend it.


