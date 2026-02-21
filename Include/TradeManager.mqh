//+------------------------------------------------------------------+
//|                                              TradeManager.mqh    |
//|               Tuto MT5 - Max Drawdown Daily                      |
//|                         https://autoea.online                    |
//+------------------------------------------------------------------+
#property copyright "EA Creator - autoea.online"
#property link      "https://autoea.online"

#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Fonction : FermerToutesPositions                                  |
//| Ferme TOUTES les positions ouvertes sur TOUS les symboles.       |
//|                                                                  |
//| C'est la "bombe nucléaire" de la gestion du risque :             |
//| quand le drawdown est atteint, on sort de TOUT.                  |
//|                                                                  |
//| ATTENTION : On parcourt les positions À L'ENVERS car             |
//| la fermeture d'une position modifie les index.                   |
//|                                                                  |
//| Exemple (parcours normal, BUG) :                                 |
//|   index 0: EURUSD → fermé → les index changent !                |
//|   index 1: était GBPUSD, maintenant c'est... rien               |
//|   → On saute une position !                                      |
//|                                                                  |
//| Exemple (parcours inversé, CORRECT) :                             |
//|   index 2: USDJPY → fermé → index 0 et 1 inchangés              |
//|   index 1: GBPUSD → fermé → index 0 inchangé                    |
//|   index 0: EURUSD → fermé → tout est fermé ✅                    |
//+------------------------------------------------------------------+
//| Retour : int - nombre de positions fermées avec succès            |
//+------------------------------------------------------------------+
int FermerToutesPositions()
{
    CTrade trade;
    trade.SetDeviationInPoints(10);

    int nbFermees = 0;
    int total = PositionsTotal();

    Print("📤 Tentative de fermeture de ", total, " position(s)...");

    // Parcourir de la dernière à la première position
    for(int i = total - 1; i >= 0; i--)
    {
        ulong ticket = PositionGetTicket(i);

        if(ticket == 0)
            continue;

        string symbole = PositionGetString(POSITION_SYMBOL);
        double volume = PositionGetDouble(POSITION_VOLUME);
        double profit = PositionGetDouble(POSITION_PROFIT);

        Print("   Fermeture #", ticket, " | ", symbole,
              " | ", volume, " lots | P/L: ", profit);

        // PositionClose ferme 100% d'une position
        bool resultat = trade.PositionClose(ticket, 10);

        if(resultat)
        {
            uint codeRetour = trade.ResultRetcode();

            if(codeRetour == TRADE_RETCODE_DONE)
            {
                Print("   ✅ Fermé avec succès !");
                nbFermees++;
            }
            else
            {
                Print("   ⚠️ Code retour : ", codeRetour,
                      " — ", trade.ResultRetcodeDescription());
            }
        }
        else
        {
            Print("   ❌ Échec ! Code : ", trade.ResultRetcode(),
                  " — ", trade.ResultRetcodeDescription());
        }
    }

    return nbFermees;
}

//+------------------------------------------------------------------+
//| Fonction : AfficherInfoPosition                                  |
//| Affiche les infos d'une position pour le debug.                  |
//+------------------------------------------------------------------+
void AfficherInfoPosition(ulong ticket)
{
    Print("═══════════════════════════════════════");
    Print("📊 Position #", ticket);
    Print("═══════════════════════════════════════");
    Print("   Symbole       : ", PositionGetString(POSITION_SYMBOL));

    ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
    Print("   Type           : ", (type == POSITION_TYPE_BUY) ? "BUY" : "SELL");
    Print("   Prix ouverture : ", PositionGetDouble(POSITION_PRICE_OPEN));
    Print("   Volume (lots)  : ", PositionGetDouble(POSITION_VOLUME));
    Print("   Profit actuel  : ", PositionGetDouble(POSITION_PROFIT), " ",
          AccountInfoString(ACCOUNT_CURRENCY));
    Print("═══════════════════════════════════════");
}
