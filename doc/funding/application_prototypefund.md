# Prototypefund

This is part of [LGro](https://github.com/LGro)'s application for the German [Prototype Fund](https://prototypefund.de).

## Projekttitel
Coagulate

## Beschreibe dein Projekt kurz (100W)
Als erstes möchten wir wissen, was ihr während der 6-monatigen Förderzeit bauen wollt. Versucht, so konkret und einfach wie möglich zu schildern, an welcher Software ihr arbeiten wollt und warum das wichtig ist.
Kurz gesagt: Was habe ich vor

- Eine kurze Beschreibung davon, welche Ziele mit eurem Softwareprojekt erreicht werden sollen
- Eine kurze Beschreibung, wie euer Softwareprojekt funktionieren soll
- Der Hintergrund eurer Idee: Wie seid ihr darauf gekommen? In welchem Zusammenhang soll das Projekt wirken?
- Warum ihr das Projekt für wichtig haltet

NICHT:
- Eine Projektbeschreibung, die nur technisch ist (das kommt später)
- Eine Beschreibung, bei der vergessen wird zu erwähnen, wie die Software das beschriebene Problem löst

> Coagulate wird eine Smartphone App, die es Menschen ermöglicht, ihre Kontaktdaten und Aufenthaltsorte privat und sicher mit anderen zu teilen.
Egal ob geografisch verteilter Bekanntenkreis, oder Treffen von nicht-normativ lebenden Menschen, Coagulate hilft digital vernetzten Menschen, physisch zusammenzukommen.
Du entscheidest individuell, was du mit Kolleg\*innen, Freund\*innen und Liebhaber\*innen teilst, damit jede\*r genau die richtigen Infos hat, um in Kontakt zu bleiben.
Coagulate nutzt die Veilid Distributed Hash Table um 100% Peer-to-Peer arbeiten zu können.
So werden die digitale Souveränität gewährleistet und Nutzer\*innen vor Überwachung und Datenhandel geschützt.
Meine Kernmotivation ist mein Bedürfnis, privatsphärefreundlich soziale Kontakte zu stärken.

## Welchem Themenfeld ordnest du dein Projekt zu?

> [Data Security](https://prototypefund.de/wp-content/uploads/2021/05/Onepager_Data_Security.pdf)


## Welche gesellschaftliche Herausforderung willst du mit dem Projekt angehen? (175W)

Alle durch den Prototype Fund geförderten Projekte haben einen klaren gesellschaftlichen Mehrwert. Hier wollen wir verstehen, wie ihr mit eurem Projekt zur Lösung einer gesellschaftlichen Herausforderung beitragen wollt.
Kurz gesagt: Warum ist euer Projekt wichtig für die Gesellschaft?

- Eine kurze, prägnante und klare Beschreibung des gesellschaftlichen Problems, das ihr identifiziert habt
- Warum dieses Problem dringend gelöst werden muss
- Die aktuelle Situation: Was fehlt, um das Problem zu lösen?
- Warum Software zur Lösung des Problems beitragen kann

NICHT
- Tech-Solutionismus: Wir erwarten keine magischen Lösungen, sondern realisierbare Ansätze.

> Globale Digitalisierung und steigende Mobilität im Lebensverlauf führen zu räumlich verteilten Freundes- und Bekanntenkreisen.
Häufig übersieht man welche digitalen Kontakte tatsächlich in der gleichen Großstadt leben, oder welche alte Bekanntschaft zufällig berufsbedingt im Nachbarort sein wird.
Trotz unserer digitalen Möglichkeiten nehmen Gefühle von Einsamkeit und Isolation zu.
Zu Beginn der sozialen Netzwerk Plattformen freuten sich viele, endlich einfacher Kontakt zu alten Bekannten pflegen zu können; Andere fanden Menschen mit ähnlichen Interessen.
Zentralisierte Plattformen kommen jedoch immer mit einem fundamentalen Risiko für die informationelle Selbstbestimmung.
Dies ist insbesondere für verfolgte und diskriminierte Gruppen gefährlich, wobei es im Besonderen diese Menschen sind, die von einem starken soziales Netz profitieren.
Innovationen aus dem Bereich verteilter Systeme wie Private Routing für private Distributed Hash Table Operationen ermöglichen, soziale Kontakte mit Coagulate privatsphärefreundlich technologisch zu stärken und durch digitale Vernetzung persönliche Begegnungen zu fördern.

## Wie willst du dein Projekt technisch umsetzen? (175W)

Jetzt sind die technischen Aspekte dran! Auch wenn Detailfragen oft erst in der Umsetzungsphase geklärt werden, solltet ihr zum Zeitpunkt der Bewerbung schon grob erklären können, wie ihr das Projekt umsetzen werdet. Anhand eurer Beschreibung müssen wir einschätzen können, ob das Projekt in dieser Form realisierbar ist und ob die Technologien sinnvoll eingesetzt werden.
Kurz gesagt: Wie wird das Projekt umgesetzt?

- Konkrete Informationen zum Tech Stack: Programmiersprachen, Frameworks, Libraries, Infos zur Infrastruktur etc.
- Projekte, auf denen ihr aufbauen wollt – wir glauben fest daran, dass man das Rad nicht immer wieder neu erfinden muss!
- Knackige Sätze, die deutlich machen, wie die Tools eingesetzt werden

NICHT
- Zu grobe Pläne: Begriffe wie "eine Website", "eine App" reichen nicht aus, um das Projekt technisch bewerten zu können.
- Reine Aufzählungen von Tools – schreibt Sätze!

> Coagulate wird als plattformübergreifende mobile Anwendung für iOS und Android mit Flutter umgesetzt.
Peer-to-Peer Funktionalität und privatsphärefreundlicher Informationstransfer basieren auf der Veilid Distributed Hash Table (DHT), da hier Lese- und Schreiboperationen möglich sind ohne die eigene IP Adresse preiszugeben.
Hilfreich ist zudem, dass Veilid in Rust implementiert und mit Flutter/Dart Bindings bereits direkt integrierbar ist.
Dabei soll Coagulate keine separate DHT betreiben sondern von der Veilid DHT profitieren und selbst zu deren Robustheit beitragen, um die Peer-to-Peer Infrastruktur auch für andere Veilid basierte Anwendungen zu stärken.
User können sich miteinander durch QR-Codes und Einladungslinks verbinden.
Für die Kartendarstellung von Kontaktadressen und Aufenthaltsorten kommt eine Open Street Map Integration zum Einsatz.
Das Release und Build Management wird mit Fastlane umgesetzt. 
Der Quellcode wird auf GitHub.com gehosted, da dort MacOS und Linux Maschinen für Continuous Integration und Delivery verfügbar sind.

## Hast du schon an der Idee gearbeitet? Wenn ja, beschreibe kurz den aktuellen Stand und erkläre die geplanten Neuerungen. (100W)

Einige Prototype-Fund-Geförderte arbeiten schon lange an dem Projekt, andere bewerben sich mit einer neuen Idee und arbeiten sich erst während der Förderung in das Thema ein. Beide Herangehensweisen – und alles, was dazwischen liegt – sind völlig in Ordnung. Es gibt also kein Richtig oder Falsch, aber eure Antwort hilft uns, die Bewerbung einzuordnen und den Zeitaufwand für die Umsetzung abzuschätzen. Bei länger bestehenden Projekten empfehlen wir, deutlich zu machen, wie sich der zu fördernde Teil klar vom Projekt abgrenzt. Es kann sich z. B. um ein neues Feature oder Modul handeln - eine "Verbesserung der bestehenden Software" ist nicht ausreichend für eine Förderung.
Kurz gesagt: Was ist der Stand eures Projektes?

- Wenn das Projekt bereits existiert: Was wurde schon erreicht, was soll nach der Förderung anders sein?
- Auch wenn es das Projekt offiziell noch nicht gibt, habt ihr schon gebastelt, ausprobiert, diskutiert?
- Ein kurzes "Nein" reicht auch aus, wenn noch nicht an dem Projekt gearbeitet wurde.

NICHT
- Der Prototype Fund fördert Software, daher können wir nur Projekte mit einem hohen Entwicklungsanteil zur Förderung auswählen. Bestehende Projekte, bei denen z. B. "nur" Dokumentation, Release und Marketing geplant sind, sind leider nicht förderfähig.

> Die Idee, Kontaktdaten privatsphärefreundlich und dezentral zu teilen, begleitet mich seit Jahren.
Die Veröffentlichung von Veilid mit ihrer Distributed Hash Table, macht die Idee ohne Preisgabe der eigenen IP-Adresse umsetzbar.
Der Wechsel in Teilzeit Anfang 2024 erlaubte mir, mit der Entwicklung von Coagulate zu beginnen.
Die Prototype-Fund-Förderung soll finanzielle Einbußen ausgleichen und eine effektive weitere Entwicklung stärken.
Bisher besteht ein Flutter-Projekt mit Veilid Anbindung, Adressbuchintegration in iOS und Android sowie einer OpenStreetMap Karte mit Kontaktadressen.
Die Synchronisation mit Veilid ist noch fehlerhaft, aber ein QR-Code- und Einladungslink-basierter Verknüpfungsprozess ist vorbereitet.
Geplante Funktionalitäten umfassen das Teilen aktueller/zukünftiger Aufenthaltsorte sowie benutzerdefinierte Profile.

## Welche ähnlichen Ansätze gibt es schon und was wird dein Projekt anders bzw. besser machen? (60W)

Hier möchten wir wissen, ob ihr euch mit den vorhandenen Alternativen auseinandergesetzt habt. Habt ihr geprüft, ob es die Software, die ihr bauen wollt, schon gibt? Es kommt sehr selten vor, dass es keine ähnlichen Projekte gibt. Sind die existierenden Projekte noch aktiv, sind sie unter einer FOSS-Lizenz verfügbar, wie unterscheidet sich euer Projekt von den existierenden Ansätzen? Auch oft relevant: Warum wollt oder könnt ihr nicht auf bestehenden Projekten aufbauen?
Kurz gesagt: Was unterscheidet euer Projekt von dem, was es schon gibt?

- Projektbeispiele, die mit eurer Idee vergleichbar sind, und warum sie nicht zu dem Problem passen, das ihr lösen wollt
- Was ist an eurem Projekt anders und besser als an bereits existierenden Alternativen?

NICHT
- Die unbegründete Behauptung, dass keine Projekte vergleichbar seien. Dadurch wirkt das Projekt nicht innovativer, sondern die Bewerbung weniger durchdacht

> Social Media Plattformen ermöglichen Nutzer\*innen Kontaktdaten zu teilen und Treffen zu organisieren, bedeuten aber den Hoheitsverlust über die eigenen Daten.
Standorte teilen ist bspw. via "Find My", "Google Maps", oder "Glympse" Apps möglich, jedoch ohne überprüfbare kryptografische Garantien.
Coagulate ermöglicht sicheren, auditierbaren Austausch durch FOSS Lizenz und Peer-to-Peer Architektur, fördert lokale Interaktionen und schließt Zensur und Monetarisierung der Nutzer\*innendaten aus.

## Wer ist die Zielgruppe und wie soll dein Projekt sie erreichen? (100W)

Wir möchten wissen, ob ihr euch Gedanken darüber gemacht habt, wer euer Projekt nutzen wird. Und wir möchten wissen, wie ihr diese Nutzer\*innen erreichen möchtet!
Kurz gesagt: Für wen ist das Projekt wichtig?

- Klar definierte Nutzer\*innengruppen, egal ob nischig oder breit – beides kann (je nach Projekt) sinnvoll sein.
- Ideen, wie diese Zielgruppen erreicht werden können
- Informationen über bestehende Kontakte, Projektpartner, Communities

NICHT
- Unklare Pläne: Ihr wollt Vorträge auf Konferenzen halten? Nennt ein Beispiel. Ihr sucht Projektpartner? Nennt einige mögliche Organisationen, Communities oder Unternehmen, mit denen ihr Kontakt aufnehmen möchtet.

> Coagulate ist für alle Menschen, die privatsphärenbewusst und plattformunabhängig mit ihren Freund\*innen und Bekannten in Kontakt bleiben möchten.
Eine Pilotzielgruppe sind internationale Studierende (bspw. ERASMUS), die viele in Europa verteilte Kontakte knüpfen.
Ihnen möchte ich mit Coagulate helfen, diesen Kontakten auch in Zukunft wieder zu begegnen.
Eine strategische Kooperation mit Organisationen wie AISEC oder AEGEE scheint hier vielversprechend.
Außerdem bietet Coagulate für nicht-normativ lebende Menschen, bspw. aus der Queeren Community, Potenzial in vertrauten Kreisen Zusammenkünfte zu organisieren und Kontakte zu pflegen.
Hier möchte ich mit persönlichen Kontakten arbeiten um Feedback aus der Zielgruppe zu erhalten.

## Erfahrung, Hintergrund, Motivation, Perspektive: Was sollen wir über dich (bzw. euch) wissen und bei der Auswahl berücksichtigen? (100W)

Wir möchten von euch hören, warum euch das Projekt wichtig ist. Seid ihr persönlich von dem Problem betroffen, das ihr lösen wollt? Habt ihr Erfahrungen, die für das Projekt wichtig sind? Beschäftigt ihr euch schon länger mit dem Thema des Projekts, seid ihr Expert\*innen im Feld? Hier könnt ihr uns alle Informationen mitteilen, die für unsere Bewertung wichtig sind.
Kurz gesagt: Was sollten wir über euch wissen?

- Persönliche Erfahrungen, relevante (technische oder andere) Kenntnisse, Informationen über die Zusammensetzung des Teams, Hintergrund des Projekts
- Wir bezeichnen diese Frage gerne als "Wild Card": Ihr entscheidet, was wir noch über euch und das Projekt wissen sollten!

> Aufgrund mehrfache Umzüge, u.a. wegen internationaler Studienaufenthalte, sowie reiseintensiver Hobbys ist der Kreis meiner Freund\*innen und Bekannten geografisch stark verteilt.
Und obwohl ich viele dieser Menschen sehr schätze fehlt mir für einige die Kapazität um aktiv unseren Kontakt zu pflegen.
Coagulate soll hier helfen, den Überblick zu behalten, wer zur Zeit wo anzutreffen und wie kontaktierbar ist.
Ich war mehrere Jahre selbstständiger Softwareentwickler, unter anderem für mobile Anwendungen, und bin auch aktuell im Softwareumfeld tätig.
Mein akademischer Hintergrund an der Schnittstelle zwischen Psychologie und Informatik hat mich darüber hinaus für User Experience und User Centered Design sensibilisiert.

## Skizziere kurz die wichtigsten Meilensteine, die im Förderzeitraum umgesetzt werden sollen. (100W)

Meilensteine geben uns immer einen guten Einblick, wie ihr bei der Umsetzung eines Projektes vorgeht und wie ihr eure Arbeit strukturiert. Natürlich können sich die Meilensteine während des Förderzeitraums leicht ändern, da man bei der Umsetzung von Prototypen immer wieder auf unvorhergesehene Hindernisse stößt oder sich bestimmte Schritte als überflüssig erweisen können. Versucht einfach, so gut wie möglich abzuschätzen, wie euer Förderungszeitraum aussehen könnte.
Kurz gesagt: Wann sollen die einzelnen Schritte des Projekts umgesetzt werden?

- Eine Liste der Meilensteine, wie sie für den Förderzeitraum voraussichtlich geplant sind. Nummerierte Schritte oder Bullet Points sehen wir hier sehr gerne.
- Auch grobe Zeitangaben (z. B. in Wochen oder Monaten) sind für uns sehr hilfreich.

> Oktober: Check-in Funktion um aktuellen Aufenthaltsort zu teilen und Visualisierung der Aufenthaltsorte anderer, sowie Start einer geschlossenen iOS und Android Beta für kontinuierliches Feedback (100h)
Dezember: Funktion "Circles" zu nuanciert konfigurierbaren Gruppen und Profilvarianten für nutzer\*innendefiniertes Teilen (140h)
Februar: Funktion zukünftige Aufenthaltsorte teilen inkl. Zeit-Slider auf der Karte zur Visualisierung zukünftiger Aufenthaltsorte anderer; sowie Release in App/Play Store und auf F-droid (140h)
