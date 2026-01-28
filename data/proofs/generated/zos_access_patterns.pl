% zos_access_patterns.pl - Learned from access logs

:- dynamic zos_path/6.  % path, access_count, avg_time, godel, shard, status

zos_path('/api/shards', 20, 50.00, 298158016697307529, 59, '500:5,200:15').
zos_path('/health', 20, 50.00, 8202097724146948571, 46, '200:20').
zos_path('/api/query', 20, 150.00, 7146428538900620292, 4, '200:20').
zos_path('/api/shards/71', 20, 50.00, 9541700523974611024, 33, '200:20').
zos_path('/metrics', 20, 50.00, 7836743380706295156, 5, '200:20').
