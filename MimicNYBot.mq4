#property strict

extern double RiskPercent = 1.0;
extern int SL_Pips = 10;
extern int TP_Pips = 20;
extern int ReferenceHour = 2;
extern string MimicTimes = "08:00,16:00";

datetime refTime;
int refDir = 0;

int OnInit() {
    Print("Mimic NY Bot (MT4) initialized");
    return(INIT_SUCCEEDED);
}

void OnTick() {
    datetime now = TimeCurrent();
    string today = TimeToString(now, TIME_DATE);
    refTime = StrToTime(today + " " + IntegerToString(ReferenceHour) + ":00");

    // Save 2am reference candle
    if (TimeCurrent() == refTime) {
        double openRef = iOpen(Symbol(), PERIOD_M5, 0);
        double closeRef = iClose(Symbol(), PERIOD_M5, 0);
        refDir = closeRef > openRef ? 1 : -1;
    }

    // Parse mimic times
    for (int i = 0; i < StringLen(MimicTimes); i++) {
        string mimic = StringSubstr(MimicTimes, i * 6, 5);
        datetime mimicTime = StrToTime(today + " " + mimic);
        if (TimeCurrent() >= mimicTime && TimeCurrent() < mimicTime + 60) {
            double highNow = iHigh(Symbol(), PERIOD_M5, 0);
            double highPrev = iHigh(Symbol(), PERIOD_M5, 12);
            double lowNow = iLow(Symbol(), PERIOD_M5, 0);
            double lowPrev = iLow(Symbol(), PERIOD_M5, 12);
            int trend = (highNow > highPrev && lowNow > lowPrev) ? 1 : (highNow < highPrev && lowNow < lowPrev) ? -1 : 0;

            double o1 = iOpen(Symbol(), PERIOD_M5, 1);
            double c1 = iClose(Symbol(), PERIOD_M5, 1);
            double o0 = iOpen(Symbol(), PERIOD_M5, 0);
            double c0 = iClose(Symbol(), PERIOD_M5, 0);
            bool isBullishEngulfing = (c1 < o1 && c0 > o0 && c0 > o1 && o0 < c1);
            bool isBearishEngulfing = (c1 > o1 && c0 < o0 && c0 < o1 && o0 > c1);

            int mimicDir = (trend != refDir && trend != 0) ? -refDir : refDir;
            double sl = SL_Pips * Point * 10;
            double tp = TP_Pips * Point * 10;

            if (mimicDir == 1 && isBullishEngulfing) {
                OrderSend(Symbol(), OP_BUY, 0.1, Ask, 3, Ask - sl, Ask + tp, "Buy", 0, 0, clrGreen);
            } else if (mimicDir == -1 && isBearishEngulfing) {
                OrderSend(Symbol(), OP_SELL, 0.1, Bid, 3, Bid + sl, Bid - tp, "Sell", 0, 0, clrRed);
            }
        }
    }
}
