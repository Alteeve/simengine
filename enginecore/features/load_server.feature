@not-ci-friendly
@server-asset
@load-behaviour
@power-behaviour
Feature: Server Load Handling
    Server may handle load differently depending on how many power sources it has;
    Servers with dual psu have 2 power sources meaning load gets re-distributed to the
    alternative power source/parent if one PSU goes offline;

    Background:
        Given the system model is empty
        And Outlet asset with key "1" is created

    @dual-psu-asset
    @server-power-toggle
    Scenario Outline: Toggling server power should affect PSU load
        Given Outlet asset with key "2" is created
        And Server asset with key "7", "2" PSU(s) and "480" Wattage is created

        And asset "1" powers target "71"
        And asset "2" powers target "72"
        And Engine is up and running
        And asset "7" is "<server-ini>"

        When asset "7" goes "<server-new>"

        # check load for assets
        Then asset "1" load is set to "<1>"
        Then asset "2" load is set to "<2>"

        And asset "71" load is set to "<71>"
        And asset "72" load is set to "<72>"

        And asset "7" load is set to "<7>"
        Examples: Toggling server status results in load update
            | server-ini | server-new | 1   | 2   | 71  | 72  | 7   |
            | online     | online     | 2.0 | 2.0 | 2.0 | 2.0 | 4.0 |
            | online     | offline    | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 |
            | offline    | online     | 2.0 | 2.0 | 2.0 | 2.0 | 4.0 |

    @dual-psu-asset
    @server-bmc-asset
    @server-power-toggle
    Scenario Outline: Toggling server bmc power should affect PSU load
        Given Outlet asset with key "2" is created
        And ServerBMC asset with key "7" and "480" Wattage is created

        And asset "1" powers target "71"
        And asset "2" powers target "72"
        And Engine is up and running
        And asset "7" is "<server-ini>"

        When asset "7" goes "<server-new>"

        # check load for assets
        Then asset "1" load is set to "<1>"
        Then asset "2" load is set to "<2>"

        And asset "71" load is set to "<71>"
        And asset "72" load is set to "<72>"

        And asset "7" load is set to "<7>"
        Examples: Toggling server status results in load update
            | server-ini | server-new | 1    | 2    | 71   | 72   | 7   |
            | online     | online     | 2.25 | 2.25 | 2.25 | 2.25 | 4.0 |
            | online     | offline    | 0.25 | 0.25 | 0.25 | 0.25 | 0.0 |
            | offline    | online     | 2.25 | 2.25 | 2.25 | 2.25 | 4.0 |

    @dual-psu-asset
    @server-bmc-asset
    @server-power-toggle
    Scenario Outline: Special Server case with PSU power change and then server state toggling

        Given Outlet asset with key "2" is created
        And ServerBMC asset with key "7" and "480" Wattage is created

        And asset "1" powers target "71"
        And asset "2" powers target "72"
        And Engine is up and running
        And asset "7" is "<server-ini>"

        When asset "<psu-key>" goes "<psu-ini>"
        And asset "7" goes "<server-new>"

        # check load for assets
        Then asset "1" load is set to "<1>"
        And asset "2" load is set to "<2>"

        And asset "71" load is set to "<71>"
        And asset "72" load is set to "<72>"

        And asset "7" load is set to "<7>"
        Examples: Toggling server and psu status results in load update
            | psu-key | psu-ini | server-ini | server-new | 1    | 2    | 71   | 72   | 7   |
            | 71      | offline | online     | offline    | 0.00 | 0.25 | 0.0  | 0.25 | 0.0 |
            | 72      | offline | online     | offline    | 0.25 | 0.00 | 0.25 | 0.0  | 0.0 |



    @dual-psu-asset
    @server-bmc-asset
    @server-power-toggle
    Scenario Outline: Special Server case with server going offline and then PSU power change

        Given Outlet asset with key "2" is created
        And ServerBMC asset with key "7" and "480" Wattage is created

        And asset "1" powers target "71"
        And asset "2" powers target "72"
        And Engine is up and running
        And asset "7" is "<server-ini>"

        When asset "7" goes "<server-new>"
        And asset "<psu-key>" goes "<psu-ini>"
        And asset "<psu-key>" goes "<psu-new>"

        # check load for assets
        Then asset "1" load is set to "<1>"
        And asset "2" load is set to "<2>"

        And asset "71" load is set to "<71>"
        And asset "72" load is set to "<72>"

        And asset "7" load is set to "<7>"
        Examples: Toggling server and psu status results in load update
            | server-ini | server-new | psu-key | psu-ini | psu-new | 1    | 2    | 71   | 72   | 7   |
            | online     | offline    | 71      | offline | online  | 2.25 | 2.25 | 2.25 | 2.25 | 4.0 |
            | online     | offline    | 72      | offline | online  | 2.25 | 2.25 | 2.25 | 2.25 | 4.0 |

    @dual-psu-asset
    Scenario Outline: Dual-PSU load re-destribution
        # initialize model & engine
        # (1)-[powers]->[1801:   server ]
        # (2)-[powers]->[1802     180   ]
        Given Outlet asset with key "2" is created
        And Server asset with key "180", "2" PSU(s) and "480" Wattage is created

        And asset "1" powers target "1801"
        And asset "2" powers target "1802"
        And Engine is up and running

        # Set up initial state
        And asset "<key-1>" is "<1-ini>"
        And asset "<key-2>" is "<2-ini>"

        # Test conditions, when this happens:
        When asset "<key-1>" goes "<1-new>"
        And asset "<key-2>" goes "<2-new>"

        # check load for assets
        Then asset "1" load is set to "<1>"
        Then asset "2" load is set to "<2>"

        And asset "1801" load is set to "<1801>"
        And asset "1802" load is set to "<1802>"

        And asset "180" load is set to "<180>"

        # manipulate 2 input power streams for the server
        # (each powering a PSU)
        Examples: Switching states from online to offline for outlets powering 2 PSUs should affect load
            | key-1 | key-2 | 1-ini  | 2-ini  | 1-new   | 2-new   | 1   | 2   | 1801 | 1802 | 180 |
            | 1     | 2     | online | online | online  | online  | 2.0 | 2.0 | 2.0  | 2.0  | 4.0 |
            | 1     | 2     | online | online | online  | offline | 4.0 | 0.0 | 4.0  | 0.0  | 4.0 |
            | 1     | 2     | online | online | offline | online  | 0.0 | 4.0 | 0.0  | 4.0  | 4.0 |
            | 1     | 2     | online | online | offline | offline | 0.0 | 0.0 | 0.0  | 0.0  | 0.0 |

        Examples: Switching states from online to offline for 2 PSUs should affect load
            | key-1 | key-2 | 1-ini  | 2-ini  | 1-new   | 2-new   | 1   | 2   | 1801 | 1802 | 180 |
            | 1801  | 1802  | online | online | online  | online  | 2.0 | 2.0 | 2.0  | 2.0  | 4.0 |
            | 1801  | 1802  | online | online | online  | offline | 4.0 | 0.0 | 4.0  | 0.0  | 4.0 |
            | 1801  | 1802  | online | online | offline | online  | 0.0 | 4.0 | 0.0  | 4.0  | 4.0 |
            | 1801  | 1802  | online | online | offline | offline | 0.0 | 0.0 | 0.0  | 0.0  | 0.0 |

        Examples: Switching states from offline to online for outlets powering PSUs should affect load
            | key-1 | key-2 | 1-ini   | 2-ini   | 1-new   | 2-new   | 1   | 2   | 1801 | 1802 | 180 |
            | 1     | 2     | offline | offline | online  | online  | 2.0 | 2.0 | 2.0  | 2.0  | 4.0 |
            | 1     | 2     | offline | offline | online  | offline | 4.0 | 0.0 | 4.0  | 0.0  | 4.0 |
            | 1     | 2     | offline | offline | offline | online  | 0.0 | 4.0 | 0.0  | 4.0  | 4.0 |
            | 1     | 2     | offline | offline | offline | offline | 0.0 | 0.0 | 0.0  | 0.0  | 0.0 |



    @dual-psu-asset
    Scenario Outline: Dual-PSU load changes with wallpower voltage
        # initialize model & engine
        # (1)-[powers]->[1801:   server ]
        # (2)-[powers]->[1802     180   ]
        Given Outlet asset with key "2" is created
        And Server asset with key "180", "2" PSU(s) and "480" Wattage is created

        And asset "1" powers target "1801"
        And asset "2" powers target "1802"
        And Engine is up and running

        When wallpower voltage "<ini-volt>" is updated to "<new-volt>"

        # check load for assets
        Then asset "1" load is set to "<1>"
        Then asset "2" load is set to "<2>"

        And asset "1801" load is set to "<1801>"
        And asset "1802" load is set to "<1802>"

        And asset "180" load is set to "<180>"

        Examples: Downstream voltage drop chaining
            | ini-volt | new-volt | 1   | 2   | 1801 | 1802 | 180 |
            | 120      | 0        | 0.0 | 0.0 | 0.0  | 0.0  | 0.0 |
            | 120      | 240      | 1.0 | 1.0 | 1.0  | 1.0  | 2.0 |
            | 120      | 60       | 4.0 | 4.0 | 4.0  | 4.0  | 8.0 |


    @dual-psu-asset
    @server-bmc-asset
    Scenario Outline: Load is distributed with ServerBMC with PSUs drawing power
        Given Outlet asset with key "2" is created
        And Outlet asset with key "22" is created
        # And Server asset with key "9", "2" PSU(s) and "480" Wattage is created

        And ServerBMC asset with key "9" and "480" Wattage is created

        And asset "1" powers target "91"
        And asset "2" powers target "22"
        And asset "22" powers target "92"

        And Engine is up and running
        # Set up initial state
        And asset "<key-1>" is "<1-ini>"
        And asset "<key-2>" is "<2-ini>"

        # Test conditions:
        When asset "<key-1>" goes "<1-new>"
        And asset "<key-2>" goes "<2-new>"

        # check load for assets
        Then asset "1" load is set to "<1>"
        Then asset "2" load is set to "<2>"
        Then asset "22" load is set to "<22>"

        And asset "91" load is set to "<91>"
        And asset "92" load is set to "<92>"

        And asset "9" load is set to "<9>"

        Examples: All Power Sources present
            | key-1 | key-2 | 1-ini  | 2-ini  | 1-new  | 2-new  | 1    | 2    | 22   | 91   | 92   | 9   |
            | 1     | 2     | online | online | online | online | 2.25 | 2.25 | 2.25 | 2.25 | 2.25 | 4.0 |


        Examples: Having both power sources offline should result in zero load
            | key-1 | key-2 | 1-ini  | 2-ini  | 1-new   | 2-new   | 1    | 2    | 22   | 91   | 92   | 9    |
            | 1     | 2     | online | online | offline | offline | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
            | 1     | 22    | online | online | offline | offline | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
            | 91    | 92    | online | online | offline | offline | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |
            | 91    | 92    | online | online | offline | offline | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 | 0.00 |


        # manipulate 2 input power streams for the server
        # (each powering a PSU)
        Examples: Switching states from online to offline for outlets powering 2 PSUs should affect load
            | key-1 | key-2 | 1-ini  | 2-ini  | 1-new   | 2-new   | 1    | 2    | 22   | 91   | 92   | 9   |
            | 1     | 2     | online | online | online  | online  | 2.25 | 2.25 | 2.25 | 2.25 | 2.25 | 4.0 |
            | 1     | 2     | online | online | offline | online  | 0.00 | 4.25 | 4.25 | 0.0  | 4.25 | 4.0 |
            | 1     | 2     | online | online | online  | offline | 4.25 | 0.00 | 0.00 | 4.25 | 0.00 | 4.0 |
            | 1     | 22    | online | online | online  | offline | 4.25 | 0.00 | 0.00 | 4.25 | 0.00 | 4.0 |

        Examples: Switching states from online to offline for PSUs should affect load
            | key-1 | key-2 | 1-ini  | 2-ini  | 1-new   | 2-new   | 1    | 2    | 22   | 91   | 92   | 9   |
            | 91    | 92    | online | online | offline | online  | 0.00 | 4.25 | 4.25 | 0.0  | 4.25 | 4.0 |
            | 91    | 92    | online | online | online  | offline | 4.25 | 0.00 | 0.00 | 4.25 | 0.00 | 4.0 |
            | 91    | 92    | online | online | online  | offline | 4.25 | 0.00 | 0.00 | 4.25 | 0.00 | 4.0 |

        Examples: Switching states from offline to online for outlets powering 2 PSUs should affect load
            | key-1 | key-2 | 1-ini   | 2-ini   | 1-new   | 2-new   | 1    | 2    | 22   | 91   | 92   | 9   |
            | 1     | 2     | offline | offline | online  | online  | 2.25 | 2.25 | 2.25 | 2.25 | 2.25 | 4.0 |
            | 1     | 2     | offline | offline | offline | online  | 0.00 | 4.25 | 4.25 | 0.0  | 4.25 | 4.0 |
            | 1     | 2     | offline | offline | online  | offline | 4.25 | 0.00 | 0.00 | 4.25 | 0.00 | 4.0 |

        Examples: Switching states from offline to online for PSUs should affect load
            | key-1 | key-2 | 1-ini   | 2-ini   | 1-new   | 2-new   | 1    | 2    | 22   | 91   | 92   | 9   |
            | 91    | 92    | offline | offline | online  | online  | 2.25 | 2.25 | 2.25 | 2.25 | 2.25 | 4.0 |
            | 91    | 92    | offline | offline | offline | online  | 0.00 | 4.25 | 4.25 | 0.0  | 4.25 | 4.0 |
            | 91    | 92    | offline | offline | online  | offline | 4.25 | 0.00 | 0.00 | 4.25 | 0.00 | 4.0 |

    Scenario Outline: Single PSU server acts just like a regular asset
        # initialize model & engine
        # (1)-[powers]->[1801:   server 180]
        Given Server asset with key "180", "1" PSU(s) and "120" Wattage is created
        And asset "1" powers target "1801"
        And Engine is up and running
        And asset "<key>" is "<state-ini>"

        When asset "<key>" goes "<state-new>"

        # check load for assets
        Then asset "1" load is set to "<1>"
        And asset "1801" load is set to "<1801>"
        And asset "180" load is set to "<180>"


        Examples: Single-psu server state going offline
            | key  | state-ini | state-new | 1   | 1801 | 180 |
            | 1    | online    | offline   | 0.0 | 0.0  | 0.0 |
            | 1801 | online    | offline   | 0.0 | 0.0  | 0.0 |
            | 180  | online    | offline   | 0.0 | 0.0  | 0.0 |

        Examples: Single-psu server state going online
            | key  | state-ini | state-new | 1   | 1801 | 180 |
            | 1    | online    | online    | 1.0 | 1.0  | 1.0 |
            | 1    | offline   | online    | 1.0 | 1.0  | 1.0 |
            | 1801 | offline   | online    | 1.0 | 1.0  | 1.0 |
            | 180  | offline   | online    | 1.0 | 1.0  | 1.0 |