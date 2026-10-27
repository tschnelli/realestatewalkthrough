# splat-poc

Phone walkthrough video -> Gaussian Splat -> shareable browser viewer with measuring.
Aimed at real estate listings.

## 1. Train (Linux + NVIDIA GPU)
Local GTX 1060 6GB is too small/awkward on Windows (CUDA extension builds). Use a rented GPU
(RunPod / Lambda / Colab, 16GB+ VRAM, CUDA 11.8 or 12.x image).

    pip install nerfstudio            # pulls gsplat
    apt install colmap ffmpeg
    ./pipeline/run.sh walkthrough.mp4 out 250

Capture tips: walk slowly, keep the phone level, overlap views, avoid mirrors and moving people,
good even lighting, finish where you started.

## 2. Prepare for web
    npx @playcanvas/splat-transform out/export/splat.ply viewer/scene.ply   # or keep .ply as-is

## 3. View
    cd viewer && npx serve .          # open http://localhost:3000/?src=scene.ply

Deploy `viewer/` to Vercel as a static site; one folder per listing, link as `?src=listing-123.ply`.

## Measuring
Click Measure, pick two points. Scale from video-only capture is arbitrary: measure a known
object (door ~2.03 m), enter its length, Calibrate. Stored per scene in localStorage (PoC only).

## Status
- pipeline/run.sh: written, untested (no Linux GPU run yet)
- viewer/index.html: written, untested against a real splat

## Sample data
- `samples/cabin-walkthrough.mov`: 56 s, 568x320 phone clip of a cabin room. Low resolution
  (a compressed copy), so expect weak results; use a native 1080p/4K capture for real tests.
- Sample splat for the viewer (not committed, 49 MB):
  `curl -L -o viewer/room.splat https://huggingface.co/cakewalk/splat-data/resolve/main/room.splat`
