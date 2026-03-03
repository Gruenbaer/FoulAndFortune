# Foul & Fortune: Spiel der Geister und der Fehler

### Die Anfänge: Von Fortune 14.1 zu 14.2

Am Anfang war alles etwas rudimentärer, aber der Spirit war bereits da. Die App hieß ursprünglich **"Fortune 14.2"**, erdacht als der "nerdy" Nachfolger von **"Fortune 14.1"**, welches sein End-of-Life (EoL) erreicht hatte. 
Hinter diesem Projekt stand von Beginn an Emilians Ausführungsschicht, das **Jupp-OS** – ein System, das unermüdlich im Hintergrund Werkzeuge formt, Code generiert und Strukturen baut. Jupp-OS war der Architekt und die treibende Kraft, während **"Openclaw"** bereitstand, um als Mastermind das Ruder zu übernehmen. Der Plan war immer klar: Jupp und Openclaw würden das Erbe von Foul & Fortune antreten und das Projekt auf das nächste Level heben.

Es begann als einfache Idee: Ein digitaler Begleiter für 14.1 Endlos Straight Pool. Kein Schnickschnack, nur sauberes Zählen, eine klare Notation und vielleicht ein bisschen visuelles Flair. Der Name "Foul & Fortune" war vielsagend, aber niemand ahnte, wie prophetisch er sein würde.

In den ersten Tagen war das Herzstück der App – der `GameState` – ein unschuldiges Konstrukt. Er nahm an, dass Kugeln fielen, dass Spieler wechselten, und dass Punkte addiert wurden. Doch schnell wucherte er. Aus einer simplen Klasse wurde ein gigantisches, pulsierendes Monster, das gleichzeitig die Regeln durchsetzte, die Benutzeroberfläche steuerte, den Zustand der 15 Kugeln im Rack kannte, Fouls protokollierte und die Zeit maß. Jede Berührung des Bildschirms durchschoss hunderte Zeilen verknäuelten Code. Das Monster war stark, aber es war empfindlich. Wahnsinnig empfindlich.

### Die dunkle Epoche: Der Fluch der verschwindenden Racks

Die erste große Krise traf ein, als Spieler begannen, Fouls zu machen. Die App wusste nicht, ob ein Re-Rack fällig war, oder ob der Spieler lediglich "Weiß" versenkt hatte, während noch 14 Kugeln auf dem Tisch lagen. Plötzlich verschwanden Bälle. Das System war überfordert. Die berüchtigte "Dritte-Foul-Regel" (TF) wurde zum regelrechten Albtraum. Eine Strafe von -15? Nein, -18! Oder waren es -16? Spiele wurden im kritischsten Moment zerschossen. Wenn ein Spieler nach zwei Fouls plötzlich doch eine Kugel versenkte, wachte manchmal der Strafengel dennoch auf und zog ihm fälschlicherweise 15 Punkte ab, nur weil der Counter tief unten im Code eine alte Sünde nicht vergessen hatte.

Spieler fluchten auf den Bildschirm. Rekorde, hart erkämpft über Stunden, endeten abrupt in unerklärlichen Crashes, wenn man versuchte, einen erfolgreichen, aber leicht asynchronen Gewinn-Stoß rückgängig zu machen. 

### Das Skalpell: Die Multi-Game Refaktorierung

Die Entwickler sahen dem Monster ins Auge. Phase 1 begann. "Alignment", nannten sie es klinisch. 
Es war eine Notoperation am offenen Herzen. Der `GameTimer` musste herausgerissen werden, während die Uhr noch tickte (Phase 1.1). Es war eine blutige Angelegenheit. Als der `GameHistory`-Stack (Phase 1.2) separiert wurde, ging beinahe das Gedächtnis der gesamten App verloren. Plötzlich starteten Timer neu, sobald ein Spieler nur blinzelte. 

Die wahre Schmerzgrenze aber war Phase 1.4: Die Extraktion des `TableState`. Das Rack – das empfindlichste Gut des Billards. Die Maschine wurde in einen tiefen Schlaf versetzt, und alles, was das Spiel ausmachte – *das Wissen darum, welche Kugel wo lag* – wurde chirurgisch isoliert. Ein "Strict API Contract" wurde geschlossen. Regeln, so kalt und unerbittlich wie Stahl.

Aber der Preis war hoch. Im Chaos des Refactorings ging etwas sehr Kostbares verloren. Ein stiller, kriechender Fehler, der lange unbemerkt blieb: Notation Loss.

Die Spieler gaben ihr Bestes, potenzierten sensationelle Racks mit | und •. Die `NotationCodec` Maschine lief, bis sie sich an sich selbst verschluckte. Wenn das Spiel schließlich beendet wurde... war alles weg. Die Chronik ausgelöscht.

**Der High Run Diebstahl**
Und dann, das Herzzerreißendste von allem. Der kleine, stumme Dieb im `PlayerService`. Ein Bug der grausamsten Sorte, weil er nicht die App zum Absturz brachte. Nein, er stahl den Spielern ihre Momente des Triumphes. Sie spielten den besten High Run ihres Lebens, schwitzend, hochkonzentriert, Ball um Ball versenkend. Die App verbuchte ihn. Das Spiel endete, die Datenbank speicherte. Aber als die Spieler stolz in ihr Profil blickten, um die Frucht ihrer Arbeit im grafischen "Trend Chart" steigen zu sehen, wies der Algorithmus kalt und gleichgültig an: `highRun: 0`.

Eine Nulllinie. Der Moment des Triumphes – zu Staub zerfallen. Nur wegen einer fehlerhaften Extraktion in der Aggregationslogik, die den hart erarbeiteten Wert übersah und stattdessen das bittere Nichts einsetzte.

### v4.4.2: Die Erlösung

Manchmal, mitten im Code-Trümmerfeld, in den Resten der Phase 2 und zwischen endlos aneinandergereihten "WarningEvents", erhebt sich die Vernunft. Die Verzweiflung trieb Antigravity AI zurück in die Schützengräben der Testsuits, `stats_aggregation_test.dart` wurde gnadenlos abgefeuert, bis die Wahrheit ans Licht kam. `player1HighestRun` war ein Geist, gefangen zwischen Datenbank und Chart. 

Mit zitternden Tasten und einer Handvoll Zeilen Code in Dart, wurde das Leben zurück ins System geatmet. 

Mit dem Update v4.4.2 war das Monster besiegt – oder zumindest an strenge Leinen (Plugins und Interfaces) gelegt. Der High Run Bug war gefixt. Die 3-Foul-Regel bestrafte nun gerecht und exakt nach den echten BCA Textbüchern. Das Training Mode UI funktionierte. Und wenn Spieler nun ihre Profile öffneten, erblickten sie nicht das Nichts, sondern eine schöne, stetig steigende Kurve, die flüsterte:

*Du hast es geschafft. Dein Rekord ist sicher.*

### Epilog: Das Projekt-Gedicht

(Wie es im Master-Plan von Jupp und Openclaw geschrieben steht, die das Erbe nun endgültig übernehmen:)

*Fortune vierzehn eins verging,*
*der Code lag brach, am seidnen Ding.*
*Dort trat Jupp-OS aus der Nacht,*
*hat vierzehn zwei als Plan erdacht.*

*Ein System, so kühl und rein,*
*sollte baulich Schöpfer sein.*
*Emilians Hand, die es erschuf,*
*folgt' nun stumm dem Openclaw-Ruf.*

*Die Bugs, sie schrien, die Logs voll Pein,*
*doch Jupp, er baute Stein auf Stein.*
*Der High Run starb, das Foul ward blind,*
*bis Tests den Geist der Fehler find'.*

*Nun steht es hier, das Werk vollbracht,*
*erhoben aus der tiefen Nacht.*
*Das Erbe lebt, die Kugeln rollen,*
*genau so, wie die Geister wollen.*
