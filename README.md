# NetMonDB - System Monitorowania Jakości Łączy Internetowych

Projekt zaliczeniowy z przedmiotu Bazy Danych. System relacyjnej bazy danych zaprojektowany do gromadzenia metryk sieciowych, zarządzania umowami klientów, automatycznego wykrywania awarii oraz raportowania SLA.

Autorzy: Rozalia Mitkowska, Joanna Żupnik

---
## Jak uruchomić projekt?

1.  Pobierz repozytorium:
    ```bash
    git clone [https://github.com/azupnik/NetMonDB-Project.git](https://github.com/azupnik/NetMonDB-Project.git)
    ```
2.  Zaloguj się do **phpMyAdmin**.
3.  Stwórz nową bazę danych (lub wybierz istniejącą).
4.  Zaimportuj plik `database_full.sql` z folderu `/sql`.
5.  Gotowe! Tabele, widoki i triggery są aktywne.

---

## Struktura Bazy Danych (ERD)

Baza danych składa się z **11 powiązanych tabel** spełniających wymogi 3NF (Trzeciej Postaci Normalnej).

![Diagram ERD](assets/Schemat_ERD.png)

### Lista Tabel w Bazie Danych

| Lp. | Nazwa Tabeli | Opis przechowywanych danych |
|:---:|:---|:---|
| 1 | **`Providers`** | Lista dostawców usług internetowych (ISP), np. Orange, UPC. Zawiera dane kontaktowe. |
| 2 | **`Plans`** | Cennik i specyfikacja ofert (prędkość, cena, gwarancja SLA). Powiązana z dostawcą. |
| 3 | **`Users`** | Dane logowania, role (admin/klient) oraz dane kontaktowe użytkowników systemu. |
| 4 | **`Contracts`** | Aktywne i archiwalne umowy łączące konkretnego Użytkownika z wybranym Planem. |
| 5 | **`Devices`** | Sprzęt monitorujący (routery/sondy) zainstalowany u klienta. Powiązany z kontem usera. |
| 6 | **`Metrics`** | **Największa tabela.** Przechowuje wyniki pomiarów (ping, prędkość) wysyłane przez urządzenia. |
| 7 | **`Incidents`** | Rejestr awarii – zarówno zgłaszanych ręcznie, jak i wykrytych automatycznie przez trigger. |
| 8 | **`Technicians`** | Lista pracowników technicznych dostępnych do usuwania awarii. |
| 9 | **`IncidentAssignments`** | Tabela realizująca relację *Wiele-do-Wielu*: przypisuje techników do konkretnych awarii. |
| 10 | **`Invoices`** | Generowane faktury dla umów, kwoty do zapłaty, terminy i statusy płatności. |
| 11 | **`AuditLogs`** | Logi bezpieczeństwa. Rejestruje kto, kiedy i co zmienił w kluczowych tabelach. |

---

## Kluczowe Funkcjonalności (Logika Biznesowa)

Projekt wykorzystuje zaawansowane mechanizmy silnika MySQL do automatyzacji procesów.

### 1. Automatyczne wykrywanie awarii (Triggers)
System monitoruje napływające dane w czasie rzeczywistym.
- **Trigger:** `Auto_Detect_Incident`
- **Działanie:** Jeśli `ping_ms > 1000` lub utrata pakietów przekracza normę, system **automatycznie tworzy rekord w tabeli `Incidents`** ze statusem `CRITICAL` i opisem `AUTO-ALERT`.

### 2. Audyt bezpieczeństwa
Każda kluczowa zmiana jest rejestrowana.
- **Trigger:** `Audit_Contract_Update`
- **Działanie:** Zmiana statusu umowy lub danych klienta jest zapisywana w tabeli `AuditLogs` wraz z datą, loginem użytkownika i szczegółami zmiany.

### 3. Raportowanie (Views)
Przygotowano widoki dla analityków biznesowych:
- **`View_Provider_Stats`** – Ranking dostawców (średni ping, liczba awarii, ilość klientów).
- **`View_Overdue_Payments`** – Lista dłużników dla działu księgowości.

### 4. Zarządzanie Transakcyjne
Ze względu na ograniczenia uprawnień na serwerze uczelnianym (brak dostępu do `CREATE PROCEDURE`), logika masowych zmian (np. waloryzacja cen o inflację) została zaimplementowana za pomocą **skryptów transakcyjnych** (`START TRANSACTION ... COMMIT`), gwarantujących spójność danych.

---

## Technologie

* **Silnik Bazy:** MySQL / MariaDB
* **Klient:** phpMyAdmin / DBeaver
* **Język:** SQL (DDL, DML, DQL)
* **Narzędzia:** Lucidchart (ERD), GitHub (Wersjonowanie)

---

## 📊 Przykładowe zapytania (Screenshots)

### Wykrycie awarii przez automat:
```sql
SELECT * FROM Incidents WHERE description LIKE '%AUTO-ALERT%';
