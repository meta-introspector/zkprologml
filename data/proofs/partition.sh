#!/bin/bash
# Partition graph using METIS along Monster Group shards

echo "Partitioning monster_graph.metis into 71 parts..."

gpmetis -ptype=rb -ufactor=1 monster_graph.metis 71

echo "Partition complete!"
echo "Output: monster_graph.metis.part.71"
