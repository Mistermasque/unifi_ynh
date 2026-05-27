## Accès au contrôleur

L'interface web UniFi Network est disponible à l'adresse :

```
https://__DOMAIN__/
```

Au premier accès, un **assistant de configuration initiale** vous guidera pour créer un compte
administrateur local et, optionnellement, lier le contrôleur à un compte cloud Ubiquiti (UI.com).
Le SSO YunoHost n'est **pas** intégré — UniFi gère sa propre authentification.

---

## Adoption des équipements

Les équipements UniFi sur le même réseau sont découverts automatiquement. Si vos équipements
se trouvent sur un sous-réseau différent, définissez manuellement l'**URL inform du contrôleur**
sur chaque équipement :

```
http://__DOMAIN__:8080/inform
```

Pour les équipements nécessitant SSH pour définir l'URL inform :

```bash
set-inform http://__DOMAIN__:8080/inform
```

---

## Ports pare-feu

Les ports suivants sont gérés par ce paquet :

| Port | Protocole | Rôle | Toujours ouvert |
|------|-----------|------|-----------------|
| 8443 | TCP | Interface web (via reverse proxy nginx) | Oui (nginx uniquement, pas en direct) |
| 8080 | TCP | Canal inform / communication des équipements | Oui |
| 3478 | UDP | STUN — traversée NAT pour les équipements | Oui |
| 10001 | UDP | Découverte des équipements (broadcast) | Oui |
| 8880 | TCP | Redirection HTTP portail invité | Uniquement si portail invité activé |
| 8843 | TCP | Redirection HTTPS portail invité | Uniquement si portail invité activé |
| 6789 | TCP | Test de vitesse application mobile | Uniquement si test de vitesse activé |

Les ports optionnels (portail invité, test de vitesse) peuvent être activés ou désactivés à tout
moment depuis **Administration YunoHost → Applications → UniFi Network → Configuration**.

---

## Répertoires de données

Toutes les données du contrôleur sont stockées en dehors du répertoire d'installation standard
de YunoHost, dans des chemins gérés directement par le paquet Debian `unifi` :

| Chemin | Contenu |
|--------|---------|
| `/var/lib/unifi/data/` | Base de données MongoDB, `system.properties`, keystore |
| `/var/lib/unifi/data/backup/` | Archives de sauvegarde automatique UniFi (fichiers `.unf`) |
| `/var/log/unifi/` | Journaux applicatifs (`server.log`, `mongod.log`) |

Ces chemins sont inclus automatiquement dans les sauvegardes YunoHost lorsque vous sauvegardez
cette application.

---

## Sauvegarde et restauration

Ce paquet s'intègre au système de sauvegarde standard de YunoHost :

```bash
# Créer une sauvegarde
yunohost backup create --apps unifi

# Restaurer depuis une sauvegarde
yunohost backup restore <nom_sauvegarde> --apps unifi
```

> **Attention :** `/var/lib/unifi` peut devenir volumineux sur les réseaux avec de nombreux
> équipements ou une longue rétention des statistiques. Vérifiez l'espace disque disponible
> avant d'effectuer une sauvegarde.

UniFi maintient également ses propres sauvegardes internes sous `/var/lib/unifi/data/backup/`.
Ces fichiers `.unf` peuvent être restaurés directement depuis l'interface web UniFi,
indépendamment du système de sauvegarde YunoHost.

---

## Mise à jour d'UniFi

Le paquet UniFi est installé depuis le dépôt APT officiel d'Ubiquiti. Pour le mettre à jour :

```bash
sudo apt-get update
sudo apt-get install --only-upgrade unifi
```

Ou via le mécanisme de mise à jour standard de YunoHost :

```bash
yunohost app upgrade unifi
```

> Après une mise à jour majeure (ex. 8.x → 9.x), le contrôleur effectuera une **migration de
> base de données** au premier démarrage. Ne redémarrez pas le service pendant cette phase —
> attendez que l'interface web redevienne disponible (peut prendre plusieurs minutes).

---

## Réglage de la mémoire JVM

UniFi s'exécute sur une machine virtuelle Java. La taille de tas par défaut est de 1024 Mo.
Sur les déploiements importants (100+ équipements), vous devrez peut-être l'augmenter via
**Administration YunoHost → Applications → UniFi Network → Configuration → Performances**.

Pour les petits déploiements domestiques, vous pouvez la réduire à 512 Mo pour libérer de la RAM.

---

## Journaux

Les journaux du service sont accessibles de deux façons :

- **Panneau d'administration YunoHost** → Services → `unifi` → onglet Journaux
- En ligne de commande :

```bash
# Journal applicatif (processus Java UniFi)
tail -f /var/log/unifi/server.log

# Journal MongoDB
tail -f /var/log/unifi/mongod.log

# Journal systemd
journalctl -u unifi -f
```
