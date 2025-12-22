# Lernsoftware zur Direkten Steifigkeitsmethode (DSM)

MATLAB-basierte **Lehrsoftware zur Berechnung von Schnittkräften, Auflagerreaktionen und Einflusslinien** mithilfe der **Direkten Steifigkeitsmethode (DSM)** – inklusive **grafischer Benutzeroberfläche (GUI)**.

Die Software richtet sich primär an Studierende der Vorlesung **„Baustatik II"** im 4. Semester des Bachelorstudiums Bauingenieurwissenschaften an der **ETH Zürich**.

---

## Motivation & Zielsetzung

Die Software soll Studierenden ermöglichen,

- **eigene Tragsysteme zu modellieren**,
- deren **Schnittkräfte**, **Auflagerreaktionen** oder **Einflusslinien** zu berechnen,
- und die Resultate direkt mit eigenen Handrechnungen zu vergleichen.

Damit bietet sie zusätzliche Übungsmöglichkeiten neben Hausübungen und Kolloquien und unterstützt ein tieferes Verständnis der DSM sowie von Einflusslinien.

Die Wahl von **MATLAB** als Entwicklungsumgebung wurde bewusst gewählt, da Studierende bereits durch Bonus-Abgaben und Übungen mit MATLAB vertraut sind.

---

## Features

- Direkte Steifigkeitsmethode (DSM)
- Berechnung von:
  - Schnittkräften
  - Auflagerreaktionen
  - Einflusslinien (Lagerreaktionen und Schnittgrössen)
- Unterstützung für:
  - Punktlasten (Knoten und Stab) und Linienlasten
  - Federn
  - Vorgeschriebene Verschiebungen
  - Alle Stabendgelenke (Normalkraft-, Querkraft-, Momentengelenke)
- **Grafische Benutzeroberfläche (GUI)** zur interaktiven Eingabe und Visualisierung
- Robuste Eingabevalidierung mit verständlichen Fehlermeldungen
- Konzeptionelle Implementierung statischer Kondensation

--- 

## GUI & Erweiterbarkeit

Die GUI stellt die **primäre Schnittstelle** zur Software dar und erlaubt es, Tragwerke
schrittweise aufzubauen und Resultate direkt visuell zu überprüfen.

Der zugrunde liegende Code ist **modular** aufgebaut:

- Neue Elemente, Lastfälle oder Auswertungen können einfach ergänzt werden.
- GUI und Rechenkern können unabhängig weiterentwickelt werden.
- Die Software kann als **Grundlage für zukünftige studentische Projektarbeiten** dienen.

Der rechnerische Kern ist zusätzlich durch ein **Unit- und System-Test-Framework** abgesichert, um mechanische Korrektheit und Robustheit bei Erweiterungen zu gewährleisten.

Für Studierende, die sich vertieft mit der Implementierung der DSM auseinandersetzen möchten, stellt die Datei `src/Main/DirectStiffnessMethod.m` den **zentralen Einstiegspunkt** dar. Dort sind die wesentlichen mechanischen Rechenschritte der Direkten Steifigkeitsmethode klar aufgeführt und **strukturell analog zur Behandlung im Kurs „Baustatik II"** organisiert.

---

## GUI & Ergebnisbeispiele

Beispielhafte Resultate aus der Software:

<table>
  <tr>
    <td align="center">
      <img src="docs/figures/einflusslinie.png" width="100%">
      <br>
      <em>Einflusslinie (Beispiel)</em>
    </td>
    <td align="center">
      <img src="docs/figures/system_vorschau.png" width="100%">
      <br>
      <em>Systemvorschau in der GUI</em>
    </td>
  </tr>
</table>

<img src="docs/figures/schnittkraefte.png" width="100%">
<em>Schnittkraftdiagramme (N, V, M)</em>

<br><br>

<img src="docs/figures/GUI_berechnung.png" width="100%">
<em>Eingabe und Visualisierung in der GUI</em>

---

## Installation & Nutzung

### Voraussetzungen

- MATLAB **R2025b** (getestet; frühere Versionen nicht verifiziert)  

### Installation

1. Klicke auf **Code → Download ZIP** und entpacke das Repository *(alternativ: Repository klonen mit Git)*
2. Öffne MATLAB, indem du die Datei `startup.m` per Doppelklick öffnest. Dadurch wird der Projektpfad korrekt gesetzt.
3. Starte die grafische Benutzeroberfläche, indem du im MATLAB Command Window eingibst:
   ```matlab
   GUI

---

## Video-Tutorial

[![Video-Tutorial zur DSM Lernsoftware](docs/figures/video_thumbnail.png)](video link)

## Zitieren dieser Software

## Lizenz

