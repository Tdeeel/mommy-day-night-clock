# Grandma's Day & Night Clock

Clock for Mommy — a large, distraction-free clock that clearly answers whether it is daytime or nighttime.

## Offline Windows version

Download `Grandmas_Day_Night_Clock.exe` and double-click it. It needs no Wi-Fi and uses the computer's own date and time.

- Press **Esc** to close it.
- Built for 64-bit Windows 10 and 11.
- Windows SmartScreen may show a warning because this personal app is not code-signed. Choose **More info → Run anyway**.

## Web version

The root files are a progressive web app:

- `index.html` — the clock
- `manifest.webmanifest` — installable-app settings
- `sw.js` — offline caching

Open `index.html` through a web server or publish the repository with GitHub Pages. Press **S** to open the clock settings.

## Display periods

| Computer time | Display |
| --- | --- |
| 5:00 A.M.–11:59 A.M. | MORNING · IT IS DAYTIME |
| 12:00 P.M.–5:59 P.M. | AFTERNOON · IT IS DAYTIME |
| 6:00 P.M.–8:59 P.M. | EVENING · IT IS NIGHTTIME |
| 9:00 P.M.–4:59 A.M. | NIGHT · IT IS NIGHTTIME |

The native Windows source is included under `windows-source/` for safekeeping.
