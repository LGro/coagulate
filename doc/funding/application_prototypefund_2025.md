# Prototypefund

This is part of [LGro](https://github.com/LGro)'s application for the German [Prototype Fund](https://prototypefund.de).

## 1. Allgemeines

### Projekttitel *

Coagulate

## 2. Dein Projekt

### Beschreibe dein Projekt kurz. *
(max. 100 Wörter)

Die Smartphone App Coagulate ermöglicht Menschen, ihre Kontaktdaten, sowie aktuelle und zukünftige Aufenthaltsorte privat und sicher mit anderen zu teilen.
Egal ob geografisch verteilter Bekanntenkreis, oder Treffen von nicht-normativ lebenden Menschen, Coagulate hilft digital vernetzten Menschen, physisch zusammenzukommen.
Du entscheidest individuell, was du mit Kolleg\*innen, Freund\*innen und Liebhaber\*innen teilst, damit jede\*r genau die richtigen Infos hat, um in Kontakt zu bleiben.
Coagulate nutzt die Veilid Distributed Hash Table, arbeitet 100% Peer-to-Peer und Ende-zu-Ende verschlüsselt.
So werden die digitale Souveränität gewährleistet und Nutzer\*innen vor Überwachung und Datenhandel geschützt.
Ich möchte privatsphärefreundlich soziale Kontakte stärken.

### Welche gesellschaftliche Herausforderung willst du mit dem Projekt angehen? *
(max. 175 Wörter)

Globale Digitalisierung und steigende Mobilität im Lebensverlauf führen zu räumlich verteilten Freundes- und Bekanntenkreisen.
Häufig übersieht man welche digitalen Kontakte tatsächlich in der gleichen Großstadt leben, oder welche alte Bekanntschaft zufällig berufsbedingt im Nachbarort sein wird.
Trotz unserer digitalen Möglichkeiten nehmen Gefühle von Einsamkeit und Isolation zu.
Zu Beginn der sozialen Netzwerk Plattformen freuten sich viele, endlich einfacher Kontakt zu alten Bekannten pflegen zu können; Andere fanden Menschen mit ähnlichen Interessen.
Zentralisierte Plattformen kommen jedoch immer mit einem fundamentalen Risiko für die informationelle Selbstbestimmung.
Dies ist insbesondere für verfolgte und diskriminierte Gruppen gefährlich, wobei es im Besonderen diese Menschen sind, die von einem starken sozialen Netz profitieren.
Innovationen aus dem Bereich verteilter Systeme wie Private Routing für private Distributed Hash Table Operationen ermöglichen, soziale Kontakte mit Coagulate privatsphärefreundlich technologisch zu stärken und durch digitale Vernetzung persönliche Begegnungen zu fördern.

### Wie willst du dein Projekt technisch umsetzen? *
(max. 175 Wörter)

Coagulate ist als plattformübergreifende mobile Anwendung für iOS und Android mit Flutter umgesetzt.
Peer-to-Peer Funktionalität und privatsphärefreundlicher Informationstransfer basieren auf der Veilid Distributed Hash Table (DHT), da hier Lese- und Schreiboperationen möglich sind ohne die eigene IP Adresse preiszugeben.
Hilfreich ist zudem, dass Veilid in Rust implementiert und mit Flutter/Dart Bindings bereits direkt integrierbar ist.
Dabei soll Coagulate keine separate DHT betreiben sondern von der Veilid DHT profitieren und selbst zu deren Robustheit beitragen, um die Peer-to-Peer Infrastruktur auch für andere Veilid basierte Anwendungen zu stärken.
User können sich miteinander durch QR-Codes und Einladungslinks verbinden.
Für die Kartendarstellung von Kontaktadressen und Aufenthaltsorten kommt eine Open Street Map Integration zum Einsatz.
Das Release und Build Management wird mit Fastlane umgesetzt. 
Der Quellcode wird auf GitHub.com gehosted, da dort MacOS und Linux Maschinen für Continuous Integration und Delivery verfügbar sind.

### Hast du schon an der Idee gearbeitet? Wenn ja, beschreibe kurz den aktuellen Stand und erkläre die geplanten Neuerungen. *
(max. 100 Wörter)

Die Coagulate iOS und Android Alpha ermöglicht, sich mit anderen zu verknüpfen, um privat Kontaktdaten und Standorte zu teilen, inkl. einer passenden Kartendarstellung.
Zur laut User-Feedback essenziellen Verbesserung des Onboardings soll im Rahmen der Förderung eine Funktion entstehen, bei der Nutzende ihren Kontakten erlauben können, einen Teil ihrer Kontaktdetails weiterzugeben, um sie Kontakten vorzustellen.
Damit können privatsphärefreundlich bestehende Kontakte gefunden und Kontakt zu relevanten neuen Menschen geknüpft werden.
Dazu soll die robuste Identifikation von Veranstaltungen kommen, damit wenn mehrere Kontakte deren Teilnahme an einer Veranstaltung vermerken, diese ohne Duplikate und mit einer privatsphärefreundlichen "wer kommt noch" Liste dargestellt werden kann.

### Link zum bestehenden Projekt (falls vorhanden)

https://coagulate.social

### Welche ähnlichen Ansätze gibt es schon und was wird dein Projekt anders bzw. besser machen? *
(max. 100 Wörter)

Social Media Plattformen ermöglichen Nutzer\*innen Kontaktdaten zu teilen und Treffen zu organisieren, bedeuten aber den Hoheitsverlust über die eigenen Daten.
Standorte teilen ist bspw. via "Find My", "Google Maps", oder "Glympse" Apps möglich, jedoch ohne überprüfbare kryptografische Garantien.
Privatsphäreorientierte Ansätze wie das GNUnet basierte secushare, passen nicht mehr in die heutige stark Smartphone zentrierte Welt.
Coagulate ermöglicht sicheren, auditierbaren Austausch durch FOSS Lizenz und Peer-to-Peer Architektur, fördert lokale Interaktionen und schließt Zensur und Monetarisierung der Nutzer\*innendaten aus.

### Wer ist die Zielgruppe und wie soll dein Projekt sie erreichen? *
(max. 100 Wörter)

Coagulate ist für alle, die sich privatsphärenbewusst mit ihren Freund\*innen und Bekannten organisieren und in Kontakt bleiben möchten.
Bevor Netzwerkeffekte ermöglichen, in größerem Rahmen Nutzende anzusprechen, liegt der Fokus auf besonders privatsphäreorientierten Menschen als Early Adopters.
Entsprechend habe ich mit Technologie Enthusiast\*innen aus dem Chaos Computer Club Umfeld, sowie Teilnehmenden der Software Craft and Testing Unconference als Testuser begonnen.
Außerdem evaluiere ich das Potenzial für nicht-normativ lebende Menschen, bspw. aus der Queeren Community, mit Coagulate in vertrauten Kreisen Zusammenkünfte zu organisieren und Kontakte zu pflegen, ohne Angst vor Verfolgung und Zensur.
Direkte Feedback-Kontakte sind dabei mein Fokus.

### Skizziere kurz die wichtigsten Meilensteine, die im Förderzeitraum umgesetzt werden sollen. *
(max. 100 Wörter)

Ende Juli: Kontakte einander anhand eines eingeschränkten Profils vorstellen für verbessertes Onboarding (140h)  
Ende August: Start einer geschlossenen iOS und Android Beta für kontinuierliches Feedback (50h)  
Ende Oktober: Konsistente Veranstaltungen bei zukünftigen Aufenthaltsorten ermöglichen, um Duplikate im eigenen Netzwerk zu vermeiden und gemeinsame Teilnahme zu zeigen (140h)  
Ende November: Zeit-Slider auf der Karte zur Visualisierung zukünftiger Aufenthaltsorte anderer; sowie Release in App/Play Store und auf F-droid (90h)

## 3. Team & Erfahrung

### An welchen Software-Projekten hast du / habt ihr bisher gearbeitet? Bei Open-Source-Projekten bitte einen Link zum Repository angeben.
Hinweis: Max. 3 Projektbeispiele angeben (mit Namen und/oder Link zum Repository)
(optional | max. 100 Wörter)

FreeYourScience, co-maintainer, https://github.com/freeyourscience
Unterstützung für Autor*innen bei der Open Access Zweitpublikation

blackboxopt, co-maintainer, https://github.com/boschresearch/blackboxopt
Bayesian Optimization Methoden mit einer einheitlichen Schnittstelle in Python

Darüber hinaus habe ich an diversen nicht-öffentlichen SaaS und App Projekten im Rahmen meines aktuellen Angestelltenverhältnisses und meiner vorherigen Selbständigkeit gearbeitet.


### Wie viele Stunden willst du (bzw. will das Team) in den 6 Monaten Förderzeitraum insgesamt an der Umsetzung arbeiten? *
Hinweis: Bitte nur eine Zahl eintragen - max. 950 h für eine Person

420


### Erfahrung, Hintergrund, Motivation, Perspektive: Was sollen wir über dich (bzw. euch) wissen und bei der Auswahl berücksichtigen?
(optional | 100 Wörter)

Mir ist es eine Herzensangelegenheit mit privatsphärefreundlicher Technologie die digitale Souveränität meiner Mitmenschen zu stärken.
Die Idee für Coagulate begleitet mich schon Jahre, weshalb mich besonders begeistert, dass mit Veilid endlich die technischen Voraussetzungen bestehen, um meine Vision ohne Kompromisse umzusetzen.
Meine Freund\*innen und Bekannten sind geografisch verteilt und selbst mit lieben Menschen vor Ort sind Zusammenkünfte oft herausfordernd zu koordinieren.
Coagulate hilft mir persönlich, zu überblicken wer zur Zeit wo anzutreffen und wie kontaktierbar ist.
Um die User Experience, besonders bei dieser Peer-to-Peer Anwendung, im Blick zu behalten, profitiere ich von meinem akademischen Hintergrund in Psychologie und Informatik.
