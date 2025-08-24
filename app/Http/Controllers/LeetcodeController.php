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

    // Example problem handlers
    protected function problem1($prices = [7, 1, 5, 3, 6, 4])
    {
        $profit = 0;

        foreach ($prices as $today => $todayPrice) {
            // if today is cheaper than tomorrow
            if ($prices[$today] < $prices[$today + 1]) {
                $buy = $today;
            } elseif (isset($buy)) {
                $sell = $today;
            }

            // if we found a buy and sell
            if (isset($buy, $sell)) {
                // if it's better to sell tomorrow
                if ($prices[$today + 1] > $prices[$today]) {
                    continue;
                } else {
                    $profit += $prices[$sell] - $prices[$buy];
                }
            }
        }

        return $profit;
    }
}
