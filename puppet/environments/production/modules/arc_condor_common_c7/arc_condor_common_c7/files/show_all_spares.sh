#!/bin/bash
for n in `~/scripts/nodes.sh`; do ~/scripts/show_spares.pl -m $n; done

