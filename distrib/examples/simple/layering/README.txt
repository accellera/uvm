This directory contains two layering examples of two upper-layer
protocols (upperA and upperB) concurrently layered on top of a single
lower-layer protocol (lower).

The example in 'sequencers' shows how to layer sequencers using
layering sequences. It is the techique that should be used for
protocols with static and well-defined layering topology, such as USB
or PCIe.

The example in 'agents' shows how to layer agents using layering
drivers.  It is the technique that should be used for layering
independently-written agents and for independent protocols that can be
arbitrarily layered, such as IP and Ethernet.

