# Oppgavesett 1.4: Databasemodell og implementasjon for Nettbasert Undervisning

I dette oppgavesettet skal du designe en database for et nettbasert undervisningssystem. Les casen nøye og løs de fire deloppgavene som følger.

Denne oppgaven er en øving og det forventes ikke at du kan alt som det er spurt etter her. Vi skal gå gjennom mange av disse tingene detaljert i de nærmeste ukene. En lignende oppbygging av oppgavesettet, er det ikke helt utelukket at, skal bli brukt i eksamensoppgaven.

Du bruker denne filen for å besvare deloppgavene. Du må eventuelt selv finne ut hvordan du kan legge inn bilder (images) i en Markdown-fil som denne. Da kan du ta et bilde av dine ER-diagrammer, legge bildefilen inn på en lokasjon i repository og henvise til filen med syntaksen i Markdown. 

Det er anbefalt å tegne ER-diagrammer med [mermaid.live](https://mermaid.live/) og legge koden inn i Markdown (denne filen) på følgende måte:
```
```mermaid
erDiagram
    studenter 
    ...
``` 
Det finnes bra dokumentasjon [EntityRelationshipDiagram](https://mermaid.js.org/syntax/entityRelationshipDiagram.html) for hvordan tegne ER-diagrammer med mermaid-kode. 

## Case: Databasesystem for Nettbasert Undervisning

Det skal lages et databasesystem for nettbasert undervisning. Brukere av systemet er studenter og lærere, som alle logger på med brukernavn og passord. Det skal være mulig å opprette virtuelle klasserom. Hvert klasserom har en kode, et navn og en lærer som er ansvarlig.

Brukere kan deles inn i grupper. En gruppe kan gis adgang ("nøkkel") til ett eller flere klasserom.

I et klasserom kan studentene lese beskjeder fra læreren. Hvert klasserom har også et diskusjonsforum, der både lærere og studenter kan skrive innlegg. Til et innlegg kan det komme flere svarinnlegg, som det igjen kan komme svar på (en hierarkisk trådstruktur). Både beskjeder og innlegg har en avsender, en dato, en overskrift og et innhold (tekst).

## Del 1: Konseptuell Datamodell

**Oppgave:** Beskriv en konseptuell datamodell (med tekst eller ER-diagram) for systemet. Modellen skal kun inneholde entiteter, som du har valgt, og forholdene mellom dem, med kardinalitet. Du trenger ikke spesifisere attributter i denne delen.

**Ditt svar:***
For den konseptuelle modellen fokuserer vi på hva vi lagrer og hvordan ting henger sammen, uten å tenke på datatyper eller fremmednøkler ennå.

Entiteter:

    Bruker: Kan være student eller lærer. Har innloggingsinfo.

    Klasserom: Det virtuelle rommet med en ansvarlig lærer.

    Gruppe: En samling brukere.

    Beskjed: Informasjon fra lærer i et klasserom.

    Innlegg (Forum): Diskusjonsinnlegg som kan være start på en tråd eller et svar (hierarkisk).

Relasjoner (Forhold):

    En Bruker kan være medlem av mange Grupper. En Gruppe har mange Brukere (Mange-til-Mange).

    En Gruppe kan ha tilgang til mange Klasserom. Et Klasserom kan ha mange Grupper (Mange-til-Mange).
    
    En Lærer (Bruker) er ansvarlig for et Klasserom (En-til-Mange).
    
    Et Klasserom har mange Beskjeder.
    
    Et Klasserom har mange Innlegg.
    
    Et Innlegg kan være et svar på et annet Innlegg (En-til-Mange, rekursivt).
```
erDiagram
    Bruker }|--|{ Gruppe : "er medlem av"
    Gruppe }|--|{ Klasserom : "har tilgang til"
    Bruker ||--o{ Klasserom : "er ansvarlig for (lærer)"
    Klasserom ||--o{ Beskjed : "inneholder"
    Klasserom ||--o{ Innlegg : "har diskusjon"
    Bruker ||--o{ Beskjed : "skriver"
    Bruker ||--o{ Innlegg : "skriver"
    Innlegg ||--o{ Innlegg : "svarer på"
``` 

## Del 2: Logisk Skjema (Tabellstruktur)

**Oppgave:** Oversett den konseptuelle modellen til en logisk tabellstruktur. Spesifiser tabellnavn, attributter (kolonner), datatyper, primærnøkler (PK) og fremmednøkler (FK). Tegn et utvidet ER-diagram med [mermaid.live](https://mermaid.live/) eller eventuelt på papir.


**Ditt svar:***
er oversetter vi modellen til tabeller. Jeg velger å samle studenter og lærere i én Brukere-tabell med en rolle-kolonne, da de deler innloggingsmekanikk.

Tabellstruktur:

- Brukere: bruker_id (PK), brukernavn, passord, fullt_navn, rolle (student/lærer).

- Grupper: gruppe_id (PK), gruppenavn.

- Klasserom: klasserom_id (PK), kode, navn, ansvarlig_laerer_id (FK mot Brukere).

- GruppeMedlemmer (Koblingstabell): gruppe_id (FK), bruker_id (FK).

- KlasseromTilgang (Koblingstabell): gruppe_id (FK), klasserom_id (FK).

- Beskjeder: beskjed_id (PK), klasserom_id (FK), avsender_id (FK), dato, overskrift, innhold.

- Innlegg: innlegg_id (PK), klasserom_id (FK), avsender_id (FK), svar_til_id (FK mot Innlegg, nullable), dato, overskrift, innhold.

``` 
erDiagram
    Brukere {
        int bruker_id PK
        string brukernavn
        string passord
        string fullt_navn
        string rolle
    }
    Grupper {
        int gruppe_id PK
        string gruppenavn
    }
    Klasserom {
        int klasserom_id PK
        string kode
        string navn
        int ansvarlig_laerer_id FK
    }
    GruppeMedlemmer {
        int gruppe_id PK, FK
        int bruker_id PK, FK
    }
    KlasseromTilgang {
        int gruppe_id PK, FK
        int klasserom_id PK, FK
    }
    Beskjeder {
        int beskjed_id PK
        int klasserom_id FK
        int avsender_id FK
        datetime dato
        string overskrift
        text innhold
    }
    Innlegg {
        int innlegg_id PK
        int klasserom_id FK
        int avsender_id FK
        int svar_til_id FK "nullable"
        datetime dato
        string overskrift
        text innhold
    }

    Brukere ||--o{ GruppeMedlemmer : ""
    Grupper ||--o{ GruppeMedlemmer : ""
    Grupper ||--o{ KlasseromTilgang : ""
    Klasserom ||--o{ KlasseromTilgang : ""
    Brukere ||--o{ Klasserom : "ansvarlig"
    Klasserom ||--o{ Beskjed : "inneholder"
    Brukere ||--o{ Beskjed : "skriver"
    Klasserom ||--o{ Innlegg : "har"
    Brukere ||--o{ Innlegg : "skriver"
    Innlegg ||--o{ Innlegg : "svarer på"
``` 

## Del 3: Datadefinisjon (DDL) og Mock-Data

**Oppgave:** Skriv SQL-setninger for å opprette tabellstrukturen (DDL - Data Definition Language) og sett inn realistiske mock-data for å simulere bruk av systemet.


**Ditt svar:***
```sql
-- Slett tabeller hvis de eksisterer (for ren reset)
DROP TABLE IF EXISTS Innlegg;
DROP TABLE IF EXISTS Beskjeder;
DROP TABLE IF EXISTS KlasseromTilgang;
DROP TABLE IF EXISTS GruppeMedlemmer;
DROP TABLE IF EXISTS Klasserom;
DROP TABLE IF EXISTS Grupper;
DROP TABLE IF EXISTS Brukere;

-- 1. Opprett Brukere
CREATE TABLE Brukere (
    bruker_id SERIAL PRIMARY KEY,
    brukernavn VARCHAR(50) UNIQUE NOT NULL,
    passord VARCHAR(100) NOT NULL, -- I produksjon: Hashed passord!
    fullt_navn VARCHAR(100),
    rolle VARCHAR(20) CHECK (rolle IN ('student', 'lærer'))
);

-- 2. Opprett Grupper
CREATE TABLE Grupper (
    gruppe_id SERIAL PRIMARY KEY,
    gruppenavn VARCHAR(100) NOT NULL
);

-- 3. Opprett Klasserom
CREATE TABLE Klasserom (
    klasserom_id SERIAL PRIMARY KEY,
    kode VARCHAR(20) UNIQUE NOT NULL,
    navn VARCHAR(100) NOT NULL,
    ansvarlig_laerer_id INT REFERENCES Brukere(bruker_id)
);

-- 4. Koblingstabell: GruppeMedlemmer
CREATE TABLE GruppeMedlemmer (
    gruppe_id INT REFERENCES Grupper(gruppe_id),
    bruker_id INT REFERENCES Brukere(bruker_id),
    PRIMARY KEY (gruppe_id, bruker_id)
);

-- 5. Koblingstabell: KlasseromTilgang
CREATE TABLE KlasseromTilgang (
    gruppe_id INT REFERENCES Grupper(gruppe_id),
    klasserom_id INT REFERENCES Klasserom(klasserom_id),
    PRIMARY KEY (gruppe_id, klasserom_id)
);

-- 6. Beskjeder
CREATE TABLE Beskjeder (
    beskjed_id SERIAL PRIMARY KEY,
    klasserom_id INT REFERENCES Klasserom(klasserom_id),
    avsender_id INT REFERENCES Brukere(bruker_id),
    dato TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    overskrift VARCHAR(150),
    innhold TEXT
);

-- 7. Innlegg (Diskusjonsforum)
CREATE TABLE Innlegg (
    innlegg_id SERIAL PRIMARY KEY,
    klasserom_id INT REFERENCES Klasserom(klasserom_id),
    avsender_id INT REFERENCES Brukere(bruker_id),
    svar_til_id INT REFERENCES Innlegg(innlegg_id), -- Rekursiv FK
    dato TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    overskrift VARCHAR(150),
    innhold TEXT
);

-- MOCK DATA --

-- Brukere
INSERT INTO Brukere (brukernavn, passord, fullt_navn, rolle) VALUES
('ola_normann', 'pass123', 'Ola Normann', 'student'), -- ID 1
('kari_li', 'hemmelig', 'Kari Li', 'student'),        -- ID 2
('per_lærer', 'admin', 'Per Hansen', 'lærer'),        -- ID 3
('anne_lærer', 'admin', 'Anne Berg', 'lærer');        -- ID 4

-- Grupper
INSERT INTO Grupper (gruppenavn) VALUES
('Dataingeniør 1. år'),
('Webutvikling Gruppe A');

-- Medlemmer i grupper
INSERT INTO GruppeMedlemmer (gruppe_id, bruker_id) VALUES
(1, 1), (1, 2), -- Ola og Kari i Dataingeniør
(2, 1);         -- Ola i Webutvikling

-- Klasserom
INSERT INTO Klasserom (kode, navn, ansvarlig_laerer_id) VALUES
('DATA1500', 'Databaser', 3),
('WEB1100', 'Grunnleggende Web', 4);

-- Gi grupper tilgang til klasserom
INSERT INTO KlasseromTilgang (gruppe_id, klasserom_id) VALUES
(1, 1), -- Dataingeniør 1. år får tilgang til Databaser
(2, 2); -- Webutvikling får tilgang til Web

-- Beskjeder
INSERT INTO Beskjeder (klasserom_id, avsender_id, dato, overskrift, innhold) VALUES
(1, 3, '2023-08-20 10:00:00', 'Velkommen!', 'Velkommen til databasekurset.'),
(1, 3, '2023-08-25 12:00:00', 'Husk innlevering', 'Fristen er på fredag.'),
(1, 3, '2023-08-26 09:00:00', 'Forelesning avlyst', 'Jeg er syk i dag.'),
(1, 3, '2023-08-27 14:00:00', 'Ny oppgave', 'Oppgavesett 1.4 er ute.');

-- Innlegg (Trådstruktur)
-- Tråd 1: Startet av Ola (ID 1)
INSERT INTO Innlegg (klasserom_id, avsender_id, svar_til_id, overskrift, innhold) VALUES
(1, 1, NULL, 'Spørsmål om ER-diagram', 'Hvordan tegner man kardinalitet?'); -- ID 1

-- Svar fra Per Lærer (ID 3) på Ola sitt innlegg (ID 1)
INSERT INTO Innlegg (klasserom_id, avsender_id, svar_til_id, overskrift, innhold) VALUES
(1, 3, 1, 'Re: Spørsmål om ER-diagram', 'Se på mermaid dokumentasjonen jeg la ut.'); -- ID 2

-- Svar fra Kari (ID 2) på Per sitt svar (ID 2)
INSERT INTO Innlegg (klasserom_id, avsender_id, svar_til_id, overskrift, innhold) VALUES
(1, 2, 2, 'Takk!', 'Det hjalp meg også.'); -- ID 3
```

## Del 4: Spørringer mot Databasen

**Oppgave:** Skriv SQL-spørringer for å hente ut informasjonen beskrevet under. For hver oppgave skal du levere svar med både relasjonsalgebra-notasjon og standard SQL.

### 1. Finn de 3 nyeste beskjeder fra læreren i et gitt klasserom (f.eks. klasserom_id = 1).

*   **Relasjonsalgebra:**
    > Her velger vi ut (Select), sorterer (Sort - ofte markert med $\tau$ tau) og begrenser antallet (Limit). Merk at standard RA ikke har en eksplisitt "LIMIT"-operator, men dette er vanlig i utvidet RA. $$\tau_{dato, DESC}(\sigma_{klasserom\_id=1}(Beskjeder))$$

*   **SQL:**
    ```sql
    SELECT *
    FROM Beskjeder
    WHERE klasserom_id = 1
    ORDER BY dato DESC
    LIMIT 3;
    ```

### 2. Vis en hel diskusjonstråd startet av en spesifikk student (f.eks. avsender_id = 2).

*   **Relasjonsalgebra**
    > Trenger ikke å skrive en relasjonsalgebra setning her, siden det blir for komplekst og uoversiktlig. 

*   **SQL (med `WITH RECURSIVE`):**

    Du kan vente med denne oppgaven til vi har gått gjennom avanserte SQL-spørringer (tips: må bruke en rekursiv konstruksjon `WITH RECURSIVE diskusjonstraad AS (..) SELECT FROM diskusjonstraad ...`)
    ```sql
    WITH RECURSIVE Traad AS (
    -- Anker-del: Finn alle "rot"-innlegg (trådstarter) for studenten
    SELECT innlegg_id, overskrift, innhold, svar_til_id, avsender_id, dato
    FROM Innlegg
    WHERE avsender_id = 2 AND svar_til_id IS NULL

    UNION ALL

    -- Rekursiv del: Finn alle svar på innleggene vi allerede har funnet
    SELECT i.innlegg_id, i.overskrift, i.innhold, i.svar_til_id, i.avsender_id, i.dato
    FROM Innlegg i
    INNER JOIN Traad t ON i.svar_til_id = t.innlegg_id
)
SELECT * FROM Traad;
    ```

### 3. Finn alle studenter i en spesifikk gruppe (f.eks. gruppe_id = 1).

*   **Relasjonsalgebra:**
    > Vi må gjøre en naturlig join ($\bowtie$) mellom Brukere og GruppeMedlemmer, og deretter selektere på gruppeID og rolle. Til slutt projiserer ($\pi$) vi navnene.$$\pi_{navn}(\sigma_{gruppe\_id=1 \land rolle='student'}(Brukere \bowtie GruppeMedlemmer))$$

*   **SQL:**
    ```sql
    SELECT b.fullt_navn, b.brukernavn
    FROM Brukere b
    JOIN GruppeMedlemmer gm ON b.bruker_id = gm.bruker_id
    WHERE gm.gruppe_id = 1 AND b.rolle = 'student';
    ```

### 4. Finn antall grupper.

*   **Relasjonsalgebra (med aggregering):**
    > Vi bruker aggregeringsoperatoren ($\mathcal{G}$ eller $\Im$) for å telle. $$\mathcal{G}_{COUNT(gruppe\_id)}(Grupper)$$

*   **SQL:**
    ```sql
    SELECT COUNT(*) AS antall_grupper
    FROM Grupper;
    ```

## Del 5: Implementer i postgreSQL i din Docker container

**Oppgave:** Gjenbruk `docker-compose.yml` fra Oppgavesett 1.3 (er i denne repositorien allerede, så du trenger ikke å gjøre noen endringer) og prøv å legge inn din skript for opprettelse av databasen for nettbasert undervsining med noen testdata i filen `01-init-database.sql` i mappen `init-scripts`. Du trenger ikke å opprette roller. 

Lagre alle SQL-spørringene dine fra oppgave 4 i en fil `oppgave4_losning.sql` i mappen `test-scripts` for at man kan teste disse med kommando:

```bash
docker-compose exec postgres psql -U admin -d data1500_db -f test-scripts/oppgave4_losning.sql
```
