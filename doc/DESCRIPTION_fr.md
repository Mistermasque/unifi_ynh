UniFi Network est le contrôleur de gestion réseau auto-hébergé développé par Ubiquiti.
Il vous permet de gérer centralement toute votre infrastructure réseau Ubiquiti — points d'accès,
commutateurs, passerelles de sécurité et autres équipements UniFi — depuis une seule interface web.

### Fonctionnalités principales

- **Tableau de bord unifié** — Surveillez le trafic, les clients connectés et l'état des équipements en temps réel
- **Gestion sans-fil** — Créez et gérez plusieurs SSID, VLAN, réseaux invités et portails captifs sur l'ensemble de vos points d'accès
- **Gestion des commutateurs** — Configurez les VLAN, profils de ports, PoE et agrégation de liens sur les commutateurs UniFi
- **Passerelle de sécurité** — Règles de pare-feu, mise en forme du trafic, VPN (IPsec, OpenVPN, WireGuard) et gestion des menaces
- **Portail invité** — Portail captif personnalisable avec accès par bon, paiement ou connexion sociale (optionnel)
- **Application mobile** — Gestion complète et test de vitesse depuis l'application mobile UniFi (optionnel)
- **Sauvegardes automatisées** — Sauvegarde planifiée intégrée de la configuration du contrôleur
- **Roaming sans coupure** — Itinérance transparente des clients entre les points d'accès du même réseau

Ce paquet YunoHost installe le contrôleur UniFi Network en tant que service systemd adossé à
MongoDB, expose l'interface web via un reverse proxy nginx sur le domaine choisi, et intègre
le service dans le panneau d'administration YunoHost.

> **Note :** Ce paquet installe uniquement le **contrôleur logiciel**. Vous avez toujours besoin
> de matériel Ubiquiti (points d'accès, commutateurs, passerelles UniFi…) sur votre réseau local
> pour le gérer. Le contrôleur ne fournit pas lui-même le Wi-Fi ni le routage.
