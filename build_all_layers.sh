#!/usr/bin/env bash
# Build and verify all 72 layers

set -e

echo "🔨 Building all 72 layers..."
echo ""

echo "Layer 0..."
nix-build layers/layer_0.nix -o layers/result_0
perf stat -e cycles,instructions,cache-misses ./layers/result_0/bin/layer_0 > layers/layer_0_output.txt 2> layers/layer_0_perf.txt || true
echo ""

echo "Layer 1..."
nix-build layers/layer_1.nix -o layers/result_1
perf stat -e cycles,instructions,cache-misses ./layers/result_1/bin/layer_1 > layers/layer_1_output.txt 2> layers/layer_1_perf.txt || true
echo ""

echo "Layer 2..."
nix-build layers/layer_2.nix -o layers/result_2
perf stat -e cycles,instructions,cache-misses ./layers/result_2/bin/layer_2 > layers/layer_2_output.txt 2> layers/layer_2_perf.txt || true
echo ""

echo "Layer 3..."
nix-build layers/layer_3.nix -o layers/result_3
perf stat -e cycles,instructions,cache-misses ./layers/result_3/bin/layer_3 > layers/layer_3_output.txt 2> layers/layer_3_perf.txt || true
echo ""

echo "Layer 4..."
nix-build layers/layer_4.nix -o layers/result_4
perf stat -e cycles,instructions,cache-misses ./layers/result_4/bin/layer_4 > layers/layer_4_output.txt 2> layers/layer_4_perf.txt || true
echo ""

echo "Layer 5..."
nix-build layers/layer_5.nix -o layers/result_5
perf stat -e cycles,instructions,cache-misses ./layers/result_5/bin/layer_5 > layers/layer_5_output.txt 2> layers/layer_5_perf.txt || true
echo ""

echo "Layer 6..."
nix-build layers/layer_6.nix -o layers/result_6
perf stat -e cycles,instructions,cache-misses ./layers/result_6/bin/layer_6 > layers/layer_6_output.txt 2> layers/layer_6_perf.txt || true
echo ""

echo "Layer 7..."
nix-build layers/layer_7.nix -o layers/result_7
perf stat -e cycles,instructions,cache-misses ./layers/result_7/bin/layer_7 > layers/layer_7_output.txt 2> layers/layer_7_perf.txt || true
echo ""

echo "Layer 8..."
nix-build layers/layer_8.nix -o layers/result_8
perf stat -e cycles,instructions,cache-misses ./layers/result_8/bin/layer_8 > layers/layer_8_output.txt 2> layers/layer_8_perf.txt || true
echo ""

echo "Layer 9..."
nix-build layers/layer_9.nix -o layers/result_9
perf stat -e cycles,instructions,cache-misses ./layers/result_9/bin/layer_9 > layers/layer_9_output.txt 2> layers/layer_9_perf.txt || true
echo ""

echo "Layer 10..."
nix-build layers/layer_10.nix -o layers/result_10
perf stat -e cycles,instructions,cache-misses ./layers/result_10/bin/layer_10 > layers/layer_10_output.txt 2> layers/layer_10_perf.txt || true
echo ""

echo "Layer 11..."
nix-build layers/layer_11.nix -o layers/result_11
perf stat -e cycles,instructions,cache-misses ./layers/result_11/bin/layer_11 > layers/layer_11_output.txt 2> layers/layer_11_perf.txt || true
echo ""

echo "Layer 12..."
nix-build layers/layer_12.nix -o layers/result_12
perf stat -e cycles,instructions,cache-misses ./layers/result_12/bin/layer_12 > layers/layer_12_output.txt 2> layers/layer_12_perf.txt || true
echo ""

echo "Layer 13..."
nix-build layers/layer_13.nix -o layers/result_13
perf stat -e cycles,instructions,cache-misses ./layers/result_13/bin/layer_13 > layers/layer_13_output.txt 2> layers/layer_13_perf.txt || true
echo ""

echo "Layer 14..."
nix-build layers/layer_14.nix -o layers/result_14
perf stat -e cycles,instructions,cache-misses ./layers/result_14/bin/layer_14 > layers/layer_14_output.txt 2> layers/layer_14_perf.txt || true
echo ""

echo "Layer 15..."
nix-build layers/layer_15.nix -o layers/result_15
perf stat -e cycles,instructions,cache-misses ./layers/result_15/bin/layer_15 > layers/layer_15_output.txt 2> layers/layer_15_perf.txt || true
echo ""

echo "Layer 16..."
nix-build layers/layer_16.nix -o layers/result_16
perf stat -e cycles,instructions,cache-misses ./layers/result_16/bin/layer_16 > layers/layer_16_output.txt 2> layers/layer_16_perf.txt || true
echo ""

echo "Layer 17..."
nix-build layers/layer_17.nix -o layers/result_17
perf stat -e cycles,instructions,cache-misses ./layers/result_17/bin/layer_17 > layers/layer_17_output.txt 2> layers/layer_17_perf.txt || true
echo ""

echo "Layer 18..."
nix-build layers/layer_18.nix -o layers/result_18
perf stat -e cycles,instructions,cache-misses ./layers/result_18/bin/layer_18 > layers/layer_18_output.txt 2> layers/layer_18_perf.txt || true
echo ""

echo "Layer 19..."
nix-build layers/layer_19.nix -o layers/result_19
perf stat -e cycles,instructions,cache-misses ./layers/result_19/bin/layer_19 > layers/layer_19_output.txt 2> layers/layer_19_perf.txt || true
echo ""

echo "Layer 20..."
nix-build layers/layer_20.nix -o layers/result_20
perf stat -e cycles,instructions,cache-misses ./layers/result_20/bin/layer_20 > layers/layer_20_output.txt 2> layers/layer_20_perf.txt || true
echo ""

echo "Layer 21..."
nix-build layers/layer_21.nix -o layers/result_21
perf stat -e cycles,instructions,cache-misses ./layers/result_21/bin/layer_21 > layers/layer_21_output.txt 2> layers/layer_21_perf.txt || true
echo ""

echo "Layer 22..."
nix-build layers/layer_22.nix -o layers/result_22
perf stat -e cycles,instructions,cache-misses ./layers/result_22/bin/layer_22 > layers/layer_22_output.txt 2> layers/layer_22_perf.txt || true
echo ""

echo "Layer 23..."
nix-build layers/layer_23.nix -o layers/result_23
perf stat -e cycles,instructions,cache-misses ./layers/result_23/bin/layer_23 > layers/layer_23_output.txt 2> layers/layer_23_perf.txt || true
echo ""

echo "Layer 24..."
nix-build layers/layer_24.nix -o layers/result_24
perf stat -e cycles,instructions,cache-misses ./layers/result_24/bin/layer_24 > layers/layer_24_output.txt 2> layers/layer_24_perf.txt || true
echo ""

echo "Layer 25..."
nix-build layers/layer_25.nix -o layers/result_25
perf stat -e cycles,instructions,cache-misses ./layers/result_25/bin/layer_25 > layers/layer_25_output.txt 2> layers/layer_25_perf.txt || true
echo ""

echo "Layer 26..."
nix-build layers/layer_26.nix -o layers/result_26
perf stat -e cycles,instructions,cache-misses ./layers/result_26/bin/layer_26 > layers/layer_26_output.txt 2> layers/layer_26_perf.txt || true
echo ""

echo "Layer 27..."
nix-build layers/layer_27.nix -o layers/result_27
perf stat -e cycles,instructions,cache-misses ./layers/result_27/bin/layer_27 > layers/layer_27_output.txt 2> layers/layer_27_perf.txt || true
echo ""

echo "Layer 28..."
nix-build layers/layer_28.nix -o layers/result_28
perf stat -e cycles,instructions,cache-misses ./layers/result_28/bin/layer_28 > layers/layer_28_output.txt 2> layers/layer_28_perf.txt || true
echo ""

echo "Layer 29..."
nix-build layers/layer_29.nix -o layers/result_29
perf stat -e cycles,instructions,cache-misses ./layers/result_29/bin/layer_29 > layers/layer_29_output.txt 2> layers/layer_29_perf.txt || true
echo ""

echo "Layer 30..."
nix-build layers/layer_30.nix -o layers/result_30
perf stat -e cycles,instructions,cache-misses ./layers/result_30/bin/layer_30 > layers/layer_30_output.txt 2> layers/layer_30_perf.txt || true
echo ""

echo "Layer 31..."
nix-build layers/layer_31.nix -o layers/result_31
perf stat -e cycles,instructions,cache-misses ./layers/result_31/bin/layer_31 > layers/layer_31_output.txt 2> layers/layer_31_perf.txt || true
echo ""

echo "Layer 32..."
nix-build layers/layer_32.nix -o layers/result_32
perf stat -e cycles,instructions,cache-misses ./layers/result_32/bin/layer_32 > layers/layer_32_output.txt 2> layers/layer_32_perf.txt || true
echo ""

echo "Layer 33..."
nix-build layers/layer_33.nix -o layers/result_33
perf stat -e cycles,instructions,cache-misses ./layers/result_33/bin/layer_33 > layers/layer_33_output.txt 2> layers/layer_33_perf.txt || true
echo ""

echo "Layer 34..."
nix-build layers/layer_34.nix -o layers/result_34
perf stat -e cycles,instructions,cache-misses ./layers/result_34/bin/layer_34 > layers/layer_34_output.txt 2> layers/layer_34_perf.txt || true
echo ""

echo "Layer 35..."
nix-build layers/layer_35.nix -o layers/result_35
perf stat -e cycles,instructions,cache-misses ./layers/result_35/bin/layer_35 > layers/layer_35_output.txt 2> layers/layer_35_perf.txt || true
echo ""

echo "Layer 36..."
nix-build layers/layer_36.nix -o layers/result_36
perf stat -e cycles,instructions,cache-misses ./layers/result_36/bin/layer_36 > layers/layer_36_output.txt 2> layers/layer_36_perf.txt || true
echo ""

echo "Layer 37..."
nix-build layers/layer_37.nix -o layers/result_37
perf stat -e cycles,instructions,cache-misses ./layers/result_37/bin/layer_37 > layers/layer_37_output.txt 2> layers/layer_37_perf.txt || true
echo ""

echo "Layer 38..."
nix-build layers/layer_38.nix -o layers/result_38
perf stat -e cycles,instructions,cache-misses ./layers/result_38/bin/layer_38 > layers/layer_38_output.txt 2> layers/layer_38_perf.txt || true
echo ""

echo "Layer 39..."
nix-build layers/layer_39.nix -o layers/result_39
perf stat -e cycles,instructions,cache-misses ./layers/result_39/bin/layer_39 > layers/layer_39_output.txt 2> layers/layer_39_perf.txt || true
echo ""

echo "Layer 40..."
nix-build layers/layer_40.nix -o layers/result_40
perf stat -e cycles,instructions,cache-misses ./layers/result_40/bin/layer_40 > layers/layer_40_output.txt 2> layers/layer_40_perf.txt || true
echo ""

echo "Layer 41..."
nix-build layers/layer_41.nix -o layers/result_41
perf stat -e cycles,instructions,cache-misses ./layers/result_41/bin/layer_41 > layers/layer_41_output.txt 2> layers/layer_41_perf.txt || true
echo ""

echo "Layer 42..."
nix-build layers/layer_42.nix -o layers/result_42
perf stat -e cycles,instructions,cache-misses ./layers/result_42/bin/layer_42 > layers/layer_42_output.txt 2> layers/layer_42_perf.txt || true
echo ""

echo "Layer 43..."
nix-build layers/layer_43.nix -o layers/result_43
perf stat -e cycles,instructions,cache-misses ./layers/result_43/bin/layer_43 > layers/layer_43_output.txt 2> layers/layer_43_perf.txt || true
echo ""

echo "Layer 44..."
nix-build layers/layer_44.nix -o layers/result_44
perf stat -e cycles,instructions,cache-misses ./layers/result_44/bin/layer_44 > layers/layer_44_output.txt 2> layers/layer_44_perf.txt || true
echo ""

echo "Layer 45..."
nix-build layers/layer_45.nix -o layers/result_45
perf stat -e cycles,instructions,cache-misses ./layers/result_45/bin/layer_45 > layers/layer_45_output.txt 2> layers/layer_45_perf.txt || true
echo ""

echo "Layer 46..."
nix-build layers/layer_46.nix -o layers/result_46
perf stat -e cycles,instructions,cache-misses ./layers/result_46/bin/layer_46 > layers/layer_46_output.txt 2> layers/layer_46_perf.txt || true
echo ""

echo "Layer 47..."
nix-build layers/layer_47.nix -o layers/result_47
perf stat -e cycles,instructions,cache-misses ./layers/result_47/bin/layer_47 > layers/layer_47_output.txt 2> layers/layer_47_perf.txt || true
echo ""

echo "Layer 48..."
nix-build layers/layer_48.nix -o layers/result_48
perf stat -e cycles,instructions,cache-misses ./layers/result_48/bin/layer_48 > layers/layer_48_output.txt 2> layers/layer_48_perf.txt || true
echo ""

echo "Layer 49..."
nix-build layers/layer_49.nix -o layers/result_49
perf stat -e cycles,instructions,cache-misses ./layers/result_49/bin/layer_49 > layers/layer_49_output.txt 2> layers/layer_49_perf.txt || true
echo ""

echo "Layer 50..."
nix-build layers/layer_50.nix -o layers/result_50
perf stat -e cycles,instructions,cache-misses ./layers/result_50/bin/layer_50 > layers/layer_50_output.txt 2> layers/layer_50_perf.txt || true
echo ""

echo "Layer 51..."
nix-build layers/layer_51.nix -o layers/result_51
perf stat -e cycles,instructions,cache-misses ./layers/result_51/bin/layer_51 > layers/layer_51_output.txt 2> layers/layer_51_perf.txt || true
echo ""

echo "Layer 52..."
nix-build layers/layer_52.nix -o layers/result_52
perf stat -e cycles,instructions,cache-misses ./layers/result_52/bin/layer_52 > layers/layer_52_output.txt 2> layers/layer_52_perf.txt || true
echo ""

echo "Layer 53..."
nix-build layers/layer_53.nix -o layers/result_53
perf stat -e cycles,instructions,cache-misses ./layers/result_53/bin/layer_53 > layers/layer_53_output.txt 2> layers/layer_53_perf.txt || true
echo ""

echo "Layer 54..."
nix-build layers/layer_54.nix -o layers/result_54
perf stat -e cycles,instructions,cache-misses ./layers/result_54/bin/layer_54 > layers/layer_54_output.txt 2> layers/layer_54_perf.txt || true
echo ""

echo "Layer 55..."
nix-build layers/layer_55.nix -o layers/result_55
perf stat -e cycles,instructions,cache-misses ./layers/result_55/bin/layer_55 > layers/layer_55_output.txt 2> layers/layer_55_perf.txt || true
echo ""

echo "Layer 56..."
nix-build layers/layer_56.nix -o layers/result_56
perf stat -e cycles,instructions,cache-misses ./layers/result_56/bin/layer_56 > layers/layer_56_output.txt 2> layers/layer_56_perf.txt || true
echo ""

echo "Layer 57..."
nix-build layers/layer_57.nix -o layers/result_57
perf stat -e cycles,instructions,cache-misses ./layers/result_57/bin/layer_57 > layers/layer_57_output.txt 2> layers/layer_57_perf.txt || true
echo ""

echo "Layer 58..."
nix-build layers/layer_58.nix -o layers/result_58
perf stat -e cycles,instructions,cache-misses ./layers/result_58/bin/layer_58 > layers/layer_58_output.txt 2> layers/layer_58_perf.txt || true
echo ""

echo "Layer 59..."
nix-build layers/layer_59.nix -o layers/result_59
perf stat -e cycles,instructions,cache-misses ./layers/result_59/bin/layer_59 > layers/layer_59_output.txt 2> layers/layer_59_perf.txt || true
echo ""

echo "Layer 60..."
nix-build layers/layer_60.nix -o layers/result_60
perf stat -e cycles,instructions,cache-misses ./layers/result_60/bin/layer_60 > layers/layer_60_output.txt 2> layers/layer_60_perf.txt || true
echo ""

echo "Layer 61..."
nix-build layers/layer_61.nix -o layers/result_61
perf stat -e cycles,instructions,cache-misses ./layers/result_61/bin/layer_61 > layers/layer_61_output.txt 2> layers/layer_61_perf.txt || true
echo ""

echo "Layer 62..."
nix-build layers/layer_62.nix -o layers/result_62
perf stat -e cycles,instructions,cache-misses ./layers/result_62/bin/layer_62 > layers/layer_62_output.txt 2> layers/layer_62_perf.txt || true
echo ""

echo "Layer 63..."
nix-build layers/layer_63.nix -o layers/result_63
perf stat -e cycles,instructions,cache-misses ./layers/result_63/bin/layer_63 > layers/layer_63_output.txt 2> layers/layer_63_perf.txt || true
echo ""

echo "Layer 64..."
nix-build layers/layer_64.nix -o layers/result_64
perf stat -e cycles,instructions,cache-misses ./layers/result_64/bin/layer_64 > layers/layer_64_output.txt 2> layers/layer_64_perf.txt || true
echo ""

echo "Layer 65..."
nix-build layers/layer_65.nix -o layers/result_65
perf stat -e cycles,instructions,cache-misses ./layers/result_65/bin/layer_65 > layers/layer_65_output.txt 2> layers/layer_65_perf.txt || true
echo ""

echo "Layer 66..."
nix-build layers/layer_66.nix -o layers/result_66
perf stat -e cycles,instructions,cache-misses ./layers/result_66/bin/layer_66 > layers/layer_66_output.txt 2> layers/layer_66_perf.txt || true
echo ""

echo "Layer 67..."
nix-build layers/layer_67.nix -o layers/result_67
perf stat -e cycles,instructions,cache-misses ./layers/result_67/bin/layer_67 > layers/layer_67_output.txt 2> layers/layer_67_perf.txt || true
echo ""

echo "Layer 68..."
nix-build layers/layer_68.nix -o layers/result_68
perf stat -e cycles,instructions,cache-misses ./layers/result_68/bin/layer_68 > layers/layer_68_output.txt 2> layers/layer_68_perf.txt || true
echo ""

echo "Layer 69..."
nix-build layers/layer_69.nix -o layers/result_69
perf stat -e cycles,instructions,cache-misses ./layers/result_69/bin/layer_69 > layers/layer_69_output.txt 2> layers/layer_69_perf.txt || true
echo ""

echo "Layer 70..."
nix-build layers/layer_70.nix -o layers/result_70
perf stat -e cycles,instructions,cache-misses ./layers/result_70/bin/layer_70 > layers/layer_70_output.txt 2> layers/layer_70_perf.txt || true
echo ""

echo "Layer 71..."
nix-build layers/layer_71.nix -o layers/result_71
perf stat -e cycles,instructions,cache-misses ./layers/result_71/bin/layer_71 > layers/layer_71_output.txt 2> layers/layer_71_perf.txt || true
echo ""

echo "✅ All layers built!"
echo ""
echo "Verify with: lean4 layers/layer_*_proof.lean"
