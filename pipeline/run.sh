#!/usr/bin/env bash
# Video -> Gaussian Splat. Run on a Linux box with an NVIDIA GPU (>=12GB recommended),
# CUDA, COLMAP, ffmpeg and nerfstudio installed (see README.md).
# Usage: ./run.sh walkthrough.mp4 [out_dir] [num_frames]
set -euo pipefail

VIDEO="${1:?usage: run.sh video.mp4 [out_dir] [num_frames]}"
OUT="${2:-out}"
FRAMES="${3:-250}"
ITERS="${ITERS:-15000}"          # training iterations
PROCESS_ARGS="${PROCESS_ARGS:-}"  # extra ns-process-data args, e.g. "--no-gpu --sfm-tool colmap"

mkdir -p "$OUT"

# 1. Sample frames + solve camera poses with COLMAP (nerfstudio wraps both).
ns-process-data video \
  --data "$VIDEO" \
  --output-dir "$OUT/data" \
  --num-frames-target "$FRAMES" \
  $PROCESS_ARGS

# 2. Train Gaussian Splats.
ns-train splatfacto \
  --data "$OUT/data" \
  --output-dir "$OUT/train" \
  --max-num-iterations "$ITERS" \
  --viewer.quit-on-train-completion True

# 3. Export a .ply splat from the latest run.
CONFIG="$(ls -t "$OUT"/train/*/splatfacto/*/config.yml | head -1)"
ns-export gaussian-splat --load-config "$CONFIG" --output-dir "$OUT/export"

echo "Done: $OUT/export/splat.ply"
echo "Next: convert/compress for the web, e.g. npx @playcanvas/splat-transform $OUT/export/splat.ply viewer/scene.ply"
