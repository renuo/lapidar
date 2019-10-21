# Changelog

## 0.3.0

* Buschtelefon remote endpoints are now connected via the local endpoint's outbound port
* `Chain` now queues up unconsolidated (future or invalid) blocks for future use.
* `Runner` now loads main chain into Buschtelefon on start.
* The miner thread now passes on thread execution after mining to make sure
  that the produced block can be digested by the queue (otherwise we may mine blocks twice).
* We can now inquire all remote neighbors manually via `Runner#inquire_all_neighbors`

## 0.2.0

* Better threading
* Blocks now use Unix timestamp
* Blocks with equal hashes are only added to the chain once
* Chains can be persisted and loaded.
* Data can be fed to new blocks.

## 0.1.0

* Initial release
