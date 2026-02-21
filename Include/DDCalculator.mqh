//+------------------------------------------------------------------+
//|                                              DDCalculator.mqh    |
//|               Tuto MT5 - Max Drawdown Daily                      |
//|                         https://autoea.online                    |
//+------------------------------------------------------------------+
#property copyright "EA Creator - autoea.online"
#property link      "https://autoea.online"

//+------------------------------------------------------------------+
//| Fonction : CalculerDrawdownJournalier                            |
//| Calcule le drawdown quotidien en pourcentage.                    |
//|                                                                  |
//| Le drawdown journalier mesure combien le compte a PERDU          |
//| depuis le début de la journée (minuit broker).                   |
//|                                                                  |
//| FORMULE :                                                        |
//|                                                                  |
//|   Equity = Solde + Profits flottants (non réalisés)              |
//|   Perte du jour = Solde du jour - Equity actuelle                |
//|   Drawdown % = (Perte du jour / Solde du jour) × 100            |
//|                                                                  |
//| POURQUOI UTILISER L'EQUITY ET PAS LE BALANCE ?                   |
//|                                                                  |
//| Le Balance (solde) ne reflète que les trades FERMÉS.             |
//| L'Equity inclut les profits/pertes des trades OUVERTS.           |
//|                                                                  |
//| Exemple :                                                        |
//|   Solde du jour : $10,000                                        |
//|   Solde actuel  : $10,000 (aucun trade fermé)                    |
//|   Mais positions ouvertes en perte de -$400                       |
//|   → Equity = $10,000 - $400 = $9,600                             |
//|   → Drawdown = ($10,000 - $9,600) / $10,000 = 4%                |
//|                                                                  |
//| Si on utilisait seulement le Balance, on ne verrait pas          |
//| la perte de $400 jusqu'à la fermeture du trade !                  |
//| C'est pour ça que les Prop Firms utilisent l'Equity.             |
//|                                                                  |
//| ATTENTION : Les Prop Firms calculent parfois le drawdown         |
//| différemment (à partir du plus haut equity, pas du solde).       |
//| Notre implémentation utilise le "solde du jour" comme            |
//| référence, ce qui est le cas le plus courant (FTMO).             |
//+------------------------------------------------------------------+
//| Paramètres :                                                     |
//|   soldeDuJour (double) - solde à 0h00 (référence)               |
//| Retour : double - drawdown en % (positif = perte)                |
//+------------------------------------------------------------------+
double CalculerDrawdownJournalier(double soldeDuJour)
{
    // L'Equity = Solde + Profits flottants
    // AccountInfoDouble(ACCOUNT_EQUITY) retourne cette valeur en temps réel
    double equity = AccountInfoDouble(ACCOUNT_EQUITY);

    // Calculer la perte du jour
    // Si equity > solde du jour → le compte est en gain → drawdown = 0
    // Si equity < solde du jour → le compte est en perte → drawdown > 0
    double perteDuJour = soldeDuJour - equity;

    // Si pas de perte (gain ou flat), drawdown = 0
    if(perteDuJour <= 0)
        return 0.0;

    // Calculer le pourcentage de drawdown
    double drawdownPourcent = (perteDuJour / soldeDuJour) * 100.0;

    return drawdownPourcent;
}

//+------------------------------------------------------------------+
//| Fonction : CalculerDrawdownDevise                                |
//| Retourne le drawdown en devise (dollars, euros...).              |
//+------------------------------------------------------------------+
double CalculerDrawdownDevise(double soldeDuJour)
{
    double equity = AccountInfoDouble(ACCOUNT_EQUITY);
    double perteDuJour = soldeDuJour - equity;

    if(perteDuJour <= 0)
        return 0.0;

    return perteDuJour;
}

//+------------------------------------------------------------------+
//| Fonction : ObtenirInfosCompte                                    |
//| Affiche les informations complètes du compte pour le debug.      |
//+------------------------------------------------------------------+
void ObtenirInfosCompte(double soldeDuJour, double maxDDPourcent)
{
    double equity = AccountInfoDouble(ACCOUNT_EQUITY);
    double balance = AccountInfoDouble(ACCOUNT_BALANCE);
    double profit = AccountInfoDouble(ACCOUNT_PROFIT);
    string devise = AccountInfoString(ACCOUNT_CURRENCY);

    double ddPourcent = CalculerDrawdownJournalier(soldeDuJour);
    double ddDevise = CalculerDrawdownDevise(soldeDuJour);
    double seuilDevise = soldeDuJour * (maxDDPourcent / 100.0);

    Print("═══════════════════════════════════════");
    Print("📊 ÉTAT DU COMPTE");
    Print("═══════════════════════════════════════");
    Print("   Solde du jour (réf)  : ", DoubleToString(soldeDuJour, 2), " ", devise);
    Print("   Solde actuel         : ", DoubleToString(balance, 2), " ", devise);
    Print("   Equity actuelle      : ", DoubleToString(equity, 2), " ", devise);
    Print("   Profit flottant      : ", DoubleToString(profit, 2), " ", devise);
    Print("   ─────────────────────────────────");
    Print("   Drawdown du jour     : ", DoubleToString(ddPourcent, 2), "% (",
          DoubleToString(ddDevise, 2), " ", devise, ")");
    Print("   Seuil max            : ", DoubleToString(maxDDPourcent, 2), "% (",
          DoubleToString(seuilDevise, 2), " ", devise, ")");
    Print("   Marge restante       : ", DoubleToString(seuilDevise - ddDevise, 2), " ", devise);
    Print("   Positions ouvertes   : ", PositionsTotal());
    Print("═══════════════════════════════════════");
}
