# AXI-4-Slave-Core
## Design Overview
This project implements a 32-bit AXI4 Slave Core with two independent transaction paths: Read Channel and Write Channel. The design supports handshake-based communication, burst transfers, FIFO buffering, backpressure handling, and outstanding transactions.

## Read Channel

- The read path uses a FIFO to store incoming read requests from the master. Whenever ARVALID is asserted and the FIFO is not full, the slave accepts the transaction and stores all required information such as address, burst type, burst length, transfer size, and transaction ID. During this time, ARREADY remains asserted as long as space is available in the FIFO.

- Stored requests are placed on the slave bus one transaction at a time. Once the slave asserts its ready signal and the current request is accepted through the handshake mechanism, the next stored request is forwarded from the FIFO to the bus. This process continues sequentially for all pending requests.

- The design supports outstanding read transactions because the slave can continue accepting new read requests even if previous read responses have not completed yet. However, responses are returned in-order, meaning each transaction is completed before starting the next one.

- Burst address generation supports FIXED, INCR, and WRAP burst types.

## Write Channel
- The write path contains independent FIFOs for write address and write data channels. The slave accepts write addresses and write data whenever AWVALID or WVALID are asserted and the corresponding FIFOs are not full.

- Write address and write data channels operate independently, allowing address and data transfers to arrive at different times. Address and data information are buffered separately and later synchronized internally before starting the write operation.

- For burst transactions, the design continues transferring all burst data beats related to the current transaction before moving to the next request. Once the entire write burst is completed, the slave generates a response through the B channel.

- Burst address generation supports FIXED, INCR, and WRAP burst types.

## Verification Environment (UVM)

- The AXI4 Slave Core was verified using a UVM-based verification environment.

- The verification environment includes:

- Separate UVM agents for Read and Write transactions
  
- Independent scoreboards for Read and Write channels
  
- Input and output monitor for each agent

- Virtual sequencer for coordinating multiple agents simultaneously

- Functional checking for burst transfers, handshaking, ordering, and channel synchronization

The virtual sequencer is used to control and synchronize both Read and Write sequences together, allowing concurrent transaction generation and more realistic AXI traffic scenarios.

## Features
- 32-bit AXI4 Slave Core
- Independent Read and Write transaction handling
- FIFO-based buffering
- Support for outstanding transactions
- In-order response handling
- FIXED, INCR, and WRAP burst support
- Backpressure handling using VALID/READY protocol
- Independent Write Address and Write Data channels
  
- UVM-based verification environment
- Separate Read and Write agents
- Virtual sequencer support

## References
- AMBA AXI Protocol Specification
- ARM AXI4 Protocol Documentation
