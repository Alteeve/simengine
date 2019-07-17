@pdu-asset
@sequential
@power-behaviour
Feature: Power Chaining for PDU (with Multiple Children)
    Testing a multi-children power scenarios where one device can power more than one device.
    Powering down a particular asset can cause a chain reaction of power events
    spread over to its children

    Background:
        Given the system model is empty
        And Outlet asset with key "1" is created
        And PDU asset with key "7",  minimum "105" Voltage and "1024" port is created

        And Lamp asset with key "3", minimum "109" Voltage and "120" Wattage is created
        And Lamp asset with key "4", minimum "109" Voltage and "120" Wattage is created
        And Lamp asset with key "5", minimum "109" Voltage and "120" Wattage is created

        # setup power connections
        And asset "1" powers target "7"
        And asset "73" powers target "3"
        And asset "74" powers target "4"
        And asset "75" powers target "5"

        And Engine is up and running

    Scenario Outline: Multiple children power chain

        # == initialize model & engine ==
        # (1)-[powers]->(2)-[powers]->(3, 4, 5)

        Given asset "<asset-key>" is "<asset-ini-state>"

        # create a certain power condition
        When asset "<asset-key>" goes "<asset-new-state>"

        # == check states ==
        Then asset "1" is "<1>"

        # PDU & its outlets
        Then asset "7" is "<7>"
        Then asset "73" is "<73>"
        Then asset "74" is "<74>"
        Then asset "75" is "<75>"

        # everythin powered by the PDU
        Then asset "3" is "<3>"
        Then asset "4" is "<4>"
        Then asset "5" is "<5>"

        Examples: Downstream power-off chaining
            | asset-key | asset-ini-state | asset-new-state | 1       | 7       | 73      | 74      | 75      | 3       | 4       | 5       |
            | 1         | online          | offline         | offline | offline | offline | offline | offline | offline | offline | offline |
            | 7         | online          | offline         | online  | offline | offline | offline | offline | offline | offline | offline |
            | 73        | online          | offline         | online  | online  | offline | online  | online  | offline | online  | online  |
            | 75        | online          | offline         | online  | online  | online  | online  | offline | online  | online  | offline |

        Examples: Downstream power-on chaining
            | asset-key | asset-ini-state | asset-new-state | 1      | 7      | 73     | 74     | 75     | 3      | 4      | 5      |
            | 1         | offline         | online          | online | online | online | online | online | online | online | online |
            | 7         | offline         | online          | online | online | online | online | online | online | online | online |
            | 73        | offline         | online          | online | online | online | online | online | online | online | online |
            | 75        | offline         | online          | online | online | online | online | online | online | online | online |

    @snmp-behaviour
    Scenario Outline: PDU Outlet SNMP control

        # Testing with APC PDU which has:
        # 1 -> for online
        # 2 -> for offline
        When asset "7" oid "1.3.6.1.4.1.318.1.1.12.3.3.1.1.4.<oid-ini-value>" is set to "<oid-ini-value>"
        And asset "7" oid "1.3.6.1.4.1.318.1.1.12.3.3.1.1.4.<oid-new-value>" is set to "<oid-new-value>"

        Then asset "73" is "<73>"
        Then asset "74" is "<74>"

        # everythin powered by the PDU
        Then asset "3" is "<3>"
        Then asset "4" is "<4>"


        Examples: Downstream power-off chaining
            | out-num | oid-ini-value | oid-new-value | 73      | 74     | 3       | 4      |
            | 1       | 1             | 2             | online  | online | online  | online |
            | 3       | 1             | 2             | offline | online | offline | online |

