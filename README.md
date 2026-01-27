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
## Opis Projektu

**NetMonDB** to kompleksowy system relacyjnej bazy danych przeznaczony do monitorowania jakości usług świadczonych przez dostawców Internetu (ISP). Głównym celem systemu jest weryfikacja zgodności parametrów łącza z zawartymi umowami (SLA – Service Level Agreement) oraz automatyzacja obsługi incydentów sieciowych.

System rozwiązuje problem rozproszenia danych, integrując w jednym miejscu informacje o:
* **Klientach i Umowach:** Zarządzanie cyklem życia abonenta, od podpisania umowy po fakturowanie.
* **Metrykach Sieciowych:** Gromadzenie masowych danych telemetrycznych (ping, jitter, utrata pakietów) z urządzeń końcowych.
* **Obsłudze Technicznej:** Zarządzanie personelem terenowym i przydzielanie zadań naprawczych.

## Struktura Bazy Danych (ERD)

Baza danych składa się z **11 powiązanych tabel** spełniających wymogi 3NF.

![Diagram ERD](assets/SchematERD.png)

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
## Szczegółowa Struktura Bazy Danych

Poniżej znajduje się pełna specyfikacja techniczna tabel w systemie.

## 1. Providers
Lista dostawców usług internetowych (ISP) obsługiwanych przez system.

| Field Name | Data Type | Length | Description |
| :--- | :--- | :--- | :--- |
| `provider_id` | INT | - | **PK**. Unikalny identyfikator dostawcy (Auto Increment). |
| `name` | VARCHAR | 100 | Nazwa firmy dostawcy (np. Orange, UPC). Musi być unikalna. |
| `support_phone` | VARCHAR | 20 | Numer telefonu do wsparcia technicznego. |
| `website` | VARCHAR | 100 | Adres strony internetowej dostawcy. |
| `created_at` | TIMESTAMP | - | Data dodania rekordu do bazy (domyślnie `current_timestamp`). |

## 2. Plans
Cennik i parametry techniczne ofert dostępnych u dostawców.

| Field Name | Data Type | Length | Description |
| :--- | :--- | :--- | :--- |
| `plan_id` | INT | - | **PK**. Unikalny identyfikator planu (Auto Increment). |
| `provider_id` | INT | - | **FK**. Klucz obcy powiązany z tabelą `Providers`. |
| `name` | VARCHAR | 100 | Nazwa handlowa planu (np. Światłowód 300). |
| `max_download_mbps` | INT | - | Maksymalna prędkość pobierania (Mb/s). |
| `max_upload_mbps` | INT | - | Maksymalna prędkość wysyłania (Mb/s). |
| `price_pln` | DECIMAL | 10,2 | Cena miesięczna brutto w PLN. |
| `sla_guarantee_percent` | DECIMAL | 5,2 | Gwarantowana dostępność usługi (domyślnie 99.00%). |

## 3. Users
Centralna baza użytkowników systemu (zarówno klientów, jak i administratorów).

| Field Name | Data Type | Length | Description |
| :--- | :--- | :--- | :--- |
| `user_id` | INT | - | **PK**. Unikalny identyfikator użytkownika (Auto Increment). |
| `username` | VARCHAR | 50 | Unikalny login użytkownika. |
| `email` | VARCHAR | 100 | Adres e-mail (musi być unikalny). |
| `password_hash` | VARCHAR | 255 | Bezpieczny hash hasła. |
| `role` | ENUM | - | Rola w systemie: `'admin'`, `'client'`, `'auditor'`. |
| `is_active` | TINYINT | 1 | Status konta (1 = aktywne, 0 = zablokowane). |

## 4. Contracts
Ewidencja umów łączących użytkowników z wybranymi planami.

| Field Name | Data Type | Length | Description |
| :--- | :--- | :--- | :--- |
| `contract_id` | INT | - | **PK**. Unikalny numer umowy (Auto Increment). |
| `user_id` | INT | - | **FK**. Klucz obcy wskazujący na użytkownika. |
| `plan_id` | INT | - | **FK**. Klucz obcy wskazujący na plan taryfowy. |
| `start_date` | DATE | - | Data rozpoczęcia świadczenia usługi. |
| `end_date` | DATE | - | Data zakończenia (NULL oznacza umowę na czas nieokreślony). |
| `address_street` | VARCHAR | 100 | Ulica i numer lokalu instalacji. |
| `address_city` | VARCHAR | 50 | Miasto instalacji. |
| `status` | ENUM | - | Status umowy: `'active'`, `'expired'`, `'terminated'`. |

## 5. Devices
Spis urządzeń (routery, modemy) zainstalowanych u klientów.

| Field Name | Data Type | Length | Description |
| :--- | :--- | :--- | :--- |
| `device_id` | INT | - | **PK**. Unikalny identyfikator urządzenia (Auto Increment). |
| `user_id` | INT | - | **FK**. Klucz obcy do właściciela urządzenia. |
| `mac_address` | VARCHAR | 17 | Unikalny adres fizyczny MAC. |
| `model` | VARCHAR | 50 | Model urządzenia (np. FunBox 6). |
| `location_name` | VARCHAR | 50 | Opis lokalizacji w lokalu (np. 'Salon', 'Biuro'). |
| `installed_at` | TIMESTAMP | - | Data instalacji/aktywacji urządzenia. |

## 6. Metrics
Tabela przechowująca dane telemetryczne z urządzeń (Big Data).

| Field Name | Data Type | Length | Description |
| :--- | :--- | :--- | :--- |
| `metric_id` | BIGINT | - | **PK**. Unikalny numer pomiaru (Auto Increment). |
| `device_id` | INT | - | **FK**. Klucz obcy urządzenia raportującego. |
| `measured_at` | TIMESTAMP | - | Dokładna data i czas pomiaru. |
| `ping_ms` | INT | - | Opóźnienie sieci w milisekundach (Ping). |
| `jitter_ms` | INT | - | Zmienność opóźnienia (Jitter). |
| `packet_loss_percent` | DECIMAL | 5,2 | Procent utraconych pakietów. |
| `download_speed_mbps` | DECIMAL | 10,2 | Zmierzona prędkość pobierania. |
| `upload_speed_mbps` | DECIMAL | 10,2 | Zmierzona prędkość wysyłania. |

## 7. Incidents
Rejestr awarii i incydentów sieciowych.

| Field Name | Data Type | Length | Description |
| :--- | :--- | :--- | :--- |
| `incident_id` | INT | - | **PK**. Unikalny numer zgłoszenia (Auto Increment). |
| `provider_id` | INT | - | **FK**. Klucz obcy dostawcy, którego dotyczy problem. |
| `start_time` | TIMESTAMP | - | Czas rozpoczęcia awarii. |
| `end_time` | TIMESTAMP | - | Czas zakończenia (NULL jeśli awaria trwa). |
| `description` | TEXT | - | Opis techniczny problemu. |
| `severity_level` | ENUM | - | Poziom: `'low'`, `'medium'`, `'critical'`. |
| `status` | ENUM | - | Status: `'open'`, `'in_progress'`, `'resolved'`. |

## 8. Technicians
Baza pracowników technicznych (serwisantów).

| Field Name | Data Type | Length | Description |
| :--- | :--- | :--- | :--- |
| `tech_id` | INT | - | **PK**. Unikalny identyfikator technika (Auto Increment). |
| `full_name` | VARCHAR | 100 | Imię i nazwisko pracownika. |
| `specialization` | VARCHAR | 50 | Specjalizacja (np. 'Światłowody', 'Sieci LAN'). |
| `phone_number` | VARCHAR | 20 | Służbowy numer telefonu. |
| `is_available` | TINYINT | 1 | Czy technik jest dostępny do pracy (1 = Tak). |

## 9. IncidentAssignments
Tabela łącząca techników z awariami (Relacja Wiele-do-Wielu).

| Field Name | Data Type | Length | Description |
| :--- | :--- | :--- | :--- |
| `assignment_id` | INT | - | **PK**. Unikalny identyfikator przypisania. |
| `incident_id` | INT | - | **FK**. Klucz obcy powiązany z tabelą `Incidents`. |
| `tech_id` | INT | - | **FK**. Klucz obcy powiązany z tabelą `Technicians`. |
| `assigned_at` | TIMESTAMP | - | Czas przypisania zadania. |
| `notes` | TEXT | - | Notatki serwisowe z przebiegu naprawy. |

## 10. Invoices
Dokumenty finansowe generowane dla umów.

| Field Name | Data Type | Length | Description |
| :--- | :--- | :--- | :--- |
| `invoice_id` | INT | - | **PK**. Unikalny numer faktury (Auto Increment). |
| `contract_id` | INT | - | **FK**. Klucz obcy umowy, której dotyczy płatność. |
| `issue_date` | DATE | - | Data wystawienia faktury. |
| `amount_pln` | DECIMAL | 10,2 | Kwota do zapłaty (PLN). |
| `payment_status` | ENUM | - | Status: `'paid'`, `'unpaid'`, `'overdue'`. |
| `due_date` | DATE | - | Termin płatności. |

## 11. AuditLogs
Dziennik zmian systemowych rejestrowany przez triggery (bez relacji FK).

| Field Name | Data Type | Length | Description |
| :--- | :--- | :--- | :--- |
| `log_id` | INT | - | **PK**. Unikalny numer wpisu w logu. |
| `table_name` | VARCHAR | 50 | Nazwa tabeli, której dotyczy zmiana. |
| `operation` | VARCHAR | 10 | Rodzaj operacji: `'INSERT'`, `'UPDATE'`, `'DELETE'`. |
| `user_context` | VARCHAR | 50 | Kto dokonał zmiany (użytkownik lub system). |
| `change_date` | TIMESTAMP | - | Dokładny czas zdarzenia. |
| `details` | TEXT | - | Szczegóły zmiany (np. stare i nowe wartości). |

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
## 📊 Widoki (Views)

W projekcie zaimplementowano mechanizm **Widoków (Virtual Tables)**, który tworzy warstwę abstrakcji nad skomplikowanymi zapytaniami SQL. Zastosowanie widoków pozwoliło na ukrycie złożoności złączeń (JOIN) wielu tabel oraz odseparowanie surowych danych od warstwy raportowej.

W systemie zdefiniowano dwa kluczowe widoki analityczne:

### 1. `View_Provider_Stats` (Ranking Jakości Dostawców)
Jest to główny widok analityczny systemu, służący do monitorowania SLA. Agreguje on dane telemetryczne z tysięcy rekordów w tabeli `Metrics` oraz łączy je z rejestrem awarii.

**Struktura Widoku:**
| Nazwa Kolumny | Typ Danych | Opis |
|:---|:---|:---|
| `Provider` | VARCHAR | Nazwa dostawcy internetu (np. Orange). |
| `Active_Contracts` | INT | Liczba aktywnych umów obsługiwanych przez dostawcę. |
| `Avg_Download` | DECIMAL | Średnia prędkość pobierania ze wszystkich pomiarów (Mb/s). |
| `Avg_Ping` | DECIMAL | Średnie opóźnienie sieci (ms). Kluczowe dla gier/VoIP. |
| `Total_Incidents` | INT | Łączna liczba awarii zarejestrowanych dla tego dostawcy. |

**Przykładowy wynik:**
| Provider | Active_Contracts | Avg_Download | Avg_Ping | Total_Incidents |
|:---|:---:|:---:|:---:|:---:|
| **Orange Polska** | 154 | 298.5 | 12.4 | 0 |
| **UPC / Play** | 89 | 550.2 | **45.1** | **3** |
| **Netia S.A.** | 42 | 890.0 | 9.8 | 1 |

---

### 2. `View_Overdue_Payments` (Raport Finansowy)
Widok dedykowany dla procesów księgowych i windykacyjnych. Dynamicznie filtruje bazę danych w poszukiwaniu przeterminowanych płatności. Wykorzystuje funkcję `DATEDIFF` do obliczania zwłoki w czasie rzeczywistym.

**Struktura Widoku:**
| Nazwa Kolumny | Typ Danych | Opis |
|:---|:---|:---|
| `username` | VARCHAR | Login dłużnika. |
| `email` | VARCHAR | Adres email do wysyłki ponaglenia. |
| `invoice_id` | INT | Numer niezapłaconej faktury. |
| `amount_pln` | DECIMAL | Kwota do zapłaty (PLN). |
| `due_date` | DATE | Termin płatności, który minął. |
| `Days_Late` | INT | **Pole wyliczane:** Liczba dni po terminie. |

**Przykładowy wynik:**
| username | email | invoice_id | amount_pln | due_date | Days_Late |
|:---|:---|:---:|:---:|:---|:---:|
| `nowak_anna` | anna.nowak@onet.pl | 15 | 65.00 | 2023-10-19 | **14** |
| `firma_x` | biuro@firma-x.pl | 22 | 120.00 | 2023-10-01 | **32** |

## Scenariusze Testowe (Dowód Działania)

Poniżej przedstawiono dowody na działanie zaimplementowanej logiki biznesowej (Triggerów) w środowisku phpMyAdmin.

### Scenariusz 1: Automatyczne wykrywanie awarii (Active Database)
**Cel:** Weryfikacja, czy system samoczynnie reaguje na krytyczne parametry sieci.

1.  **Akcja:** Symulacja "złego" pomiaru przez wstawienie rekordu z pingiem **2500ms**:
    ```sql
    INSERT INTO Metrics (device_id, ping_ms, ...) VALUES (1, 2500, ...);
    ```
2.  **Wynik:** Trigger `Auto_Detect_Incident` uruchomił się automatycznie. W tabeli `Incidents` pojawił się nowy wiersz ze statusem `CRITICAL` i opisem **"AUTO-ALERT: Krytyczny ping na urządzeniu ID: 1"**.

![Dowód Triggera Awarii](assets/test_incidents.png)

---

### Scenariusz 2: Audyt bezpieczeństwa i zmian
**Cel:** Weryfikacja, czy kluczowe zmiany w danych są rejestrowane (kto, co i kiedy zmienił).

1.  **Akcja:** Ręczna zmiana statusu umowy klienta na wypowiedzianą (`terminated`) oraz wykonanie skryptu podwyżki cen:
    ```sql
    UPDATE Contracts SET status = 'terminated' WHERE contract_id = 1;
    ```
2.  **Wynik:** Tabela `AuditLogs` zarejestrowała obie operacje.
    * Widać wpis o **"Masowej podwyżce cen"**.
    * Widać wpis o zmianie w tabeli `Contracts` (Operacja `UPDATE`, zmiana statusu z `active` na `terminated`).

![Dowód Audytu](assets/test_audit.png)

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
