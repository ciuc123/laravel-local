<?php


namespace App\Http\Controllers;

class LeetcodeController extends Controller
{
    /**
     * @param int $problem
     * @return void
     */
    public function show(int $problem)
    {
        // Dispatch to the corresponding solver
        $method = 'problem' . $problem;

        if (method_exists($this, $method)) {
            return $this->$method();
        }

        abort(404);
    }

    /**
     * Leetcode 121. Best Time to Buy and Sell Stock
     *
     * @param $prices
     * @return int|mixed
     */
    protected function problem121()
    {
        $prices = [7,1,5,3,6,4];
//        $prices = [1,2,3,4,5];

        $profit = 0;

        foreach ($prices as $today => $todayPrice) {
            // exit when tomorrow doesn't exist
            if(!isset($prices[$today + 1])){
                break;
            }


            if (!isset($buy) && $prices[$today] < $prices[$today + 1]) {
                $buy = $today;
                // when dealing with incremental prices per day
                // we don't want to simply buy tomorrow instead of today
                // we want to buy at the first cheapest and sell at the first highest

                // so when tomorrow is more expensive
                // buy today but run a future check to sell when incrementing ends
                // then make the sale

            }

            if (isset($buy) && $prices[$today + 1] > $prices[$today]) {
                $sell = $today;

                // run a future check until we find the highest sell
                $remainingPrices = array_slice($prices, $today + 1, null, true);
                foreach($remainingPrices as $futureKey => $futurePrice){
                    if($futurePrice > $prices[$today]){
                        $sell = $futureKey;
                        $today = $futureKey;
                    }
                }

            }

            // if we found a buy and sell
            if (isset($buy, $sell)) {
                // if tomorrow doesn't exist sell now
                if(!isset($prices[$today + 1])){
                    $profit += $prices[$sell] - $prices[$buy];
                    $buy = $sell = null;
                    break;
                }

                // if it's better to sell tomorrow
                if ($prices[$today + 1] > $prices[$today]) {
                    continue;
                } else {
                    $profit += $prices[$sell] - $prices[$buy];
                    $buy = $sell = null;
                }
            }
        }

        return $profit;
    }

    /**
     * @param     $prices
     * @param int $today
     * @return bool
     */
    private function shouldBuyToday($prices, int $today): bool
    {
        $shouldBuyToday = false;

        // today is lowest price from all the days
        if($prices[$today] < krsort($prices)){
            return true;
        }

        // check if today is less expensive than every following day
        foreach($prices as $price){

        }
        return $shouldBuyToday;

        return
            // if today is less expensive than tomorrow
            $prices[$today] < $prices[$today + 1];
    }
}
