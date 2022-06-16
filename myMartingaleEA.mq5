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
input double firstVolume = 0.1;
input double rate = 1.5;
input double pip = 10;
input double pendingOrderPrice = 0.0;
input bool isBuy = true;
bool isDone = false;
bool isError = false;
bool isFirst = true;


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

   
   //--- enter buy/sell stop if there's no existing trade
   if(PositionsTotal() <= 0 && OrdersTotal() <= 0 && !isDone && !isError && isFirst) {
      if(isBuy){
         double askPrice = pendingOrderPrice;
         double posVol = NormalizeDouble(firstVolume,rate);
         double sl = askPrice - (pip * GetPipValue());
         double tp = askPrice + (pip * 2 * GetPipValue());
      
         Print("--Entering first buy stop at: ask: " + askPrice + "sl: " + sl + "tp: " + tp);
         trade.BuyStop(posVol,askPrice,_Symbol,sl,tp);
         
      } else if(!isBuy) {
         double bidPrice = pendingOrderPrice;
         double posVol = NormalizeDouble(firstVolume,rate);
         double sl = bidPrice + (pip * GetPipValue());
         double tp = bidPrice - (pip * 2 * GetPipValue());
                  
         Print("--Entering first sell stop at: bid: " + bidPrice + "sl: " + sl + "tp: " + tp);
         trade.SellStop(posVol,bidPrice,_Symbol,sl,tp);
      }
           
      posTicket = trade.ResultOrder();
      Print("--Ticket: " + posTicket);
            
      if(posTicket <= 0)
        {
         Print("Something went wrong!!");
         isError = true;
        } 
   }
   
   if(PositionsTotal() <= 0 && OrdersTotal() >= 0 && !isDone && !isFirst) {
      Print("There are no positions. There is " + OrdersTotal() + " order ");
      ulong orderTicket = OrderGetTicket(0);         
      trade.OrderDelete(orderTicket);
      isDone = true;   
   }

   
   if(PositionSelect(_Symbol) && !isDone && !isError) {
      isFirst = false;
      //Print("=== There's an active position: " + _Symbol);   
      double posCurrentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
      double posOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double posSl = PositionGetDouble(POSITION_SL);
      double posTp = PositionGetDouble(POSITION_TP);
      int posType = PositionGetInteger(POSITION_TYPE);
      
       
           
      Comment("openPrice: " + posOpenPrice, "\n", 
         "currPrice: " + posCurrentPrice, "\n",
         "posSl: " + posSl, "\n",
         "posTp: " + posTp, "\n",
         "orders: " + OrdersTotal(), "\n",
         "positions: " + PositionsTotal(), "\n",
         "ticket: " + posTicket, "\n",
         "count: " + count );
         
  
         
      if(OrdersTotal() <= 0) {
         if(posType ==  POSITION_TYPE_BUY) {
            //--- open sell pending order         
            Print("====Opening sell pending order...");
            if(count <= 1) {
               // first time
               Print("== First Time");
               double posVol = NormalizeDouble(firstVolume * rate,2);
               double bidPrice = posSl;
               double sl = posOpenPrice;
               double tp = bidPrice - (pip * 2 * GetPipValue());
               Print("--->..sl:" + sl + "..tp: " + tp + "..bid: " + bidPrice + "..volume: " + posVol);
               Print("---> volume: " + posVol);
               trade.SellStop(posVol,bidPrice,_Symbol,sl,tp);
               posTicket = trade.ResultOrder();
                               
            } else {
               // other times
               Print("== Second Time");
               double posVol = NormalizeDouble(firstVolume * pow(rate,count),2);
               double bidPrice = posSl;
               double sl = posOpenPrice;
               double tp = posSl - (pip * 2 * GetPipValue());
               Print("--->....sl:" + sl + "..tp: " + tp + "..bid: " + bidPrice + "..volume: " + posVol);
               Print("---> volume: " + posVol);
               trade.SellStop(posVol,bidPrice,_Symbol,sl,tp);
               posTicket = trade.ResultOrder();
               
            }
            
            count += 1;
            
         } else if(posType == POSITION_TYPE_SELL) {
            //--- open buy pending order
            Print("===Opening buy pending order...");
            if(count <= 1) {
               Print("== First Time");
               double posVol = NormalizeDouble(firstVolume * rate, 2);
               double askPrice = posSl;
               double sl = posOpenPrice;
               double tp = askPrice + (pip * 2 * GetPipValue());
               Print("--->..sl:" + sl + "..tp: " + tp + "..ask: " + askPrice + "..volume: " + posVol);
               Print("---> volume: " + posVol);
               trade.BuyStop(posVol,askPrice,_Symbol,sl,tp); 
               posTicket = trade.ResultOrder();
                               
            } else {
               // other times
               Print("== Second Time");
               double posVol = NormalizeDouble(firstVolume * pow(rate,count), 2);
               double askPrice = posSl;
               double sl = posOpenPrice;
               double tp = posSl + (pip * 2 * GetPipValue());
               Print("--->....sl:" + sl + "..tp: " + tp + "..ask: " + askPrice + "..volume: " + posVol);
               Print("---> volume: " + posVol);
               trade.BuyStop(posVol,askPrice,_Symbol,sl,tp);
               posTicket = trade.ResultOrder();
               
            }
            
            count += 1;
         }
      }      
    }
    
    if(isDone && PositionsTotal() <= 0 && OrdersTotal() > 0 &!isError) {
       Print("CONGRATULATIONS!! YOUVE HIT THE TAKE PROFIT!!");
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


