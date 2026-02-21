## 😎 La flemme de coder ?

Si vous avez la flemme d'être développeur et que vous voulez un **Expert Advisor personnalisé** sans écrire une seule ligne de code, venez voir notre générateur en ligne :

### 👉 [**EA Creator — Créez votre EA en 2 minutes**](https://autoea.online/generate) 👈

- ✅ Aucune compétence en programmation requise
- ✅ Configurez visuellement vos modules (SL, TP, TP Partiel, Break Even, Trailing Stop, **Max Drawdown**...)
- ✅ Fichier `.ex5` compilé et livré par email en 5 minutes
- ✅ Compatible toutes les Prop Firms
- ✅ Lié à votre compte MT5 pour plus de sécurité

> 🌐 **Site web :** [https://autoea.online](https://autoea.online)
>
> 📧 **Contact :** snowfallsys@proton.me


# 🚨 Tutoriel MT5 — Max Drawdown Daily (Protection Perte Quotidienne)

[![MetaTrader 5](https://img.shields.io/badge/MetaTrader_5-Expert_Advisor-blue?style=for-the-badge&logo=metatrader5)](https://www.metatrader5.com)
[![MQL5](https://img.shields.io/badge/MQL5-Language-orange?style=for-the-badge)](https://www.mql5.com/fr/docs)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

> **Tutoriel complet et détaillé** pour créer un Expert Advisor MQL5 qui surveille le drawdown quotidien et **ferme automatiquement toutes les positions** si la perte dépasse un seuil configuré. **Indispensable pour les Prop Firms** (FTMO, MFF, The5ers). Chaque ligne de code est expliquée en français.

---

## 📖 Table des matières

1. [Introduction](#-introduction)
2. [Prérequis](#-prérequis)
3. [Architecture du projet](#-architecture-du-projet)
4. [Installation](#-installation)
5. [Explication complète du code](#-explication-complète-du-code)
   - [Fichier principal — MaxDrawdownBot.mq5](#1-fichier-principal--maxdrawdownbotmq5)
   - [Sélection des trades — TradeSelector.mqh](#2-sélection-des-trades--tradeselectormqh)
   - [Calcul du drawdown — DDCalculator.mqh](#3-calcul-du-drawdown--ddcalculatormqh)
   - [Fermeture de masse — TradeManager.mqh](#4-fermeture-de-masse--trademanagermqh)
6. [Comment fonctionne le Max Drawdown ?](#-comment-fonctionne-le-max-drawdown-)
7. [Balance vs Equity : la différence cruciale](#-balance-vs-equity--la-différence-cruciale)
8. [Le bug de l'itération : boucle inversée](#-le-bug-de-litération--boucle-inversée)
9. [Prop Firms et règles de drawdown](#-prop-firms-et-règles-de-drawdown)
10. [Configuration et paramètres](#-configuration-et-paramètres)
11. [Gestion des erreurs](#-gestion-des-erreurs)
12. [Tests et backtest](#-tests-et-backtest)
13. [FAQ](#-faq)
14. [Liens utiles](#-liens-utiles)

---

## 🌟 Introduction

### Qu'est-ce que le Max Drawdown Daily ?

Le **Max Drawdown Daily** (perte quotidienne maximale) est le montant maximum que vous pouvez perdre en **une seule journée** avant que la protection se déclenche. C'est le **bouton d'arrêt d'urgence** du trading.

### Pourquoi c'est indispensable

```
Scénario sans Max Drawdown (vendredi soir, fatigué) :

  Trade 1 : -$100 😑 "Pas grave, je me rattrape"
  Trade 2 : -$150 😤 "Allez, un dernier"
  Trade 3 : -$200 😡 "Revenge trading !"
  Trade 4 : -$300 🤬 "ALL IN !"
  Trade 5 : -$500 💀 Compte en danger

  Total du jour : -$1,250 sur un compte de $10,000 = -12.5%
  → Compte éliminé de la Prop Firm (limite = -5%) 😵
```

```
Même scénario AVEC Max Drawdown Bot (5%) :

  Trade 1 : -$100
  Trade 2 : -$150
  Trade 3 : -$200
  → Perte totale = -$500 = 5% 🚨
  → EA FERME TOUT et arrête le trading

  "Mais je voulais continuer !"
  → NON. C'est exactement le but. 🛑
  → Vous avez encore $9,500 demain.
```

### La psychologie du "Revenge Trading"

Le Max Drawdown Bot protège contre la plus grande menace du trader :  **lui-même**.

| Phase | Émotion | Action typique | Sans DD Bot | Avec DD Bot |
|:---:|:---:|:---:|:---:|:---:|
| 1 | Confiance | Trade normal | Perte -$100 | Perte -$100 |
| 2 | Agacement | Trade de revanche | Perte -$200 | Perte -$200 |
| 3 | Colère | Taille x2 | Perte -$400 | 🛑 STOP |
| 4 | Panique | ALL IN | **-$2,000** | *(pas de trade)* |
| | | **Total** | **-$2,700** | **-$500** |

---

## 🔧 Prérequis

- **MetaTrader 5** installé ([télécharger ici](https://www.metatrader5.com/fr/download))
- **MetaEditor** (inclus dans MT5)
- Un **compte de trading** (démo ou réel)

### Tutoriels de la série

| # | Tutoriel | Concept | Lien |
|:-:|:---|:---|:---:|
| 1 | Stop Loss Automatique | Protection initiale | [GitHub](https://github.com/VOTRE_USER/Tuto-MT5-Stop-Loss-Automatique) |
| 2 | Take Profit Automatique | Objectif de gain | [GitHub](https://github.com/VOTRE_USER/Tuto-MT5-Take-Profit-Automatique) |
| 3 | TP Partiel Automatique | Sécuriser une partie | [GitHub](https://github.com/VOTRE_USER/Tuto-MT5-TP-Partiel-Automatique) |
| 4 | Trailing Stop Automatique | SL suiveur | [GitHub](https://github.com/VOTRE_USER/Tuto-MT5-Trailing-Stop-Automatique) |
| 5 | Break Even Automatique | Risque zéro | [GitHub](https://github.com/VOTRE_USER/Tuto-MT5-Break-Even-Automatique) |
| **6** | **Max Drawdown Daily** | **Protection du compte** | **Vous êtes ici** |

---

## 📁 Architecture du projet

```
📂 Tuto-MT5-Max-Drawdown-Daily/
│
├── 📂 Experts/
│   └── 📄 MaxDrawdownBot.mq5           ← Fichier principal de l'EA
│
├── 📂 Include/
│   ├── 📄 TradeSelector.mqh            ← Sélection des positions (toutes)
│   ├── 📄 DDCalculator.mqh             ← Calcul du drawdown quotidien
│   └── 📄 TradeManager.mqh             ← Fermeture de toutes les positions
│
├── 📄 README.md                        ← Ce fichier
└── 📄 LICENSE                          ← Licence MIT
```

### Différence avec les autres EA

| Aspect | SL/TP/BE/TS Bot | **Max Drawdown Bot** |
|:-:|:-:|:-:|
| Scope | Un symbole | **Tout le compte** |
| Action | Modifier SL/TP | **Fermer TOUT** |
| Fréquence | Par position | **Par compte** |
| Urgence | Normale | **Critique** |

---

## 📥 Installation

### Méthode 1 : Installation manuelle

1. **Ouvrez MetaTrader 5**

2. **Accédez au dossier de données :**
   - Menu `Fichier` → `Ouvrir le dossier des données`

3. **Copiez les fichiers :**
   ```
   MaxDrawdownBot.mq5    →  MQL5/Experts/MaxDrawdownBot.mq5
   TradeSelector.mqh     →  MQL5/Include/TradeSelector.mqh
   DDCalculator.mqh      →  MQL5/Include/DDCalculator.mqh
   TradeManager.mqh      →  MQL5/Include/TradeManager.mqh
   ```

4. **Compilez dans MetaEditor :**
   - Ouvrez `MaxDrawdownBot.mq5` et appuyez sur `F7`

5. **Lancez l'EA :**
   - Glissez `MaxDrawdownBot` sur n'importe quel graphique
   - Configurez le pourcentage de drawdown maximum
   - Cliquez sur `OK`

### Méthode 2 : Clone Git

```bash
git clone https://github.com/VOTRE_USER/Tuto-MT5-Max-Drawdown-Daily.git
```

---

## 📝 Explication complète du code

### 1. Fichier principal — `MaxDrawdownBot.mq5`

Cet EA est **fondamentalement différent** des autres :
- Il ne modifie pas des SL/TP → il **ferme des positions**
- Il ne surveille pas un symbole → il surveille **tout le compte**
- Il n'agit pas par position → il agit sur le **compte global**

#### Le paramètre d'entrée

```mql5
input double Max_DD_Pourcentage = 5.0;   // Max Drawdown Daily (%)
```

Un seul paramètre. Simple, mais **critique**. La valeur de 5% correspond au standard FTMO.

#### Les variables d'état

```mql5
double SoldeDuJour = 0;          // Solde de référence
datetime DateDuJour;              // Date courante
bool JourneeFinie = false;       // Flag d'arrêt
```

**Trois variables essentielles :**

| Variable | Rôle | Durée de vie |
|:-:|:---|:---:|
| `SoldeDuJour` | Référence pour le calcul du drawdown | Reset chaque jour |
| `DateDuJour` | Détecter le changement de jour | Reset chaque jour |
| `JourneeFinie` | Empêcher de trader après le seuil | Reset chaque jour |

#### `OnTick()` — La logique de protection

```
┌────────────────────────────────────────────┐
│           Nouveau tick reçu                 │
└──────────────────┬─────────────────────────┘
                   │
                   ▼
┌────────────────────────────────────────────┐
│  1. Nouveau jour ?                          │
│     → OUI : réinitialiser solde + flag      │
│     → NON : continuer                       │
│                                             │
│  2. Journée déjà finie ?                    │
│     → OUI : STOP (ne rien faire)            │
│     → NON : continuer                       │
│                                             │
│  3. Calculer drawdown % du jour             │
│     (Equity vs Solde du jour)               │
│                                             │
│  4. Drawdown >= seuil ?                     │
│     → NON : tout va bien, on continue       │
│     → OUI : 🚨🚨🚨                         │
│                                             │
│  5. FERMER TOUTES LES POSITIONS             │
│                                             │
│  6. Marquer la journée comme finie          │
│     (JourneeFinie = true)                   │
└────────────────────────────────────────────┘
```

---

### 2. Sélection des trades — `TradeSelector.mqh`

**Différence clé** avec les autres EA : ici `CompterPositionsOuvertes()` compte les positions sur **TOUS les symboles**, pas juste le symbole courant.

```mql5
int CompterPositionsOuvertes()
{
    return PositionsTotal();   // Toutes les positions, tous symboles
}
```

Le drawdown est un concept **global du compte**, pas limité à un instrument.

---

### 3. Calcul du drawdown — `DDCalculator.mqh`

#### `CalculerDrawdownJournalier()` — La formule clé

```mql5
double CalculerDrawdownJournalier(double soldeDuJour)
{
    double equity = AccountInfoDouble(ACCOUNT_EQUITY);
    double perteDuJour = soldeDuJour - equity;

    if(perteDuJour <= 0)
        return 0.0;

    return (perteDuJour / soldeDuJour) * 100.0;
}
```

**Pourquoi l'Equity et pas le Balance ?**

L'**Equity** = Balance + Profits flottants (positions ouvertes).

```
Exemple :
  Balance  = $10,000 (aucun trade fermé dans la journée)
  Position ouverte en perte de -$400

  Balance dit : "Tout va bien, $10,000"
  Equity dit  : "Non, le compte vaut $9,600"

  Les Prop Firms utilisent l'EQUITY → il faut faire pareil.
```

---

### 4. Fermeture de masse — `TradeManager.mqh`

#### `FermerToutesPositions()` — Pourquoi la boucle inversée ?

```mql5
for(int i = total - 1; i >= 0; i--)
{
    ulong ticket = PositionGetTicket(i);
    trade.PositionClose(ticket, 10);
}
```

**Le bug classique de l'itération :**

```
Positions avant fermeture : [EURUSD, GBPUSD, USDJPY]
Index :                      [0,      1,      2     ]

Boucle NORMALE (i = 0, 1, 2) :
  i=0 : Ferme EURUSD → indices changent !
  Nouvelles positions : [GBPUSD, USDJPY]
  i=1 : Ferme USDJPY (c'est maintenant l'index 1)
  Nouvelles positions : [GBPUSD]
  i=2 : index 2 n'existe plus → rien
  → GBPUSD N'A PAS ÉTÉ FERMÉ ! ❌

Boucle INVERSÉE (i = 2, 1, 0) :
  i=2 : Ferme USDJPY → ok
  i=1 : Ferme GBPUSD → ok
  i=0 : Ferme EURUSD → ok
  → TOUT est fermé ! ✅
```

---

## 🎯 Comment fonctionne le Max Drawdown ?

### Chronologie d'une journée

```
╔═══════════════════════════════════════════════════════════╗
║                JOURNÉE DE TRADING                         ║
╠═══════════════════════════════════════════════════════════╣
║                                                           ║
║  00:00  DÉBUT DU JOUR                                     ║
║  │      Solde de référence : $10,000                      ║
║  │      Max DD : 5% = $500                                ║
║  │                                                        ║
║  08:30  Trade 1 : Perte -$150                              ║
║  │      Equity = $9,850 → DD = 1.5% ✅                    ║
║  │                                                        ║
║  10:15  Trade 2 : Perte -$200                              ║
║  │      Equity = $9,650 → DD = 3.5% ✅                    ║
║  │                                                        ║
║  14:00  Trade 3 : En cours, profit flottant -$200          ║
║  │      Equity = $9,450 → DD = 5.5% 🚨 SEUIL DÉPASSÉ !   ║
║  │      → TOUTES les positions fermées                     ║
║  │      → EA en pause                                      ║
║  │                                                        ║
║  14:01 → 23:59  Aucun trading (JourneeFinie = true) 🛑     ║
║                                                           ║
║  00:00  NOUVEAU JOUR                                      ║
║  │      Nouveau solde de référence capturé                 ║
║  │      JourneeFinie = false → EA reprend                  ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
```

### Calcul du drawdown : exemples concrets

| Solde du jour | Equity actuelle | Drawdown | Seuil 5% | Action |
|:---:|:---:|:---:|:---:|:---:|
| $10,000 | $9,800 | 2.0% | Non | ✅ Continue |
| $10,000 | $9,550 | 4.5% | Non | ⚠️ Attention |
| $10,000 | $9,500 | 5.0% | **OUI** | 🚨 TOUT FERMER |
| $10,000 | $9,200 | 8.0% | **OUI** | 🚨 TOUT FERMER |
| $10,000 | $10,200 | 0% | Non | ✅ En profit |

---

## 💰 Balance vs Equity : la différence cruciale

### Définitions

| Terme | Définition | Inclut les trades ouverts ? |
|:---:|:---|:---:|
| **Balance** | Solde du compte (trades fermés uniquement) | ❌ Non |
| **Equity** | Balance + profits/pertes flottants | ✅ Oui |
| **Marge** | Capital utilisé comme garantie | - |
| **Marge libre** | Equity - Marge | - |

### Exemple concret

```
Situation :
  Balance = $10,000 (aucun trade fermé aujourd'hui)
  Position ouverte BUY EURUSD : -$480 (perte flottante)

  Balance        = $10,000 → "Pas de perte" ← FAUX !
  Equity         = $9,520  → "Perte de $480" ← VRAI
  Drawdown réel  = 4.8%    → Proche du seuil de 5% ⚠️
```

**Si on calculait le drawdown avec le Balance, on ne verrait pas la perte de $480 !** C'est exactement comme ça que des traders se font éliminer des Prop Firms : ils ne surveillent que le Balance.

```mql5
// ❌ MAUVAIS : utiliser le Balance
double dd = (soldeDuJour - AccountInfoDouble(ACCOUNT_BALANCE)) / soldeDuJour * 100;

// ✅ BON : utiliser l'Equity
double dd = (soldeDuJour - AccountInfoDouble(ACCOUNT_EQUITY)) / soldeDuJour * 100;
```

---

## 🔄 Le bug de l'itération : boucle inversée

Ce pattern est un **classique** en MQL5 et dans tout langage de programmation quand on supprime des éléments d'une liste tout en la parcourant.

### Le problème

```
Liste : [A, B, C, D]
Index :  0  1  2  3

Supprimer de gauche à droite :
  i=0: Supprimer A → Liste: [B, C, D], index: 0, 1, 2
  i=1: Supprimer C (pas B !) → B est sauté !
  i=2: Supprimer D
  Résultat : [B] → B n'a pas été supprimé ❌
```

### La solution

```
Liste : [A, B, C, D]
Index :  0  1  2  3

Supprimer de droite à gauche :
  i=3: Supprimer D → Liste: [A, B, C]
  i=2: Supprimer C → Liste: [A, B]
  i=1: Supprimer B → Liste: [A]
  i=0: Supprimer A → Liste: []
  Résultat : [] → Tout est supprimé ✅
```

**Retenez cette règle : quand vous supprimez des éléments d'une liste en boucle, parcourez DE LA FIN VERS LE DÉBUT.**

---

## 🏢 Prop Firms et règles de drawdown

### Règles typiques des principales Prop Firms

| Prop Firm | DD Daily Max | DD Total Max | Taille compte |
|:---:|:---:|:---:|:---:|
| FTMO | **5%** | 10% | $10K-$200K |
| MyForexFunds | **5%** | 12% | $5K-$300K |
| The5ers | **4%** | 6% | $20K-$250K |
| Funding Pips | **5%** | 10% | $5K-$100K |
| True Forex Funds | **5%** | 10% | $10K-$400K |

### Comment notre EA aide les Prop Firms

```
SANS notre EA :
  → Vous tradez → Perte cumulée = 4.8%
  → "Encore un trade..." → Total = 6%
  → 🚨 ÉLIMINÉ DE LA PROP FIRM
  → Vous perdez votre accès ET vos frais d'inscription

AVEC notre EA (configuré à 4.5% pour avoir une marge) :
  → Perte cumulée = 4.5%
  → 🛑 EA ferme tout
  → "Mais je voulais..." → NON, l'EA dit NON
  → Vous gardez votre compte pour demain ✅
```

### Configuration recommandée pour Prop Firms

```
Max_DD_Pourcentage = 4.5%   (marge de sécurité de 0.5%)
```

**Pourquoi 4.5% et pas 5% ?**
- Le slippage peut causer une perte légèrement supérieure au SL
- Le spread peut s'élargir pendant les news
- Un gap peut sauter votre SL
- **Avoir 0.5% de marge peut sauver votre compte**

---

## ⚙️ Configuration et paramètres

| Paramètre | Type | Défaut | Description |
|:---:|:---:|:---:|:---|
| `Max_DD_Pourcentage` | double | 5.0 | Perte max quotidienne en % du solde |

### Configurations recommandées

| Profil | DD Max | Pour qui ? |
|:---:|:---:|:---|
| Prop Firm standard | 4.5% | FTMO, MFF, Funding Pips |
| Prop Firm prudent | 3.0% | The5ers, comptes stricts |
| Compte personnel | 5-10% | Traders indépendants |
| Scalper | 2-3% | Petits gains, petites pertes |
| Swing trader | 5-8% | Mouvements plus larges |

---

## ❌ Gestion des erreurs

### Erreurs de paramètres

| Erreur | Cause | Solution |
|:---:|:---|:---|
| DD ≤ 0 | Valeur négative ou nulle | Entrez un pourcentage positif |
| DD ≥ 100 | Valeur aberrante | Utilisez 1-10% pour la plupart des cas |

### Erreurs de fermeture

| Situation | Cause | Impact |
|:---:|:---|:---|
| Position non fermée | Marché fermé | L'EA retente au prochain tick |
| Slippage | Volatilité élevée | Perte légèrement supérieure |
| Requête rejetée | Rate limit broker | Retry automatique |

---

## 🧪 Tests et backtest

### Test en temps réel (compte démo)

1. Ouvrez un **compte démo** avec un solde connu (ex : $10,000)
2. Configurez le Max DD à **2%** (pour tester facilement)
3. Ouvrez plusieurs positions sur différents symboles
4. Laissez les pertes s'accumuler jusqu'au seuil
5. Vérifiez que **TOUTES** les positions sont fermées
6. Vérifiez que l'EA **ne laisse plus ouvrir** de trades

### Points à vérifier

- [ ] Le solde de référence est correct au démarrage
- [ ] Le drawdown est calculé avec l'Equity (pas le Balance)
- [ ] TOUTES les positions sont fermées quand le seuil est atteint
- [ ] L'EA s'arrête après la fermeture (pas de nouveau trading)
- [ ] Le lendemain, l'EA reprend automatiquement avec un nouveau solde
- [ ] Les logs affichent toutes les informations de fermeture

---

## ❓ FAQ

### L'EA bloque-t-il l'ouverture de nouvelles positions ?

**Non directement.** L'EA ferme les positions existantes et se met en pause (`JourneeFinie = true`). Un autre EA pourrait théoriquement ouvrir de nouvelles positions. Pour une protection complète, combinez avec les autres modules de gestion de risque.

### Le jour se réinitialise à quelle heure ?

À **minuit heure du broker** (pas votre heure locale). L'EA utilise `iTime(_Symbol, PERIOD_D1, 0)` qui correspond à l'heure du serveur. Attention : l'heure du broker peut différer de votre heure locale.

### Le drawdown inclut-il les commissions et swaps ?

**Oui**, car l'Equity (`ACCOUNT_EQUITY`) prend en compte tout : profits, pertes, commissions, et swaps. C'est l'image la plus fidèle de la valeur réelle du compte.

### Puis-je configurer le drawdown en devise ($ au lieu de %) ?

Ce tutoriel utilise le pourcentage, qui est le standard des Prop Firms. Pour un seuil en devise, vous pouvez modifier la comparaison dans `OnTick()` pour utiliser `CalculerDrawdownDevise()` au lieu de `CalculerDrawdownJournalier()`.

### Que se passe-t-il si l'EA est redémarré en cours de journée ?

Le solde de référence est capturé à l'initialisation (`OnInit`). Si l'EA est redémarré en milieu de journée, le nouveau solde de référence sera le solde **actuel** (qui peut déjà inclure des pertes). Pour une solution plus robuste, utilisez des GlobalVariables pour stocker le solde de début de journée.

### Cet EA ouvre-t-il des positions ?

**Non.** C'est un EA de **protection pure**. Il ne fait que surveiller le drawdown et fermer des positions existantes.

---

## 🔗 Liens utiles

### Nos autres tutoriels
- 🛡️ [Tuto MT5 — Stop Loss Automatique](https://github.com/VOTRE_USER/Tuto-MT5-Stop-Loss-Automatique)
- 🎯 [Tuto MT5 — Take Profit Automatique](https://github.com/VOTRE_USER/Tuto-MT5-Take-Profit-Automatique)
- 📊 [Tuto MT5 — TP Partiel Automatique](https://github.com/VOTRE_USER/Tuto-MT5-TP-Partiel-Automatique)
- 📈 [Tuto MT5 — Trailing Stop Automatique](https://github.com/VOTRE_USER/Tuto-MT5-Trailing-Stop-Automatique)
- 🔒 [Tuto MT5 — Break Even Automatique](https://github.com/VOTRE_USER/Tuto-MT5-Break-Even-Automatique)

### Documentation officielle
- 📖 [Documentation MQL5 complète](https://www.mql5.com/fr/docs)
- 📖 [AccountInfoDouble (ACCOUNT_EQUITY)](https://www.mql5.com/fr/docs/account/accountinfodouble)
- 📖 [Classe CTrade - PositionClose](https://www.mql5.com/fr/docs/standardlibrary/tradeclasses/ctrade/ctradepositionclose)

### Téléchargements
- ⬇️ [MetaTrader 5](https://www.metatrader5.com/fr/download)

---

### 🎬 Vidéo tutoriel

[![Voir la vidéo sur YouTube](https://img.youtube.com/vi/HrCb3Lcgyd0/maxresdefault.jpg)](https://www.youtube.com/watch?v=HrCb3Lcgyd0)

---

## 📄 Licence

Ce projet est sous licence [MIT](LICENSE). Vous êtes libre de l'utiliser, le modifier et le distribuer.

---

<p align="center">
  Fait par <a href="https://autoea.online">EA Creator</a>
</p>
