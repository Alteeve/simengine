"""Access to outlet state"""
from enum import Enum
from enginecore.state.api.snmp_state import ISnmpDeviceStateManager
from enginecore.model.graph_reference import GraphReference

from enginecore.tools.randomizer import Randomizer


@Randomizer.register
class IOutletStateManager(ISnmpDeviceStateManager):
    """Exposes state logic for Outlet asset"""

    class OutletState(Enum):
        """Outlet States (oid) - values match APC PDU MIB spec"""

        switchOn = 1
        switchOff = 2

    def _set_parent_oid_states(self, state):
        """Bulk-set parent oid values to synchronize SNMP OIDs with outlet state

        Args:
            state(OutletState): new parent(s) state
        """
        graph_ref = GraphReference()
        with graph_ref.get_session() as session:
            _, oids = GraphReference.get_parent_keys(session, self.key)

        # Skip if no parent OIDs (wall-powered outlets don't have SNMP)
        if not oids:
            return

        oid_keys = oids.keys()
        parents_new_states = {}
        parent_values = self.get_store().mget(oid_keys)

        for rkey, rvalue in zip(oid_keys, parent_values):
            #  datatype -> {} | {} <- value
            parents_new_states[rkey] = "{}|{}".format(
                rvalue.split(b"|")[0].decode(), oids[rkey][state.name]
            )

        self.get_store().mset(parents_new_states)

    def power_off(self):
        """Power down this outlet and update SNMP OID states

        Returns:
            int: Asset's status after power-off operation
        """
        result = super().power_off()
        # Synchronize SNMP OID states with internal outlet state
        if result == 0:  # Successfully powered off
            self._set_parent_oid_states(self.OutletState.switchOff)
        return result

    def power_up(self):
        """Power up this outlet and update SNMP OID states

        Returns:
            int: Asset's status after power-on operation
        """
        # Set OIDs to switchOn BEFORE power up so _parents_available() check passes
        self._set_parent_oid_states(self.OutletState.switchOn)
        result = super().power_up()
        # If power up failed, revert OIDs back to switchOff
        if result == 0:
            self._set_parent_oid_states(self.OutletState.switchOff)
        return result

    def shut_down(self):
        """Gracefully shut down this outlet and update SNMP OID states

        Returns:
            int: Asset's status after shutdown operation
        """
        result = super().shut_down()
        # Synchronize SNMP OID states with internal outlet state
        if result == 0:  # Successfully shut down
            self._set_parent_oid_states(self.OutletState.switchOff)
        return result
