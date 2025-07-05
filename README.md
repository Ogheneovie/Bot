# Bot
EA Overview (MimicNYBot – MT4 & MT5)

This EA mimics the 2am NY candle at 8am and 4pm NY time.

Key Logic:

Inputs: Risk %, SL/TP in pips, reference time (default 2am), mimic times (default 8am, 4pm).

Reference Candle: Captures 2am candle direction (bullish/bearish).

Trend Detection: Compares recent highs/lows to detect uptrend or downtrend.

Candlestick Filter: Trades only if patterns like bullish/bearish engulfing match.

Trade Entry: Executes trade at mimic time if trend + pattern align or mirror 2am direction.


What to Improve/Fix:

Use RiskPercent to calculate dynamic lot size.

Confirm time logic matches broker server time.

Expand candlestick pattern support.

Add logging for easier debugging.
