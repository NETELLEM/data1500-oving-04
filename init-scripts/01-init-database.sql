-- ============================================================================
-- DATA1500 - Oppgavesett 1.4: Databasemodellering og implementasjon
-- Initialiserings-skript for PostgreSQL
-- ============================================================================

-- Opprett grunnleggende tabeller

-- Vi sletter tabellene først hvis de finnes, for å kunne kjøre scriptet flere ganger (idempotens)
-- CASCADE sørger for at tabeller som er avhengige av disse også blir slettet.
DROP TABLE IF EXISTS Innlegg CASCADE;
DROP TABLE IF EXISTS Beskjeder CASCADE;
DROP TABLE IF EXISTS KlasseromTilgang CASCADE;
DROP TABLE IF EXISTS GruppeMedlemmer CASCADE;
DROP TABLE IF EXISTS Klasserom CASCADE;
DROP TABLE IF EXISTS Grupper CASCADE;
DROP TABLE IF EXISTS Brukere CASCADE;

-- 1. Brukere
CREATE TABLE Brukere (
    bruker_id SERIAL PRIMARY KEY,
    brukernavn VARCHAR(50) UNIQUE NOT NULL,
    passord VARCHAR(100) NOT NULL,
    fullt_navn VARCHAR(100),
    rolle VARCHAR(20) CHECK (rolle IN ('student', 'lærer'))
);

-- 2. Grupper
CREATE TABLE Grupper (
    gruppe_id SERIAL PRIMARY KEY,
    gruppenavn VARCHAR(100) NOT NULL
);

-- 3. Klasserom
CREATE TABLE Klasserom (
    klasserom_id SERIAL PRIMARY KEY,
    kode VARCHAR(20) UNIQUE NOT NULL,
    navn VARCHAR(100) NOT NULL,
    ansvarlig_laerer_id INT REFERENCES Brukere(bruker_id)
);

-- 4. GruppeMedlemmer (Koblingstabell)
CREATE TABLE GruppeMedlemmer (
    gruppe_id INT REFERENCES Grupper(gruppe_id),
    bruker_id INT REFERENCES Brukere(bruker_id),
    PRIMARY KEY (gruppe_id, bruker_id)
);

-- 5. KlasseromTilgang (Koblingstabell)
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
    svar_til_id INT REFERENCES Innlegg(innlegg_id), -- Rekursiv FK (svarer på et annet innlegg)
    dato TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    overskrift VARCHAR(150),
    innhold TEXT
);


-- Sett inn testdata

-- Brukere
INSERT INTO Brukere (brukernavn, passord, fullt_navn, rolle) VALUES
('ola_normann', 'pass123', 'Ola Normann', 'student'),
('kari_li', 'hemmelig', 'Kari Li', 'student'),
('per_lærer', 'admin', 'Per Hansen', 'lærer'),
('anne_lærer', 'admin', 'Anne Berg', 'lærer');

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

-- Innlegg
-- Tråd 1
INSERT INTO Innlegg (klasserom_id, avsender_id, svar_til_id, overskrift, innhold) VALUES
(1, 1, NULL, 'Spørsmål om ER-diagram', 'Hvordan tegner man kardinalitet?'); -- ID 1

-- Svar på tråd 1
INSERT INTO Innlegg (klasserom_id, avsender_id, svar_til_id, overskrift, innhold) VALUES
(1, 3, 1, 'Re: Spørsmål om ER-diagram', 'Se på mermaid dokumentasjonen jeg la ut.'); -- ID 2

-- Svar på svaret
INSERT INTO Innlegg (klasserom_id, avsender_id, svar_til_id, overskrift, innhold) VALUES
(1, 2, 2, 'Takk!', 'Det hjalp meg også.'); -- ID 3


-- Eventuelt: Opprett indekser for ytelse

-- Indeks på klasserom_id i Beskjeder vil gjøre det raskere å hente alle beskjeder for et rom
CREATE INDEX idx_beskjeder_klasserom ON Beskjeder(klasserom_id);

-- Indeks på klasserom_id i Innlegg
CREATE INDEX idx_innlegg_klasserom ON Innlegg(klasserom_id);

-- Indeks på svar_til_id gjør det raskere å finne hele diskusjonstråder (rekursiv spørring)
CREATE INDEX idx_innlegg_svar_til ON Innlegg(svar_til_id);


-- Vis at initialisering er fullført
SELECT 'Database initialisert!' as status;
