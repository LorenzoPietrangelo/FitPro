-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Creato il: Mag 14, 2026 alle 16:02
-- Versione del server: 10.4.32-MariaDB
-- Versione PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `fitpro`
--

-- --------------------------------------------------------

--
-- Struttura della tabella `categoria_prodotto`
--

CREATE TABLE `categoria_prodotto` (
  `id_prodotto` int(11) NOT NULL,
  `categoria` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `categoria_prodotto`
--

INSERT INTO `categoria_prodotto` (`id_prodotto`, `categoria`) VALUES
(8, 'days:3'),
(8, 'goal:ipertrofia'),
(8, 'level:base'),
(9, 'days:3'),
(9, 'goal:ipertrofia'),
(9, 'level:intermedio'),
(10, 'days:4'),
(10, 'goal:forza'),
(10, 'level:avanzato'),
(11, 'days:4'),
(11, 'goal:calisthenics'),
(11, 'level:intermedio'),
(12, 'custom');

-- --------------------------------------------------------

--
-- Struttura della tabella `coupon`
--

CREATE TABLE `coupon` (
  `id_coupon` int(11) NOT NULL,
  `nome` varchar(100) NOT NULL,
  `sconto` decimal(5,2) NOT NULL,
  `data_scadenza` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struttura della tabella `groups`
--

CREATE TABLE `groups` (
  `id_group` int(11) NOT NULL,
  `nome` varchar(50) NOT NULL,
  `descrizione` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `groups`
--

INSERT INTO `groups` (`id_group`, `nome`, `descrizione`) VALUES
(1, 'admin', 'Accesso completo alla gestione del sistema'),
(2, 'premium', 'Accesso ai servizi di allenamento personalizzato');

-- --------------------------------------------------------

--
-- Struttura della tabella `ordine`
--

CREATE TABLE `ordine` (
  `id_ordine` int(11) NOT NULL,
  `id_utente` int(11) NOT NULL,
  `data` date NOT NULL,
  `prezzo` decimal(10,2) NOT NULL DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `ordine`
--

INSERT INTO `ordine` (`id_ordine`, `id_utente`, `data`, `prezzo`) VALUES
(1, 2, '2026-05-10', 50.00),
(2, 2, '2026-05-10', 100.00),
(3, 2, '2026-05-10', 100.00),
(4, 2, '2026-05-10', 100.00),
(5, 2, '2026-05-10', 100.00),
(6, 3, '2026-05-11', 150.00),
(7, 4, '2026-05-11', 150.00),
(8, 5, '2026-05-12', 150.00),
(9, 2, '2026-05-13', 100.00),
(10, 2, '2026-05-13', 100.00),
(11, 2, '2026-05-13', 100.00);

-- --------------------------------------------------------

--
-- Struttura della tabella `ordine_prodotto`
--

CREATE TABLE `ordine_prodotto` (
  `id_ordine` int(11) NOT NULL,
  `id_prodotto` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `ordine_prodotto`
--

INSERT INTO `ordine_prodotto` (`id_ordine`, `id_prodotto`) VALUES
(1, 10),
(2, 12),
(3, 12),
(4, 12),
(5, 12),
(6, 10),
(6, 12),
(7, 8),
(7, 12),
(8, 9),
(8, 12),
(9, 12),
(10, 12),
(11, 12);

-- --------------------------------------------------------

--
-- Struttura della tabella `prodotti_acquistati`
--

CREATE TABLE `prodotti_acquistati` (
  `id_utente` int(11) NOT NULL,
  `id_prodotto` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `prodotti_acquistati`
--

INSERT INTO `prodotti_acquistati` (`id_utente`, `id_prodotto`) VALUES
(2, 10),
(2, 12),
(3, 10),
(3, 12),
(4, 8),
(4, 12),
(5, 9),
(5, 12);

-- --------------------------------------------------------

--
-- Struttura della tabella `prodotto`
--

CREATE TABLE `prodotto` (
  `id_prodotto` int(11) NOT NULL,
  `titolo` varchar(190) NOT NULL,
  `prezzo` decimal(10,2) NOT NULL DEFAULT 0.00,
  `descrizione` text NOT NULL,
  `tipo` varchar(50) NOT NULL,
  `immagine_path` varchar(255) DEFAULT NULL,
  `file_path` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `prodotto`
--

INSERT INTO `prodotto` (`id_prodotto`, `titolo`, `prezzo`, `descrizione`, `tipo`, `immagine_path`, `file_path`) VALUES
(8, 'Lufy\"s Protocol', 50.00, 'il programma di allenamento scelto dal futuro re dei pirati', 'scheda', '/prova_smarty/assets/prodotti/foto_schede/b12d6aabd08fb40b74594672d9370356.png', '/prova_smarty/assets/prodotti/schede_standard/cf3af2077253f282fd85ccb55e97a81a.pdf'),
(9, 'Zoro\'s Protocol', 50.00, 'il programma di allenamento scelto da colui che diventera il miglior spadacino al mondo', 'scheda', '/prova_smarty/assets/prodotti/foto_schede/53f80c80b4c11b2e35433f90196da554.png', '/prova_smarty/assets/prodotti/schede_standard/ec65d41a6dc198ec77436d227ec413bd.pdf'),
(10, 'Sanji\'s protocol', 50.00, 'il programma di allenamento di colui che diventera il miglior chef di sempre', 'scheda', '/prova_smarty/assets/prodotti/foto_schede/bdef778eab87f686a3716dfc1dffb408.png', '/prova_smarty/assets/prodotti/schede_standard/6b679e7d18eaf1e2acecc7198457f75d.pdf'),
(11, 'Usop\'s protocol', 50.00, 'il programma di allenamento scelto da colui che diventera il piu grande cecchino di tutti i tempi', 'scheda', '/prova_smarty/assets/prodotti/foto_schede/c0017d9714f4fdefcab2071b4ab4ae45.png', '/prova_smarty/assets/prodotti/schede_standard/25b114ec133105c141d6c766fae9109d.pdf'),
(12, 'Protocolli di allenamento perosnalizati', 100.00, 'sono dei protocolli di allenamento basati sulle tue esigenze', 'custom', '/prova_smarty/assets/prodotti/foto_schede/c3ec781f8272ff31c7f7b995fd1ed50e.png', NULL);

-- --------------------------------------------------------

--
-- Struttura della tabella `recensioni`
--

CREATE TABLE `recensioni` (
  `id_utente` int(11) NOT NULL,
  `id_prodotto` int(11) NOT NULL,
  `valore_recensioni` tinyint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `recensioni`
--

INSERT INTO `recensioni` (`id_utente`, `id_prodotto`, `valore_recensioni`) VALUES
(2, 10, 4),
(5, 9, 4);

-- --------------------------------------------------------

--
-- Struttura della tabella `richieste`
--

CREATE TABLE `richieste` (
  `id_richiesta` int(11) NOT NULL,
  `id_utente` int(11) NOT NULL,
  `id_prodotto` int(11) NOT NULL,
  `stato` varchar(50) NOT NULL DEFAULT 'pending',
  `answers_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`answers_json`)),
  `pdf_path` varchar(255) DEFAULT NULL,
  `titolo_personalizzato` varchar(190) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `richieste`
--

INSERT INTO `richieste` (`id_richiesta`, `id_utente`, `id_prodotto`, `stato`, `answers_json`, `pdf_path`, `titolo_personalizzato`, `created_at`) VALUES
(1, 2, 12, 'completed', '{}', '/prova_smarty/assets/prodotti/schede_personalizate/e48b8a5107f9c963b44546d3ed39fbaa.pdf', 'Scheda test1', '2026-05-10 12:25:17'),
(2, 2, 12, 'completed', '{\"nome\":\"Lorenzo\",\"motivazione\":\"mi vedo secco\",\"eta\":\"30-40\",\"altezza\":\"178\",\"peso\":\"200\",\"esperienza\":\"5<\",\"effort\":\"No\",\"giorni\":\"4 giorni\",\"tempo\":\"120 min\",\"evitare\":\"\",\"avere\":\"\",\"infortuni\":\"\",\"attrezzatura\":[\"cavo alto/basso\"],\"photos\":{\"foto_1\":\"/prova_smarty/uploads/questionnaires/2/foto_1_1778408974.png\",\"foto_2\":\"/prova_smarty/uploads/questionnaires/2/foto_2_1778408974.png\",\"foto_3\":\"/prova_smarty/uploads/questionnaires/2/foto_3_1778408974.png\",\"foto_4\":\"/prova_smarty/uploads/questionnaires/2/foto_4_1778408974.png\",\"foto_5\":\"/prova_smarty/uploads/questionnaires/2/foto_5_1778408974.png\"}}', '/prova_smarty/assets/prodotti/schede_personalizate/db3e82f3d759ae68ed0a46b1ca86df96.pdf', 'Scheda test 2', '2026-05-10 12:25:23'),
(3, 2, 12, 'completed', '{\"nome\":\"Franco\",\"motivazione\":\"89\",\"eta\":\"30-40\",\"altezza\":\"178\",\"peso\":\"200\",\"esperienza\":\"1-2\",\"effort\":\"No\",\"giorni\":\"2 giorni\",\"tempo\":\"60 min\",\"evitare\":\"\",\"avere\":\"\",\"infortuni\":\"\",\"attrezzatura\":[\"cavo alto/basso\",\"cavo regolabile\",\"multipower\",\"lat machine\",\"cable pulley\",\"chest supported tbar row\",\"sbarra alta\",\"peck deck/fly\",\"chest press\",\"incline chest press\",\"side delt machine\",\"panca scot\",\"hack squat\",\"leg press\",\"leg extension\",\"hyperextension 45\",\"leg curl da seduto\",\"leg curl da allungato\",\"adductor machine\",\"Vulken\"],\"photos\":{\"foto_1\":\"/prova_smarty/assets/prodotti/schede_personalizate/foto_schede_perosnalizate/2/foto_1_1778415087_52c94af3.png\",\"foto_2\":\"/prova_smarty/assets/prodotti/schede_personalizate/foto_schede_perosnalizate/2/foto_2_1778415087_fb1f6fe6.png\",\"foto_3\":\"/prova_smarty/assets/prodotti/schede_personalizate/foto_schede_perosnalizate/2/foto_3_1778415087_eb168764.png\",\"foto_4\":\"/prova_smarty/assets/prodotti/schede_personalizate/foto_schede_perosnalizate/2/foto_4_1778415087_316ac96b.png\",\"foto_5\":\"/prova_smarty/assets/prodotti/schede_personalizate/foto_schede_perosnalizate/2/foto_5_1778415087_6d7fad2f.png\"}}', '/prova_smarty/assets/prodotti/schede_personalizate/68e207170ef29d9775d1d194c6dfb12b.pdf', 'Scheda dranco 1', '2026-05-10 14:03:14'),
(4, 2, 12, 'completed', '{\"nome\":\"lorenzo\",\"motivazione\":\"e\",\"eta\":\"30-40\",\"altezza\":\"e\",\"peso\":\"e\",\"esperienza\":\"0\",\"effort\":\"si\",\"giorni\":\"4 giorni\",\"tempo\":\"60 min\",\"evitare\":\"\",\"avere\":\"\",\"infortuni\":\"\",\"attrezzatura\":[\"multipower\"],\"photos\":{\"foto_1\":\"/prova_smarty/assets/prodotti/schede_personalizate/foto_schede_perosnalizate/2/foto_1_1778415145_3a60cca9.png\",\"foto_2\":\"/prova_smarty/assets/prodotti/schede_personalizate/foto_schede_perosnalizate/2/foto_2_1778415145_99237c86.png\",\"foto_3\":\"/prova_smarty/assets/prodotti/schede_personalizate/foto_schede_perosnalizate/2/foto_3_1778415145_fd7c3184.png\",\"foto_4\":\"/prova_smarty/assets/prodotti/schede_personalizate/foto_schede_perosnalizate/2/foto_4_1778415145_72a5d44d.png\",\"foto_5\":\"/prova_smarty/assets/prodotti/schede_personalizate/foto_schede_perosnalizate/2/foto_5_1778415145_9f650019.png\"}}', '/prova_smarty/assets/prodotti/schede_personalizate/a6ed091d9ef4636a11102b1b9c0da3f2.pdf', 'Scheda test 2', '2026-05-10 14:03:29'),
(5, 3, 12, 'pending', '{\"nome\":\"Franco\",\"motivazione\":\"so secco\",\"eta\":\"30-40\",\"altezza\":\"178\",\"peso\":\"200\",\"esperienza\":\"3-5\",\"effort\":\"si\",\"giorni\":\"4 giorni\",\"tempo\":\"120 min\",\"evitare\":\"\",\"avere\":\"\",\"infortuni\":\"\",\"attrezzatura\":[\"cavo alto/basso\",\"multipower\",\"cable pulley\",\"sbarra alta\"],\"photos\":{\"foto_1\":\"/prova_smarty/assets/prodotti/schede_personalizate/foto_schede_perosnalizate/3/foto_1_1778497378_6966a5a4.png\",\"foto_2\":\"/prova_smarty/assets/prodotti/schede_personalizate/foto_schede_perosnalizate/3/foto_2_1778497378_341ffd1c.png\",\"foto_3\":\"/prova_smarty/assets/prodotti/schede_personalizate/foto_schede_perosnalizate/3/foto_3_1778497378_1e1eb5bc.png\",\"foto_4\":\"/prova_smarty/assets/prodotti/schede_personalizate/foto_schede_perosnalizate/3/foto_4_1778497378_16f0d5ec.png\",\"foto_5\":\"/prova_smarty/assets/prodotti/schede_personalizate/foto_schede_perosnalizate/3/foto_5_1778497378_286446f5.png\"}}', NULL, NULL, '2026-05-11 13:02:02'),
(6, 4, 12, 'pending', '{}', NULL, NULL, '2026-05-11 15:01:24'),
(7, 5, 12, 'pending', '{}', NULL, NULL, '2026-05-12 16:16:50'),
(8, 2, 12, 'pending', '{\"nome\":\"e\",\"motivazione\":\"e\",\"eta\":\"18-30\",\"altezza\":\"e\",\"peso\":\"e\",\"esperienza\":\"1-2\",\"effort\":\"No\",\"giorni\":\"2 giorni\",\"tempo\":\"60 min\",\"evitare\":\"e\",\"avere\":\"e322e\",\"infortuni\":\"e32e\",\"attrezzatura\":[\"cavo alto/basso\",\"cavo regolabile\",\"multipower\",\"lat machine\",\"cable pulley\",\"chest supported tbar row\",\"sbarra alta\",\"peck deck/fly\",\"chest press\",\"incline chest press\",\"side delt machine\",\"panca scot\",\"hack squat\",\"leg press\",\"leg extension\",\"hyperextension 45\",\"leg curl da seduto\",\"leg curl da allungato\",\"adductor machine\",\"Vulken\"],\"photos\":{\"foto_1\":\"/prova_smarty/assets/prodotti/schede_personalizate/foto_schede_perosnalizate/2/foto_1_1778674399_48f1362c.png\",\"foto_2\":\"/prova_smarty/assets/prodotti/schede_personalizate/foto_schede_perosnalizate/2/foto_2_1778674399_ec0fd56d.png\",\"foto_3\":\"/prova_smarty/assets/prodotti/schede_personalizate/foto_schede_perosnalizate/2/foto_3_1778674399_0f3206c4.png\",\"foto_4\":\"/prova_smarty/assets/prodotti/schede_personalizate/foto_schede_perosnalizate/2/foto_4_1778674399_afb8e70f.png\",\"foto_5\":\"/prova_smarty/assets/prodotti/schede_personalizate/foto_schede_perosnalizate/2/foto_5_1778674399_3ea9e4dd.png\"}}', NULL, NULL, '2026-05-13 14:12:26'),
(9, 2, 12, 'pending', '{\"nome\":\"lorenzo\",\"motivazione\":\"cuao\",\"eta\":\"40<\",\"altezza\":\"e\",\"peso\":\"e\",\"esperienza\":\"1-2\",\"effort\":\"No\",\"giorni\":\"4 giorni\",\"tempo\":\"120 min\",\"evitare\":\"eew2q\",\"avere\":\"ewqe\",\"infortuni\":\"eqewq\",\"attrezzatura\":[\"cavo alto/basso\",\"cavo regolabile\",\"multipower\",\"lat machine\",\"cable pulley\",\"chest supported tbar row\",\"sbarra alta\",\"peck deck/fly\",\"chest press\",\"incline chest press\",\"side delt machine\",\"panca scot\",\"hack squat\",\"leg press\",\"leg extension\",\"hyperextension 45\",\"leg curl da seduto\",\"leg curl da allungato\",\"adductor machine\",\"Vulken\"],\"photos\":{\"foto_1\":\"/prova_smarty/assets/questionari/2/foto_1_1778675185_522b3e21.png\",\"foto_2\":\"/prova_smarty/assets/questionari/2/foto_2_1778675185_019311b0.png\",\"foto_3\":\"/prova_smarty/assets/questionari/2/foto_3_1778675185_965627bc.png\",\"foto_4\":\"/prova_smarty/assets/questionari/2/foto_4_1778675185_acfe7add.png\",\"foto_5\":\"/prova_smarty/assets/questionari/2/foto_5_1778675185_25580556.png\"}}', NULL, NULL, '2026-05-13 14:24:25'),
(10, 2, 12, 'pending', '{\"nome\":\"e\",\"motivazione\":\"e\",\"eta\":\"18-30\",\"altezza\":\"e\",\"peso\":\"e\",\"esperienza\":\"3-5\",\"effort\":\"abbastanza\",\"giorni\":\"3 giorni\",\"tempo\":\"90 min\",\"evitare\":\"r\",\"avere\":\"ee\",\"infortuni\":\"e\",\"attrezzatura\":[\"side delt machine\"],\"photos\":{\"foto_1\":\"/prova_smarty/assets/questionari/2/foto_1_1778675990_274df567.png\",\"foto_2\":\"/prova_smarty/assets/questionari/2/foto_2_1778675990_eaf9be5e.png\",\"foto_3\":\"/prova_smarty/assets/questionari/2/foto_3_1778675990_f34f7856.png\",\"foto_4\":\"/prova_smarty/assets/questionari/2/foto_4_1778675990_90776078.png\",\"foto_5\":\"/prova_smarty/assets/questionari/2/foto_5_1778675990_fc60faf5.png\"}}', NULL, NULL, '2026-05-13 14:38:15');

-- --------------------------------------------------------

--
-- Struttura della tabella `services`
--

CREATE TABLE `services` (
  `username` varchar(50) NOT NULL,
  `descrizione` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `services`
--

INSERT INTO `services` (`username`, `descrizione`) VALUES
('custom', 'Protocolli di allenamento personalizzati su misura');

-- --------------------------------------------------------

--
-- Struttura della tabella `services_has_groups`
--

CREATE TABLE `services_has_groups` (
  `username` varchar(50) NOT NULL,
  `id_group` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `services_has_groups`
--

INSERT INTO `services_has_groups` (`username`, `id_group`) VALUES
('custom', 2);

-- --------------------------------------------------------

--
-- Struttura della tabella `testimonianze`
--

CREATE TABLE `testimonianze` (
  `id_testimonianza` int(11) NOT NULL,
  `foto` varchar(255) NOT NULL,
  `descrizione` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `testimonianze`
--

INSERT INTO `testimonianze` (`id_testimonianza`, `foto`, `descrizione`) VALUES
(1, '/prova_smarty/assets/foto_testimonianze/086df3cdf4d5ffe0e74a5e0f1aa7dbe9.png', '{\"name\":\"Luffy\",\"result\":\"+5 kg di massa\",\"quote\":\"Non mi sono mai sentito meglio\"}'),
(2, '/prova_smarty/assets/foto_testimonianze/d1179704bd8f21c821b0c9599d42cd19.png', '{\"name\":\"Zoro\",\"result\":\"+10kg di massa muscolare\",\"quote\":\"uno dei migliori programmi di allenamento mai provati prima d\'ora\"}'),
(3, '/prova_smarty/assets/foto_testimonianze/e505d6172526c2902ea79ee88a14a192.png', '{\"name\":\"Usop\",\"result\":\"-2 kg di grasso di 1 mese\",\"quote\":\"non mi vedevo cosi bene da tempo\"}'),
(4, '/prova_smarty/assets/foto_testimonianze/778728f79cccfa237dbda725bfc2e1bd.png', '{\"name\":\"Sanji\",\"result\":\"+5 kg di massa\",\"quote\":\"la scheda e\' veramente incredibile, in particolare il leg day\"}');

-- --------------------------------------------------------

--
-- Struttura della tabella `users_has_groups`
--

CREATE TABLE `users_has_groups` (
  `id_utente` int(11) NOT NULL,
  `id_group` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `users_has_groups`
--

INSERT INTO `users_has_groups` (`id_utente`, `id_group`) VALUES
(1, 1),
(2, 2),
(3, 2),
(4, 2),
(5, 2);

-- --------------------------------------------------------

--
-- Struttura della tabella `utenti`
--

CREATE TABLE `utenti` (
  `id_utente` int(11) NOT NULL,
  `email` varchar(190) NOT NULL,
  `password` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dump dei dati per la tabella `utenti`
--

INSERT INTO `utenti` (`id_utente`, `email`, `password`) VALUES
(1, 'admin@gmail.com', '$2y$10$Wugypn0RRjGWASTPnIKiqOk3bik1eMuZAgI.LHDiMwIUfClNeXblK'),
(2, 'lorenzopietrangeloyt@gmail.com', '$2y$10$Wugypn0RRjGWASTPnIKiqOk3bik1eMuZAgI.LHDiMwIUfClNeXblK'),
(3, 'test2@gmail.com', '$2y$10$jTKnfCkN/4GxMWipcdV1ReDbKdpM1wow95BlcnTTiayOyBD8UotCO'),
(4, 'test3@gmail.com', '$2y$10$byb66aaPDAHlWf24tqqSXu9uEFOw03k47pftB9VOaJYDM/M/ggKUW'),
(5, 'test4@gmail.com', '$2y$10$O7S5QusYx8xQGNaPFVBZ9.k.rxK6./jkExSaXV1TYpqod0kO0LdZm');

--
-- Indici per le tabelle scaricate
--

--
-- Indici per le tabelle `categoria_prodotto`
--
ALTER TABLE `categoria_prodotto`
  ADD PRIMARY KEY (`id_prodotto`,`categoria`);

--
-- Indici per le tabelle `coupon`
--
ALTER TABLE `coupon`
  ADD PRIMARY KEY (`id_coupon`),
  ADD UNIQUE KEY `uq_coupon_nome` (`nome`);

--
-- Indici per le tabelle `groups`
--
ALTER TABLE `groups`
  ADD PRIMARY KEY (`id_group`);

--
-- Indici per le tabelle `ordine`
--
ALTER TABLE `ordine`
  ADD PRIMARY KEY (`id_ordine`),
  ADD KEY `idx_ordine_utente` (`id_utente`);

--
-- Indici per le tabelle `ordine_prodotto`
--
ALTER TABLE `ordine_prodotto`
  ADD PRIMARY KEY (`id_ordine`,`id_prodotto`),
  ADD KEY `fk_ordine_prodotto_prodotto` (`id_prodotto`);

--
-- Indici per le tabelle `prodotti_acquistati`
--
ALTER TABLE `prodotti_acquistati`
  ADD PRIMARY KEY (`id_utente`,`id_prodotto`),
  ADD KEY `fk_acq_prodotto` (`id_prodotto`);

--
-- Indici per le tabelle `prodotto`
--
ALTER TABLE `prodotto`
  ADD PRIMARY KEY (`id_prodotto`),
  ADD KEY `idx_prodotto_tipo` (`tipo`);

--
-- Indici per le tabelle `recensioni`
--
ALTER TABLE `recensioni`
  ADD PRIMARY KEY (`id_utente`,`id_prodotto`),
  ADD KEY `fk_recensioni_prodotto` (`id_prodotto`);

--
-- Indici per le tabelle `richieste`
--
ALTER TABLE `richieste`
  ADD PRIMARY KEY (`id_richiesta`),
  ADD KEY `idx_richieste_stato` (`stato`),
  ADD KEY `fk_richieste_utente` (`id_utente`),
  ADD KEY `fk_richieste_prodotto` (`id_prodotto`);

--
-- Indici per le tabelle `services`
--
ALTER TABLE `services`
  ADD PRIMARY KEY (`username`);

--
-- Indici per le tabelle `services_has_groups`
--
ALTER TABLE `services_has_groups`
  ADD PRIMARY KEY (`username`,`id_group`),
  ADD KEY `fk_shg_group` (`id_group`);

--
-- Indici per le tabelle `testimonianze`
--
ALTER TABLE `testimonianze`
  ADD PRIMARY KEY (`id_testimonianza`);

--
-- Indici per le tabelle `users_has_groups`
--
ALTER TABLE `users_has_groups`
  ADD PRIMARY KEY (`id_utente`,`id_group`),
  ADD KEY `fk_uhg_group` (`id_group`);

--
-- Indici per le tabelle `utenti`
--
ALTER TABLE `utenti`
  ADD PRIMARY KEY (`id_utente`),
  ADD UNIQUE KEY `uq_utenti_email` (`email`);

--
-- AUTO_INCREMENT per le tabelle scaricate
--

--
-- AUTO_INCREMENT per la tabella `coupon`
--
ALTER TABLE `coupon`
  MODIFY `id_coupon` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT per la tabella `groups`
--
ALTER TABLE `groups`
  MODIFY `id_group` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT per la tabella `ordine`
--
ALTER TABLE `ordine`
  MODIFY `id_ordine` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT per la tabella `prodotto`
--
ALTER TABLE `prodotto`
  MODIFY `id_prodotto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT per la tabella `richieste`
--
ALTER TABLE `richieste`
  MODIFY `id_richiesta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT per la tabella `testimonianze`
--
ALTER TABLE `testimonianze`
  MODIFY `id_testimonianza` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT per la tabella `utenti`
--
ALTER TABLE `utenti`
  MODIFY `id_utente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Limiti per le tabelle scaricate
--

--
-- Limiti per la tabella `categoria_prodotto`
--
ALTER TABLE `categoria_prodotto`
  ADD CONSTRAINT `fk_cat_prodotto` FOREIGN KEY (`id_prodotto`) REFERENCES `prodotto` (`id_prodotto`) ON DELETE CASCADE;

--
-- Limiti per la tabella `ordine`
--
ALTER TABLE `ordine`
  ADD CONSTRAINT `fk_ordine_utente` FOREIGN KEY (`id_utente`) REFERENCES `utenti` (`id_utente`) ON DELETE CASCADE;

--
-- Limiti per la tabella `ordine_prodotto`
--
ALTER TABLE `ordine_prodotto`
  ADD CONSTRAINT `fk_ordine_prodotto_ordine` FOREIGN KEY (`id_ordine`) REFERENCES `ordine` (`id_ordine`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_ordine_prodotto_prodotto` FOREIGN KEY (`id_prodotto`) REFERENCES `prodotto` (`id_prodotto`) ON DELETE CASCADE;

--
-- Limiti per la tabella `prodotti_acquistati`
--
ALTER TABLE `prodotti_acquistati`
  ADD CONSTRAINT `fk_acq_prodotto` FOREIGN KEY (`id_prodotto`) REFERENCES `prodotto` (`id_prodotto`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_acq_utente` FOREIGN KEY (`id_utente`) REFERENCES `utenti` (`id_utente`) ON DELETE CASCADE;

--
-- Limiti per la tabella `recensioni`
--
ALTER TABLE `recensioni`
  ADD CONSTRAINT `fk_recensioni_prodotto` FOREIGN KEY (`id_prodotto`) REFERENCES `prodotto` (`id_prodotto`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_recensioni_utente` FOREIGN KEY (`id_utente`) REFERENCES `utenti` (`id_utente`) ON DELETE CASCADE;

--
-- Limiti per la tabella `richieste`
--
ALTER TABLE `richieste`
  ADD CONSTRAINT `fk_richieste_prodotto` FOREIGN KEY (`id_prodotto`) REFERENCES `prodotto` (`id_prodotto`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_richieste_utente` FOREIGN KEY (`id_utente`) REFERENCES `utenti` (`id_utente`) ON DELETE CASCADE;

--
-- Limiti per la tabella `services_has_groups`
--
ALTER TABLE `services_has_groups`
  ADD CONSTRAINT `fk_shg_group` FOREIGN KEY (`id_group`) REFERENCES `groups` (`id_group`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_shg_service` FOREIGN KEY (`username`) REFERENCES `services` (`username`) ON DELETE CASCADE;

--
-- Limiti per la tabella `users_has_groups`
--
ALTER TABLE `users_has_groups`
  ADD CONSTRAINT `fk_uhg_group` FOREIGN KEY (`id_group`) REFERENCES `groups` (`id_group`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_uhg_utente` FOREIGN KEY (`id_utente`) REFERENCES `utenti` (`id_utente`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
