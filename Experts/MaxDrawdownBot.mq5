//+------------------------------------------------------------------+
//|                                        MaxDrawdownBot.mq5        |
//|               Tuto MT5 - Max Drawdown Daily Automatique          |
//|                         https://autoea.online                    |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| DESCRIPTION GÉNÉRALE                                             |
//|                                                                  |
//| Cet Expert Advisor (EA) surveille la perte quotidienne du        |
//| compte et FERME TOUTES LES POSITIONS si le drawdown dépasse     |
//| un seuil configuré (en pourcentage ou en devise).                |
//|                                                                  |
//| Qu'est-ce que le "Max Drawdown Daily" ?                          |
//|                                                                  |
//| C'est la perte maximale autorisée sur UNE JOURNÉE de trading.   |
//| Si le compte perd plus que ce seuil, l'EA :                      |
//|   1. Ferme TOUTES les positions ouvertes                          |
//|   2. Arrête de trader pour le reste de la journée                 |
//|                                                                  |
//| Exemple (Prop Firm FTMO, compte $100,000) :                      |
//|   Max Drawdown Daily = 5% = $5,000                               |
//|   Le compte perd $4,800 sur la journée                           |
//|   → Plus que $200 de marge avant le seuil !                       |
//|   → L'EA ferme tout pour ne pas risquer l'élimination             |
//|                                                                  |
//| POURQUOI C'EST ESSENTIEL :                                       |
//|                                                                  |
//| ✅ OBLIGATOIRE pour les Prop Firms (FTMO, MFF, The5ers...)       |
//| ✅ Protège contre les trades émotionnels ("revenge trading")     |
//| ✅ Discipline automatique sans intervention humaine               |
//| ✅ Sauvegarde le compte en cas de mouvement violent du marché     |
//|                                                                  |
//| STRUCTURE DES FICHIERS :                                         |
//|                                                                  |
//| MaxDrawdownBot.mq5              ← Fichier principal (celui-ci)   |
//|  ├── Include/TradeSelector.mqh   ← Sélection des positions       |
//|  ├── Include/DDCalculator.mqh    ← Calcul du drawdown            |
//|  └── Include/TradeManager.mqh    ← Fermeture de toutes positions |
//+------------------------------------------------------------------+

// ===================================================================
// PROPRIÉTÉS DE L'EA
// ===================================================================

#property copyright   "EA Creator - autoea.online"
#property link        "https://autoea.online"
#property version     "1.00"
#property description "EA qui ferme tout si la perte quotidienne"
#property description "dépasse le seuil configuré (Max Drawdown)."
#property description ""
#property description "Générateur EA sans code : https://autoea.online"

// ===================================================================
// INCLUSIONS
// ===================================================================

#include "Include\TradeSelector.mqh"   // Sélection des positions
#include "Include\DDCalculator.mqh"    // Calcul du drawdown
#include "Include\TradeManager.mqh"    // Fermeture des positions

// ===================================================================
// PARAMÈTRES D'ENTRÉE (INPUT)
// ===================================================================

// Perte quotidienne maximale autorisée, en POURCENTAGE du solde.
// Si la perte du jour dépasse ce pourcentage, l'EA ferme tout.
//
// Exemples :
//   5.0 = 5% du solde du jour (standard Prop Firm)
//   3.0 = 3% de drawdown max (configuration prudente)
//  10.0 = 10% (très agressif, risqué)
input double Max_DD_Pourcentage = 5.0;    // Max Drawdown Daily (%)

// ===================================================================
// VARIABLES GLOBALES
// ===================================================================

// Solde de référence du jour (capturé à l'initialisation ou au
// changement de jour). Le drawdown est calculé par rapport à ce solde.
double SoldeDuJour = 0;

// Date du jour courant (pour détecter le changement de journée)
datetime DateDuJour;

// Flag indiquant si le seuil a été atteint aujourd'hui
// Si true, l'EA ne fait plus rien jusqu'au lendemain
bool JourneeFinie = false;

// ===================================================================
// FONCTION OnInit()
// ===================================================================

int OnInit()
{
    if(Max_DD_Pourcentage <= 0 || Max_DD_Pourcentage >= 100)
    {
        Print("❌ ERREUR : Le drawdown max doit être entre 0 et 100% !");
        return INIT_PARAMETERS_INCORRECT;
    }

    // Capturer le solde initial du jour
    SoldeDuJour = AccountInfoDouble(ACCOUNT_BALANCE);
    DateDuJour = iTime(_Symbol, PERIOD_D1, 0);
    JourneeFinie = false;

    // Calculer le seuil en devise
    double seuilDevise = SoldeDuJour * (Max_DD_Pourcentage / 100.0);

    Print("══════════════════════════════════════════");
    Print("🛡️ Max Drawdown Bot démarré !");
    Print("   Solde du jour  : ", SoldeDuJour, " ", AccountInfoString(ACCOUNT_CURRENCY));
    Print("   Max DD         : ", Max_DD_Pourcentage, "%");
    Print("   Seuil en devise: -", DoubleToString(seuilDevise, 2),
          " ", AccountInfoString(ACCOUNT_CURRENCY));
    Print("   Solde minimum  : ", DoubleToString(SoldeDuJour - seuilDevise, 2),
          " ", AccountInfoString(ACCOUNT_CURRENCY));
    Print("══════════════════════════════════════════");

    return INIT_SUCCEEDED;
}

// ===================================================================
// FONCTION OnDeinit()
// ===================================================================

void OnDeinit(const int reason)
{
    Print("🛑 Max Drawdown Bot arrêté. Raison : ", reason);
}

// ===================================================================
// FONCTION OnTick() — CŒUR DE L'EA
// ===================================================================

void OnTick()
{
    // ─────────────────────────────────────────────────
    // ÉTAPE 1 : Détecter le changement de jour
    // ─────────────────────────────────────────────────
    // Quand un nouveau jour commence, on réinitialise :
    // - Le solde de référence
    // - Le flag "journée finie"

    datetime dateActuelle = iTime(_Symbol, PERIOD_D1, 0);

    if(dateActuelle != DateDuJour)
    {
        DateDuJour = dateActuelle;
        SoldeDuJour = AccountInfoDouble(ACCOUNT_BALANCE);
        JourneeFinie = false;

        double seuilDevise = SoldeDuJour * (Max_DD_Pourcentage / 100.0);

        Print("══════════════════════════════════════════");
        Print("📅 NOUVEAU JOUR détecté !");
        Print("   Nouveau solde de référence : ", SoldeDuJour);
        Print("   Seuil de perte : -", DoubleToString(seuilDevise, 2));
        Print("══════════════════════════════════════════");
    }

    // ─────────────────────────────────────────────────
    // ÉTAPE 2 : Vérifier si la journée est déjà finie
    // ─────────────────────────────────────────────────
    if(JourneeFinie)
        return;   // Le drawdown a été atteint, on ne fait plus rien

    // ─────────────────────────────────────────────────
    // ÉTAPE 3 : Calculer le drawdown actuel
    // ─────────────────────────────────────────────────
    double drawdownPourcentage = CalculerDrawdownJournalier(SoldeDuJour);

    // ─────────────────────────────────────────────────
    // ÉTAPE 4 : Vérifier le seuil
    // ─────────────────────────────────────────────────
    if(drawdownPourcentage < Max_DD_Pourcentage)
        return;   // Drawdown OK, pas d'action

    // ─────────────────────────────────────────────────
    // ⚠️ SEUIL ATTEINT ! FERMER TOUT !
    // ─────────────────────────────────────────────────

    Print("══════════════════════════════════════════");
    Print("🚨🚨🚨 MAX DRAWDOWN ATTEINT ! 🚨🚨🚨");
    Print("   Drawdown actuel   : ", DoubleToString(drawdownPourcentage, 2), "%");
    Print("   Seuil configuré   : ", Max_DD_Pourcentage, "%");
    Print("   → FERMETURE DE TOUTES LES POSITIONS !");
    Print("══════════════════════════════════════════");

    // Fermer toutes les positions de TOUS les symboles
    int nbFermees = FermerToutesPositions();

    Print("📊 Bilan : ", nbFermees, " position(s) fermée(s)");

    // Marquer la journée comme terminée
    JourneeFinie = true;

    Print("🛑 EA en pause jusqu'à demain.");
    Print("   Le trading reprendra automatiquement au prochain jour.");
}
