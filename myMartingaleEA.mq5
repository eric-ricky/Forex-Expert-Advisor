//+------------------------------------------------------------------+
//|                                               myMartingaleEA.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade/Trade.mqh>
#include <matingaleHelpers.mqh>

CTrade trade;
ulong posTicket;
double count = 1;
double firstVolume = 0.01;
double firstPip = 100;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   
   //--- enter buy trade if there's no existing trade
   if(PositionsTotal() <= 0) {      
      double askPrice = CurrentAsk();
      double sl = askPrice - (firstPip * GetPipValue());
      double tp = askPrice + (firstPip * GetPipValue());
      
      Print("--Entering first buy order at: ask: " + askPrice + "sl: " + sl + "tp: " + tp);
      
      trade.Buy(firstVolume,_Symbol,CurrentAsk(),sl,tp);      
      posTicket = trade.ResultOrder();
      
      Print("--Ticket: " + posTicket);
      
      if(posTicket <= 0)
        {
         Print("Something went wrong!!");
         posTicket = 1;
        } 
   }
   
   
   
   if(PositionSelect(_Symbol)) {
      //Print("=== There's an active position: " + _Symbol);   
      double posCurrentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
      double posOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double posSl = PositionGetDouble(POSITION_SL);
      double posTp = PositionGetDouble(POSITION_TP);
      int posType = PositionGetInteger(POSITION_TYPE);
      
      //Print("....sl: " + posSl + "..tp: " + posTp);     
      Comment("openPrice: " + posOpenPrice, "\n", 
         "currPrice: " + posCurrentPrice, "\n",
         "posSl: " + posSl, "\n",
         "posTp: " + posTp, "\n",
         "orders: " + OrdersTotal(), "\n",
         "positions: " + PositionsTotal(), "\n",
         "count: " + count );
         
      if(OrdersTotal() <= 0) {
         if(posType ==  POSITION_TYPE_BUY) {
            //--- open sell pending order         
            Print("====Opening sell pending order...");
            if(count <= 1) {
               // first time
               Print("== First Time");
               double posVol = firstVolume * 2;
               double bidPrice = posSl;
               double sl = posOpenPrice;
               double tp = bidPrice - ((firstPip * 2) * GetPipValue());
               Print("--->..sl:" + sl + "..tp: " + tp + "..bid: " + bidPrice + "..volume: " + posVol);
               Print("---> volume: " + posVol);
               trade.SellStop(posVol,bidPrice,_Symbol,sl,tp);
                               
            } else {
               // other times
               Print("== Second Time");
               double posVol = firstVolume * pow(2,count);
               double bidPrice = posSl;
               double sl = posOpenPrice;
               double tp = posSl - ((firstPip * pow(2,count)) * GetPipValue());
               Print("--->....sl:" + sl + "..tp: " + tp + "..bid: " + bidPrice + "..volume: " + posVol);
               Print("---> volume: " + posVol);
               trade.SellStop(posVol,bidPrice,_Symbol,sl,tp);  
            }
            
            count += 1;
            
         } else if(posType == POSITION_TYPE_SELL) {
            //--- open buy pending order
            Print("===Opening buy pending order...");
            if(count <= 1) {
               Print("== First Time");
               double posVol = firstVolume * 2;
               double askPrice = posSl;
               double sl = posOpenPrice;
               double tp = askPrice + ((firstPip * 2) * GetPipValue());
               Print("--->..sl:" + sl + "..tp: " + tp + "..ask: " + askPrice + "..volume: " + posVol);
               Print("---> volume: " + posVol);
               trade.BuyStop(posVol,askPrice,_Symbol,sl,tp);                 
            } else {
               // other times
               Print("== Second Time");
               double posVol = firstVolume * pow(2,count);
               double askPrice = posSl;
               double sl = posOpenPrice;
               double tp = posSl + ((firstPip * pow(2,count)) * GetPipValue());
               Print("--->....sl:" + sl + "..tp: " + tp + "..ask: " + askPrice + "..volume: " + posVol);
               Print("---> volume: " + posVol);
               trade.BuyStop(posVol,askPrice,_Symbol,sl,tp);
            }
            
            count += 1;
         }
      }
      
      
      if(posCurrentPrice == posTp) {
         Print("CONGRATULATIONS!! YOUVE HIT THE TAKE PROFIT!!");
      }   
    }
   
   
   //--- if there is an existing position
   //if(PositionSelectByTicket(posTicket)) {
     // double posCurrentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
      //double posSl = PositionGetDouble(POSITION_SL);
      //double posTp = PositionGetDouble(POSITION_TP);
 //     int posType = PositionGetInteger(POSITION_TYPE);
 //    
 //     if(posCurrentPrice == posSl) {
  //      count += 1;
    //     if(posType == POSITION_TYPE_BUY) {
      //      Print("Entering " + count + "nd order, sell, at" + CurrentAsk());
        //    double volume = pow((firstVolume * 2),count);
          //  double bidPrice = CurrentBid();
            //double sl = posSl;
            //double tp = bidPrice + pow((firstPip * 2), count) * GetPipValue();
            //trade.Sell(firstVolume,_Symbol,CurrentAsk(),sl,tp);
   //      } else if(POSITION_TYPE_SELL) {
     //       Print("Entering " + count + "nd order, buy, at" + CurrentAsk());
       //     double volume = pow((firstVolume * 2), count);
         //   double askPrice = CurrentBid();
           // double sl = posSl;
            //double tp = askPrice + pow((firstPip * 2), count) * GetPipValue();
   //         trade.Sell(firstVolume,_Symbol,CurrentAsk(),sl,tp);
     //    }
//      } else if(posCurrentPrice == posTp) {
  //       Print("CONGRATULATIONS!! YOUVE HIT THE TAKE PROFIT");
    //  }
      
  // }
   
   




//   double askPrice = CurrentAsk();
//   double bidPrice = CurrentBid();
//   Comment("ask: " + askPrice, "\n", 
  //          "bid: " + bidPrice, "\n",
//            "positions: " + PositionsTotal(), "\n",
//            "orders: " + OrdersTotal(), "\n",
   //         "count: " + count );
  }
//+------------------------------------------------------------------+


