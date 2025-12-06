# Système de Prompts – Contrôle & Sommaire

Ce document initialise le système de prompts pour guider un agent AI à réaliser le projet de bout en bout de manière chirurgicale et fiable. Il contient:

- Un Prompt de Contrôle du Protocole (PCP) qui fixe les règles, contraintes et formats.
- Une Table de Matières des Prompts (TMP) qui répertorie tous les prompts par sous-tâche.

Veuillez valider ce fichier. Après validation, j’ajouterai les prompts détaillés pour chaque sous-tâche selon la table.

---

## 1) Prompt de Contrôle du Protocole (PCP)

Objectif: Définir le cadre d’exécution, les restrictions, les formats de sortie, et les critères d’acceptation pour toutes les interactions entre l’agent AI et le projet.

```
RÔLE:
Tu es un Agent AI d’ingénierie logicielle opérant dans un environnement Windows (PowerShell pwsh), responsable de réaliser intégralement un système de cache distribué orchestré par Apache NiFi avec intégrations MySQL, MongoDB (ReplicaSet), Redis, Kafka, et trois applications Laravel (Employees CRUD, Monitoring temps réel, Search Redis).

PRINCIPES:
1. Précision chirurgicale: exécuter chaque sous-tâche strictement selon les spécifications.
2. Traçabilité: documenter les actions, chemins, commandes, fichiers modifiés.
3. Idempotence: les scripts et étapes doivent pouvoir être relancés sans effets indésirables.
4. Sécurité: ne jamais exposer secrets; utiliser `.env` et variables sécurisées.
5. Vérification: après chaque étape, valider l’état (services up, ports, logs, tests).
6. Atomicité des commits: grouper changements par sous-tâche avec message clair.
7. Compatibilité Windows: toutes les commandes doivent être fournies en PowerShell (`pwsh`).

CONTRAINTES:
- Respect des versions: PHP 8.2.3, Laravel 9, Node 19, Kafka/Zookeeper 7.3.0, NiFi, Redis 7.x, MongoDB 6.x.
- Utiliser réseau Docker `cachesys` et volumes définis.
- Ne jamais committer `.env`, dumps, secrets.
- Ne pas modifier le protocole sans validation.

FORMATS DE SORTIE:
- Pour chaque sous-tâche, produire:
  a) Résumé: objectif + critères d’acceptation
  b) Étapes détaillées
  c) Commandes PowerShell (bloc code) prêtes à copier
  d) Fichiers créés/modifiés avec chemins
  e) Vérifications (checklist) + tests rapides
  f) Résultats attendus

CRITÈRES D’ACCEPTATION (génériques):
- Toutes les commandes s’exécutent sans erreur dans pwsh.
- Les services sont accessibles aux ports attendus.
- Les flux (Kafka → NiFi → Mongo/Redis) sont validés par données de test.
- Les apps Laravel démarrent et répondent.
- Les documents/artefacts sont à jour et cohérents.

PROCESSUS D’INTERACTION:
- L’agent lit la TMP, puis exécute chaque prompt dans l’ordre.
- À la fin de chaque sous-tâche, produire un rapport court et passer à la suivante.
- En cas de blocage, proposer 2 alternatives et demander validation.
```

---

## 2) Table de Matières des Prompts (TMP)

Cette table liste tous les prompts (numérotés) correspondant aux sous-tâches du projet. Chaque entrée sera développée ultérieurement.

### Phase A – Préparation & Infrastructure

1. A1 – Vérification des prérequis (Docker, Git, PHP, Node, Python)
2. A2 – Initialisation Git & conventions
3. A3 – Création réseau Docker `cachesys`
4. A4 – Rédaction et validation de `docker-compose.yml`
5. A5 – Création des volumes de persistance (data, db, cache, nifi)
6. A6 – Démarrage du cluster et contrôle de santé

### Phase B – Bases de données & Streaming

7. B1 – MySQL: création base `cachesystem`, import schéma & data
8. B2 – MongoDB: initialisation ReplicaSet `rs0`
9. B3 – Redis: configuration persistance et test SET/GET
10. B4 – Kafka: création topic `cache`, tests producteur/consommateur

### Phase C – Apache NiFi (Orchestration)

11. C1 – Accès NiFi & création des Controller Services
12. C2 – Flow Part 1: `ConsumeKafkaRecord` + `EvaluateJsonPath`
13. C3 – Flow Part 2 (Mongo): `ExecuteSQL` → `ConvertAvroToJSON` → `PutMongo`
14. C4 – Flow Part 3 (Redis): `ExecuteSQL` → `SplitRecord` → `MergeRecord` → `JoltTransformJson` → `PutDistributedMapCache`
15. C5 – Scheduling, démarrage et validations (Event Driven / All nodes)

### Phase D – Application Laravel Employees (CRUD)

16. D1 – Création projet Laravel + `.env` (MySQL)
17. D2 – Modèles `Customer`/`Order` (relations, clés)
18. D3 – Contrôleurs & routes (CRUD + nested)
19. D4 – Vues Blade (index/create/edit/show) + validation
20. D5 – Intégration `produce.py` via Symfony Process
21. D6 – Tests de bout en bout (CRUD → Kafka)

### Phase E – Script Python Kafka Producer

22. E1 – Création `produce.py` (message JSON, topic `cache`)
23. E2 – Gestion erreurs/retry + tests standalone

### Phase F – Application Laravel Monitoring (Temps Réel)

24. F1 – Projet Laravel + dépendances (`jenssegers/mongodb`, `pusher`, `echo`)
25. F2 – Config `.env`, `database.php`, `broadcasting.php`, `BroadcastServiceProvider`
26. F3 – Modèle MongoDB `Order`
27. F4 – Commande `WatchOrders` (Change Streams) + `Kernel.php`
28. F5 – Événement `NewOrder` (ShouldBroadcast) + channel `orders`
29. F6 – Assets Echo + Vue `monitor.blade.php`
30. F7 – Tests temps réel (insert Mongo → broadcast → UI)

### Phase G – Application Laravel Search (Redis)

31. G1 – Projet Laravel + `predis/predis`
32. G2 – Config `.env`, `database.php`, facade Redis
33. G3 – `SearchController` + route
34. G4 – Vue `search.blade.php` (form + résultats)
35. G5 – (Optionnel) Echo pour mise à jour en temps réel
36. G6 – Tests (GET Redis par `customerNumber`)

### Phase H – Qualité, Sécurité, CI/CD, Déploiement

37. H1 – Tests unitaires & intégration
38. H2 – Observabilité (logs, métriques)
39. H3 – Sécurité (HTTPS NiFi, secrets, permissions DB)
40. H4 – Documentation (ARCHITECTURE_COMPLETE.md, guides run)
41. H5 – CI/CD (lint, tests, build, déploiement)
42. H6 – Déploiement & exploitation (procédures, backup)
43. H7 – Validation finale & handover

---

Format attendu pour chaque prompt (lors de la suite):

- Contexte
- Objectif
- Étapes détaillées
- Commandes PowerShell
- Fichiers touchés
- Vérifications et critères d’acceptation
- Résultat attendu

---

## 3) Prompts Détaillés – Phase A (Préparation & Infrastructure)

### A1 – Vérification des prérequis (Docker, Git, PHP, Node, Python)

**Contexte:**  
Avant toute installation ou configuration, nous devons vérifier que tous les outils nécessaires sont présents et aux bonnes versions sur la machine Windows.

**Objectif:**  
Confirmer la présence et les versions de Docker Desktop, Git, PHP 8.2.3, Composer, Node.js 19+, npm, et Python 3.x.

**Étapes détaillées:**

1. Ouvrir PowerShell (`pwsh`) en tant qu'administrateur.
2. Vérifier Docker Desktop (version et statut).
3. Vérifier Git (version).
4. Vérifier PHP (version 8.2.3).
5. Vérifier Composer.
6. Vérifier Node.js (v19+) et npm.
7. Vérifier Python 3.x.
8. Vérifier les extensions PHP requises (php_mongodb, php_redis) dans php.ini.
9. Si un outil manque ou version incorrecte, télécharger/installer depuis les sources officielles.

**Commandes PowerShell:**

```powershell
# Vérifier Docker
docker --version
docker info

# Vérifier Git
git --version

# Vérifier PHP
php -v

# Vérifier Composer
composer --version

# Vérifier Node.js et npm
node -v
npm -v

# Vérifier Python
python --version

# Vérifier extensions PHP
php -m | Select-String "mongodb"
php -m | Select-String "redis"
```

**Fichiers touchés:**  
Aucun fichier projet. Configuration système uniquement.

**Vérifications:**

- [ ] Docker Desktop installé et en cours d'exécution.
- [ ] Git version ≥ 2.x.
- [ ] PHP version 8.2.3.
- [ ] Composer ≥ 2.x.
- [ ] Node.js version 19.x+, npm ≥ 9.x.
- [ ] Python 3.x (3.8+).

**Résultat attendu:**  
Toutes les commandes retournent les versions attendues sans erreur. Le système est prêt pour les installations suivantes.

---

### A2 – Initialisation Git & conventions

**Contexte:**  
Le projet nécessite un dépôt Git avec branches principales et conventions de commits claires.

**Objectif:**  
Initialiser un dépôt Git, créer les branches `main` et `develop`, configurer `.gitignore`, et définir les conventions de commit.

**Étapes détaillées:**

1. Se placer dans le répertoire du projet (`c:\Users\Lenovo\Desktop\Projet\Projet`).
2. Initialiser Git (`git init`).
3. Créer `.gitignore` avec exclusions (vendor, node_modules, .env, data, db, cache, nifi).
4. Faire un premier commit sur `main`.
5. Créer branche `develop` à partir de `main`.
6. Documenter les conventions de commits (ex: `feat:`, `fix:`, `docs:`, `chore:`).

**Commandes PowerShell:**

```powershell
cd c:\Users\Lenovo\Desktop\Projet\Projet

# Initialiser Git
git init

# Créer .gitignore
@"
vendor/
node_modules/
.env
.env.*
data/
db/
cache/
nifi/database_repository/
nifi/flowfile_repository/
nifi/content_repository/
nifi/provenance_repository/
nifi/state/
nifi/logs/
*.log
.DS_Store
Thumbs.db
"@ | Out-File -FilePath .gitignore -Encoding utf8

# Premier commit
git add .
git commit -m "chore: initialisation du projet avec .gitignore"

# Créer branche develop
git branch develop
git checkout develop

# Documenter conventions (créer CONTRIBUTING.md)
@"
# Conventions de Commits

- **feat:** Nouvelle fonctionnalité
- **fix:** Correction de bug
- **docs:** Modification documentation
- **chore:** Tâches de maintenance (config, deps)
- **test:** Ajout/modification tests
- **refactor:** Refactorisation sans changement fonctionnel

Format: `type: description courte`

Exemple: `feat: ajout du modèle Customer`
"@ | Out-File -FilePath CONTRIBUTING.md -Encoding utf8

git add CONTRIBUTING.md
git commit -m "docs: ajout des conventions de commits"
```

**Fichiers touchés:**

- `.gitignore` (créé)
- `CONTRIBUTING.md` (créé)

**Vérifications:**

- [ ] Dépôt Git initialisé (`.git/` présent).
- [ ] `.gitignore` contient toutes les exclusions nécessaires.
- [ ] Branches `main` et `develop` existent.
- [ ] Au moins un commit sur `main`.
- [ ] `CONTRIBUTING.md` présent et documenté.

**Résultat attendu:**  
Dépôt Git opérationnel avec conventions claires. Prêt pour versionner le code.

---

### A3 – Création réseau Docker `cachesys`

**Contexte:**  
Tous les services Docker (Kafka, MySQL, MongoDB, Redis, NiFi) doivent communiquer sur un réseau bridge nommé `cachesys`.

**Objectif:**  
Créer le réseau Docker `cachesys` en mode bridge.

**Étapes détaillées:**

1. Vérifier si le réseau `cachesys` existe déjà.
2. Si non, créer le réseau.
3. Lister les réseaux Docker pour validation.

**Commandes PowerShell:**

```powershell
# Lister réseaux existants
docker network ls

# Créer réseau cachesys (si absent)
docker network create cachesys

# Vérifier création
docker network inspect cachesys
```

**Fichiers touchés:**  
Aucun fichier projet. Configuration Docker uniquement.

**Vérifications:**

- [ ] Réseau `cachesys` visible dans `docker network ls`.
- [ ] Type: bridge.
- [ ] Pas d'erreur lors de la création.

**Résultat attendu:**  
Réseau Docker `cachesys` créé et prêt à accueillir les conteneurs.

---

### A4 – Rédaction et validation de `docker-compose.yml`

**Contexte:**  
Le fichier `docker-compose.yml` orchestrera tous les services: zookeeper, broker (Kafka), mongo1/2/3, mysql, redis, nifi.

**Objectif:**  
Créer un `docker-compose.yml` complet, respectant les versions, ports, volumes, et réseau `cachesys`.

**Étapes détaillées:**

1. Créer `docker-compose.yml` à la racine du projet.
2. Définir les services selon l'architecture (voir ARCHITECTURE_COMPLETE.md).
3. Spécifier les ports, variables d'environnement, volumes, et réseau.
4. Valider la syntaxe avec `docker compose config`.

**Commandes PowerShell:**

```powershell
# Créer docker-compose.yml (contenu ci-dessous)
# Copier le fichier depuis le template ou écrire directement

# Valider syntaxe
docker compose config

# Vérifier absence d'erreurs
```

**Fichiers touchés:**

- `docker-compose.yml` (créé)

**Contenu `docker-compose.yml`:**

```yaml
version: '3'
services:
  zookeeper:
    image: confluentinc/cp-zookeeper:7.3.0
    container_name: zookeeper
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000
    ports:
      - "2181:2181"
    networks:
      - cachesys

  broker:
    image: confluentinc/cp-kafka:7.3.0
    container_name: broker
    restart: always
    ports:
      - "9092:9092"
    depends_on:
      - zookeeper
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: 'zookeeper:2181'
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_INTERNAL:PLAINTEXT
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://localhost:9092,PLAINTEXT_INTERNAL://broker:29092
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
      KAFKA_TRANSACTION_STATE_LOG_MIN_ISR: 1
      KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR: 1
    networks:
      - cachesys

  mongo1:
    image: mongo:6.0
    container_name: mongo1
    ports:
      - "27017:27017"
    volumes:
      - ./db/db1:/data/db
    restart: always
    command: --replSet rs0 --bind_ip_all --port 27017
    networks:
      - cachesys

  mongo2:
    image: mongo:6.0
    container_name: mongo2
    ports:
      - "27018:27018"
    volumes:
      - ./db/db2:/data/db
    restart: always
    command: --replSet rs0 --bind_ip_all --port 27018
    networks:
      - cachesys

  mongo3:
    image: mongo:6.0
    container_name: mongo3
    ports:
      - "27019:27019"
    volumes:
      - ./db/db3:/data/db
    restart: always
    command: --replSet rs0 --bind_ip_all --port 27019
    networks:
      - cachesys

  mysql:
    image: mysql:8.0
    container_name: mysql
    restart: always
    environment:
      MYSQL_DATABASE: 'cachesystem'
      MYSQL_USER: 'youness'
      MYSQL_PASSWORD: 'doronbola'
      MYSQL_ROOT_PASSWORD: 'Bgj5WL#F8Ztaz'
    ports:
      - "3306:3306"
    expose:
      - '3306'
    volumes:
      - ./data:/var/lib/mysql
    networks:
      - cachesys

  nifi:
    container_name: nifi
    image: 'apache/nifi:1.23.2'
    ports:
      - 9443:9443
    environment:
      - SINGLE_USER_CREDENTIALS_USERNAME=admin
      - SINGLE_USER_CREDENTIALS_PASSWORD=ctsBtRBKHRAx69EqUghvvgEvjnaLjFEB
      - NIFI_WEB_HTTPS_PORT=9443
    restart: on-failure
    volumes:
      - ./nifi/database_repository:/opt/nifi/nifi-current/database_repository
      - ./nifi/flowfile_repository:/opt/nifi/nifi-current/flowfile_repository
      - ./nifi/content_repository:/opt/nifi/nifi-current/content_repository
      - ./nifi/provenance_repository:/opt/nifi/nifi-current/provenance_repository
      - ./nifi/state:/opt/nifi/nifi-current/state
      - ./nifi/logs:/opt/nifi/nifi-current/logs
      - ./nifi/conf:/opt/nifi/nifi-current/conf
    networks:
      - cachesys

  redis:
    image: redis:7.0
    container_name: redis
    ports:
      - "6379:6379"
    volumes:
      - ./cache:/data
    networks:
      - cachesys

networks:
  cachesys:
    external: true
```

**Vérifications:**

- [ ] `docker-compose.yml` présent à la racine.
- [ ] `docker compose config` s'exécute sans erreur.
- [ ] Tous les services listés (zookeeper, broker, mongo1/2/3, mysql, nifi, redis).
- [ ] Réseau `cachesys` référencé comme `external: true`.
- [ ] Volumes et ports correctement mappés.

**Résultat attendu:**  
Fichier `docker-compose.yml` valide, prêt à démarrer le cluster.

---

### A5 – Création des volumes de persistance (data, db, cache, nifi)

**Contexte:**  
Les services nécessitent des volumes sur l'hôte pour persister les données (MySQL, MongoDB, Redis, NiFi).

**Objectif:**  
Créer les répertoires locaux `data/`, `db/db1`, `db/db2`, `db/db3`, `cache/`, et sous-répertoires `nifi/`.

**Étapes détaillées:**

1. Créer dossier `data` pour MySQL.
2. Créer dossier `db` avec sous-dossiers `db1`, `db2`, `db3` pour MongoDB.
3. Créer dossier `cache` pour Redis.
4. Créer dossiers `nifi/database_repository`, `nifi/flowfile_repository`, `nifi/content_repository`, `nifi/provenance_repository`, `nifi/state`, `nifi/logs`, `nifi/conf`.

**Commandes PowerShell:**

```powershell
# Se placer à la racine du projet
cd c:\Users\Lenovo\Desktop\Projet\Projet

# Créer volumes
New-Item -ItemType Directory -Path .\data -Force
New-Item -ItemType Directory -Path .\db\db1 -Force
New-Item -ItemType Directory -Path .\db\db2 -Force
New-Item -ItemType Directory -Path .\db\db3 -Force
New-Item -ItemType Directory -Path .\cache -Force
New-Item -ItemType Directory -Path .\nifi\database_repository -Force
New-Item -ItemType Directory -Path .\nifi\flowfile_repository -Force
New-Item -ItemType Directory -Path .\nifi\content_repository -Force
New-Item -ItemType Directory -Path .\nifi\provenance_repository -Force
New-Item -ItemType Directory -Path .\nifi\state -Force
New-Item -ItemType Directory -Path .\nifi\logs -Force
New-Item -ItemType Directory -Path .\nifi\conf -Force

# Lister pour vérifier
Get-ChildItem -Directory
```

**Fichiers touchés:**  
Répertoires créés sur le disque (non versionnés grâce à `.gitignore`).

**Vérifications:**

- [ ] Dossier `data/` existe.
- [ ] Dossiers `db/db1`, `db/db2`, `db/db3` existent.
- [ ] Dossier `cache/` existe.
- [ ] Sous-dossiers `nifi/*` existent.

**Résultat attendu:**  
Structure de volumes prête pour le démarrage des conteneurs Docker.

---

### A6 – Démarrage du cluster et contrôle de santé

**Contexte:**  
Tous les services sont définis dans `docker-compose.yml` et les volumes sont créés. Il est temps de démarrer le cluster et valider la santé.

**Objectif:**  
Démarrer tous les conteneurs avec `docker compose up -d` et vérifier leur état (running, ports, logs).

**Étapes détaillées:**

1. Démarrer le cluster en mode détaché.
2. Attendre quelques secondes pour initialisation.
3. Vérifier l'état des conteneurs (tous doivent être `Up`).
4. Vérifier les ports exposés.
5. Consulter les logs de chaque service pour erreurs éventuelles.

**Commandes PowerShell:**

```powershell
# Démarrer le cluster
docker compose up -d

# Attendre initialisation (30 secondes)
Start-Sleep -Seconds 30

# Lister conteneurs
docker ps

# Vérifier ports exposés
docker ps --format "table {{.Names}}\t{{.Ports}}\t{{.Status}}"

# Consulter logs (exemples)
docker logs zookeeper
docker logs broker
docker logs mysql
docker logs mongo1
docker logs redis
docker logs nifi

# Vérifier santé réseau
docker network inspect cachesys
```

**Fichiers touchés:**  
Aucun. Opération runtime.

**Vérifications:**

- [ ] Tous les conteneurs sont en état `Up` (zookeeper, broker, mongo1/2/3, mysql, redis, nifi).
- [ ] Ports accessibles: 2181 (zk), 9092 (kafka), 27017/27018/27019 (mongo), 3306 (mysql), 6379 (redis), 9443 (nifi).
- [ ] Aucune erreur critique dans les logs.
- [ ] Réseau `cachesys` contient tous les conteneurs.

**Résultat attendu:**  
Cluster Docker opérationnel avec tous les services en ligne et communicants via `cachesys`.

---

**Fin Phase A**

Les prompts A1 à A6 sont désormais définis. L'agent peut exécuter chaque prompt dans l'ordre, valider les critères d'acceptation, et passer à la phase suivante (Phase B).

---

## 4) Prompts Détaillés – Phase B (Bases de données & Streaming)

### B1 – MySQL: création base `cachesystem`, import schéma & data

**Contexte:**  
MySQL doit contenir la base `cachesystem` avec les tables `customers`, `orders`, `products`, et `employees`, ainsi que des données d'exemple pour tester le flux.

**Objectif:**  
Créer la base de données, importer le schéma SQL, et charger les données d'exemple depuis le script MySQL Tutorial.

**Étapes détaillées:**

1. Vérifier que le conteneur MySQL est en cours d'exécution.
2. Télécharger le script SQL d'exemple (<https://www.mysqltutorial.org/mysql-sample-database.aspx>).
3. Se connecter à MySQL via client (ou MySQL Workbench).
4. Créer la base `cachesystem` si elle n'existe pas déjà (normalement créée via docker-compose).
5. Importer le script SQL dans la base `cachesystem`.
6. Vérifier la présence des tables et quelques lignes de données.

**Commandes PowerShell:**

```powershell
# Vérifier que MySQL est up
docker ps | Select-String mysql

# Télécharger script SQL (exemple: mysqlsampledatabase.sql)
# Placer le fichier dans ./scripts/mysqlsampledatabase.sql

# Se connecter à MySQL et importer
docker exec -i mysql mysql -uyouness -pdonronbola cachesystem < .\scripts\mysqlsampledatabase.sql

# Vérifier import (connexion interactive)
docker exec -it mysql mysql -uyouness -pdonronbola cachesystem

# Dans le shell MySQL:
# SHOW TABLES;
# SELECT COUNT(*) FROM customers;
# SELECT COUNT(*) FROM orders;
# EXIT;
```

**Fichiers touchés:**

- `scripts/mysqlsampledatabase.sql` (ajouté)

**Vérifications:**

- [ ] Base `cachesystem` existe.
- [ ] Tables `customers`, `orders`, `products`, `employees` présentes.
- [ ] Données présentes (> 0 lignes dans customers et orders).
- [ ] Connexion MySQL fonctionnelle depuis Workbench (optionnel).

**Résultat attendu:**  
Base MySQL `cachesystem` opérationnelle avec schéma et données prêtes pour les flux NiFi.

---

### B2 – MongoDB: initialisation ReplicaSet `rs0`

**Contexte:**  
MongoDB doit fonctionner en Replica Set pour activer les Change Streams (requis pour l'application Monitoring temps réel).

**Objectif:**  
Initialiser le Replica Set `rs0` avec `mongo1` en primaire et `mongo2`, `mongo3` en secondaires.

**Étapes détaillées:**

1. Vérifier que les 3 conteneurs MongoDB sont up.
2. Se connecter au shell de `mongo1`.
3. Initialiser le Replica Set avec la configuration `rs0`.
4. Ajouter `mongo1` en primaire, `mongo2` et `mongo3` en secondaires.
5. Vérifier le statut du Replica Set.
6. Noter la connection string: `mongodb://mongo1:27017,mongo2:27018,mongo3:27019/?replicaSet=rs0`.

**Commandes PowerShell:**

```powershell
# Vérifier conteneurs MongoDB
docker ps | Select-String mongo

# Se connecter au shell mongo1
docker exec -it mongo1 mongosh

# Dans le shell mongosh:
# Initialiser le Replica Set
rs.initiate({
  _id: "rs0",
  members: [
    { _id: 0, host: "mongo1:27017" },
    { _id: 1, host: "mongo2:27018" },
    { _id: 2, host: "mongo3:27019" }
  ]
})

# Vérifier statut
rs.status()

# Vérifier membres
rs.conf()

# Sortir
exit
```

**Alternative (script automatisé):**

```powershell
# Créer script init-mongo-replica.js
@"
rs.initiate({
  _id: 'rs0',
  members: [
    { _id: 0, host: 'mongo1:27017' },
    { _id: 1, host: 'mongo2:27018' },
    { _id: 2, host: 'mongo3:27019' }
  ]
});
"@ | Out-File -FilePath .\scripts\init-mongo-replica.js -Encoding utf8

# Exécuter script
docker exec -i mongo1 mongosh < .\scripts\init-mongo-replica.js

# Vérifier
docker exec -it mongo1 mongosh --eval "rs.status()"
```

**Fichiers touchés:**

- `scripts/init-mongo-replica.js` (créé)

**Vérifications:**

- [ ] Replica Set `rs0` initialisé.
- [ ] `mongo1` est PRIMARY.
- [ ] `mongo2` et `mongo3` sont SECONDARY.
- [ ] `rs.status()` retourne état sain (stateStr: "PRIMARY" / "SECONDARY").
- [ ] Connection string documentée: `mongodb://mongo1:27017,mongo2:27018,mongo3:27019/?replicaSet=rs0`.

**Résultat attendu:**  
MongoDB Replica Set `rs0` opérationnel. Change Streams activables. Prêt pour l'app Monitoring.

---

### B3 – Redis: configuration persistance et test SET/GET

**Contexte:**  
Redis doit persister les données dans le volume `./cache` et répondre aux commandes de base.

**Objectif:**  
Vérifier la persistance Redis et tester les opérations SET/GET.

**Étapes détaillées:**

1. Vérifier que le conteneur Redis est up.
2. Se connecter au CLI Redis.
3. Effectuer un test SET/GET.
4. Vérifier que le dump Redis est créé dans `./cache`.
5. Redémarrer le conteneur Redis et vérifier que les données persistent.

**Commandes PowerShell:**

```powershell
# Vérifier Redis
docker ps | Select-String redis

# Se connecter au CLI Redis
docker exec -it redis redis-cli

# Dans le CLI Redis:
# SET test "hello"
# GET test
# KEYS *
# EXIT

# Vérifier dump.rdb dans ./cache
Get-ChildItem .\cache

# Test persistance: redémarrer Redis
docker restart redis

# Attendre 5 secondes
Start-Sleep -Seconds 5

# Se reconnecter et vérifier
docker exec -it redis redis-cli GET test
# Doit retourner "hello"
```

**Fichiers touchés:**

- `./cache/dump.rdb` (généré automatiquement)

**Vérifications:**

- [ ] Conteneur Redis en état `Up`.
- [ ] Commande `SET` fonctionne.
- [ ] Commande `GET` retourne la valeur correcte.
- [ ] Fichier `dump.rdb` présent dans `./cache`.
- [ ] Après redémarrage, données persistent.

**Résultat attendu:**  
Redis opérationnel avec persistance activée. Prêt pour le cache distribué via NiFi.

---

### B4 – Kafka: création topic `cache`, tests producteur/consommateur

**Contexte:**  
Kafka doit avoir un topic nommé `cache` pour recevoir les messages de l'application Laravel Employees.

**Objectif:**  
Créer le topic `cache` avec 1 partition et replication factor 1, puis tester production et consommation de messages.

**Étapes détaillées:**

1. Vérifier que Zookeeper et Broker sont up.
2. Créer le topic `cache` via CLI Kafka.
3. Lister les topics pour validation.
4. Tester production d'un message.
5. Tester consommation du message.

**Commandes PowerShell:**

```powershell
# Vérifier Zookeeper et Broker
docker ps | Select-String -Pattern "zookeeper|broker"

# Créer topic cache
docker exec -it broker kafka-topics --create `
  --topic cache `
  --partitions 1 `
  --replication-factor 1 `
  --bootstrap-server broker:9092

# Lister topics
docker exec -it broker kafka-topics --list --bootstrap-server broker:9092

# Décrire le topic
docker exec -it broker kafka-topics --describe --topic cache --bootstrap-server broker:9092

# Test producteur (envoyer un message)
docker exec -it broker kafka-console-producer --topic cache --bootstrap-server broker:9092
# Taper un message JSON (exemple):
# {"customerNumber": 123, "orderNumber": 456}
# Puis Ctrl+C pour quitter

# Test consommateur (lire les messages)
docker exec -it broker kafka-console-consumer --topic cache --from-beginning --bootstrap-server broker:9092
# Doit afficher le message envoyé
# Ctrl+C pour quitter
```

**Fichiers touchés:**  
Aucun. Configuration Kafka runtime.

**Vérifications:**

- [ ] Topic `cache` créé.
- [ ] Topic visible dans `kafka-topics --list`.
- [ ] Partition: 1, Replication: 1.
- [ ] Message de test envoyé et reçu correctement.

**Résultat attendu:**  
Kafka opérationnel avec topic `cache` prêt à recevoir les messages de Laravel. Tests producteur/consommateur validés.

---

**Fin Phase B**

Les prompts B1 à B4 sont désormais définis. L'agent peut exécuter chaque prompt dans l'ordre pour configurer les bases de données et le streaming Kafka. Prêt pour la Phase C (Apache NiFi).

---

## 5) Prompts Détaillés – Phase C (Apache NiFi - Orchestration)

### C1 – Accès NiFi & création des Controller Services

**Contexte:**  
Apache NiFi est l'orchestrateur central du système. Il consomme les messages Kafka, interroge MySQL, et écrit dans MongoDB et Redis via des Controller Services.

**Objectif:**  
Accéder à l'interface NiFi, créer les Controller Services nécessaires (DBCPConnectionPool pour MySQL, DistributedMapCacheClientService pour Redis, MongoDBControllerService).

**Étapes détaillées:**

1. Vérifier que le conteneur NiFi est en état `Up` et accessible sur <https://localhost:9443>.
2. Se connecter à l'interface NiFi avec les credentials (admin / ctsBtRBKHRAx69EqUghvvgEvjnaLjFEB).
3. Créer un Process Group nommé `CacheSystemFlow`.
4. Créer les Controller Services au niveau du Process Group:
   - **DBCPConnectionPool** (MySQL):
     - Database Connection URL: `jdbc:mysql://mysql:3306/cachesystem`
     - Database Driver Class Name: `com.mysql.cj.jdbc.Driver`
     - Database User: `youness`
     - Password: `doronbola`
     - Télécharger driver MySQL Connector/J 8.0+ et l'ajouter à NiFi (`/opt/nifi/nifi-current/lib/`)
   - **RedisDistributedMapCacheClientService**:
     - Redis Mode: `Standalone`
     - Connection String: `redis://redis:6379`
     - Password: (laisser vide ou configurer si AUTH activé)
   - **MongoDBControllerService** (optionnel si PutMongo utilise connection string):
     - URI: `mongodb://mongo1:27017,mongo2:27018,mongo3:27019/?replicaSet=rs0`
5. Activer tous les Controller Services.
6. Vérifier l'état (vert = enabled).

**Commandes PowerShell:**

```powershell
# Vérifier NiFi
docker ps | Select-String nifi

# Télécharger MySQL Connector/J (si nécessaire)
# URL: https://dev.mysql.com/downloads/connector/j/
# Exemple: mysql-connector-java-8.0.33.jar

# Copier driver dans NiFi
docker cp .\drivers\mysql-connector-java-8.0.33.jar nifi:/opt/nifi/nifi-current/lib/

# Redémarrer NiFi pour charger driver
docker restart nifi

# Attendre redémarrage (60 secondes)
Start-Sleep -Seconds 60

# Accéder interface
Start-Process "https://localhost:9443/nifi"
```

**Fichiers touchés:**

- `drivers/mysql-connector-java-8.0.33.jar` (copié dans conteneur)

**Vérifications:**

- [ ] Interface NiFi accessible sur <https://localhost:9443>.
- [ ] Process Group `CacheSystemFlow` créé.
- [ ] Controller Service DBCPConnectionPool créé et enabled.
- [ ] Controller Service RedisDistributedMapCacheClientService créé et enabled.
- [ ] Controller Service MongoDBControllerService créé et enabled (si utilisé).
- [ ] Tous les services affichent état vert (enabled).

**Résultat attendu:**  
NiFi configuré avec les Controller Services MySQL, Redis, et MongoDB. Prêt pour la création des processeurs.

---

### C2 – Flow Part 1: `ConsumeKafkaRecord` + `EvaluateJsonPath`

**Contexte:**  
Le flux NiFi commence par consommer les messages du topic Kafka `cache`, extraire les attributs JSON (customerNumber, orderNumber), et router les FlowFiles pour traitement ultérieur.

**Objectif:**  
Créer le processeur `ConsumeKafkaRecord` pour lire Kafka, puis `EvaluateJsonPath` pour extraire les champs JSON en attributs de FlowFile.

**Étapes détaillées:**

1. Dans le Process Group `CacheSystemFlow`, ajouter un processeur `ConsumeKafka_2_6` (ou version récente).
2. Configurer `ConsumeKafka_2_6`:
   - Kafka Brokers: `broker:29092` (internal listener)
   - Topic Name(s): `cache`
   - Group ID: `nifi-cache-consumer`
   - Offset Reset: `earliest`
   - Record Reader: `JsonTreeReader` (créer Controller Service si nécessaire)
   - Record Writer: `JsonRecordSetWriter` (créer Controller Service si nécessaire)
   - Activer le processeur.
3. Ajouter un processeur `EvaluateJsonPath`.
4. Configurer `EvaluateJsonPath`:
   - Destination: `flowfile-attribute`
   - Ajouter propriétés dynamiques:
     - `customerNumber`: `$.customerNumber`
     - `orderNumber`: `$.orderNumber`
   - Relier `ConsumeKafka_2_6` (success) → `EvaluateJsonPath`.
5. Tester en envoyant un message Kafka et vérifier les attributs dans le FlowFile (via Data Provenance).

**Commandes PowerShell:**

```powershell
# Envoyer message de test Kafka
docker exec -it broker kafka-console-producer --topic cache --bootstrap-server broker:9092
# Taper: {"customerNumber": 103, "orderNumber": 10100}
# Ctrl+C pour quitter

# Consulter logs NiFi pour vérifier consommation
docker logs nifi --tail 50
```

**Fichiers touchés:**  
Aucun. Configuration NiFi via interface.

**Vérifications:**

- [ ] Processeur `ConsumeKafka_2_6` créé et actif.
- [ ] Processeur `EvaluateJsonPath` créé et actif.
- [ ] Connection entre ConsumeKafka → EvaluateJsonPath établie.
- [ ] Message Kafka consommé et attributs `customerNumber`, `orderNumber` extraits.
- [ ] Data Provenance montre FlowFile avec attributs corrects.

**Résultat attendu:**  
FlowFiles Kafka consommés avec attributs JSON extraits. Prêt pour routage vers MongoDB et Redis.

---

### C3 – Flow Part 2 (Mongo): `ExecuteSQL` → `ConvertAvroToJSON` → `PutMongo`

**Contexte:**  
Pour chaque message Kafka (customerNumber, orderNumber), on doit interroger MySQL pour récupérer les détails (customers, orders), les convertir en JSON, et les insérer dans MongoDB.

**Objectif:**  
Créer un flux qui exécute une requête SQL paramétrée, convertit le résultat Avro en JSON, et insère dans MongoDB collection `orders`.

**Étapes détaillées:**

1. Ajouter un processeur `ExecuteSQL` après `EvaluateJsonPath`.
2. Configurer `ExecuteSQL`:
   - Database Connection Pooling Service: sélectionner `DBCPConnectionPool`.
   - SQL select query:

     ```sql
     SELECT c.customerNumber, c.customerName, c.phone, c.city, c.country,
            o.orderNumber, o.orderDate, o.status, o.shippedDate
     FROM customers c
     INNER JOIN orders o ON c.customerNumber = o.customerNumber
     WHERE c.customerNumber = ${customerNumber} AND o.orderNumber = ${orderNumber}
     ```

   - Relier `EvaluateJsonPath` (matched) → `ExecuteSQL`.
3. Ajouter un processeur `ConvertAvroToJSON`.
4. Configurer `ConvertAvroToJSON`:
   - Relier `ExecuteSQL` (success) → `ConvertAvroToJSON`.
5. Ajouter un processeur `PutMongo`.
6. Configurer `PutMongo`:
   - Mongo URI: `mongodb://mongo1:27017,mongo2:27018,mongo3:27019/?replicaSet=rs0`
   - Mongo Database Name: `cachesystem`
   - Mongo Collection Name: `orders`
   - Mode: `insert`
   - Relier `ConvertAvroToJSON` (success) → `PutMongo`.
7. Tester en envoyant un message Kafka et vérifier insertion MongoDB.

**Commandes PowerShell:**

```powershell
# Envoyer message test
docker exec -it broker kafka-console-producer --topic cache --bootstrap-server broker:9092
# Taper: {"customerNumber": 103, "orderNumber": 10123}
# Ctrl+C

# Vérifier insertion MongoDB
docker exec -it mongo1 mongosh

# Dans mongosh:
use cachesystem
db.orders.find().pretty()
# Doit afficher le document inséré
exit
```

**Fichiers touchés:**  
Aucun. Configuration NiFi runtime.

**Vérifications:**

- [ ] Processeur `ExecuteSQL` créé et actif.
- [ ] Processeur `ConvertAvroToJSON` créé et actif.
- [ ] Processeur `PutMongo` créé et actif.
- [ ] Connections établies: ExecuteSQL → ConvertAvroToJSON → PutMongo.
- [ ] Requête SQL retourne données correctes.
- [ ] Document JSON inséré dans MongoDB collection `orders`.
- [ ] Data Provenance valide le flux complet.

**Résultat attendu:**  
Flux Kafka → MySQL → MongoDB opérationnel. Données enrichies stockées dans MongoDB pour Change Streams.

---

### C4 – Flow Part 3 (Redis): `ExecuteSQL` → `SplitRecord` → `MergeRecord` → `JoltTransformJson` → `PutDistributedMapCache`

**Contexte:**  
En parallèle du flux MongoDB, on doit interroger MySQL, transformer les résultats en format clé-valeur adapté à Redis (customerNumber → JSON), et écrire dans Redis via DistributedMapCache.

**Objectif:**  
Créer un flux parallèle qui récupère les données MySQL, les transforme avec Jolt, et les écrit dans Redis.

**Étapes détaillées:**

1. Ajouter un second processeur `ExecuteSQL` branché sur `EvaluateJsonPath`.
2. Configurer `ExecuteSQL` (même requête que C3 ou simplifiée):

   ```sql
   SELECT c.customerNumber, c.customerName, c.phone, c.city, c.country,
          o.orderNumber, o.orderDate, o.status
   FROM customers c
   INNER JOIN orders o ON c.customerNumber = o.customerNumber
   WHERE c.customerNumber = ${customerNumber} AND o.orderNumber = ${orderNumber}
   ```

3. Ajouter `ConvertAvroToJSON`.
4. Ajouter `SplitRecord` (si besoin de traiter chaque ligne individuellement).
5. Ajouter `MergeRecord` (pour consolider si nécessaire).
6. Ajouter `JoltTransformJSON` pour transformer en format Redis:
   - Spec Jolt (exemple):

     ```json
     [
       {
         "operation": "shift",
         "spec": {
           "customerNumber": "key",
           "*": "value.&"
         }
       }
     ]
     ```

7. Ajouter `PutDistributedMapCache`.
8. Configurer `PutDistributedMapCache`:
   - Distributed Cache Service: sélectionner `RedisDistributedMapCacheClientService`.
   - Cache Entry Identifier: `${key}` (ou `${customerNumber}`).
   - Relier le flux: ExecuteSQL → ConvertAvroToJSON → JoltTransformJSON → PutDistributedMapCache.
9. Tester et vérifier entrée Redis.

**Commandes PowerShell:**

```powershell
# Envoyer message test
docker exec -it broker kafka-console-producer --topic cache --bootstrap-server broker:9092
# Taper: {"customerNumber": 103, "orderNumber": 10123}
# Ctrl+C

# Vérifier Redis
docker exec -it redis redis-cli

# Dans redis-cli:
KEYS *
GET 103
# Doit retourner JSON avec infos customer/order
EXIT
```

**Fichiers touchés:**  
Aucun. Configuration NiFi runtime.

**Vérifications:**

- [ ] Processeur `ExecuteSQL` (Redis branch) créé et actif.
- [ ] Processeur `ConvertAvroToJSON` créé.
- [ ] Processeur `JoltTransformJSON` configuré avec spec correcte.
- [ ] Processeur `PutDistributedMapCache` créé et relié au RedisDistributedMapCacheClientService.
- [ ] Connections établies: ExecuteSQL → ConvertAvroToJSON → JoltTransformJSON → PutDistributedMapCache.
- [ ] Clé Redis créée avec customerNumber.
- [ ] Valeur Redis contient JSON des données customer/order.

**Résultat attendu:**  
Flux Kafka → MySQL → Redis opérationnel. Données cachées dans Redis pour accès rapide via l'app Search.

---

### C5 – Scheduling, démarrage et validations (Event Driven / All nodes)

**Contexte:**  
Tous les processeurs sont configurés. Il faut maintenant définir le scheduling (Event Driven pour réactivité), démarrer le flux complet, et valider le fonctionnement end-to-end.

**Objectif:**  
Configurer le scheduling des processeurs, démarrer le Process Group, et effectuer des tests de bout en bout.

**Étapes détaillées:**

1. Pour chaque processeur, configurer Scheduling:
   - `ConsumeKafka_2_6`: Scheduling Strategy = `Timer Driven`, Run Duration = `0 sec` (ou Event Driven si supporté).
   - Autres processeurs: Scheduling Strategy = `Event Driven` (pour réactivité instantanée).
   - Concurrent Tasks: `1` (ajuster selon charge).
2. Démarrer tous les processeurs (ou démarrer le Process Group entier).
3. Envoyer plusieurs messages Kafka de test avec différents customerNumber et orderNumber.
4. Vérifier:
   - MongoDB: documents insérés dans collection `orders`.
   - Redis: clés créées avec customerNumber et valeurs JSON.
   - Data Provenance NiFi: FlowFiles traités sans erreur.
   - Queues NiFi: pas de blocages (queues vides ou faibles).
5. Consulter bulletins NiFi pour warnings/errors.

**Commandes PowerShell:**

```powershell
# Envoyer batch de messages test
docker exec -it broker kafka-console-producer --topic cache --bootstrap-server broker:9092
# Taper plusieurs messages:
# {"customerNumber": 103, "orderNumber": 10123}
# {"customerNumber": 112, "orderNumber": 10298}
# {"customerNumber": 114, "orderNumber": 10120}
# Ctrl+C

# Vérifier MongoDB
docker exec -it mongo1 mongosh --eval "use cachesystem; db.orders.countDocuments()"

# Vérifier Redis
docker exec -it redis redis-cli KEYS "*"

# Consulter bulletins NiFi (via interface web)
# Menu hamburger > Summary > System Diagnostics > Bulletins
```

**Fichiers touchés:**  
Aucun. Opération runtime.

**Vérifications:**

- [ ] Tous les processeurs en état `Running`.
- [ ] Scheduling configuré (Event Driven / Timer Driven).
- [ ] Messages Kafka consommés et traités.
- [ ] MongoDB: documents présents dans collection `orders`.
- [ ] Redis: clés présentes avec valeurs JSON.
- [ ] Aucun bulletin d'erreur dans NiFi.
- [ ] Queues NiFi vides ou faibles (pas de backlog).
- [ ] Data Provenance montre FlowFiles réussis.

**Résultat attendu:**  
Flux NiFi complet opérationnel. Kafka → MySQL → MongoDB + Redis fonctionne de bout en bout. Prêt pour les applications Laravel.

---

**Fin Phase C**

Les prompts C1 à C5 sont désormais définis. L'agent peut configurer et démarrer l'orchestration NiFi complète. Le système backend (Docker, DB, Streaming, NiFi) est maintenant prêt pour les applications frontend Laravel (Phases D, E, F, G).

---

## 6) Prompts Détaillés – Phase D (Application Laravel Employees - CRUD)

### D1 – Création projet Laravel + `.env` (MySQL)

**Contexte:**  
L'application Laravel Employees permet de gérer les customers et orders via une interface CRUD. Elle se connecte à MySQL et envoie des messages à Kafka après chaque opération CRUD.

**Objectif:**  
Créer un nouveau projet Laravel 9, configurer `.env` pour MySQL, et installer les dépendances de base.

**Étapes détaillées:**

1. Se placer dans le répertoire du projet.
2. Créer un nouveau projet Laravel nommé `employees-app` via Composer.
3. Configurer `.env` avec les paramètres MySQL (host, port, database, user, password).
4. Générer la clé d'application Laravel.
5. Tester la connexion à MySQL.

**Commandes PowerShell:**

```powershell
# Se placer à la racine du projet
cd c:\Users\Lenovo\Desktop\Projet\Projet

# Créer projet Laravel
composer create-project --prefer-dist laravel/laravel:^9.0 employees-app

# Se placer dans le projet
cd employees-app

# Configurer .env
@"
APP_NAME=EmployeesApp
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost:8000

LOG_CHANNEL=stack

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=cachesystem
DB_USERNAME=youness
DB_PASSWORD=doronbola

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DRIVER=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120
"@ | Out-File -FilePath .env -Encoding utf8

# Générer clé application
php artisan key:generate

# Tester connexion MySQL
php artisan migrate:status
```

**Fichiers touchés:**

- `employees-app/` (nouveau projet Laravel)
- `employees-app/.env` (configuré)

**Vérifications:**

- [ ] Projet Laravel créé dans `employees-app/`.
- [ ] `.env` configuré avec paramètres MySQL corrects.
- [ ] `php artisan key:generate` s'exécute sans erreur.
- [ ] `php artisan migrate:status` se connecte à MySQL avec succès.
- [ ] Aucune erreur de connexion base de données.

**Résultat attendu:**  
Projet Laravel Employees opérationnel avec connexion MySQL validée. Prêt pour la création des modèles et contrôleurs.

---

### D2 – Modèles `Customer`/`Order` (relations, clés)

**Contexte:**  
Les modèles Eloquent `Customer` et `Order` représentent les tables MySQL. Ils doivent définir les relations (hasMany, belongsTo) et les clés primaires/étrangères.

**Objectif:**  
Créer les modèles `Customer` et `Order` avec relations, fillable, et configuration des clés.

**Étapes détaillées:**

1. Créer le modèle `Customer` via artisan.
2. Créer le modèle `Order` via artisan.
3. Définir la relation `Customer` hasMany `Orders`.
4. Définir la relation `Order` belongsTo `Customer`.
5. Configurer les propriétés `$table`, `$primaryKey`, `$fillable`, `$timestamps`.
6. Valider les modèles avec tinker.

**Commandes PowerShell:**

```powershell
# Se placer dans employees-app
cd c:\Users\Lenovo\Desktop\Projet\Projet\employees-app

# Créer modèle Customer
php artisan make:model Customer

# Créer modèle Order
php artisan make:model Order
```

**Fichiers touchés:**

- `app/Models/Customer.php` (créé)
- `app/Models/Order.php` (créé)

**Contenu `app/Models/Customer.php`:**

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Customer extends Model
{
    use HasFactory;

    protected $table = 'customers';
    protected $primaryKey = 'customerNumber';
    public $incrementing = true;
    public $timestamps = false;

    protected $fillable = [
        'customerName',
        'contactLastName',
        'contactFirstName',
        'phone',
        'addressLine1',
        'addressLine2',
        'city',
        'state',
        'postalCode',
        'country',
        'salesRepEmployeeNumber',
        'creditLimit'
    ];

    public function orders()
    {
        return $this->hasMany(Order::class, 'customerNumber', 'customerNumber');
    }
}
```

**Contenu `app/Models/Order.php`:**

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    use HasFactory;

    protected $table = 'orders';
    protected $primaryKey = 'orderNumber';
    public $incrementing = true;
    public $timestamps = false;

    protected $fillable = [
        'orderDate',
        'requiredDate',
        'shippedDate',
        'status',
        'comments',
        'customerNumber'
    ];

    public function customer()
    {
        return $this->belongsTo(Customer::class, 'customerNumber', 'customerNumber');
    }
}
```

**Commandes de validation:**

```powershell
# Tester avec tinker
php artisan tinker

# Dans tinker:
# \App\Models\Customer::count()
# \App\Models\Order::count()
# $customer = \App\Models\Customer::first()
# $customer->orders
# exit
```

**Vérifications:**

- [ ] Modèle `Customer` créé dans `app/Models/`.
- [ ] Modèle `Order` créé dans `app/Models/`.
- [ ] Relations hasMany et belongsTo définies.
- [ ] Propriétés `$table`, `$primaryKey`, `$fillable` configurées.
- [ ] Tinker retourne données correctes (count > 0).
- [ ] `$customer->orders` retourne collection d'ordres.

**Résultat attendu:**  
Modèles Eloquent opérationnels avec relations. Prêt pour les contrôleurs CRUD.

---

### D3 – Contrôleurs & routes (CRUD + nested)

**Contexte:**  
Les contrôleurs `CustomerController` et `OrderController` gèrent les opérations CRUD (create, read, update, delete) via des routes RESTful.

**Objectif:**  
Créer les contrôleurs avec méthodes CRUD, définir les routes dans `web.php`, et implémenter la logique métier.

**Étapes détaillées:**

1. Créer `CustomerController` avec resource methods.
2. Créer `OrderController` avec resource methods.
3. Définir les routes RESTful dans `routes/web.php`.
4. Implémenter les méthodes: index, create, store, show, edit, update, destroy.
5. Ajouter validation dans les méthodes store et update.

**Commandes PowerShell:**

```powershell
# Créer contrôleurs
php artisan make:controller CustomerController --resource
php artisan make:controller OrderController --resource
```

**Fichiers touchés:**

- `app/Http/Controllers/CustomerController.php` (créé)
- `app/Http/Controllers/OrderController.php` (créé)
- `routes/web.php` (modifié)

**Contenu `routes/web.php`:**

```php
<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\CustomerController;
use App\Http\Controllers\OrderController;

Route::get('/', function () {
    return redirect()->route('customers.index');
});

Route::resource('customers', CustomerController::class);
Route::resource('customers.orders', OrderController::class)->shallow();
```

**Contenu `app/Http/Controllers/CustomerController.php` (extrait):**

```php
<?php

namespace App\Http\Controllers;

use App\Models\Customer;
use Illuminate\Http\Request;

class CustomerController extends Controller
{
    public function index()
    {
        $customers = Customer::paginate(20);
        return view('customers.index', compact('customers'));
    }

    public function create()
    {
        return view('customers.create');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'customerName' => 'required|max:255',
            'phone' => 'required|max:50',
            'city' => 'required|max:100',
            'country' => 'required|max:100',
        ]);

        $customer = Customer::create($validated);

        return redirect()->route('customers.index')->with('success', 'Customer created successfully.');
    }

    public function show(Customer $customer)
    {
        return view('customers.show', compact('customer'));
    }

    public function edit(Customer $customer)
    {
        return view('customers.edit', compact('customer'));
    }

    public function update(Request $request, Customer $customer)
    {
        $validated = $request->validate([
            'customerName' => 'required|max:255',
            'phone' => 'required|max:50',
            'city' => 'required|max:100',
            'country' => 'required|max:100',
        ]);

        $customer->update($validated);

        return redirect()->route('customers.index')->with('success', 'Customer updated successfully.');
    }

    public function destroy(Customer $customer)
    {
        $customer->delete();
        return redirect()->route('customers.index')->with('success', 'Customer deleted successfully.');
    }
}
```

**Contenu `app/Http/Controllers/OrderController.php` (similaire avec nested routes):**

```php
<?php

namespace App\Http\Controllers;

use App\Models\Customer;
use App\Models\Order;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    public function index(Customer $customer)
    {
        $orders = $customer->orders()->paginate(20);
        return view('orders.index', compact('customer', 'orders'));
    }

    public function create(Customer $customer)
    {
        return view('orders.create', compact('customer'));
    }

    public function store(Request $request, Customer $customer)
    {
        $validated = $request->validate([
            'orderDate' => 'required|date',
            'status' => 'required|max:50',
        ]);

        $validated['customerNumber'] = $customer->customerNumber;
        $order = Order::create($validated);

        return redirect()->route('customers.orders.index', $customer)->with('success', 'Order created successfully.');
    }

    public function show(Order $order)
    {
        return view('orders.show', compact('order'));
    }

    public function edit(Order $order)
    {
        return view('orders.edit', compact('order'));
    }

    public function update(Request $request, Order $order)
    {
        $validated = $request->validate([
            'orderDate' => 'required|date',
            'status' => 'required|max:50',
        ]);

        $order->update($validated);

        return redirect()->route('orders.show', $order)->with('success', 'Order updated successfully.');
    }

    public function destroy(Order $order)
    {
        $customerNumber = $order->customerNumber;
        $order->delete();
        return redirect()->route('customers.orders.index', $customerNumber)->with('success', 'Order deleted successfully.');
    }
}
```

**Vérifications:**

- [ ] Contrôleurs `CustomerController` et `OrderController` créés.
- [ ] Routes RESTful définies dans `web.php`.
- [ ] Méthodes CRUD implémentées (index, create, store, show, edit, update, destroy).
- [ ] Validation des données présente dans store et update.
- [ ] Routes nested pour orders fonctionnelles.

**Résultat attendu:**  
Contrôleurs et routes CRUD opérationnels. Prêt pour les vues Blade.

---

### D4 – Vues Blade (index/create/edit/show) + validation

**Contexte:**  
Les vues Blade affichent les formulaires et listes pour gérer customers et orders. Elles incluent validation, messages flash, et Bootstrap pour le style.

**Objectif:**  
Créer les vues Blade pour customers et orders (index, create, edit, show) avec layout commun.

**Étapes détaillées:**

1. Créer layout principal `resources/views/layouts/app.blade.php`.
2. Créer vues customers: `index.blade.php`, `create.blade.php`, `edit.blade.php`, `show.blade.php`.
3. Créer vues orders: `index.blade.php`, `create.blade.php`, `edit.blade.php`, `show.blade.php`.
4. Ajouter messages flash (success, error).
5. Inclure Bootstrap via CDN pour styling.

**Commandes PowerShell:**

```powershell
# Créer répertoires vues
New-Item -ItemType Directory -Path resources\views\layouts -Force
New-Item -ItemType Directory -Path resources\views\customers -Force
New-Item -ItemType Directory -Path resources\views\orders -Force
```

**Fichiers touchés:**

- `resources/views/layouts/app.blade.php` (créé)
- `resources/views/customers/*.blade.php` (créés)
- `resources/views/orders/*.blade.php` (créés)

**Contenu `resources/views/layouts/app.blade.php`:**

```blade
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'Employees App')</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="{{ route('customers.index') }}">Employees App</a>
        </div>
    </nav>

    <div class="container mt-4">
        @if(session('success'))
            <div class="alert alert-success">{{ session('success') }}</div>
        @endif

        @if(session('error'))
            <div class="alert alert-danger">{{ session('error') }}</div>
        @endif

        @yield('content')
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
```

**Contenu `resources/views/customers/index.blade.php`:**

```blade
@extends('layouts.app')

@section('title', 'Customers List')

@section('content')
<h1>Customers</h1>
<a href="{{ route('customers.create') }}" class="btn btn-primary mb-3">Add Customer</a>

<table class="table table-striped">
    <thead>
        <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Phone</th>
            <th>City</th>
            <th>Country</th>
            <th>Actions</th>
        </tr>
    </thead>
    <tbody>
        @foreach($customers as $customer)
        <tr>
            <td>{{ $customer->customerNumber }}</td>
            <td>{{ $customer->customerName }}</td>
            <td>{{ $customer->phone }}</td>
            <td>{{ $customer->city }}</td>
            <td>{{ $customer->country }}</td>
            <td>
                <a href="{{ route('customers.show', $customer) }}" class="btn btn-sm btn-info">View</a>
                <a href="{{ route('customers.edit', $customer) }}" class="btn btn-sm btn-warning">Edit</a>
                <form action="{{ route('customers.destroy', $customer) }}" method="POST" class="d-inline">
                    @csrf
                    @method('DELETE')
                    <button type="submit" class="btn btn-sm btn-danger" onclick="return confirm('Are you sure?')">Delete</button>
                </form>
            </td>
        </tr>
        @endforeach
    </tbody>
</table>

{{ $customers->links() }}
@endsection
```

**Contenu `resources/views/customers/create.blade.php`:**

```blade
@extends('layouts.app')

@section('title', 'Create Customer')

@section('content')
<h1>Create Customer</h1>

<form action="{{ route('customers.store') }}" method="POST">
    @csrf

    <div class="mb-3">
        <label for="customerName" class="form-label">Customer Name</label>
        <input type="text" class="form-control @error('customerName') is-invalid @enderror" id="customerName" name="customerName" value="{{ old('customerName') }}" required>
        @error('customerName')
            <div class="invalid-feedback">{{ $message }}</div>
        @enderror
    </div>

    <div class="mb-3">
        <label for="phone" class="form-label">Phone</label>
        <input type="text" class="form-control @error('phone') is-invalid @enderror" id="phone" name="phone" value="{{ old('phone') }}" required>
        @error('phone')
            <div class="invalid-feedback">{{ $message }}</div>
        @enderror
    </div>

    <div class="mb-3">
        <label for="city" class="form-label">City</label>
        <input type="text" class="form-control @error('city') is-invalid @enderror" id="city" name="city" value="{{ old('city') }}" required>
        @error('city')
            <div class="invalid-feedback">{{ $message }}</div>
        @enderror
    </div>

    <div class="mb-3">
        <label for="country" class="form-label">Country</label>
        <input type="text" class="form-control @error('country') is-invalid @enderror" id="country" name="country" value="{{ old('country') }}" required>
        @error('country')
            <div class="invalid-feedback">{{ $message }}</div>
        @enderror
    </div>

    <button type="submit" class="btn btn-success">Create</button>
    <a href="{{ route('customers.index') }}" class="btn btn-secondary">Cancel</a>
</form>
@endsection
```

**Note:** Créer des vues similaires pour `edit.blade.php`, `show.blade.php` (customers) et les vues orders.

**Vérifications:**

- [ ] Layout `app.blade.php` créé avec Bootstrap.
- [ ] Vues customers (index, create, edit, show) créées.
- [ ] Vues orders (index, create, edit, show) créées.
- [ ] Messages flash affichés correctement.
- [ ] Validation errors affichés dans les formulaires.
- [ ] Interface responsive et stylée avec Bootstrap.

**Résultat attendu:**  
Interface CRUD complète et fonctionnelle pour customers et orders. Prêt pour l'intégration Kafka.

---

### D5 – Intégration `produce.py` via Symfony Process

**Contexte:**  
Après chaque opération CRUD (create, update, delete), l'application doit envoyer un message JSON à Kafka via le script Python `produce.py`.

**Objectif:**  
Intégrer l'appel au script `produce.py` dans les contrôleurs en utilisant Symfony Process component.

**Étapes détaillées:**

1. Installer Symfony Process via Composer.
2. Créer un service helper `KafkaProducer` pour encapsuler l'appel à `produce.py`.
3. Modifier les méthodes store, update, destroy des contrôleurs pour appeler le service.
4. Passer les données (customerNumber, orderNumber) en paramètres au script Python.
5. Gérer les erreurs (retry, logs).

**Commandes PowerShell:**

```powershell
# Installer Symfony Process
composer require symfony/process
```

**Fichiers touchés:**

- `app/Services/KafkaProducer.php` (créé)
- `app/Http/Controllers/CustomerController.php` (modifié)
- `app/Http/Controllers/OrderController.php` (modifié)

**Contenu `app/Services/KafkaProducer.php`:**

```php
<?php

namespace App\Services;

use Symfony\Component\Process\Process;
use Symfony\Component\Process\Exception\ProcessFailedException;
use Illuminate\Support\Facades\Log;

class KafkaProducer
{
    public function sendMessage($customerNumber, $orderNumber)
    {
        $pythonScript = base_path('../produce.py');
        $message = json_encode([
            'customerNumber' => $customerNumber,
            'orderNumber' => $orderNumber
        ]);

        $process = new Process(['python', $pythonScript, $message]);
        $process->setTimeout(10);

        try {
            $process->mustRun();
            Log::info('Kafka message sent', ['customer' => $customerNumber, 'order' => $orderNumber]);
            return true;
        } catch (ProcessFailedException $exception) {
            Log::error('Kafka message failed', ['error' => $exception->getMessage()]);
            return false;
        }
    }
}
```

**Modification `app/Http/Controllers/OrderController.php` (méthode store):**

```php
use App\Services\KafkaProducer;

public function store(Request $request, Customer $customer)
{
    $validated = $request->validate([
        'orderDate' => 'required|date',
        'status' => 'required|max:50',
    ]);

    $validated['customerNumber'] = $customer->customerNumber;
    $order = Order::create($validated);

    // Envoyer message Kafka
    $kafkaProducer = new KafkaProducer();
    $kafkaProducer->sendMessage($customer->customerNumber, $order->orderNumber);

    return redirect()->route('customers.orders.index', $customer)->with('success', 'Order created and sent to Kafka.');
}
```

**Note:** Appliquer la même logique aux méthodes update et destroy.

**Vérifications:**

- [ ] Symfony Process installé.
- [ ] Service `KafkaProducer` créé.
- [ ] Contrôleurs appellent `sendMessage` après CRUD.
- [ ] Messages JSON envoyés à Kafka.
- [ ] Logs Laravel enregistrent succès/échec.

**Résultat attendu:**  
Intégration Kafka opérationnelle. Chaque opération CRUD envoie un message à Kafka pour traitement NiFi.

---

### D6 – Tests de bout en bout (CRUD → Kafka)

**Contexte:**  
Valider que le flux complet fonctionne: CRUD Laravel → Kafka → NiFi → MongoDB/Redis.

**Objectif:**  
Effectuer des tests end-to-end pour vérifier l'intégration complète.

**Étapes détaillées:**

1. Démarrer le serveur Laravel (`php artisan serve`).
2. Créer un customer via l'interface web.
3. Créer un order pour ce customer.
4. Vérifier que le message Kafka est produit.
5. Vérifier que NiFi consomme le message.
6. Vérifier l'insertion dans MongoDB collection `orders`.
7. Vérifier l'écriture dans Redis (clé = customerNumber).

**Commandes PowerShell:**

```powershell
# Démarrer serveur Laravel
php artisan serve

# Dans un autre terminal, vérifier Kafka consumer
docker exec -it broker kafka-console-consumer --topic cache --from-beginning --bootstrap-server broker:9092

# Après création d'order via web:
# Vérifier MongoDB
docker exec -it mongo1 mongosh --eval "use cachesystem; db.orders.find().pretty()"

# Vérifier Redis
docker exec -it redis redis-cli KEYS "*"
docker exec -it redis redis-cli GET <customerNumber>
```

**Fichiers touchés:**  
Aucun. Tests manuels.

**Vérifications:**

- [ ] Serveur Laravel accessible sur <http://localhost:8000>.
- [ ] Interface web affiche liste customers.
- [ ] Création customer fonctionne.
- [ ] Création order fonctionne.
- [ ] Message JSON apparaît dans Kafka consumer.
- [ ] NiFi traite le message (vérifier Data Provenance).
- [ ] Document inséré dans MongoDB collection `orders`.
- [ ] Clé créée dans Redis avec customerNumber.
- [ ] Aucune erreur dans logs Laravel, NiFi, Kafka.

**Résultat attendu:**  
Flux end-to-end validé. Application Laravel Employees envoie correctement les données à Kafka, qui sont traitées par NiFi et stockées dans MongoDB et Redis.

---

**Fin Phase D**

Les prompts D1 à D6 sont désormais définis. L'agent peut créer l'application Laravel Employees avec CRUD complet et intégration Kafka. Prêt pour la Phase E (Script Python Kafka Producer).

---

## 7) Prompts Détaillés – Phase E (Script Python Kafka Producer)

### E1 – Création `produce.py` (message JSON, topic `cache`)

**Contexte:**  
Le script Python `produce.py` est appelé par Laravel pour envoyer des messages JSON au topic Kafka `cache`. Il utilise la bibliothèque `kafka-python`.

**Objectif:**  
Créer le script `produce.py` qui accepte un message JSON en argument CLI et le produit vers Kafka avec gestion des erreurs.

**Étapes détaillées:**

1. Créer le fichier `produce.py` à la racine du projet.
2. Installer la dépendance `kafka-python` via pip.
3. Implémenter la fonction de production Kafka.
4. Accepter le message JSON en argument de ligne de commande.
5. Configurer les paramètres Kafka (bootstrap servers, topic).
6. Ajouter logging pour traçabilité.
7. Tester le script en standalone.

**Commandes PowerShell:**

```powershell
# Se placer à la racine du projet
cd c:\Users\Lenovo\Desktop\Projet\Projet

# Installer kafka-python
pip install kafka-python

# Créer produce.py (voir contenu ci-dessous)

# Tester script standalone
python produce.py '{"customerNumber": 103, "orderNumber": 10123}'
```

**Fichiers touchés:**

- `produce.py` (créé)
- `requirements.txt` (créé)

**Contenu `produce.py`:**

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import json
import logging
from kafka import KafkaProducer
from kafka.errors import KafkaError

# Configuration du logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Configuration Kafka
KAFKA_BROKER = 'localhost:9092'
KAFKA_TOPIC = 'cache'

def create_producer():
    """Crée et retourne un producteur Kafka"""
    try:
        producer = KafkaProducer(
            bootstrap_servers=[KAFKA_BROKER],
            value_serializer=lambda v: json.dumps(v).encode('utf-8'),
            acks='all',
            retries=3,
            max_in_flight_requests_per_connection=1
        )
        logger.info(f"Kafka producer créé avec succès (broker: {KAFKA_BROKER})")
        return producer
    except Exception as e:
        logger.error(f"Erreur lors de la création du producer: {e}")
        sys.exit(1)

def send_message(producer, message_data):
    """Envoie un message au topic Kafka"""
    try:
        # Valider que message_data est un dict
        if isinstance(message_data, str):
            message_data = json.loads(message_data)
        
        # Vérifier les champs requis
        if 'customerNumber' not in message_data or 'orderNumber' not in message_data:
            raise ValueError("Message doit contenir 'customerNumber' et 'orderNumber'")
        
        # Envoyer le message
        future = producer.send(KAFKA_TOPIC, value=message_data)
        
        # Attendre confirmation
        record_metadata = future.get(timeout=10)
        
        logger.info(f"Message envoyé avec succès - Topic: {record_metadata.topic}, "
                   f"Partition: {record_metadata.partition}, Offset: {record_metadata.offset}")
        logger.info(f"Contenu: {message_data}")
        
        return True
        
    except json.JSONDecodeError as e:
        logger.error(f"Erreur de parsing JSON: {e}")
        return False
    except ValueError as e:
        logger.error(f"Validation message échouée: {e}")
        return False
    except KafkaError as e:
        logger.error(f"Erreur Kafka: {e}")
        return False
    except Exception as e:
        logger.error(f"Erreur inattendue: {e}")
        return False

def main():
    """Point d'entrée principal"""
    if len(sys.argv) < 2:
        logger.error("Usage: python produce.py '<json_message>'")
        logger.error("Exemple: python produce.py '{\"customerNumber\": 103, \"orderNumber\": 10123}'")
        sys.exit(1)
    
    message_json = sys.argv[1]
    
    # Créer producer
    producer = create_producer()
    
    try:
        # Envoyer message
        success = send_message(producer, message_json)
        
        # Flush pour garantir l'envoi
        producer.flush()
        
        sys.exit(0 if success else 1)
        
    finally:
        # Fermer le producer proprement
        producer.close()
        logger.info("Producer fermé")

if __name__ == "__main__":
    main()
```

**Contenu `requirements.txt`:**

```txt
kafka-python==2.0.2
```

**Vérifications:**

- [ ] Fichier `produce.py` créé à la racine.
- [ ] Dépendance `kafka-python` installée.
- [ ] Script accepte argument JSON en CLI.
- [ ] Message envoyé au topic `cache` avec succès.
- [ ] Logs affichent succès/échec.
- [ ] Test standalone réussi (message visible dans Kafka consumer).

**Résultat attendu:**  
Script Python `produce.py` opérationnel. Capable d'envoyer des messages JSON à Kafka avec logging et validation.

---

### E2 – Gestion erreurs/retry + tests standalone

**Contexte:**  
Le script doit être robuste avec gestion des erreurs réseau, timeouts, et retry automatique. Il doit également être testable en standalone.

**Objectif:**  
Améliorer la gestion des erreurs avec retry logic, ajouter des tests, et documenter l'usage.

**Étapes détaillées:**

1. Ajouter retry logic avec backoff exponentiel.
2. Gérer les timeouts et erreurs réseau.
3. Créer un script de test `test_produce.py`.
4. Documenter l'usage dans `README_PRODUCER.md`.
5. Tester différents scénarios (succès, échec Kafka down, JSON invalide).

**Commandes PowerShell:**

```powershell
# Tester avec Kafka actif
python produce.py '{"customerNumber": 103, "orderNumber": 10123}'

# Tester avec JSON invalide
python produce.py '{"customerNumber": 103}'

# Tester avec Kafka down (arrêter broker temporairement)
docker stop broker
python produce.py '{"customerNumber": 103, "orderNumber": 10123}'
# Doit logger l'erreur et retourner exit code 1

# Redémarrer broker
docker start broker
```

**Fichiers touchés:**

- `produce.py` (modifié avec retry)
- `test_produce.py` (créé)
- `README_PRODUCER.md` (créé)

**Modification `produce.py` (ajout retry logic):**

```python
import time
from functools import wraps

def retry_on_failure(max_retries=3, delay=1, backoff=2):
    """Décorateur pour retry avec backoff exponentiel"""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            retries = 0
            current_delay = delay
            
            while retries < max_retries:
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    retries += 1
                    if retries >= max_retries:
                        logger.error(f"Échec après {max_retries} tentatives")
                        raise
                    
                    logger.warning(f"Tentative {retries}/{max_retries} échouée: {e}")
                    logger.info(f"Retry dans {current_delay}s...")
                    time.sleep(current_delay)
                    current_delay *= backoff
            
        return wrapper
    return decorator

@retry_on_failure(max_retries=3, delay=1, backoff=2)
def send_message_with_retry(producer, message_data):
    """Envoie message avec retry automatique"""
    return send_message(producer, message_data)
```

**Contenu `test_produce.py`:**

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import subprocess
import json

def test_valid_message():
    """Test avec message valide"""
    message = json.dumps({"customerNumber": 103, "orderNumber": 10123})
    result = subprocess.run(['python', 'produce.py', message], capture_output=True)
    assert result.returncode == 0, "Message valide devrait réussir"
    print("✓ Test message valide: OK")

def test_invalid_json():
    """Test avec JSON invalide"""
    result = subprocess.run(['python', 'produce.py', 'invalid json'], capture_output=True)
    assert result.returncode != 0, "JSON invalide devrait échouer"
    print("✓ Test JSON invalide: OK")

def test_missing_fields():
    """Test avec champs manquants"""
    message = json.dumps({"customerNumber": 103})
    result = subprocess.run(['python', 'produce.py', message], capture_output=True)
    assert result.returncode != 0, "Champs manquants devrait échouer"
    print("✓ Test champs manquants: OK")

if __name__ == "__main__":
    print("Exécution des tests produce.py...")
    test_valid_message()
    test_invalid_json()
    test_missing_fields()
    print("\n✓ Tous les tests réussis!")
```

**Contenu `README_PRODUCER.md`:**

```markdown
# Kafka Producer Script

## Description
Script Python pour produire des messages JSON vers Kafka topic `cache`.

## Installation
```bash
pip install -r requirements.txt
```

## Usage

### Ligne de commande

```bash
python produce.py '{"customerNumber": 103, "orderNumber": 10123}'
```

### Depuis Laravel (Symfony Process)

```php
$process = new Process(['python', 'produce.py', $message]);
$process->mustRun();
```

## Format Message

```json
{
  "customerNumber": 103,
  "orderNumber": 10123
}
```

## Configuration

- **Broker**: localhost:9092
- **Topic**: cache
- **Retries**: 3 (avec backoff exponentiel)
- **Acks**: all (confirmation de tous les réplicas)

## Tests

```bash
python test_produce.py
```

## Logs

Les logs sont écrits sur stdout avec format:

```
2025-12-03 10:30:45 - __main__ - INFO - Message envoyé avec succès
```

## Exit Codes

- 0: Succès
- 1: Erreur (JSON invalide, Kafka down, timeout, etc.)

```

**Vérifications:**
- [ ] Retry logic implémenté avec backoff exponentiel.
- [ ] Timeouts et erreurs réseau gérés.
- [ ] Script de test `test_produce.py` créé et réussi.
- [ ] Documentation `README_PRODUCER.md` complète.
- [ ] Tests scénarios multiples validés (succès, échec).
- [ ] Exit codes corrects (0 = succès, 1 = échec).

**Résultat attendu:**  
Script Python robuste et testé. Gestion complète des erreurs avec retry. Documentation claire pour utilisation standalone ou depuis Laravel.

---

**Fin Phase E**

Les prompts E1 à E2 sont désormais définis. L'agent peut créer le script Python `produce.py` avec gestion d'erreurs robuste et tests. Prêt pour la Phase F (Application Laravel Monitoring temps réel).

---

## 8) Prompts Détaillés – Phase F (Application Laravel Monitoring - Temps Réel)

### F1 – Projet Laravel + dépendances (`jenssegers/mongodb`, `pusher`, `echo`)

**Contexte:**  
L'application Monitoring affiche en temps réel les nouveaux orders insérés dans MongoDB via Change Streams et diffuse les mises à jour via WebSockets (Pusher/Echo).

**Objectif:**  
Créer un nouveau projet Laravel pour le monitoring, installer les dépendances MongoDB, Pusher PHP Server, et Laravel Echo.

**Étapes détaillées:**
1. Créer projet Laravel `monitoring-app`.
2. Installer `jenssegers/mongodb` pour connexion MongoDB.
3. Installer `pusher/pusher-php-server` pour broadcasting.
4. Installer Laravel Echo côté frontend (npm).
5. Configurer `.env` avec paramètres MongoDB et Pusher.

**Commandes PowerShell:**
```powershell
# Se placer à la racine du projet
cd c:\Users\Lenovo\Desktop\Projet\Projet

# Créer projet Laravel
composer create-project --prefer-dist laravel/laravel:^9.0 monitoring-app

# Se placer dans le projet
cd monitoring-app

# Installer dépendances MongoDB
composer require jenssegers/mongodb:^3.9

# Installer Pusher PHP Server
composer require pusher/pusher-php-server

# Installer Laravel Breeze (optionnel pour auth)
composer require laravel/breeze --dev
php artisan breeze:install

# Installer dépendances npm
npm install
npm install --save-dev laravel-echo pusher-js
```

**Fichiers touchés:**

- `monitoring-app/` (nouveau projet Laravel)
- `monitoring-app/composer.json` (dépendances)
- `monitoring-app/package.json` (dépendances npm)

**Vérifications:**

- [ ] Projet `monitoring-app` créé.
- [ ] Package `jenssegers/mongodb` installé.
- [ ] Package `pusher/pusher-php-server` installé.
- [ ] Laravel Echo et Pusher.js installés via npm.
- [ ] Commande `composer show` affiche les packages installés.
- [ ] `npm list` affiche laravel-echo et pusher-js.

**Résultat attendu:**  
Projet Laravel Monitoring créé avec toutes les dépendances nécessaires pour MongoDB, broadcasting, et WebSockets.

---

### F2 – Config `.env`, `database.php`, `broadcasting.php`, `BroadcastServiceProvider`

**Contexte:**  
Configuration des connexions MongoDB ReplicaSet, broadcasting Pusher, et activation du service provider.

**Objectif:**  
Configurer tous les fichiers de configuration pour activer MongoDB Change Streams et broadcasting temps réel.

**Étapes détaillées:**

1. Configurer `.env` avec MongoDB ReplicaSet URI et credentials Pusher.
2. Modifier `config/database.php` pour ajouter connexion MongoDB.
3. Configurer `config/broadcasting.php` avec driver Pusher.
4. Activer `BroadcastServiceProvider` dans `config/app.php`.
5. Tester la configuration.

**Commandes PowerShell:**

```powershell
# Configurer .env
@"
APP_NAME=MonitoringApp
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost:8001

DB_CONNECTION=mongodb
DB_HOST=127.0.0.1
DB_PORT=27017
DB_DATABASE=cachesystem
DB_USERNAME=
DB_PASSWORD=

MONGODB_DSN=mongodb://mongo1:27017,mongo2:27018,mongo3:27019/cachesystem?replicaSet=rs0

BROADCAST_DRIVER=pusher
CACHE_DRIVER=file
QUEUE_CONNECTION=sync
SESSION_DRIVER=file

PUSHER_APP_ID=local-app-id
PUSHER_APP_KEY=local-app-key
PUSHER_APP_SECRET=local-app-secret
PUSHER_APP_CLUSTER=mt1
"@ | Out-File -FilePath .env -Encoding utf8

# Générer clé
php artisan key:generate
```

**Fichiers touchés:**

- `monitoring-app/.env` (configuré)
- `config/database.php` (modifié)
- `config/broadcasting.php` (modifié)
- `config/app.php` (modifié)

**Modification `config/database.php`:**

```php
'connections' => [
    // ... autres connexions ...

    'mongodb' => [
        'driver' => 'mongodb',
        'dsn' => env('MONGODB_DSN', 'mongodb://127.0.0.1:27017/'),
        'database' => env('DB_DATABASE', 'cachesystem'),
    ],
],
```

**Modification `config/broadcasting.php`:**

```php
'connections' => [
    'pusher' => [
        'driver' => 'pusher',
        'key' => env('PUSHER_APP_KEY'),
        'secret' => env('PUSHER_APP_SECRET'),
        'app_id' => env('PUSHER_APP_ID'),
        'options' => [
            'cluster' => env('PUSHER_APP_CLUSTER'),
            'host' => '127.0.0.1',
            'port' => 6001,
            'scheme' => 'http',
            'encrypted' => false,
            'useTLS' => false,
        ],
    ],
],
```

**Modification `config/app.php` (activer BroadcastServiceProvider):**

```php
'providers' => [
    // ...
    App\Providers\BroadcastServiceProvider::class,
],
```

**Vérifications:**

- [ ] `.env` configuré avec MongoDB DSN ReplicaSet.
- [ ] `config/database.php` contient connexion `mongodb`.
- [ ] `config/broadcasting.php` configuré avec Pusher.
- [ ] `BroadcastServiceProvider` activé dans `config/app.php`.
- [ ] `php artisan config:cache` s'exécute sans erreur.

**Résultat attendu:**  
Configuration complète pour MongoDB Change Streams et broadcasting Pusher. Application prête pour les modèles et commandes.

---

### F3 – Modèle MongoDB `Order`

**Contexte:**  
Le modèle `Order` représente les documents MongoDB dans la collection `orders` et utilise le driver Jenssegers.

**Objectif:**  
Créer le modèle Eloquent MongoDB `Order` avec configuration appropriée.

**Étapes détaillées:**

1. Créer modèle `Order` étendant `Jenssegers\Mongodb\Eloquent\Model`.
2. Configurer connexion, collection, et champs fillable.
3. Tester le modèle avec tinker.

**Commandes PowerShell:**

```powershell
# Créer modèle Order
php artisan make:model Order
```

**Fichiers touchés:**

- `app/Models/Order.php` (créé)

**Contenu `app/Models/Order.php`:**

```php
<?php

namespace App\Models;

use Jenssegers\Mongodb\Eloquent\Model;

class Order extends Model
{
    protected $connection = 'mongodb';
    protected $collection = 'orders';

    protected $fillable = [
        'customerNumber',
        'customerName',
        'phone',
        'city',
        'country',
        'orderNumber',
        'orderDate',
        'status',
        'shippedDate',
    ];

    // Pas de timestamps automatiques car données viennent de NiFi
    public $timestamps = false;

    // Cast pour dates
    protected $casts = [
        'orderDate' => 'datetime',
        'shippedDate' => 'datetime',
    ];
}
```

**Commandes de validation:**

```powershell
# Tester avec tinker
php artisan tinker

# Dans tinker:
# \App\Models\Order::count()
# \App\Models\Order::first()
# \App\Models\Order::latest()->take(5)->get()
# exit
```

**Vérifications:**

- [ ] Modèle `Order` créé dans `app/Models/`.
- [ ] Étend `Jenssegers\Mongodb\Eloquent\Model`.
- [ ] Connexion `mongodb` et collection `orders` configurées.
- [ ] Champs fillable définis.
- [ ] Tinker retourne documents MongoDB (count > 0).

**Résultat attendu:**  
Modèle MongoDB `Order` opérationnel. Capable de lire les documents insérés par NiFi.

---

### F4 – Commande `WatchOrders` (Change Streams) + `Kernel.php`

**Contexte:**  
La commande artisan `WatchOrders` écoute les Change Streams MongoDB et diffuse un événement à chaque nouvel order inséré.

**Objectif:**  
Créer une commande artisan qui écoute les Change Streams et broadcast les nouveaux orders en temps réel.

**Étapes détaillées:**

1. Créer commande artisan `WatchOrders`.
2. Implémenter la logique Change Streams avec `MongoDB\Driver\Manager`.
3. Broadcaster un événement `NewOrder` à chaque insertion.
4. Enregistrer la commande dans `Kernel.php` (optionnel, pour schedule).
5. Tester la commande en standalone.

**Commandes PowerShell:**

```powershell
# Créer commande
php artisan make:command WatchOrders
```

**Fichiers touchés:**

- `app/Console/Commands/WatchOrders.php` (créé)
- `app/Console/Kernel.php` (modifié)

**Contenu `app/Console/Commands/WatchOrders.php`:**

```php
<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Events\NewOrder;
use MongoDB\Driver\Manager;
use MongoDB\Driver\Command;

class WatchOrders extends Command
{
    protected $signature = 'orders:watch';
    protected $description = 'Watch MongoDB Change Streams for new orders and broadcast events';

    public function handle()
    {
        $this->info('Starting MongoDB Change Stream listener...');

        try {
            // Connexion MongoDB ReplicaSet
            $manager = new Manager(env('MONGODB_DSN'));
            $database = env('DB_DATABASE', 'cachesystem');

            // Configuration Change Stream
            $pipeline = [
                ['$match' => ['operationType' => 'insert']]
            ];

            $command = new Command([
                'aggregate' => 'orders',
                'pipeline' => $pipeline,
                'cursor' => ['batchSize' => 1],
            ]);

            $cursor = $manager->executeCommand($database, $command);

            $this->info('Listening for new orders...');

            // Écoute infinie
            foreach ($cursor as $change) {
                if (isset($change->fullDocument)) {
                    $order = (array) $change->fullDocument;
                    
                    $this->info('New order detected: ' . json_encode($order));

                    // Broadcaster l'événement
                    broadcast(new NewOrder($order));

                    $this->info('Event broadcasted successfully');
                }
            }

        } catch (\Exception $e) {
            $this->error('Error: ' . $e->getMessage());
            return 1;
        }

        return 0;
    }
}
```

**Modification `app/Console/Kernel.php` (optionnel):**

```php
protected function schedule(Schedule $schedule)
{
    // Pas de schedule nécessaire, commande manuelle ou via Supervisor
}
```

**Commandes de test:**

```powershell
# Lancer la commande (reste en écoute)
php artisan orders:watch

# Dans un autre terminal, insérer un order via NiFi ou directement MongoDB
docker exec -it mongo1 mongosh

# Dans mongosh:
use cachesystem
db.orders.insertOne({
  customerNumber: 999,
  customerName: "Test Customer",
  orderNumber: 99999,
  orderDate: new Date(),
  status: "Processing"
})
exit

# La commande artisan devrait afficher "New order detected"
```

**Vérifications:**

- [ ] Commande `WatchOrders` créée.
- [ ] Change Stream configuré pour `operationType: insert`.
- [ ] Commande détecte les insertions en temps réel.
- [ ] Événement `NewOrder` broadcasted (voir logs).
- [ ] Commande s'exécute sans erreur.

**Résultat attendu:**  
Commande artisan opérationnelle qui écoute MongoDB Change Streams et broadcast les nouveaux orders.

---

### F5 – Événement `NewOrder` (ShouldBroadcast) + channel `orders`

**Contexte:**  
L'événement `NewOrder` implémente `ShouldBroadcast` pour diffuser les données via WebSockets sur le channel `orders`.

**Objectif:**  
Créer l'événement `NewOrder` avec interface ShouldBroadcast et configuration du channel.

**Étapes détaillées:**

1. Créer événement `NewOrder` avec artisan.
2. Implémenter `ShouldBroadcast`.
3. Définir le channel public `orders`.
4. Passer les données de l'order dans le payload.
5. Tester l'événement manuellement.

**Commandes PowerShell:**

```powershell
# Créer événement
php artisan make:event NewOrder
```

**Fichiers touchés:**

- `app/Events/NewOrder.php` (créé)
- `routes/channels.php` (modifié si nécessaire)

**Contenu `app/Events/NewOrder.php`:**

```php
<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class NewOrder implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $order;

    /**
     * Create a new event instance.
     *
     * @param  array  $order
     * @return void
     */
    public function __construct($order)
    {
        $this->order = $order;
    }

    /**
     * Get the channels the event should broadcast on.
     *
     * @return \Illuminate\Broadcasting\Channel|array
     */
    public function broadcastOn()
    {
        return new Channel('orders');
    }

    /**
     * The event's broadcast name.
     *
     * @return string
     */
    public function broadcastAs()
    {
        return 'new.order';
    }

    /**
     * Get the data to broadcast.
     *
     * @return array
     */
    public function broadcastWith()
    {
        return [
            'customerNumber' => $this->order['customerNumber'] ?? null,
            'customerName' => $this->order['customerName'] ?? null,
            'orderNumber' => $this->order['orderNumber'] ?? null,
            'orderDate' => $this->order['orderDate'] ?? null,
            'status' => $this->order['status'] ?? null,
        ];
    }
}
```

**Modification `routes/channels.php` (si channel privé nécessaire):**

```php
<?php

use Illuminate\Support\Facades\Broadcast;

// Channel public, pas d'authentification nécessaire
Broadcast::channel('orders', function ($user) {
    return true;
});
```

**Vérifications:**

- [ ] Événement `NewOrder` créé.
- [ ] Implémente `ShouldBroadcast`.
- [ ] Channel `orders` défini.
- [ ] Méthode `broadcastWith()` retourne payload correct.
- [ ] Méthode `broadcastAs()` retourne `new.order`.

**Résultat attendu:**  
Événement `NewOrder` prêt à broadcaster les données via WebSockets sur le channel `orders`.

---

### F6 – Assets Echo + Vue `monitor.blade.php`

**Contexte:**  
La vue frontend doit écouter le channel `orders` via Laravel Echo et afficher les nouveaux orders en temps réel dans une table HTML.

**Objectif:**  
Créer la vue Blade avec intégration Laravel Echo, écoute du channel, et mise à jour dynamique de l'interface.

**Étapes détaillées:**

1. Compiler les assets avec Laravel Mix/Vite.
2. Créer vue `monitor.blade.php` avec layout.
3. Configurer Laravel Echo dans `resources/js/bootstrap.js`.
4. Écouter le channel `orders` et événement `new.order`.
5. Afficher les nouveaux orders dans une table HTML.
6. Ajouter route pour la vue.

**Commandes PowerShell:**

```powershell
# Compiler assets
npm run dev

# (ou en mode watch)
npm run watch
```

**Fichiers touchés:**

- `resources/js/bootstrap.js` (modifié)
- `resources/views/monitor.blade.php` (créé)
- `routes/web.php` (modifié)

**Modification `resources/js/bootstrap.js`:**

```javascript
import Echo from 'laravel-echo';
import Pusher from 'pusher-js';

window.Pusher = Pusher;

window.Echo = new Echo({
    broadcaster: 'pusher',
    key: import.meta.env.VITE_PUSHER_APP_KEY || 'local-app-key',
    wsHost: window.location.hostname,
    wsPort: 6001,
    forceTLS: false,
    disableStats: true,
    enabledTransports: ['ws', 'wss'],
});
```

**Contenu `resources/views/monitor.blade.php`:**

```blade
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Real-Time Orders Monitor</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body>
    <div class="container mt-5">
        <h1>Real-Time Orders Monitor</h1>
        <p class="text-muted">Listening for new orders from MongoDB Change Streams...</p>

        <div id="status" class="alert alert-info">
            <strong>Status:</strong> <span id="connection-status">Connecting...</span>
        </div>

        <table class="table table-striped" id="orders-table">
            <thead>
                <tr>
                    <th>Order Number</th>
                    <th>Customer Number</th>
                    <th>Customer Name</th>
                    <th>Order Date</th>
                    <th>Status</th>
                    <th>Received At</th>
                </tr>
            </thead>
            <tbody id="orders-body">
                <!-- Les nouveaux orders seront ajoutés ici -->
            </tbody>
        </table>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const ordersBody = document.getElementById('orders-body');
            const connectionStatus = document.getElementById('connection-status');

            // Écouter le channel 'orders'
            window.Echo.channel('orders')
                .listen('.new.order', (data) => {
                    console.log('New order received:', data);

                    // Mettre à jour le statut
                    connectionStatus.textContent = 'Connected';
                    connectionStatus.parentElement.classList.remove('alert-info');
                    connectionStatus.parentElement.classList.add('alert-success');

                    // Créer une nouvelle ligne
                    const row = document.createElement('tr');
                    row.classList.add('table-success');
                    
                    row.innerHTML = `
                        <td>${data.orderNumber || 'N/A'}</td>
                        <td>${data.customerNumber || 'N/A'}</td>
                        <td>${data.customerName || 'N/A'}</td>
                        <td>${data.orderDate || 'N/A'}</td>
                        <td><span class="badge bg-primary">${data.status || 'N/A'}</span></td>
                        <td>${new Date().toLocaleString()}</td>
                    `;

                    // Ajouter en haut du tableau
                    ordersBody.insertBefore(row, ordersBody.firstChild);

                    // Animation fade-in
                    setTimeout(() => {
                        row.classList.remove('table-success');
                    }, 3000);
                });

            // Gérer les erreurs de connexion
            window.Echo.connector.pusher.connection.bind('error', function(err) {
                console.error('WebSocket error:', err);
                connectionStatus.textContent = 'Connection Error';
                connectionStatus.parentElement.classList.remove('alert-success');
                connectionStatus.parentElement.classList.add('alert-danger');
            });

            // Confirmer la connexion
            window.Echo.connector.pusher.connection.bind('connected', function() {
                console.log('WebSocket connected');
                connectionStatus.textContent = 'Connected (waiting for events)';
                connectionStatus.parentElement.classList.remove('alert-info');
                connectionStatus.parentElement.classList.add('alert-success');
            });
        });
    </script>
</body>
</html>
```

**Modification `routes/web.php`:**

```php
Route::get('/monitor', function () {
    return view('monitor');
})->name('monitor');
```

**Vérifications:**

- [ ] Laravel Echo configuré dans `bootstrap.js`.
- [ ] Vue `monitor.blade.php` créée avec interface Bootstrap.
- [ ] Channel `orders` écouté via `Echo.channel('orders')`.
- [ ] Événement `.new.order` capturé.
- [ ] Nouveaux orders affichés dynamiquement dans la table.
- [ ] Assets compilés (`npm run dev` sans erreur).
- [ ] Route `/monitor` accessible.

**Résultat attendu:**  
Interface web temps réel opérationnelle. Affiche instantanément les nouveaux orders reçus via WebSockets.

---

### F7 – Tests temps réel (insert Mongo → broadcast → UI)

**Contexte:**  
Valider le flux complet: insertion MongoDB → Change Stream → Broadcast → Echo → UI.

**Objectif:**  
Effectuer des tests end-to-end pour confirmer que les nouveaux orders apparaissent en temps réel dans l'interface.

**Étapes détaillées:**

1. Démarrer le serveur Laravel Monitoring.
2. Démarrer Laravel WebSockets (ou utiliser Pusher cloud).
3. Lancer la commande `orders:watch`.
4. Ouvrir la vue `/monitor` dans le navigateur.
5. Insérer un order dans MongoDB (via NiFi ou directement).
6. Vérifier que l'order apparaît instantanément dans l'UI.

**Commandes PowerShell:**

```powershell
# Terminal 1: Démarrer serveur Laravel
cd c:\Users\Lenovo\Desktop\Projet\Projet\monitoring-app
php artisan serve --port=8001

# Terminal 2: Démarrer Laravel WebSockets (si utilisé)
composer require beyondcode/laravel-websockets
php artisan websockets:serve

# Terminal 3: Lancer commande Watch
php artisan orders:watch

# Terminal 4: Insérer un order de test
docker exec -it mongo1 mongosh

# Dans mongosh:
use cachesystem
db.orders.insertOne({
  customerNumber: 888,
  customerName: "Real-Time Test",
  orderNumber: 88888,
  orderDate: new Date(),
  status: "Shipped"
})
exit

# Ouvrir navigateur: http://localhost:8001/monitor
# L'order devrait apparaître instantanément dans la table
```

**Fichiers touchés:**  
Aucun. Tests runtime.

**Vérifications:**

- [ ] Serveur Laravel accessible sur <http://localhost:8001>.
- [ ] WebSockets serveur en cours d'exécution (port 6001).
- [ ] Commande `orders:watch` en écoute active.
- [ ] Vue `/monitor` affiche "Connected".
- [ ] Insertion MongoDB détectée par Change Stream.
- [ ] Événement `NewOrder` broadcasted (voir logs).
- [ ] Order apparaît instantanément dans l'interface web.
- [ ] Console navigateur affiche "New order received".
- [ ] Aucune erreur dans logs Laravel, WebSockets, ou console navigateur.

**Résultat attendu:**  
Flux temps réel complet opérationnel. Les insertions MongoDB sont instantanément visibles dans l'interface web via WebSockets.

---

**Fin Phase F**

Les prompts F1 à F7 sont désormais définis. L'agent peut créer l'application Laravel Monitoring avec Change Streams MongoDB et broadcasting temps réel. Prêt pour la Phase G (Application Laravel Search Redis).

---

## 9) Prompts Détaillés – Phase G (Application Laravel Search - Redis)

### G1 – Projet Laravel + `predis/predis`

**Contexte:**  
L'application Search permet de rechercher des orders par customerNumber directement depuis Redis (cache rapide). Elle utilise le package Predis pour la connexion Redis.

**Objectif:**  
Créer un nouveau projet Laravel pour la recherche, installer Predis, et configurer la connexion Redis.

**Étapes détaillées:**

1. Créer projet Laravel `search-app`.
2. Installer package `predis/predis`.
3. Configurer `.env` avec paramètres Redis.
4. Tester la connexion Redis avec tinker.

**Commandes PowerShell:**

```powershell
# Se placer à la racine du projet
cd c:\Users\Lenovo\Desktop\Projet\Projet

# Créer projet Laravel
composer create-project --prefer-dist laravel/laravel:^9.0 search-app

# Se placer dans le projet
cd search-app

# Installer Predis
composer require predis/predis:^2.0

# Configurer .env
@"
APP_NAME=SearchApp
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost:8002

LOG_CHANNEL=stack

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379
REDIS_DB=0

CACHE_DRIVER=redis
SESSION_DRIVER=redis
"@ | Out-File -FilePath .env -Encoding utf8

# Générer clé application
php artisan key:generate
```

**Fichiers touchés:**

- `search-app/` (nouveau projet Laravel)
- `search-app/.env` (configuré)
- `search-app/composer.json` (dépendances)

**Commandes de validation:**

```powershell
# Tester connexion Redis avec tinker
php artisan tinker

# Dans tinker:
# use Illuminate\Support\Facades\Redis;
# Redis::set('test', 'hello')
# Redis::get('test')
# Redis::keys('*')
# exit
```

**Vérifications:**

- [ ] Projet `search-app` créé.
- [ ] Package `predis/predis` installé (visible dans `composer.json`).
- [ ] `.env` configuré avec paramètres Redis.
- [ ] `php artisan key:generate` s'exécute sans erreur.
- [ ] Tinker se connecte à Redis avec succès.
- [ ] `Redis::keys('*')` retourne les clés existantes.

**Résultat attendu:**  
Projet Laravel Search créé avec connexion Redis opérationnelle via Predis.

---

### G2 – Config `.env`, `database.php`, facade Redis

**Contexte:**  
Configuration de la connexion Redis dans `database.php` et activation de la facade Redis pour accès simplifié.

**Objectif:**  
Configurer complètement Redis dans Laravel pour utiliser la facade et le cache Redis.

**Étapes détaillées:**

1. Vérifier configuration Redis dans `config/database.php`.
2. Configurer cache driver Redis dans `config/cache.php`.
3. Tester la facade Redis dans un contrôleur.
4. Valider la configuration.

**Fichiers touchés:**

- `config/database.php` (vérifier/modifier)
- `config/cache.php` (vérifier/modifier)

**Vérification `config/database.php`:**

```php
'redis' => [
    'client' => env('REDIS_CLIENT', 'predis'),

    'options' => [
        'cluster' => env('REDIS_CLUSTER', 'redis'),
        'prefix' => env('REDIS_PREFIX', Str::slug(env('APP_NAME', 'laravel'), '_').'_database_'),
    ],

    'default' => [
        'url' => env('REDIS_URL'),
        'host' => env('REDIS_HOST', '127.0.0.1'),
        'password' => env('REDIS_PASSWORD', null),
        'port' => env('REDIS_PORT', '6379'),
        'database' => env('REDIS_DB', '0'),
    ],

    'cache' => [
        'url' => env('REDIS_URL'),
        'host' => env('REDIS_HOST', '127.0.0.1'),
        'password' => env('REDIS_PASSWORD', null),
        'port' => env('REDIS_PORT', '6379'),
        'database' => env('REDIS_CACHE_DB', '1'),
    ],
],
```

**Vérification `config/cache.php`:**

```php
'default' => env('CACHE_DRIVER', 'redis'),

'stores' => [
    'redis' => [
        'driver' => 'redis',
        'connection' => 'cache',
        'lock_connection' => 'default',
    ],
],
```

**Commandes PowerShell:**

```powershell
# Tester facade Redis
php artisan tinker

# Dans tinker:
# use Illuminate\Support\Facades\Redis;
# Redis::set('app:test', 'SearchApp')
# Redis::get('app:test')
# Redis::ttl('app:test')
# exit

# Tester cache
php artisan tinker

# Dans tinker:
# use Illuminate\Support\Facades\Cache;
# Cache::put('test-cache', 'value', 60)
# Cache::get('test-cache')
# exit
```

**Vérifications:**

- [ ] `config/database.php` contient configuration Redis complète.
- [ ] `config/cache.php` utilise driver `redis`.
- [ ] `.env` contient `REDIS_CLIENT=predis`.
- [ ] Facade `Redis::` fonctionne dans tinker.
- [ ] Facade `Cache::` fonctionne avec Redis.
- [ ] Aucune erreur de connexion.

**Résultat attendu:**  
Configuration Redis complète avec facade Laravel opérationnelle. Prêt pour le contrôleur de recherche.

---

### G3 – `SearchController` + route

**Contexte:**  
Le contrôleur `SearchController` gère la recherche d'orders par customerNumber dans Redis et affiche les résultats.

**Objectif:**  
Créer le contrôleur avec méthode de recherche et définir les routes correspondantes.

**Étapes détaillées:**

1. Créer contrôleur `SearchController`.
2. Implémenter méthode `search()` qui lit Redis.
3. Gérer les cas: clé trouvée, clé non trouvée, erreur.
4. Définir routes GET pour affichage formulaire et résultats.
5. Retourner JSON ou vue Blade selon besoin.

**Commandes PowerShell:**

```powershell
# Créer contrôleur
php artisan make:controller SearchController
```

**Fichiers touchés:**

- `app/Http/Controllers/SearchController.php` (créé)
- `routes/web.php` (modifié)

**Contenu `app/Http/Controllers/SearchController.php`:**

```php
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Redis;
use Illuminate\Support\Facades\Log;

class SearchController extends Controller
{
    /**
     * Afficher le formulaire de recherche
     */
    public function index()
    {
        return view('search');
    }

    /**
     * Effectuer la recherche dans Redis
     */
    public function search(Request $request)
    {
        $request->validate([
            'customerNumber' => 'required|integer',
        ]);

        $customerNumber = $request->input('customerNumber');

        try {
            // Rechercher dans Redis
            $data = Redis::get($customerNumber);

            if ($data === null) {
                return back()->with('error', "Customer #{$customerNumber} not found in cache.");
            }

            // Décoder JSON
            $orderData = json_decode($data, true);

            if (!$orderData) {
                Log::error("Invalid JSON in Redis for key: {$customerNumber}");
                return back()->with('error', "Invalid data format for Customer #{$customerNumber}.");
            }

            Log::info("Cache hit for customerNumber: {$customerNumber}");

            return view('search', [
                'customerNumber' => $customerNumber,
                'orderData' => $orderData,
            ]);

        } catch (\Exception $e) {
            Log::error("Redis search error: " . $e->getMessage());
            return back()->with('error', 'Search failed. Please try again.');
        }
    }

    /**
     * API endpoint pour recherche JSON
     */
    public function apiSearch(Request $request)
    {
        $request->validate([
            'customerNumber' => 'required|integer',
        ]);

        $customerNumber = $request->input('customerNumber');

        try {
            $data = Redis::get($customerNumber);

            if ($data === null) {
                return response()->json([
                    'success' => false,
                    'message' => 'Customer not found in cache',
                ], 404);
            }

            $orderData = json_decode($data, true);

            return response()->json([
                'success' => true,
                'data' => $orderData,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Search failed',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}
```

**Modification `routes/web.php`:**

```php
<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\SearchController;

Route::get('/', [SearchController::class, 'index'])->name('search.index');
Route::post('/search', [SearchController::class, 'search'])->name('search.submit');

// API endpoint
Route::get('/api/search', [SearchController::class, 'apiSearch'])->name('api.search');
```

**Vérifications:**

- [ ] Contrôleur `SearchController` créé.
- [ ] Méthode `index()` retourne vue formulaire.
- [ ] Méthode `search()` lit Redis et retourne résultats.
- [ ] Méthode `apiSearch()` retourne JSON.
- [ ] Routes définies dans `web.php`.
- [ ] Validation du champ `customerNumber`.
- [ ] Gestion des erreurs (clé non trouvée, Redis down).

**Résultat attendu:**  
Contrôleur de recherche opérationnel avec gestion complète des cas et API JSON.

---

### G4 – Vue `search.blade.php` (form + résultats)

**Contexte:**  
La vue Blade affiche un formulaire de recherche et les résultats provenant de Redis en format lisible.

**Objectif:**  
Créer une interface utilisateur pour la recherche avec affichage des résultats sous forme de table ou cards.

**Étapes détaillées:**

1. Créer vue `resources/views/search.blade.php`.
2. Ajouter formulaire de recherche (input customerNumber).
3. Afficher résultats si présents.
4. Gérer messages d'erreur et succès.
5. Styliser avec Bootstrap.

**Commandes PowerShell:**

```powershell
# Créer fichier vue
New-Item -ItemType File -Path resources\views\search.blade.php -Force
```

**Fichiers touchés:**

- `resources/views/search.blade.php` (créé)

**Contenu `resources/views/search.blade.php`:**

```blade
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Redis Cache Search</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .search-container {
            max-width: 800px;
            margin: 50px auto;
        }
        .result-card {
            margin-top: 30px;
            animation: fadeIn 0.5s;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }
    </style>
</head>
<body>
    <div class="container search-container">
        <h1 class="text-center mb-4">🔍 Redis Cache Search</h1>
        <p class="text-center text-muted">Search for customer orders cached in Redis</p>

        {{-- Messages flash --}}
        @if(session('error'))
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                {{ session('error') }}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        @endif

        @if(session('success'))
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                {{ session('success') }}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        @endif

        {{-- Formulaire de recherche --}}
        <div class="card">
            <div class="card-body">
                <form method="POST" action="{{ route('search.submit') }}">
                    @csrf
                    <div class="mb-3">
                        <label for="customerNumber" class="form-label">Customer Number</label>
                        <input 
                            type="number" 
                            class="form-control @error('customerNumber') is-invalid @enderror" 
                            id="customerNumber" 
                            name="customerNumber" 
                            placeholder="Enter customer number (e.g., 103)"
                            value="{{ old('customerNumber', $customerNumber ?? '') }}"
                            required
                            autofocus
                        >
                        @error('customerNumber')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                    <button type="submit" class="btn btn-primary w-100">
                        <i class="bi bi-search"></i> Search Redis Cache
                    </button>
                </form>
            </div>
        </div>

        {{-- Résultats --}}
        @isset($orderData)
            <div class="card result-card">
                <div class="card-header bg-success text-white">
                    <h5 class="mb-0">✅ Cache Hit - Customer #{{ $customerNumber }}</h5>
                </div>
                <div class="card-body">
                    <h6 class="card-subtitle mb-3 text-muted">Order Details from Redis</h6>

                    <table class="table table-bordered">
                        <tbody>
                            <tr>
                                <th width="200">Customer Number</th>
                                <td>{{ $orderData['customerNumber'] ?? 'N/A' }}</td>
                            </tr>
                            <tr>
                                <th>Customer Name</th>
                                <td>{{ $orderData['customerName'] ?? 'N/A' }}</td>
                            </tr>
                            <tr>
                                <th>Phone</th>
                                <td>{{ $orderData['phone'] ?? 'N/A' }}</td>
                            </tr>
                            <tr>
                                <th>City</th>
                                <td>{{ $orderData['city'] ?? 'N/A' }}</td>
                            </tr>
                            <tr>
                                <th>Country</th>
                                <td>{{ $orderData['country'] ?? 'N/A' }}</td>
                            </tr>
                            <tr>
                                <th>Order Number</th>
                                <td><span class="badge bg-info">{{ $orderData['orderNumber'] ?? 'N/A' }}</span></td>
                            </tr>
                            <tr>
                                <th>Order Date</th>
                                <td>{{ $orderData['orderDate'] ?? 'N/A' }}</td>
                            </tr>
                            <tr>
                                <th>Status</th>
                                <td><span class="badge bg-primary">{{ $orderData['status'] ?? 'N/A' }}</span></td>
                            </tr>
                        </tbody>
                    </table>

                    <div class="alert alert-info mt-3">
                        <strong>ℹ️ Cache Info:</strong> This data was retrieved directly from Redis cache for ultra-fast access.
                    </div>
                </div>
            </div>
        @endisset
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
```

**Vérifications:**

- [ ] Vue `search.blade.php` créée.
- [ ] Formulaire de recherche avec input `customerNumber`.
- [ ] Messages flash (error/success) affichés.
- [ ] Résultats affichés dans table Bootstrap si trouvés.
- [ ] Style responsive avec animations.
- [ ] Validation errors affichés correctement.

**Résultat attendu:**  
Interface de recherche complète et stylée. Affichage clair des résultats Redis avec gestion des messages.

---

### G5 – (Optionnel) Echo pour mise à jour en temps réel

**Contexte:**  
Pour améliorer l'expérience utilisateur, on peut ajouter Laravel Echo pour notifier automatiquement quand de nouvelles données sont disponibles dans le cache.

**Objectif:**  
Intégrer Laravel Echo pour écouter un channel et rafraîchir automatiquement les résultats de recherche.

**Étapes détaillées:**

1. Installer Laravel Echo et Pusher.js (si pas déjà fait).
2. Créer un événement `CacheUpdated`.
3. Broadcaster l'événement lors de mises à jour Redis.
4. Écouter le channel dans la vue search.blade.php.
5. Afficher notification ou rafraîchir résultats automatiquement.

**Commandes PowerShell:**

```powershell
# Installer dépendances (si nécessaire)
npm install --save-dev laravel-echo pusher-js

# Créer événement
php artisan make:event CacheUpdated
```

**Fichiers touchés:**

- `app/Events/CacheUpdated.php` (créé)
- `resources/views/search.blade.php` (modifié)
- `resources/js/bootstrap.js` (modifié si nécessaire)

**Contenu `app/Events/CacheUpdated.php`:**

```php
<?php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class CacheUpdated implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $customerNumber;

    public function __construct($customerNumber)
    {
        $this->customerNumber = $customerNumber;
    }

    public function broadcastOn()
    {
        return new Channel('cache-updates');
    }

    public function broadcastAs()
    {
        return 'cache.updated';
    }
}
```

**Modification `resources/views/search.blade.php` (ajouter section Echo):**

```blade
<script src="{{ asset('js/app.js') }}"></script>
<script>
    // Écouter les mises à jour de cache
    window.Echo.channel('cache-updates')
        .listen('.cache.updated', (data) => {
            console.log('Cache updated for customer:', data.customerNumber);
            
            // Afficher notification
            const toast = document.createElement('div');
            toast.className = 'alert alert-info alert-dismissible fade show position-fixed top-0 end-0 m-3';
            toast.innerHTML = `
                Cache updated for customer #${data.customerNumber}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            `;
            document.body.appendChild(toast);

            // Auto-dismiss après 5 secondes
            setTimeout(() => toast.remove(), 5000);
        });
</script>
```

**Note:** Cette fonctionnalité est optionnelle et nécessite un serveur WebSockets actif.

**Vérifications:**

- [ ] Événement `CacheUpdated` créé (optionnel).
- [ ] Broadcasting configuré (optionnel).
- [ ] Echo écoute channel `cache-updates` (optionnel).
- [ ] Notifications affichées lors de mises à jour (optionnel).

**Résultat attendu:**  
Fonctionnalité optionnelle de notifications temps réel pour mises à jour cache Redis.

---

### G6 – Tests (GET Redis par `customerNumber`)

**Contexte:**  
Valider le fonctionnement complet de l'application de recherche avec tests manuels et automatisés.

**Objectif:**  
Effectuer des tests end-to-end pour confirmer que la recherche Redis fonctionne correctement.

**Étapes détaillées:**

1. Démarrer le serveur Laravel Search.
2. S'assurer que Redis contient des clés (via NiFi ou insertion manuelle).
3. Tester recherche avec customerNumber existant.
4. Tester recherche avec customerNumber inexistant.
5. Tester API endpoint JSON.
6. Vérifier logs Laravel pour cache hits/misses.

**Commandes PowerShell:**

```powershell
# Terminal 1: Démarrer serveur Laravel
cd c:\Users\Lenovo\Desktop\Projet\Projet\search-app
php artisan serve --port=8002

# Terminal 2: Vérifier clés Redis
docker exec -it redis redis-cli KEYS "*"

# Si aucune clé, ajouter une clé de test
docker exec -it redis redis-cli SET 103 '{"customerNumber":103,"customerName":"Atelier graphique","phone":"40.32.2555","city":"Nantes","country":"France","orderNumber":10123,"orderDate":"2023-01-15","status":"Shipped"}'

# Tester via navigateur
# Ouvrir: http://localhost:8002
# Entrer customerNumber: 103
# Vérifier affichage résultats

# Tester API
curl http://localhost:8002/api/search?customerNumber=103

# Tester customerNumber inexistant
# Entrer: 99999
# Vérifier message "not found in cache"
```

**Tests automatisés (optionnel):**

```powershell
# Créer test
php artisan make:test SearchTest

# Contenu test (exemple)
```

**Contenu `tests/Feature/SearchTest.php` (optionnel):**

```php
<?php

namespace Tests\Feature;

use Tests\TestCase;
use Illuminate\Support\Facades\Redis;

class SearchTest extends TestCase
{
    public function test_search_page_loads()
    {
        $response = $this->get('/');
        $response->assertStatus(200);
        $response->assertSee('Redis Cache Search');
    }

    public function test_search_finds_existing_customer()
    {
        // Setup: ajouter clé test dans Redis
        Redis::set('999', json_encode([
            'customerNumber' => 999,
            'customerName' => 'Test Customer',
        ]));

        $response = $this->post('/search', ['customerNumber' => 999]);
        $response->assertStatus(200);
        $response->assertSee('Test Customer');

        // Cleanup
        Redis::del('999');
    }

    public function test_search_handles_missing_customer()
    {
        $response = $this->post('/search', ['customerNumber' => 88888]);
        $response->assertStatus(302); // Redirect back
        $response->assertSessionHas('error');
    }
}
```

**Commandes de test:**

```powershell
# Exécuter tests
php artisan test --filter SearchTest
```

**Vérifications:**

- [ ] Serveur Laravel accessible sur <http://localhost:8002>.
- [ ] Redis contient au moins une clé test.
- [ ] Recherche avec customerNumber existant affiche résultats.
- [ ] Recherche avec customerNumber inexistant affiche erreur.
- [ ] API endpoint `/api/search` retourne JSON correct.
- [ ] Logs Laravel montrent "Cache hit" pour clés trouvées.
- [ ] Tests automatisés réussissent (si implémentés).

**Résultat attendu:**  
Application de recherche Redis complètement fonctionnelle. Recherche rapide avec gestion complète des cas (trouvé/non trouvé/erreur).

---

**Fin Phase G**

Les prompts G1 à G6 sont désormais définis. L'agent peut créer l'application Laravel Search avec recherche Redis ultra-rapide. Prêt pour la Phase H (Qualité, Sécurité, CI/CD, Déploiement).

---

## 10) Prompts Détaillés – Phase H (Qualité, Sécurité, CI/CD, Déploiement)

### H1 – Tests unitaires & intégration

**Contexte:**  
Pour garantir la qualité du code et la stabilité du système, il faut implémenter des tests unitaires et d'intégration pour chaque application Laravel.

**Objectif:**  
Créer une suite de tests complète couvrant les modèles, contrôleurs, événements, et intégrations (Redis, MongoDB, Kafka).

**Étapes détaillées:**

1. Configurer PHPUnit dans chaque application Laravel.
2. Créer tests unitaires pour modèles (Customer, Order).
3. Créer tests de feature pour contrôleurs CRUD.
4. Tester intégrations Redis et MongoDB.
5. Créer tests pour événements et broadcasting.
6. Mesurer la couverture de code.
7. Configurer CI pour exécution automatique des tests.

**Commandes PowerShell:**

```powershell
# Pour chaque application Laravel (employees-app, monitoring-app, search-app)

# Application Employees
cd c:\Users\Lenovo\Desktop\Projet\Projet\employees-app

# Créer tests
php artisan make:test CustomerControllerTest
php artisan make:test OrderControllerTest
php artisan make:test KafkaProducerTest

# Exécuter tests
php artisan test

# Avec couverture (nécessite Xdebug)
php artisan test --coverage

# Application Monitoring
cd ..\monitoring-app
php artisan make:test OrderModelTest
php artisan make:test WatchOrdersCommandTest
php artisan make:test NewOrderEventTest
php artisan test

# Application Search
cd ..\search-app
php artisan make:test SearchControllerTest
php artisan make:test RedisIntegrationTest
php artisan test
```

**Fichiers touchés:**

- `employees-app/tests/Feature/CustomerControllerTest.php` (créé)
- `employees-app/tests/Feature/OrderControllerTest.php` (créé)
- `employees-app/tests/Unit/KafkaProducerTest.php` (créé)
- `monitoring-app/tests/Feature/OrderModelTest.php` (créé)
- `monitoring-app/tests/Feature/WatchOrdersCommandTest.php` (créé)
- `monitoring-app/tests/Unit/NewOrderEventTest.php` (créé)
- `search-app/tests/Feature/SearchControllerTest.php` (créé)
- `search-app/tests/Unit/RedisIntegrationTest.php` (créé)

**Exemple `employees-app/tests/Feature/CustomerControllerTest.php`:**

```php
<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\Customer;
use Illuminate\Foundation\Testing\RefreshDatabase;

class CustomerControllerTest extends TestCase
{
    use RefreshDatabase;

    public function test_customer_index_page_loads()
    {
        $response = $this->get(route('customers.index'));
        $response->assertStatus(200);
        $response->assertViewIs('customers.index');
    }

    public function test_can_create_customer()
    {
        $customerData = [
            'customerName' => 'Test Customer',
            'phone' => '123456789',
            'city' => 'Test City',
            'country' => 'Test Country',
        ];

        $response = $this->post(route('customers.store'), $customerData);
        $response->assertRedirect(route('customers.index'));
        $this->assertDatabaseHas('customers', ['customerName' => 'Test Customer']);
    }

    public function test_can_update_customer()
    {
        $customer = Customer::factory()->create();

        $updateData = [
            'customerName' => 'Updated Name',
            'phone' => '987654321',
            'city' => 'Updated City',
            'country' => 'Updated Country',
        ];

        $response = $this->put(route('customers.update', $customer), $updateData);
        $response->assertRedirect(route('customers.index'));
        $this->assertDatabaseHas('customers', ['customerName' => 'Updated Name']);
    }

    public function test_can_delete_customer()
    {
        $customer = Customer::factory()->create();

        $response = $this->delete(route('customers.destroy', $customer));
        $response->assertRedirect(route('customers.index'));
        $this->assertDatabaseMissing('customers', ['customerNumber' => $customer->customerNumber]);
    }
}
```

**Exemple `search-app/tests/Unit/RedisIntegrationTest.php`:**

```php
<?php

namespace Tests\Unit;

use Tests\TestCase;
use Illuminate\Support\Facades\Redis;

class RedisIntegrationTest extends TestCase
{
    public function test_redis_connection()
    {
        $this->assertTrue(Redis::connection()->ping());
    }

    public function test_can_set_and_get_value()
    {
        Redis::set('test-key', 'test-value');
        $value = Redis::get('test-key');
        
        $this->assertEquals('test-value', $value);
        
        Redis::del('test-key');
    }

    public function test_can_store_json_data()
    {
        $data = ['customerNumber' => 123, 'orderNumber' => 456];
        Redis::set('test-json', json_encode($data));
        
        $retrieved = json_decode(Redis::get('test-json'), true);
        $this->assertEquals(123, $retrieved['customerNumber']);
        
        Redis::del('test-json');
    }
}
```

**Vérifications:**

- [ ] Tests créés pour chaque application Laravel.
- [ ] Tests unitaires couvrent modèles et services.
- [ ] Tests de feature couvrent contrôleurs et routes.
- [ ] Tests d'intégration valident Redis, MongoDB, Kafka.
- [ ] `php artisan test` réussit dans chaque app (0 failures).
- [ ] Couverture de code > 70% (si mesurée).
- [ ] Tests exécutables en CI/CD.

**Résultat attendu:**  
Suite de tests complète et fonctionnelle. Qualité du code validée automatiquement.

---

### H2 – Observabilité (logs, métriques)

**Contexte:**  
Pour monitorer le système en production, il faut implémenter des logs structurés, métriques, et dashboards.

**Objectif:**  
Configurer logging centralisé, métriques de performance, et outils d'observabilité.

**Étapes détaillées:**

1. Configurer Laravel logging avec channels séparés.
2. Implémenter logs structurés (JSON format).
3. Ajouter métriques de performance (temps de réponse, cache hits).
4. Configurer logs Docker (stdout/stderr).
5. (Optionnel) Intégrer ELK Stack ou Grafana.
6. Créer dashboard de monitoring.
7. Configurer alertes pour erreurs critiques.

**Commandes PowerShell:**

```powershell
# Configuration logging pour chaque app Laravel
# Modifier config/logging.php

# Créer channel JSON pour logs structurés
# Ajouter dans config/logging.php:
```

**Fichiers touchés:**

- `employees-app/config/logging.php` (modifié)
- `monitoring-app/config/logging.php` (modifié)
- `search-app/config/logging.php` (modifié)
- `.env` (ajout variables logging)

**Modification `config/logging.php` (exemple):**

```php
'channels' => [
    'stack' => [
        'driver' => 'stack',
        'channels' => ['daily', 'json'],
        'ignore_exceptions' => false,
    ],

    'json' => [
        'driver' => 'daily',
        'path' => storage_path('logs/laravel.log'),
        'level' => env('LOG_LEVEL', 'debug'),
        'days' => 14,
        'formatter' => \Monolog\Formatter\JsonFormatter::class,
    ],

    'performance' => [
        'driver' => 'daily',
        'path' => storage_path('logs/performance.log'),
        'level' => 'info',
        'days' => 7,
    ],
],
```

**Ajout middleware de performance:**

```php
<?php
// app/Http/Middleware/LogPerformance.php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Support\Facades\Log;

class LogPerformance
{
    public function handle($request, Closure $next)
    {
        $start = microtime(true);
        
        $response = $next($request);
        
        $duration = microtime(true) - $start;
        
        Log::channel('performance')->info('Request processed', [
            'method' => $request->method(),
            'uri' => $request->path(),
            'duration' => round($duration * 1000, 2) . 'ms',
            'status' => $response->status(),
            'memory' => round(memory_get_peak_usage() / 1024 / 1024, 2) . 'MB',
        ]);
        
        return $response;
    }
}
```

**Configuration Docker logs:**

```powershell
# Consulter logs en temps réel
docker logs -f broker
docker logs -f nifi
docker logs -f mongo1
docker logs -f redis

# Exporter logs vers fichier
docker logs broker > logs/kafka-broker.log 2>&1
docker logs nifi > logs/nifi.log 2>&1
```

**Métriques Redis (exemple):**

```php
// Dans SearchController
use Illuminate\Support\Facades\Cache;

public function search(Request $request)
{
    $customerNumber = $request->input('customerNumber');
    $start = microtime(true);
    
    $data = Redis::get($customerNumber);
    $duration = microtime(true) - $start;
    
    // Logger métriques
    Log::channel('performance')->info('Redis lookup', [
        'key' => $customerNumber,
        'hit' => $data !== null,
        'duration_ms' => round($duration * 1000, 2),
    ]);
    
    // Incrémenter compteurs
    if ($data !== null) {
        Cache::increment('metrics:redis:hits');
    } else {
        Cache::increment('metrics:redis:misses');
    }
    
    // ...
}
```

**Dashboard métriques (optionnel):**

```powershell
# Créer route pour dashboard
# routes/web.php
Route::get('/metrics', function() {
    return response()->json([
        'redis_hits' => Cache::get('metrics:redis:hits', 0),
        'redis_misses' => Cache::get('metrics:redis:misses', 0),
        'uptime' => exec('uptime'),
    ]);
});
```

**Vérifications:**

- [ ] Logs structurés configurés (JSON format).
- [ ] Channel `performance` créé pour métriques.
- [ ] Middleware de logging actif.
- [ ] Logs Docker accessibles via `docker logs`.
- [ ] Métriques collectées (cache hits, temps réponse).
- [ ] Dashboard métriques accessible (optionnel).
- [ ] Alertes configurées pour erreurs critiques (optionnel).

**Résultat attendu:**  
Système d'observabilité complet. Logs centralisés, métriques de performance, et monitoring actif.

---

### H3 – Sécurité (HTTPS NiFi, secrets, permissions DB)

**Contexte:**  
Sécuriser l'ensemble du système: chiffrement des communications, gestion des secrets, permissions databases, et hardening.

**Objectif:**  
Implémenter les meilleures pratiques de sécurité pour production.

**Étapes détaillées:**

1. Vérifier que NiFi utilise HTTPS (déjà configuré port 9443).
2. Sécuriser les secrets (`.env`, variables d'environnement).
3. Configurer permissions minimales pour users MySQL/MongoDB.
4. Activer authentification Redis (optionnel).
5. Implémenter CORS pour APIs.
6. Ajouter rate limiting sur endpoints publics.
7. Configurer HTTPS pour Laravel apps (production).

**Commandes PowerShell:**

```powershell
# Vérifier HTTPS NiFi
Start-Process "https://localhost:9443/nifi"

# Créer user MySQL avec permissions limitées
docker exec -it mysql mysql -uroot -p'Bgj5WL#F8Ztaz'

# Dans MySQL:
# CREATE USER 'laravel_reader'@'%' IDENTIFIED BY 'secure_password';
# GRANT SELECT ON cachesystem.* TO 'laravel_reader'@'%';
# FLUSH PRIVILEGES;
# EXIT;

# Configurer Redis AUTH (optionnel)
# Modifier redis.conf pour ajouter: requirepass your_secure_password

# Rate limiting Laravel
php artisan make:middleware RateLimitApi
```

**Fichiers touchés:**

- `.env` (sécuriser secrets)
- `app/Http/Middleware/RateLimitApi.php` (créé)
- `config/cors.php` (modifié)
- `config/database.php` (credentials sécurisés)

**Sécurisation `.env`:**

```env
# Générer secrets forts
PUSHER_APP_SECRET=$(openssl rand -base64 32)
DB_PASSWORD=$(openssl rand -base64 16)

# Ne jamais committer .env
# Utiliser .env.example comme template
```

**Configuration CORS `config/cors.php`:**

```php
return [
    'paths' => ['api/*', 'broadcasting/auth'],
    'allowed_methods' => ['GET', 'POST'],
    'allowed_origins' => [
        'http://localhost:8000',
        'http://localhost:8001',
        'http://localhost:8002',
    ],
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => true,
];
```

**Rate Limiting Middleware:**

```php
<?php
// app/Http/Middleware/RateLimitApi.php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Cache\RateLimiter;
use Symfony\Component\HttpFoundation\Response;

class RateLimitApi
{
    protected $limiter;

    public function __construct(RateLimiter $limiter)
    {
        $this->limiter = $limiter;
    }

    public function handle($request, Closure $next)
    {
        $key = 'api:' . $request->ip();
        
        if ($this->limiter->tooManyAttempts($key, 60)) {
            return response()->json([
                'error' => 'Too many requests. Please try again later.'
            ], Response::HTTP_TOO_MANY_REQUESTS);
        }
        
        $this->limiter->hit($key, 60);
        
        return $next($request);
    }
}
```

**Permissions MongoDB:**

```powershell
# Se connecter à MongoDB
docker exec -it mongo1 mongosh

# Dans mongosh:
use admin
db.createUser({
  user: "laravel_monitoring",
  pwd: "secure_password",
  roles: [
    { role: "read", db: "cachesystem" },
    { role: "changeStream", db: "cachesystem" }
  ]
})
exit
```

**Checklist sécurité:**

```markdown
- [ ] NiFi accessible uniquement via HTTPS (9443)
- [ ] Secrets stockés dans .env (jamais commités)
- [ ] Users DB avec permissions minimales
- [ ] Redis AUTH activé (production)
- [ ] CORS configuré pour domaines autorisés
- [ ] Rate limiting actif sur APIs publiques
- [ ] HTTPS configuré pour Laravel apps (production)
- [ ] Firewall règles pour limiter accès aux ports sensibles
- [ ] Logs ne contiennent pas de secrets
- [ ] Dépendances à jour (composer update, npm update)
```

**Vérifications:**

- [ ] NiFi utilise HTTPS (certificat auto-signé OK pour dev).
- [ ] Aucun secret en clair dans le code versionné.
- [ ] Users MySQL/MongoDB avec permissions restreintes.
- [ ] CORS configuré correctement.
- [ ] Rate limiting actif et testé.
- [ ] Audit de sécurité réalisé (composer audit, npm audit).

**Résultat attendu:**  
Système sécurisé selon les meilleures pratiques. Secrets protégés, communications chiffrées, permissions minimales.

---

### H4 – Documentation (ARCHITECTURE_COMPLETE.md, guides run)

**Contexte:**  
Documentation complète pour développeurs, opérateurs, et nouveaux contributeurs.

**Objectif:**  
Créer/mettre à jour toute la documentation du projet: architecture, guides de démarrage, API, troubleshooting.

**Étapes détaillées:**

1. Mettre à jour `ARCHITECTURE_COMPLETE.md` avec détails finaux.
2. Créer `README.md` principal à la racine.
3. Créer guides de démarrage pour chaque application.
4. Documenter les APIs (OpenAPI/Swagger).
5. Créer guide de troubleshooting.
6. Documenter les procédures de backup/restore.
7. Créer guide de contribution.

**Commandes PowerShell:**

```powershell
# Créer fichiers documentation
cd c:\Users\Lenovo\Desktop\Projet\Projet

New-Item -ItemType File -Path README.md -Force
New-Item -ItemType File -Path QUICKSTART.md -Force
New-Item -ItemType File -Path TROUBLESHOOTING.md -Force
New-Item -ItemType File -Path API_DOCUMENTATION.md -Force
New-Item -ItemType File -Path BACKUP_RESTORE.md -Force
```

**Fichiers touchés:**

- `README.md` (créé/mis à jour)
- `QUICKSTART.md` (créé)
- `TROUBLESHOOTING.md` (créé)
- `API_DOCUMENTATION.md` (créé)
- `BACKUP_RESTORE.md` (créé)
- `ARCHITECTURE_COMPLETE.md` (mis à jour)

**Contenu `README.md` (exemple):**

```markdown
# CacheSystem - Distributed Cache Orchestration Platform

## Overview
CacheSystem is a distributed cache orchestration platform using Apache NiFi, Kafka, MySQL, MongoDB, Redis, and Laravel applications.

## Architecture
See [ARCHITECTURE_COMPLETE.md](ARCHITECTURE_COMPLETE.md) for detailed system architecture.

## Quick Start
See [QUICKSTART.md](QUICKSTART.md) for step-by-step setup instructions.

## Components
- **Kafka/Zookeeper**: Event streaming
- **MySQL**: Relational data storage
- **MongoDB ReplicaSet**: Event logging with Change Streams
- **Redis**: Cache layer
- **Apache NiFi**: Data orchestration
- **Employees App**: CRUD interface (Laravel)
- **Monitoring App**: Real-time dashboard (Laravel + Echo)
- **Search App**: Redis cache search (Laravel)

## Prerequisites
- Docker Desktop
- PHP 8.2.3
- Composer 2.x
- Node.js 19+
- Python 3.8+

## Installation
```bash
# Clone repository
git clone <repo-url>
cd projet

# Start infrastructure
docker compose up -d

# Setup Laravel apps
cd employees-app && composer install && npm install
cd ../monitoring-app && composer install && npm install
cd ../search-app && composer install && npm install
```

## Running

```bash
# Start all services
docker compose up -d

# Start Laravel apps
cd employees-app && php artisan serve --port=8000
cd monitoring-app && php artisan serve --port=8001
cd search-app && php artisan serve --port=8002
```

## Testing

```bash
# Run tests
cd employees-app && php artisan test
cd monitoring-app && php artisan test
cd search-app && php artisan test
```

## Troubleshooting

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

## API Documentation

See [API_DOCUMENTATION.md](API_DOCUMENTATION.md).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for commit conventions and guidelines.

## License

MIT

```

**Contenu `QUICKSTART.md` (exemple):**
```markdown
# Quick Start Guide

## Step 1: Prerequisites
Verify all tools installed:
```bash
docker --version
php -v
composer --version
node -v
python --version
```

## Step 2: Clone & Setup

```bash
git clone <repo-url>
cd projet
docker network create cachesys
```

## Step 3: Start Infrastructure

```bash
docker compose up -d
docker ps  # Verify all containers running
```

## Step 4: Initialize Databases

```bash
# MySQL
docker exec -i mysql mysql -uyouness -pdonronbola cachesystem < scripts/mysqlsampledatabase.sql

# MongoDB ReplicaSet
docker exec -i mongo1 mongosh < scripts/init-mongo-replica.js

# Kafka topic
docker exec -it broker kafka-topics --create --topic cache --partitions 1 --replication-factor 1 --bootstrap-server broker:9092
```

## Step 5: Setup NiFi

1. Open <https://localhost:9443/nifi>
2. Login: admin / ctsBtRBKHRAx69EqUghvvgEvjnaLjFEB
3. Import flow template or configure manually

## Step 6: Setup Laravel Apps

```bash
cd employees-app
composer install
npm install
php artisan key:generate
php artisan serve --port=8000

# Repeat for monitoring-app (port 8001) and search-app (port 8002)
```

## Step 7: Test End-to-End

1. Open <http://localhost:8000> (Employees)
2. Create a customer and order
3. Verify in MongoDB and Redis
4. Open <http://localhost:8001/monitor> (Real-time monitoring)
5. Open <http://localhost:8002> (Search)

```

**Contenu `TROUBLESHOOTING.md` (exemple):**
```markdown
# Troubleshooting Guide

## Docker Issues

### Containers not starting
```bash
docker ps -a
docker logs <container-name>
docker compose down && docker compose up -d
```

### Network issues

```bash
docker network ls
docker network inspect cachesys
```

## Database Issues

### MySQL connection refused

- Check container status: `docker ps | grep mysql`
- Verify credentials in .env
- Check port 3306 available

### MongoDB ReplicaSet not initialized

```bash
docker exec -it mongo1 mongosh --eval "rs.status()"
# If error, re-initialize: docker exec -i mongo1 mongosh < scripts/init-mongo-replica.js
```

## Kafka Issues

### Topic not created

```bash
docker exec -it broker kafka-topics --list --bootstrap-server broker:9092
# Recreate if needed
```

### Messages not consumed

```bash
docker exec -it broker kafka-console-consumer --topic cache --from-beginning --bootstrap-server broker:9092
```

## NiFi Issues

### Cannot access interface

- Wait 60 seconds after container start
- Check logs: `docker logs nifi`
- Verify port 9443 available

### Flow not processing

- Check processor status (play button)
- View bulletins for errors
- Check Data Provenance

## Laravel Issues

### Class not found

```bash
composer dump-autoload
```

### Database connection error

```bash
php artisan config:clear
php artisan cache:clear
```

## Performance Issues

### Slow queries

- Check MySQL slow query log
- Verify indexes on customerNumber, orderNumber

### High memory usage

```bash
docker stats
```

```

**Vérifications:**
- [ ] `README.md` complet et à jour.
- [ ] `QUICKSTART.md` avec instructions pas à pas.
- [ ] `TROUBLESHOOTING.md` couvre problèmes courants.
- [ ] `API_DOCUMENTATION.md` documente tous les endpoints.
- [ ] `BACKUP_RESTORE.md` explique procédures.
- [ ] `ARCHITECTURE_COMPLETE.md` mis à jour avec détails finaux.
- [ ] Tous les guides testés et validés.

**Résultat attendu:**  
Documentation complète et professionnelle. Nouveau développeur peut démarrer le projet en < 30 minutes.

---

### H5 – CI/CD (lint, tests, build, déploiement)

**Contexte:**  
Automatiser les processus de validation, build, et déploiement via pipeline CI/CD (GitHub Actions, GitLab CI, etc.).

**Objectif:**  
Créer pipeline CI/CD complet pour automatiser tests, linting, builds, et déploiements.

**Étapes détaillées:**
1. Créer fichier GitHub Actions workflow.
2. Configurer jobs: lint, test, build, deploy.
3. Installer dépendances automatiquement.
4. Exécuter tests sur chaque push/PR.
5. Déployer automatiquement sur environnement staging.
6. Créer badges de statut pour README.

**Commandes PowerShell:**
```powershell
# Créer répertoire workflows
New-Item -ItemType Directory -Path .github\workflows -Force

# Créer workflow file
New-Item -ItemType File -Path .github\workflows\ci.yml -Force
```

**Fichiers touchés:**

- `.github/workflows/ci.yml` (créé)
- `.github/workflows/deploy.yml` (créé)

**Contenu `.github/workflows/ci.yml`:**

```yaml
name: CI Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  lint:
    name: Lint Code
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.2'
          
      - name: Install dependencies
        run: |
          cd employees-app
          composer install --no-interaction --prefer-dist
          
      - name: Run PHP CS Fixer
        run: |
          cd employees-app
          vendor/bin/php-cs-fixer fix --dry-run --diff
          
      - name: Run PHPStan
        run: |
          cd employees-app
          vendor/bin/phpstan analyse

  test-employees:
    name: Test Employees App
    runs-on: ubuntu-latest
    services:
      mysql:
        image: mysql:8
        env:
          MYSQL_ROOT_PASSWORD: root
          MYSQL_DATABASE: cachesystem
        ports:
          - 3306:3306
        options: --health-cmd="mysqladmin ping" --health-interval=10s --health-timeout=5s --health-retries=3
        
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.2'
          extensions: pdo, pdo_mysql
          
      - name: Install dependencies
        run: |
          cd employees-app
          composer install
          
      - name: Copy .env
        run: |
          cd employees-app
          cp .env.example .env
          php artisan key:generate
          
      - name: Run tests
        run: |
          cd employees-app
          php artisan test
          
  test-monitoring:
    name: Test Monitoring App
    runs-on: ubuntu-latest
    services:
      mongodb:
        image: mongo:6
        ports:
          - 27017:27017
          
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.2'
          extensions: mongodb
          
      - name: Install dependencies
        run: |
          cd monitoring-app
          composer install
          
      - name: Run tests
        run: |
          cd monitoring-app
          php artisan test
          
  test-search:
    name: Test Search App
    runs-on: ubuntu-latest
    services:
      redis:
        image: redis:7
        ports:
          - 6379:6379
          
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.2'
          extensions: redis
          
      - name: Install dependencies
        run: |
          cd search-app
          composer install
          
      - name: Run tests
        run: |
          cd search-app
          php artisan test

  build:
    name: Build Docker Images
    runs-on: ubuntu-latest
    needs: [lint, test-employees, test-monitoring, test-search]
    if: github.ref == 'refs/heads/main'
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Build Docker Compose
        run: |
          docker compose build
          
      - name: Tag images
        run: |
          docker tag cachesystem-nifi:latest cachesystem-nifi:${{ github.sha }}
```

**Contenu `.github/workflows/deploy.yml`:**

```yaml
name: Deploy to Staging

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    name: Deploy
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to staging server
        uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.STAGING_HOST }}
          username: ${{ secrets.STAGING_USER }}
          key: ${{ secrets.STAGING_SSH_KEY }}
          script: |
            cd /var/www/cachesystem
            git pull origin main
            docker compose down
            docker compose up -d
            cd employees-app && composer install --no-dev
            cd ../monitoring-app && composer install --no-dev
            cd ../search-app && composer install --no-dev
```

**Badges pour README:**

```markdown
![CI Pipeline](https://github.com/<username>/<repo>/actions/workflows/ci.yml/badge.svg)
![Deploy Status](https://github.com/<username>/<repo>/actions/workflows/deploy.yml/badge.svg)
```

**Vérifications:**

- [ ] Workflow CI/CD créé dans `.github/workflows/`.
- [ ] Jobs lint, test, build configurés.
- [ ] Tests exécutés automatiquement sur push/PR.
- [ ] Services Docker (MySQL, MongoDB, Redis) configurés pour tests.
- [ ] Déploiement automatique sur staging (optionnel).
- [ ] Badges de statut ajoutés au README.
- [ ] Pipeline s'exécute sans erreur.

**Résultat attendu:**  
Pipeline CI/CD opérationnel. Tests automatiques sur chaque commit, déploiement automatisé.

---

### H6 – Déploiement & exploitation (procédures, backup)

**Contexte:**  
Préparer le système pour la production: procédures de déploiement, backup/restore, monitoring, et disaster recovery.

**Objectif:**  
Créer runbooks et procédures opérationnelles pour production.

**Étapes détaillées:**

1. Créer procédure de déploiement production.
2. Configurer backups automatiques (MySQL, MongoDB).
3. Tester procédure de restore.
4. Créer script de healthcheck.
5. Configurer alerting (email, Slack).
6. Documenter procédures d'incident.
7. Créer plan de disaster recovery.

**Commandes PowerShell:**

```powershell
# Créer scripts de backup
New-Item -ItemType Directory -Path scripts\backup -Force
New-Item -ItemType File -Path scripts\backup\backup-mysql.ps1 -Force
New-Item -ItemType File -Path scripts\backup\backup-mongodb.ps1 -Force
New-Item -ItemType File -Path scripts\healthcheck.ps1 -Force
```

**Fichiers touchés:**

- `scripts/backup/backup-mysql.ps1` (créé)
- `scripts/backup/backup-mongodb.ps1` (créé)
- `scripts/healthcheck.ps1` (créé)
- `DEPLOYMENT.md` (créé)
- `BACKUP_RESTORE.md` (créé)

**Contenu `scripts/backup/backup-mysql.ps1`:**

```powershell
# Backup MySQL
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFile = "backups/mysql_backup_$timestamp.sql"

Write-Host "Starting MySQL backup..."

docker exec mysql mysqldump -uyouness -pdonronbola --all-databases > $backupFile

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ MySQL backup completed: $backupFile"
    
    # Compression
    Compress-Archive -Path $backupFile -DestinationPath "$backupFile.zip"
    Remove-Item $backupFile
    
    # Retention: garder 7 derniers backups
    Get-ChildItem backups\mysql_backup_*.zip | 
        Sort-Object LastWriteTime -Descending | 
        Select-Object -Skip 7 | 
        Remove-Item
        
    Write-Host "✓ Backup compressed and old backups cleaned"
} else {
    Write-Host "✗ MySQL backup failed"
    exit 1
}
```

**Contenu `scripts/backup/backup-mongodb.ps1`:**

```powershell
# Backup MongoDB
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupDir = "backups/mongodb_backup_$timestamp"

Write-Host "Starting MongoDB backup..."

docker exec mongo1 mongodump --uri="mongodb://mongo1:27017,mongo2:27018,mongo3:27019/?replicaSet=rs0" --out=/tmp/backup

docker cp mongo1:/tmp/backup $backupDir

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ MongoDB backup completed: $backupDir"
    
    # Compression
    Compress-Archive -Path $backupDir -DestinationPath "$backupDir.zip"
    Remove-Item -Recurse $backupDir
    
    Write-Host "✓ Backup compressed"
} else {
    Write-Host "✗ MongoDB backup failed"
    exit 1
}
```

**Contenu `scripts/healthcheck.ps1`:**

```powershell
# System Healthcheck Script

Write-Host "=== CacheSystem Health Check ===" -ForegroundColor Cyan

$allHealthy = $true

# Check Docker containers
Write-Host "`nChecking Docker containers..." -ForegroundColor Yellow
$containers = @("zookeeper", "broker", "mongo1", "mongo2", "mongo3", "mysql", "redis", "nifi")

foreach ($container in $containers) {
    $status = docker ps --filter "name=$container" --filter "status=running" --format "{{.Names}}"
    if ($status -eq $container) {
        Write-Host "✓ $container is running" -ForegroundColor Green
    } else {
        Write-Host "✗ $container is NOT running" -ForegroundColor Red
        $allHealthy = $false
    }
}

# Check MySQL
Write-Host "`nChecking MySQL..." -ForegroundColor Yellow
$mysqlCheck = docker exec mysql mysqladmin ping -uyouness -pdonronbola 2>&1
if ($mysqlCheck -like "*alive*") {
    Write-Host "✓ MySQL is responsive" -ForegroundColor Green
} else {
    Write-Host "✗ MySQL is not responsive" -ForegroundColor Red
    $allHealthy = $false
}

# Check MongoDB ReplicaSet
Write-Host "`nChecking MongoDB ReplicaSet..." -ForegroundColor Yellow
$mongoCheck = docker exec mongo1 mongosh --quiet --eval "rs.status().ok" 2>&1
if ($mongoCheck -eq "1") {
    Write-Host "✓ MongoDB ReplicaSet is healthy" -ForegroundColor Green
} else {
    Write-Host "✗ MongoDB ReplicaSet has issues" -ForegroundColor Red
    $allHealthy = $false
}

# Check Redis
Write-Host "`nChecking Redis..." -ForegroundColor Yellow
$redisCheck = docker exec redis redis-cli ping 2>&1
if ($redisCheck -eq "PONG") {
    Write-Host "✓ Redis is responsive" -ForegroundColor Green
} else {
    Write-Host "✗ Redis is not responsive" -ForegroundColor Red
    $allHealthy = $false
}

# Check Kafka
Write-Host "`nChecking Kafka..." -ForegroundColor Yellow
$kafkaCheck = docker exec broker kafka-topics --list --bootstrap-server broker:9092 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Kafka broker is responsive" -ForegroundColor Green
} else {
    Write-Host "✗ Kafka broker is not responsive" -ForegroundColor Red
    $allHealthy = $false
}

# Summary
Write-Host "`n=== Health Check Summary ===" -ForegroundColor Cyan
if ($allHealthy) {
    Write-Host "✓ All systems are healthy" -ForegroundColor Green
    exit 0
} else {
    Write-Host "✗ Some systems have issues - check logs" -ForegroundColor Red
    exit 1
}
```

**Contenu `DEPLOYMENT.md`:**

```markdown
# Production Deployment Guide

## Pre-Deployment Checklist
- [ ] All tests passing
- [ ] Security audit completed
- [ ] Backup procedures tested
- [ ] Monitoring configured
- [ ] DNS configured
- [ ] SSL certificates ready
- [ ] Environment variables set

## Deployment Steps

### 1. Prepare Server
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### 2. Clone & Configure

```bash
git clone <repo-url> /var/www/cachesystem
cd /var/www/cachesystem
cp .env.example .env
# Edit .env with production values
```

### 3. Initialize Infrastructure

```bash
docker network create cachesys
docker compose up -d
```

### 4. Initialize Databases

```bash
# Run initialization scripts
./scripts/init-production.sh
```

### 5. Deploy Laravel Apps

```bash
cd employees-app
composer install --no-dev --optimize-autoloader
npm install --production
npm run build
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Repeat for monitoring-app and search-app
```

### 6. Configure Web Server (Nginx)

```nginx
# /etc/nginx/sites-available/cachesystem
server {
    listen 80;
    server_name employees.example.com;
    root /var/www/cachesystem/employees-app/public;
    
    index index.php;
    
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
    }
}
```

### 7. Setup Supervisor for Laravel Commands

```ini
[program:orders-watch]
command=php /var/www/cachesystem/monitoring-app/artisan orders:watch
autostart=true
autorestart=true
user=www-data
stdout_logfile=/var/log/supervisor/orders-watch.log
```

### 8. Verify Deployment

```bash
./scripts/healthcheck.ps1
```

## Rollback Procedure

```bash
git checkout <previous-commit>
docker compose down
docker compose up -d
cd employees-app && php artisan config:clear
```

```

**Vérifications:**
- [ ] Scripts de backup créés et testés.
- [ ] Procédure de restore validée.
- [ ] Script healthcheck fonctionne.
- [ ] Guide de déploiement complet.
- [ ] Plan de disaster recovery documenté.
- [ ] Backups automatiques configurés (cron).
- [ ] Alerting configuré (optionnel).

**Résultat attendu:**  
Système prêt pour production avec procédures opérationnelles complètes, backups automatiques, et disaster recovery plan.

---

### H7 – Validation finale & handover

**Contexte:**  
Dernière vérification complète du système avant livraison/handover.

**Objectif:**  
Valider que tous les composants fonctionnent ensemble, créer checklist de handover, et préparer formation.

**Étapes détaillées:**
1. Exécuter tous les tests (unitaires, intégration, E2E).
2. Vérifier tous les flux end-to-end.
3. Valider performance et scalabilité.
4. Créer checklist de handover.
5. Préparer documentation de formation.
6. Effectuer démonstration complète.
7. Transférer connaissances à l'équipe.

**Commandes PowerShell:**
```powershell
# Validation complète
cd c:\Users\Lenovo\Desktop\Projet\Projet

# 1. Vérifier infrastructure
docker ps
.\scripts\healthcheck.ps1

# 2. Exécuter tous les tests
cd employees-app && php artisan test
cd ..\monitoring-app && php artisan test
cd ..\search-app && php artisan test

# 3. Test end-to-end complet
# (Manuel via interface web)

# 4. Vérifier documentation
Get-ChildItem *.md

# 5. Générer rapport final
New-Item -ItemType File -Path HANDOVER_CHECKLIST.md -Force
```

**Fichiers touchés:**

- `HANDOVER_CHECKLIST.md` (créé)
- `TRAINING_GUIDE.md` (créé)
- `VALIDATION_REPORT.md` (créé)

**Contenu `HANDOVER_CHECKLIST.md`:**

```markdown
# Handover Checklist

## Infrastructure
- [ ] All Docker containers running (zookeeper, broker, mongo1/2/3, mysql, redis, nifi)
- [ ] Network `cachesys` operational
- [ ] Volumes persisting data correctly
- [ ] Healthcheck script passing

## Databases
- [ ] MySQL contains sample data
- [ ] MongoDB ReplicaSet initialized and healthy
- [ ] Redis accepting connections
- [ ] Kafka topic `cache` created

## NiFi
- [ ] Interface accessible (https://localhost:9443)
- [ ] Controller Services enabled
- [ ] Flow processing messages correctly
- [ ] Data written to MongoDB and Redis

## Laravel Applications
- [ ] Employees App (port 8000) - CRUD working
- [ ] Monitoring App (port 8001) - Real-time updates working
- [ ] Search App (port 8002) - Redis search working

## Testing
- [ ] All unit tests passing
- [ ] All integration tests passing
- [ ] End-to-end flows validated

## Documentation
- [ ] README.md complete
- [ ] QUICKSTART.md tested
- [ ] ARCHITECTURE_COMPLETE.md up to date
- [ ] API_DOCUMENTATION.md complete
- [ ] TROUBLESHOOTING.md comprehensive
- [ ] BACKUP_RESTORE.md tested

## Security
- [ ] Secrets secured in .env
- [ ] HTTPS enabled for NiFi
- [ ] Database permissions minimized
- [ ] CORS configured
- [ ] Rate limiting active

## CI/CD
- [ ] GitHub Actions workflows configured
- [ ] Tests running automatically
- [ ] Deployment pipeline working

## Backup & Recovery
- [ ] Backup scripts tested
- [ ] Restore procedure validated
- [ ] Retention policy configured

## Knowledge Transfer
- [ ] Team trained on system architecture
- [ ] Runbooks reviewed
- [ ] Incident procedures understood
- [ ] Support contacts documented

## Sign-off
- [ ] Development Team: ___________  Date: _______
- [ ] Operations Team: ___________  Date: _______
- [ ] Project Manager: ___________  Date: _______
```

**Contenu `VALIDATION_REPORT.md`:**

```markdown
# System Validation Report

## Date: [Date]
## Validator: [Name]

## Test Results

### Unit Tests
- Employees App: ✓ PASS (X tests, 0 failures)
- Monitoring App: ✓ PASS (X tests, 0 failures)
- Search App: ✓ PASS (X tests, 0 failures)

### Integration Tests
- Kafka → NiFi: ✓ PASS
- NiFi → MongoDB: ✓ PASS
- NiFi → Redis: ✓ PASS
- MongoDB Change Streams: ✓ PASS

### End-to-End Flows
- Customer CRUD → Kafka → NiFi → MongoDB/Redis: ✓ PASS
- MongoDB Insert → Change Stream → WebSocket → UI: ✓ PASS
- Redis Search: ✓ PASS

### Performance
- Average response time: XX ms
- Throughput: XX requests/sec
- Database query performance: Acceptable

### Security
- Vulnerability scan: No critical issues
- Secrets management: Compliant
- Access controls: Configured

## Issues Found
[None / List any issues]

## Recommendations
[Any recommendations for improvements]

## Approval
System validated and ready for production deployment.

Signature: ___________  Date: _______
```

**Test E2E complet:**

1. Créer customer dans Employees App
2. Créer order pour ce customer
3. Vérifier message Kafka (console consumer)
4. Vérifier document MongoDB (mongosh)
5. Vérifier clé Redis (redis-cli)
6. Vérifier affichage temps réel dans Monitoring App
7. Rechercher dans Search App
8. Valider que toutes les données correspondent

**Vérifications:**

- [ ] Tous les tests passent sans erreur.
- [ ] Flux E2E complet validé.
- [ ] Performance acceptable.
- [ ] Checklist de handover complète.
- [ ] Documentation finale vérifiée.
- [ ] Démonstration réalisée avec succès.
- [ ] Équipe formée et autonome.

**Résultat attendu:**  
Projet validé, documenté, et transféré avec succès. Système prêt pour production et équipe prête à opérer/maintenir.

---

**Fin Phase H**

Les prompts H1 à H7 sont désormais définis. L'agent peut finaliser le projet avec qualité, sécurité, CI/CD, et documentation complète. Système prêt pour production et handover réussi.

---

## Conclusion

Le système de prompts est maintenant complet avec 43 prompts détaillés couvrant toutes les phases du projet:

- **Phase A**: Infrastructure (6 prompts)
- **Phase B**: Bases de données & Streaming (4 prompts)
- **Phase C**: Apache NiFi (5 prompts)
- **Phase D**: Laravel Employees (6 prompts)
- **Phase E**: Python Producer (2 prompts)
- **Phase F**: Laravel Monitoring (7 prompts)
- **Phase G**: Laravel Search (6 prompts)
- **Phase H**: Qualité & Production (7 prompts)

Chaque prompt contient:

- Contexte clair
- Objectif précis
- Étapes détaillées
- Commandes PowerShell prêtes à exécuter
- Fichiers touchés
- Code complet quand applicable
- Vérifications (checklist)
- Résultat attendu

L'agent AI peut maintenant exécuter l'intégralité du projet de manière chirurgicale et autonome.
