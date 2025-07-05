#property strict

input double RiskPercent = 1.0;
input int SL_Pips = 10;
input int TP_Pips = 20;
input int ReferenceHour = 2;
input string MimicTimes = "08:00,16:00";

datetime refTime;
int refDir = 0;

int OnInit() {
    Print("Mimic NY Bot (MT5) initialized");
    return(INIT_SUCCEEDED);
}

void OnTick() {
    datetime now = TimeCurrent();
    string today = TimeToString(now, TIME_DATE);
    refTime = StringToTime(today + " " + IntegerToString(ReferenceHour) + ":00");

    if (now == refTime) {
        double openRef = iOpen(_Symbol, PERIOD_M5, 0);
        double closeRef = iClose(_Symbol, PERIOD_M5, 0);
        refDir = closeRef > openRef ? 1 : -1;
    }

    string times[]; StringSplit(MimicTimes, ',', times);
    for (int i = 0; i < ArraySize(times); i++) {
        datetime mimicTime = StringToTime(today + " " + times[i]);
        if (now >= mimicTime && now < mimicTime + 60) {
            double highNow = iHigh(_Symbol, PERIOD_M5, 0);
            double highPrev = iHigh(_Symbol, PERIOD_M5, 12);
            double lowNow = iLow(_Symbol, PERIOD_M5, 0);
            double lowPrev = iLow(_Symbol, PERIOD_M5, 12);
            int trend = (highNow > highPrev && lowNow > lowPrev) ? 1 : (highNow < highPrev && lowNow < lowPrev) ? -1 : 0;

            double o1 = iOpen(_Symbol, PERIOD_M5, 1);
            double c1 = iClose(_Symbol, PERIOD_M5, 1);
            double o0 = iOpen(_Symbol, PERIOD_M5, 0);
            double c0 = iClose(_Symbol, PERIOD_M5, 0);
            bool isBullishEngulfing = (c1 < o1 && c0 > o0 && c0 > o1 && o0 < c1);
            bool isBearishEngulfing = (c1 > o1 && c0 < o0 && c0 < o1 && o0 > c1);

            int mimicDir = (trend != refDir && trend != 0) ? -refDir : refDir;
            double sl = SL_Pips * _Point * 10;
            double tp = TP_Pips * _Point * 10;

            if (mimicDir == 1 && isBullishEngulfing) {
                trade.Buy(0.1, _Symbol, _Ask, sl, tp, "Buy Signal");
            } else if (mimicDir == -1 && isBearishEngulfing) {
                trade.Sell(0.1, _Symbol, _Bid, sl, tp, "Sell Signal");
            }
        }
    }
}
